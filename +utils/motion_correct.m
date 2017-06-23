function varargout = motion_correct(imgSeq, varargin)
%motion_correct - Motion correct an image sequence
%
%   CORRSEQ = motion_correct(IMGSEQ) motion corrects imgSeq
%   using the default parameters. IMGSEQ must be a numeric array with at
%   least 3 dimensions.  If IMGSEQ is an integer data type, it will be
%   converted into a single precision floating point array so that out of
%   range pixels can be represented as NaN.
% 
%   CORRSEQ = motion_correct(..., 'attribute', value) specifies one or more
%   attribute/value pairs.  Valid attributes (case insensitive) are:
%
%       ch ->       The channel used for the motion correction. (The
%                   transformation will be applied to all other image
%                   channels.) The channel must be a scalar integer.
%                   [default = 1]
%
%       constantShift -> Whether to calculate a single shift for the whole
%                   image sequence, or calculate individual shifts for each
%                   frame in the sequence. The constantShift must be a
%                   scalar value that can be converted to a logical, and is
%                   only relevant for the convfft method. [default = false]
%
%       doPlot ->   Whether to display a plot for debugging purposes. The
%                   doPlot must be a scalar value that can be converted to
%                   a logical. [default = false]
%
%       inpaintIters -> An iterative method is used when inpainting
%                   (filling in) NaN and Inf values. The parameter
%                   inpaintIters is a positive scalar integer specifying
%                   the number of iterations to perform. It is only used
%                   when fillBadData = 'inpaint'. [default = 5]
%
%       fillBadData -> Which method to use for filling bad frames or
%                   estimating missing data. The method must be a single
%                   row character array and correspond to a valid method
%                   ('nan', 'zero', 'median', 'inpaint'). 'median' is
%                   only possible for the convfft method [default = 'nan']
%
%       maxShift -> The maximum number of pixels to consider when searching
%                   for the optimal x and y shift.  The parameter maxShift
%                   must be either a scalar integer (in which case the
%                   maxShift will be the same in both directions) or a
%                   length two array [maxShiftX, maxShiftY] where the 
%                   elements correspond to the maxShift in each direction
%
%       method ->   The motion correction algorithm to use. The method must
%                   be a single row character array and correspond to a
%                   valid method. The available methods are 'convfft' and
%                   'hmm'. [default = 'convfft']
%
%       minCorr ->  The minimal correlation required for motion correction.
%                   The minCorr must be a positive real finite scalar less
%                   than 1, , and is only relevant for the convfft method.
%                   [default = 0.6]
%
%       refImg ->   A reference image to motion correct to. If empty, the
%                   first frame from IMGSEQ will be used. [default = []]
%
%       skipChs ->  Image channel(s) that the motion correction is not
%                   applied to. [default = []]
%
%       verbose ->  Whether to display progbars. [default = true] 
%
%
%   [CORRSEQ, REFIMG, SX, SY, METHOD] = motion_correct(...) returns the
%   reference image used for motion correction, the resulting x and y
%   shifts, and the method.
%
%   Note: the method 'convfft' uses code originally developed by Bruno
%   Luong (see the file ACKNOWLEDGEMENTS.txt for more information).  The
%   method 'hmm' is based on a Hidden Markov Model approach.  For further
%   information on this algorithm, please refer to <a href="matlab:web('http://dx.doi.org/10.1016/j.neuron.2007.08.003', '-browser')">Dombeck et al. (2007)</a>, 
%   Neuron 56(1):43–57.
%
%   See also utils.convnfft, utils.hmm

%   Copyright (C) 2017  Matthew J.P. Barrett, Kim David Ferrari et al.
%
%   This program is free software: you can redistribute it and/or modify
%   it under the terms of the GNU General Public License as published by
%   the Free Software Foundation, either version 3 of the License, or
%   (at your option) any later version.
% 
%   This program is distributed in the hope that it will be useful,
%   but WITHOUT ANY WARRANTY; without even the implied warranty of
%   MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
%   GNU General Public License for more details.
%   
%   You should have received a copy of the GNU General Public License 
%   along with this program.  If not, see <http://www.gnu.org/licenses/>.

% Check the number of input arguments
narginchk(1, inf)

