function [minShifts, probMat] = estimate_offset(chSeq, refImgs, ...
    framesPer30sec, maxShift, doPar, varargin)
%% Preallocate offsets
% need inputSequence, maxDx, maxDy, frameRate, doPar, doPlot, verbose

%% Get supplied info
% Image dimensions
[nFrames, nLines, ~] = size(chSeq);
% Parse optional arguments
[verbose] = utils.parse_opt_args({true}, varargin);

% Extract individual shifts
maxDx = maxShift(1);
maxDy = maxShift(2);

% Consider the shift in both directions (e.g. left/right)
Nx = 2*maxDx+1;
Ny = 2*maxDy+1;

%% Compute preliminary offsets

% Initialize status bar
if verbose
    strMsg = 'Estimating Probabilities';
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
    
% Number of lines per each frame
numLinesCrop = (nLines - 2*maxDy);

% Total number of lines to consider
totLines =  numLinesCrop * nFrames;

% Preallocate the error matrix for all lines and possible offsets
errMat = zeros(numLinesCrop, nFrames, Ny, Nx);
probMat = errMat;
parfor iFrame = 1:nFrames

    % Which reference frame are we aligning to
    idxRef = ceil(iFrame/framesPer30sec);

    % Pull out that reference frame
    refImg = squeeze(refImgs(idxRef, :, :)); %#ok<PFBNS>

    % Fill errMat for one frame, line by line for all x-shifts
    % packing this as function is required by parfor
    errMat(:,iFrame,:,:) = utils.hmm.fillErrMat(iFrame, chSeq, ...
        refImg, maxDy, maxDx, Ny, Nx, nLines);
    
    % Fill probMat for one frame, line by line for all x-shifts
    % packing this as function is required by parfor
    probMat(:,iFrame,:,:) = utils.hmm.fillProbMat(iFrame, chSeq, ...
        refImg, maxDy, maxDx, Ny, Nx, nLines);

    %Update status bar, if needed
    if verbose
        if doPar
            utils.progbarpar(fnPB, nFrames, 'msg', strMsg);
        else
            utils.progbar(1 - (iFrame-1)/nFrames, 'msg', strMsg, ...
                'doBackspace', 1);
        end
    end
    
end

% Reshape the probability matrix
probMat = reshape(probMat, totLines, Ny, Nx);

% Close the progress bar
if doPar
    utils.progbarpar(fnPB, 0, 'msg', strMsg);
end

%% Search for minimal offsets

% Reshape error matrix for convenience
errMat2 = reshape(errMat, totLines, []);

% Find the x and y shifts that correspond to the minimum error
xs = -maxDx:maxDx;
ys = -maxDy:maxDy;
[~, idxMin] = min(errMat2, [], 2);
[idxY, idxX] = ind2sub([Ny, Nx], idxMin);
minShifts = [ys(idxY); xs(idxX)]';

end