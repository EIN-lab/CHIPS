function self = find_ROIs(self, objPI)
%find_ROIs - Identify regions of interest

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

% ======================================================================= %

% Check for the image processing toolbox
featureImg = 'Image_Toolbox';
className = 'CalcFindROIsFLIKA:FindROIs';
utils.verify_license(featureImg, className);

% Check for the signal processing toolbox
featureSig = 'Signal_Toolbox';
toolboxdirSig = 'signal';
verSig = '6.21';
isOldSPTB = utils.verify_license(featureSig, className, ...
    toolboxdirSig, verSig) < 1;

% Initialise a progress bar
isWorker = utils.is_on_worker();
if ~isWorker
    utils.progbar(0, 'msg', self.strMsg);
end

% ----------------------------------------------------------------------- %

% Pull out any properties from the metadata that the calc
% object will need
frameRate = objPI.rawImg.metadata.frameRate;
pixelSize = objPI.rawImg.metadata.pixelSize;
imgSeq = squeeze(...
    objPI.rawImg.rawdata(:,:,objPI.channelToUse,:));

% Convert the imgSeq to a double precision array to ensure we don't lose
% any data because of subtractions etc
imgSeq = double(imgSeq);
dims = size(imgSeq);

% Inpaint any non-finite data to ensure filtering etc works properly, but
% keep a record in case we need this.  Also, don't bother doing this if
% there are no NaNs or Inf values, since it takes a bit of time
badDataMask = ~isfinite(imgSeq);
nBadVals = sum(badDataMask(:));
doInpaint = (nBadVals > 0) && (self.config.inpaintIters > 0);
if doInpaint
    imgSeq = utils.inpaintn(imgSeq, self.config.inpaintIters);
end

% ----------------------------------------------------------------------- %

% Calculate the baseline average
baselineAverage = utils.nansuite.nanmean(...
    imgSeq(:,:,self.config.baselineFrames), 3);

% Subtract the baseline from the image
[imgSeq, bgLevel] = utils.subtract_bg(imgSeq, self.config.backgroundLevel);

% ----------------------------------------------------------------------- %

% Spatial filtering
sigmaXY = round(self.config.sigmaXY/pixelSize);
if sigmaXY > 0 % only if spatial filter is set
    N_gauss = ceil(4*sigmaXY + 1); % N is grid size of filter
    h2d_gauss = fspecial('gaussian', N_gauss, sigmaXY); % 2D filter
    imgSeq = imfilter(imgSeq, h2d_gauss, 'replicate');
end

% ----------------------------------------------------------------------- %

% Normalise each pixel to its baseline variation

% Design a Butterworth-like FIR high-pass filter.  Using a filter like this
% means we can apply the filter using the imfilter function, which is much
% faster than looping pixel by pixel.
fPB = self.config.freqPassBand/(frameRate/2);
hpFilterOrder = 3;
fSB = min([0.001, fPB/2]);
if isOldSPTB
    h3d_hp(1,1,:) = firls(hpFilterOrder, ...
        [0 fSB, fPB, 1], [0, 0, 1, 1], 'h');
else
    dd = designfilt('highpassfir', 'FilterOrder', hpFilterOrder, ...
        'DesignMethod', 'ls', 'StopbandFrequency', fSB, ...
        'PassbandFrequency', fPB);
    h3d_hp(1,1,:) = dd.Coefficients;
end

% Detect edge cases
isEnd = self.config.baselineFrames(end) + numel(h3d_hp) > ...
    size(imgSeq, 3);
isStart = self.config.baselineFrames(1) - numel(h3d_hp) < 1;

if isStart && isEnd
    error('CalcFindROIsFLIKA:find_ROIs:baselineSpan', ['The baseline ', ...
        'seems to span the whole range of frames.']);
end

% Extract out the baseline section of the image sequence, with some overlap
% so we don't have issues with the filter running off
if ~isEnd
    frameStart = self.config.baselineFrames(1);
    frameEnd = self.config.baselineFrames(end) + numel(h3d_hp);
else
    frameStart = self.config.baselineFrames(1) - numel(h3d_hp);
    frameEnd = self.config.baselineFrames(end);
end
butFiltSeq = imgSeq(:,:,frameStart:frameEnd);

% Remove any bad frames from the butterworth filtering sequence
goodFrames = ~squeeze(all(all(isnan(butFiltSeq), 2), 1));
butFiltSeq = butFiltSeq(:,:,goodFrames);

% Subtract off the first frame from all frames
butFiltSeq = bsxfun(@minus, butFiltSeq, butFiltSeq(:,:,1));

% Apply the filter twice, once in each direction, to ensure that the filter
% has no effect on the signal phase
butFiltSeq = imfilter(butFiltSeq, h3d_hp, 'replicate');
butFiltSeq = imfilter(butFiltSeq(:,:,end:-1:1), h3d_hp, 'replicate');
butFiltSeq = butFiltSeq(:,:,end:-1:1);

% Calculate the standard deviation of the filtered baseline sequence
if ~isEnd
    frameStart = 1;
    frameEnd = numel(goodFrames) - numel(h3d_hp) - 2;
else
    frameStart = numel(h3d_hp);
    frameEnd = numel(goodFrames) - 2;
end
butStd = utils.nansuite.nanstd(butFiltSeq(:,:,frameStart:frameEnd), 0, 3);

% ----------------------------------------------------------------------- %

% Temporal filtering, if sigmaT is set > 0
sigmaT = round(self.config.sigmaT*frameRate);
if sigmaT > 0
    % Create filter
    h3d_ma = repmat(1/sigmaT, [1, 1, sigmaT]);
    
    % Filter image along 3rd dimension
    imgSeq = imfilter(imgSeq, h3d_ma, 'replicate');
    imgSeq = imfilter(imgSeq(:,:,end:-1:1), h3d_ma, 'replicate');
    imgSeq = imgSeq(:,:,end:-1:1);
end

% ----------------------------------------------------------------------- %

% Calculate the normalised sequence
imgSeq = bsxfun(@rdivide, imgSeq, butStd);

% ----------------------------------------------------------------------- %

% Detect puffing pixels (stage 1 mask)
[self, puffPixelMask] = self.detectPuffingPixels(imgSeq, frameRate);

% Dilate and erode the puffing pixels
puffPixelMask = self.dilate_erode(puffPixelMask, pixelSize, frameRate);

% Group puffing pixels into discrete puffs
puffs = bwconncomp(puffPixelMask);
pixelIdxs = puffs.PixelIdxList;
    
% Create stage 2 mask
puffGroupMask = false(dims);
puffGroupMask(vertcat(pixelIdxs{:})) = true;

% Store raw data
self.data = self.data.add_raw_data(bgLevel, baselineAverage, ...
    puffGroupMask, puffPixelMask);

% ----------------------------------------------------------------------- %

% Create the stage 3 mask, final ROI mask and it's associated statistics
[puffSignificantMask, roiMask, stats] = self.create_roiMask(...
    dims, pixelIdxs, pixelSize, frameRate);

% Create the ROI names
roiNames = utils.create_ROI_names(roiMask, self.is3D);

% Add the processed data
self = self.add_data(puffSignificantMask, roiMask, stats, roiNames);

end