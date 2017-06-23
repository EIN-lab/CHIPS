function [sy, sx, refImg] = calcShifts(imgSeq, varargin)
%calcShifts - Calculate the whole frame shifts
%
%   This function is not intended to be called directly.

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

% Parse arguments
[refImg, minCorr, maxshift, GPU] = utils.parse_opt_args(...
    {[], false, 0.6, [], false}, varargin);

% Calculate shifts frame-by-frame
[ydim, xdim, nFrames] = size(imgSeq);

% Check if reference image is provided and in the right format
if isempty(refImg)
    refImg = imgSeq(:,:,1); % Use first frame then
else
    refImg = utils.resize_img(refImg, [ydim, xdim]);
end

maskBadRef = ~isfinite(refImg);
if any(maskBadRef)
    warning('Utils:Convnfft:Convnfft:BadRefImg', ['The reference image ' ...
        'contains non-finite values.'])
    refImg(maskBadRef) = 0;
end

% Preallocate vectors for shifts
sx = zeros(1,nFrames);
sy = zeros(1,nFrames);

% Work out if we're using the parallel features
[isParallel, numWorkers] = utils.is_parallel();
doPar = isParallel && (nFrames > 2*numWorkers);

isWorker = utils.is_on_worker();
strMsg = 'Correcting motion';
    
% Initialise a progress bar
if ~isWorker
    if doPar
        fnPB = utils.progbarpar('msg', strMsg);
    else
        fnPB = '';
        utils.progbar(0, 'msg', strMsg);
    end
else
    % This is needed for parallel processing, even if it's unused
    fnPB = '';
end

parfor iFrame = 1:nFrames

    % Calculate the frame-by-frame shift
    currFrame = imgSeq(:,:,iFrame);
    [sx(iFrame), sy(iFrame), ~] = pattern_matching(refImg, ...
        currFrame, minCorr, maxshift, GPU);

    % Update the progress bar
    if ~isWorker
        if doPar
            utils.progbarpar(fnPB, nFrames, 'msg', strMsg);
        else
            utils.progbar(1 - (iFrame-1)/nFrames, 'msg', strMsg, ...
                'doBackspace', true);
        end
    end

end

% Close the progress bar
if ~isWorker && doPar
    utils.progbarpar(fnPB, 0, 'msg', strMsg);
end

end

function [dx, dy, corr] = pattern_matching(seqFrame, refImg, minCorr, ...
    maxshift, GPU)

% This function will output the shift of two images in x-y-dimension and
% the corresponding correlation

% Load data
A = sum(double([seqFrame; refImg]),3); % concatenate the two images and sum
A1 = A(1:size(seqFrame,1),:);
A2 = A(size(seqFrame,1)+1:end,:);

% Use maximum shift
if nargin<4 || isempty(maxshift)
    % We don't look for shift larger than this
    maxshift = ceil(0.3*min(size(A1),size(A2)));
end

% Use GPU
if nargin<5 || isempty(GPU)
    GPU = false;
end

% Run Matching and display output
[dx, dy, corr] = pmatch(A1, A2, minCorr, maxshift, GPU);

end

function [dx, dy, corr] = pmatch(A1, A2, minCorr, maxshift, GPU)
%% Pattern matching engine

if isscalar(maxshift)
    % common margin duplicated for both dimensions
    maxshift = maxshift([1 1]);
end

% Select 2D convolution engine
if exist(which('utils.convnfft.convnfft'), 'file')
    % http://www.mathworks.com/matlabcentral/fileexchange/24504
    convfun = @utils.convnfft.convnfft;
    convarg = {[], GPU};
else
    % This one will last almost forever
    convfun = @conv2;
    convarg = {};
    warning('PatternMatching:NoGpuDevice','Slow Matlab CONV2');
end

% Remove any infinite values from the image frame
maskBadA2 = ~isfinite(A2);
if any(maskBadA2(:))
    A2(maskBadA2) = 0;
end

% Correlation engine
A2f = A2(end:-1:1,end:-1:1);
C = convfun(A1, A2f, 'full', convarg{:});
V1 = convfun(A1.^2, ones(size(A2f)), 'full', convarg{:});
V2 = convfun(ones(size(A1)), A2f.^2, 'full', convarg{:});
C2 = C.^2 ./ (V1.*V2);
center = size(A2f);
C2 = C2(center(1)+(-maxshift(1):maxshift(1)), ...
    center(2)+(-maxshift(2):maxshift(2)));
[cmax, ilin] = max(C2(:));
corr = sqrt(cmax);

%Decide if correlation is good enough
if corr < minCorr
    warning('motion_correction:calcShifts:pmatch', ['Correlation is ', ...
        '%.3f and lower than the specified minimal correlation %.3f.'], ...
        corr, minCorr);
        
    dx = NaN;
    dy = NaN;
    return
end

[iy, ix] = ind2sub(size(C2),ilin);
dx = ix - (maxshift(2)+1);
dy = iy - (maxshift(1)+1);

end
