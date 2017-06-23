function [offsets, refImgs, doPar] = calculate_offset(chSeq, ...
    refImg, maxShift, frameRate, varargin)
%calculate_offset - Calculate line-by-line offsets
%
%   [offsets, refImgs] = calculate_offset(CHSEQ, REFIMG, MAXSHIFT, FRAMERATE)
%   calculates the offsets for each line in an image stack based on the
%   maximum shifts and the frame rate provided and returns the reference
%   images created.
%
%   [offsets, refImgs] = calculate_offset(..., 'attribute', value)
%   specifies one or more attribute/value pairs.  Valid attributes (case
%   insensitive) are:
%
%       doPlot ->   Whether to display plots for debugging purposes. The
%                   doPlot must be a scalar value that can be converted to
%                   a logical. [default = false]
%
%       verbose ->  Whether to display status bars and more elaborate plots 
%                   for debugging purposes. The verbose must be a scalar  
%                   value that can be converted to a logical. 
%                   [default = false]
%
%   See also utils.motion_correct
%% Assign parameters and variables

% Image dimensions
[nFrames, nLines, nPxlPerLine] = size(chSeq);

% % Parse optional arguments
[verbose] = utils.parse_opt_args({true}, varargin);

% Work out if we're using the parallel features
[isParallel, nWorkers] = utils.is_parallel();
doPar = isParallel && (nFrames > 2*nWorkers);
isWorker = utils.is_on_worker();
verbose = verbose && ~isWorker;

% Extract individual shifts
maxDx = maxShift(1);
maxDy = maxShift(2);

%% Calculate gain of imaging system
streak = max(int8(floor(nFrames / 3))); % Chen (2011), p3
gain = utils.hmm.find_gain(chSeq, streak, verbose);

%% Create reference images

% Avoid zeros because of ln-function later
chSeq = chSeq + 1;

% How many frames per 30 seconds imaging.  Here we manually decide that
% 30*frame rate is good spacing for taking reference images. Although
% supported by the paper, we should test it out first.
framesPer30sec = floor(30*frameRate);

% One reference image per 30 seconds, plus one for the remaining frames at
% the end
numStills = ceil(nFrames/framesPer30sec);

% Check the reference images
if isempty(refImg)
    
    % Create reference images from stack
    refImgs = zeros(numStills, nLines, nPxlPerLine);
    for iStill=1:numStills
        idxFrames = 1+(iStill-1)*framesPer30sec : ...
            min(iStill*framesPer30sec,nFrames);
        stillSeq = chSeq(idxFrames,:,:);
        refImgs(iStill,:,:) = mean(stillSeq, 1); 
    end

else
    
    % Avoid zeros because of exp and log later
    refImg = refImg +1;
    
    % Check the size of the reference image
    isOkSize = size(refImg, 1) == nLines && ...
        size(refImg, 2) == nPxlPerLine;
    if ~isOkSize
        refImg = utils.resize_img(refImg, [nLines, nPxlPerLine]);
    end
    
    % For simplicity, replicate the reference image for every 30 second
    % epoch
    refImgs = repmat(refImg, 1, 1, numStills);
    refImgs = permute(refImgs, [3, 1, 2]);
    
end

% Align reference images to each other. Take minimum of provided lineShifts
% and use it as maxOffset for frame alignement
maxOffset = min(maxShift);
refOffsets = utils.hmm.refs_align(refImgs, maxOffset);

%% Estimate Preliminary Offsets and Probabilities

[minShifts, probMat] = utils.hmm.estimate_offset(chSeq, refImgs, ...
    framesPer30sec, maxShift, doPar, verbose);

%% Estimate Preliminary Offsets and Probabilities

% Show status bar, if needed
if verbose 
    strMsg = 'Expectation Maximization';
    if doPar
        fnPB = utils.progbarpar('msg', strMsg);
    else
        fnPB = '';
        utils.progbar(0, 'msg', strMsg);
    end
else
    % This is needed for parallel processing, even if it's unused
    fnPB = '';
    strMsg = '';
end

% Values of lambda to sample
nn = -3:.1:.5;
lambdas = 10.^nn;

% Preallocate probability vector
nLambdas = numel(lambdas);
pLambda = zeros(1, nLambdas);

% Run short HMM for different lambdas
doFull = false;
parfor iLambda = 1:nLambdas

    % Run an abbreviated version of the HMM and store overall probability
    % for each run. Plot predicted offsets, if needed
    [~, pLambda(iLambda)] = utils.hmm.markov(probMat, minShifts, ...
        lambdas(iLambda), refOffsets, gain, nLines, nFrames, frameRate, ...
        [maxDx, maxDy], doFull, verbose);

    % Update status bar, if needed
    if verbose
        if doPar
            utils.progbarpar(fnPB, nLambdas, 'msg', strMsg);
        else
            utils.progbar(1 - (iLambda-1)/nLambdas, 'msg', strMsg, ...
                'doBackspace', 1);
        end
    end
    
end

% Close the progress bar
if doPar
    utils.progbarpar(fnPB, 0, 'msg', strMsg);
end

% Pick out the lambda with highest probability
[valMax, idxMax] = max(pLambda); %#ok<ASGLU>
maxLambda = lambdas(idxMax);

% % Figure for debugging only
% figure();
% plot(lambdas, pLambda);
% hold on;
% plot(maxLambda,valMax,'rx');
% xlabel('\lambda');
% ylabel('total probability');

%% Final calculation

% Run the HMM algorithm, now that lambda is set to its most probable value,
% over all frames of the movie
doFull = true;
[offsets, ~] = utils.hmm.markov(probMat, minShifts, maxLambda, ...
    refOffsets, gain, nLines, nFrames, frameRate, [maxDx, maxDy], ...
    doFull, verbose);

end