% Check the format of the image sequence
utils.checks.object_class(imgSeq, 'numeric', 'image sequence');
if ismatrix(imgSeq)
    error('Utils:MotionCorrect:NotEnoughDims', ['The image sequence ' ...
        'must have at least 3 dimensions to perform motion correction'])
end
is3D = ndims(imgSeq) == 3;
if is3D
    imgSeq = permute(imgSeq, [1, 2, 4, 3]);
end

% Define the allowed optional arguments and default values, and create a
% default parameters structure
pnames = {'ch', 'constantShift', 'method', 'refImg', 'maxShift', ...
    'minCorr', 'skipChs', 'doPlot', 'fillBadData', 'inpaintIters', ...
    'frameRate', 'verbose', 'useParallel'};
dflts  = {1, false, 'convfft', [], [], 0.6, [], false, 'nan', 5, [], ...
    true, true};
params = cell2struct(dflts, pnames, 2);

% Parse function input arguments
params = utils.parsepropval(params, varargin{:});

% Check the channel
utils.checks.scalar(params.ch, 'channel');
utils.checks.integer(params.ch, 'channel');
utils.checks.less_than(params.ch, size(imgSeq, 3), true, 'channel');

% Check the constantShift
utils.checks.scalar_logical_able(params.constantShift, 'constantShift');

% Check the method
utils.checks.single_row_char(params.method, 'method');

% Check the refImg
if ~isempty(params.refImg)
    utils.checks.object_class(params.refImg, 'numeric', 'refImg');
    utils.checks.greater_than(params.refImg, 0, true, 'refImg');
    
    if ~ismatrix(params.refImg)
        error('motion_correct:WrongRefImgFormat', ['The reference image', ...
            ' must have exactly 2 dimensions. You provided an image with', ...
            sprintf(' %1d dimensions', ndims(params.refImg))]);
    end
end

% Check the corr
utils.checks.prfs(params.minCorr, 'minCorr');
utils.checks.less_than(params.minCorr, 1, [], 'minCorr');

% Check the skipChannels
if ~isempty(params.skipChs)
    utils.checks.integer(params.skipChs, 'channel');
    utils.checks.less_than(params.skipChs, size(imgSeq, 3), ...
        true, 'channel');
end

% Check the doPlot
utils.checks.scalar_logical_able(params.doPlot, 'doPlot');

% Convert image sequence to single precision.
if isinteger(imgSeq)
    imgSeq = single(imgSeq);
end

% ---------------------------------------------------------------------- %

switch lower(params.method)
    case 'convfft'
        
        [imgSeq, refImg, sx, sy] = mc_convfft(imgSeq, params);
        
    case 'hmm'
        
        [imgSeq, refImg, sx, sy] = mc_hmm(imgSeq, params);
                
    otherwise
        
        error('Utils:MotionCorrect:UnknownMethod', ...
            'The method "%s" is unknown', params.method);
        
end

% ---------------------------------------------------------------------- %

% Make a plot, if desired
if params.doPlot
    dims = size(squeeze(imgSeq(:,:,params.ch,:)));
    figure, utils.motion_correct_plot(sx, sy, dims, refImg);
end

% Restore the image sequence to 3d, if necessary
if is3D
    imgSeq = squeeze(imgSeq);
end

% Assign output arguments
varargout{1} = imgSeq;
varargout{2} = refImg;
varargout{3} = sx;
varargout{4} = sy;
varargout{5} = params.method;

end

% ====================================================================== %

function [imgSeq, refImg, sx, sy] = mc_convfft(imgSeq, params)

% Only use specified channel
if ndims(imgSeq) == 4

    chSeq = squeeze(imgSeq(:, :, params.ch, :));
    tempExtraCh = 1:size(imgSeq, 3);
    applyExtraChannels = tempExtraCh(tempExtraCh ~= params.ch);

elseif ndims(imgSeq) == 3

    chSeq = imgSeq;
    applyExtraChannels = [];

end

% If we're only doing a constant shift, use the mean of the image
% sequence to ensure more accurate results, but store a temporary
% copy of the original sequence for use later
if params.constantShift
    nFrames = size(chSeq, 3);
    chSeqOrig = chSeq;
    chSeq = utils.nansuite.nanmean(chSeq, 3);
end

% Run 2D convolution
[sy, sx, refImg] = utils.convnfft.calcShifts(chSeq, params.refImg, ...
    params.minCorr, params.maxShift);

