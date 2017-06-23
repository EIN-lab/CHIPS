function self = find_ROIs(self, objPI)
%find_ROIs - Identify regions of interest
%
%   function self = find_ROIs(self, imgSeq, frameRate, pixelSize)
%
%   OBJ = find_ROIs(OBJ, IMG, FRAMERATE, PIXELSIZE) requires passing of a
%   CalcFindROIsCellSort object (OBJ), the image sequence (IMG), the frame
%   rate of the recording (FRAMERATE) and the pixel size (PIXELSIZE).
%   find_ROIs runs first 4 steps of the CellSort segmentation algorithm.
%   For further reference, please see <a href="matlab:web('http://dx.doi.org/10.1016/j.neuron.2009.08.009', '-browser')">Mukamel et al. (2009)</a>, 
%   Neuron 63(6):747–760.
%
%   See also CalcFindROIsCellSort, CalcFindROIs, Calc, CellScan

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
className = 'CalcFindROIsCellSort:FindROIs';
utils.verify_license(featureImg, className);

% ----------------------------------------------------------------------- %

% Initialise a progress bar
isWorker = utils.is_on_worker();
doProgBar = ~isWorker;
if doProgBar
    utils.progbar(0, 'msg', self.strMsg);
end

% ----------------------------------------------------------------------- %

% Pull out any data from the objPI that we need
pixelSize = objPI.rawImg.metadata.pixelSize;
frameRate = objPI.rawImg.metadata.frameRate;
t0 = objPI.rawImg.t0;
imgSeq = squeeze(...
    objPI.rawImg.rawdata(:,:,objPI.channelToUse,:));

% Determine size of the Field of View
FOV = [objPI.rawImg.metadata.nLinesPerFrame, ...
    objPI.rawImg.metadata.nPixelsPerLine];
FOV = FOV .* objPI.rawImg.metadata.pixelSize;

% Convert the imgSeq to a double precision array to ensure we don't lose
% any data because of subtractions etc
imgSeq = double(imgSeq);
dims = size(imgSeq);

% Obtain necessary parameters
fLims = self.config.fLims;
nPCs = self.config.nPCs;
dsamp = []; % dsamp = self.config.dsamp;
badFrames = self.config.badFrames;
mu = self.config.mu;
sigma = self.config.sigma;
thresholdSeg = self.config.thresholdSeg;
rndSeed = self.config.rndSeed;
arealims = [self.config.minROIArea, self.config.maxROIArea] ./ ...
    (pixelSize^2);
termTol = self.config.termTol;
maxrounds = self.config.maxIters;

% Inpaint any non-finite data to ensure filtering etc works properly, but
% keep a record in case we need this.  Also, don't bother doing this if
% there are no NaNs or Inf values, since it takes a bit of time
badDataMask = ~isfinite(imgSeq);
nBadVals = sum(badDataMask(:));
doInpaint = (nBadVals > 0) && (self.config.inpaintIters > 0);
if doInpaint
    imgSeq = utils.inpaintn(imgSeq, self.config.inpaintIters);
end

% Create the time vector
nFrames = dims(3);
time = ((0.5:nFrames-0.5)./frameRate)' - t0;

% Set the random state
rndState = rng;
rng(rndSeed); % fix random state

%% 1. Do PCA

[mixedTraces, mixedFilters, CovEvals, ~, ~, tAverage, ~] = ...
    utils.cellsort.CellsortPCA(imgSeq, fLims, nPCs, dsamp, badFrames);

% Update the progress bar
if doProgBar
    utils.progbar(1/5, 'msg', self.strMsg, 'doBackspace', true);
end
        
%% 2. Choose PCs

% Select PCs to analyze automatically
if isempty(self.config.PCuse)
    self.config.PCuse = utils.cellsort.defaultPCs(imgSeq, ...
        mixedFilters, FOV);
end

% Update the progress bar
if doProgBar
    utils.progbar(2/5, 'msg', self.strMsg, 'doBackspace', true);
end

%% 3. Do ICA 

nIC = length(self.config.PCuse);
ica_A_guess = [];
[icTraces, icFilters, ~, ~] = ...
    utils.cellsort.CellsortICA(mixedTraces, mixedFilters, CovEvals, ...
        self.config.PCuse, mu, nIC, ica_A_guess, termTol, ...
        maxrounds, self.strMsg);
icTraces = permute(icTraces, [2 1]);

% Update the progress bar
if doProgBar
    utils.progbar(3/5, 'msg', self.strMsg, 'doBackspace', true);
end

%% 4. Segment contiguous regions within ICs

[roiFilters, icMask, segmentlabel] = utils.cellsort.CellsortSegmentation(...
    icFilters, sigma, thresholdSeg, arealims, self.config.discardBorderROIs);
roiFilters = permute(roiFilters, [2 3 1]);
icFilters = permute(icFilters, [2 3 1]);

% Update the progress bar
if doProgBar
    utils.progbar(4/5, 'msg', self.strMsg, 'doBackspace', true);
end

%% 5. Filter out unwanted ROIs and create the final mask

% Create the ROI mask
hasROIs = nnz(roiFilters > 0);
if hasROIs
    roiMask = roiFilters ~= 0;
else
    roiMask = false(size(imgSeq(:,:,1)));
end

% Create the ROI names
roiNames = utils.create_ROI_names(roiMask, self.is3D);

%% 6. Extract descriptive statistics about individiual ROIs

stats = CalcFindROIs.get_ROI_stats(roiMask, pixelSize);
if ~hasROIs
    stats(1).Area = NaN;
    stats(1).Centroid = [NaN, NaN];
    stats(1).PixelIdxList = {NaN};
end

% Update the progress bar
if doProgBar
    utils.progbar(5/5, 'msg', self.strMsg, 'doBackspace', true);
end

%% Store some computed data for later use

% Store raw data
self.data = self.data.add_raw_data(icFilters, icTraces, mixedFilters, ...
    tAverage, time);

% Add the processed data
self = self.add_data(icMask, roiFilters, roiMask, roiNames, ...
    stats, segmentlabel);

% Store the extra data needed for plotting
self.CovEvals = CovEvals;
self.PCuse = self.config.PCuse;

% Restore the random state
rng(rndState)

end