% If we're only doing a constant shift, restore the original chSeq,
% but repeat the same constant shift for all frames
if params.constantShift
    chSeq = chSeqOrig;
    sy = repmat(sy, [1, nFrames]);
    sx = repmat(sx, [1, nFrames]);
end

% Loop through all specified additional channels
for ch = [params.ch, applyExtraChannels]

    if ~ismember(ch, params.skipChs)

        % Extract the current channel
        chSeq = squeeze(imgSeq(:, :, ch, :));

        chSeq = utils.convnfft.applyShifts(chSeq, sx, ...
            sy, params.fillBadData, params.inpaintIters);

    end

    if ndims(imgSeq) == 4
        chSeq = permute(chSeq, [1,2,4,3]);
        imgSeq(:, :, ch, :) = chSeq;
    else
        imgSeq = chSeq;
    end

end
        
end

% ====================================================================== %

function [imgSeq, refImg, sx, sy] = mc_hmm(imgSeq, params)

% Check maxshift
if isempty(params.maxShift)
    
    % Supply a default value
    params.maxShift = [5 10];
    
elseif isscalar(params.maxShift)
    
    % If maxShift is scalar, duplicate it
    params.maxShift(1,2) = params.maxShift;
    
end

% Check that maxShift is real, finite, vector with exactly two
% integer elements smaller than 20
utils.checks.rfv(params.maxShift, 'maxShift')
utils.checks.integer(params.maxShift, 'maxShift')
utils.checks.numel(params.maxShift, 2, 'maxShift')
utils.checks.less_than(params.maxShift, 20, true, 'maxShift')

% Check that frame rate is specified
utils.checks.prfs(params.frameRate, 'frameRate')

% Give a warning for constantShift
if params.constantShift
    warning('Utils:MotionCorrect:HMM:ConstantShift', ['Constant shift ' ...
        'is only relevant for the convfft motion correction method ' ...
        'and will be ignored when using the hmm method.'])
end

% Only use specified channel
if ndims(imgSeq) == 4

    chSeq = squeeze(imgSeq(:, :, params.ch, :));
    chSeq = permute(chSeq, [3 ,1, 2]);
    tempExtraCh = 1:size(imgSeq, 3);
    applyExtraChannels = tempExtraCh(tempExtraCh ~= params.ch);

elseif ndims(imgSeq) == 3

    chSeq = permute(imgSeq, [3 ,1, 2]);
    applyExtraChannels = [];

end

% Run 2D Hidden Markov Model
[offsets, stillimages, doPar] = utils.hmm.calculate_offset(chSeq, ...
    params.refImg, params.maxShift, params.frameRate, ...
    params.verbose);

% Loop through all specified additional channels
for ch = [params.ch, applyExtraChannels]

    if (ndims(imgSeq) == 4) && ~ismember(ch, params.skipChs)

        % Extract the current channel
        chSeq = squeeze(imgSeq(:, :, ch, :));
        chSeq = permute(chSeq, [3, 1, 2]);

        % Apply the shifts and playback
        [chSeq, ~] = utils.hmm.playback_markov(chSeq, ...
                offsets, params.maxShift(2), ch, params.fillBadData, ...
                params.inpaintIters, params.verbose, doPar);

        % Permute to original format
        chSeq = permute(chSeq, [2,3,4,1]);

    elseif ndims(imgSeq) == 3

        % Apply the shifts and playback
         [chSeq, ~] = utils.hmm.playback_markov(chSeq, ...
                offsets, params.maxShift(2), ch, params.fillBadData, ...
                params.inpaintIters, params.verbose, doPar);

        % Permute to original format
        chSeq = permute(chSeq, [2, 3, 1]);

    end

    % Replace original with corrected image
    if ndims(imgSeq) == 4
        utils.checks.same_size(chSeq, imgSeq(:, :, ch, :), ...
            'chSeq and imgSeq');
        imgSeq(:, :, ch, :) = chSeq;
    else
        utils.checks.same_size(chSeq, imgSeq, 'chSeq and imgSeq');
        imgSeq = chSeq;
    end

end

% Retain reference images and shifts
refImg = squeeze(mean(stillimages, 1));
sx = offsets(2,:);
sy = offsets(1,:);

end
