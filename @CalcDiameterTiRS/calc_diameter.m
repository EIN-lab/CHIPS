function self = calc_diameter(self, imgSeq, frameRate, doInvert, t0)

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
    
% Work out if we're using the parallel features
isParallel = utils.is_parallel();

% Initialise a progress bar
strMsg = 'Calculating diameter';
isWorker = utils.is_on_worker();
if ~isWorker
    if isParallel
        fnPB = utils.progbarpar('msg', strMsg);
    else
        fnPB = '';
        utils.progbar(0, 'msg', strMsg);
    end
else
    % This is needed for parallel processing, even if it's unused
    fnPB = '';
end

% Preallocate memory
[nRows, nCols, nFrames] = size(imgSeq);
areaPixels = zeros(nFrames, 1);
thetaRange = 0:179;
nAngles = length(thetaRange);
nRadii = 2*ceil(norm(size(imgSeq(:, :, 1)) - ...
    floor((size(imgSeq(:, :, 1)) - 1)/2) - 1)) + 3;
imgNorm = zeros(nRadii, nAngles, nFrames);
idxEdges = zeros(2, nAngles, nFrames);
imgInv = zeros(size(imgSeq));
vesselMask = false(size(imgInv));

% Calculate the time
frameTime = 1/frameRate;
time = ((0.5*frameTime):frameTime:(nFrames*frameTime))'  - t0;

% Setup some parameters for reduced communication betwen
% parallel pool workers
thresholdFWHM = self.config.thresholdFWHM;
thresholdInv = self.config.thresholdInv;
connectivity = self.config.connectivity;

% Setup arguments for inverse radon transform
% interpMode = 'linear';
filterType = 'Hamming';
% freqScaling = 1;
outputSize = max([nRows, nCols]);
argsIRadon = {thetaRange, filterType, outputSize};

% Setup some helper arguments for resizing the image
doResizeInv = false;
colsToUseInv = 1:nCols;
rowsToUseInv = 1:nRows;
if nRows ~= nCols
    doResizeInv = true;
    ctrOrig = floor(([nRows, nCols]+1)/2);
    ctrInv = floor((outputSize+1)/2);
    adjPixels = ctrInv - ctrOrig;
    hasRoundingProblem = all(adjPixels == 0);
    if hasRoundingProblem
        adjPixels = abs([nRows, nCols] - outputSize);
    end
    dimToAdj = find(adjPixels);
    if dimToAdj == 1
        rowsToUseInv = (1:nRows) + adjPixels(dimToAdj);
    else
        colsToUseInv = (1:nCols) + adjPixels(dimToAdj);
    end
end

% Invert the image sequence if necessary
if doInvert
    imgSeq = max(imgSeq(:)) - imgSeq;
end

% Loop through all the frames
parfor iFrame = 1:nFrames

    % Calculate the radon transform of the frame
    imgTrans = radon(imgSeq(:, :, iFrame), thetaRange);
    [nRowsT, ~] = size(imgTrans);

    % Normalise each column (angle) of the radon transform
    imgNorm(:, :, iFrame) = (imgTrans - ...
        repmat(min(imgTrans, [], 1), [nRowsT, 1]))./ ...
        repmat(max(imgTrans, [], 1) - min(imgTrans, [], 1), ...
            [nRowsT, 1]);

    % Threshold the image, fill in any holes, and extract out
    % only the largest contiguous area
    imgThresh = imgNorm(:, :, iFrame) >= thresholdFWHM;
    imgThresh = imfill(imgThresh, 8, 'holes');
    ccT = bwconncomp(imgThresh, 4);
    ssT = regionprops(ccT);
    [~, maxIdx] = max([ssT(:).Area]);
    imgThresh = (labelmatrix(ccT) == maxIdx);

    for jAngle = 1:nAngles

        % Find the 'FWHM' edges of the transformed image
        idxEdgesTmp = [...
            find(imgThresh(:, jAngle), 1, 'first'), ...
            find(imgThresh(:, jAngle), 1, 'last')];

        % Manually threshold the transformed image using the
        % edges defined by the 'FWHM'
        imgThreshRowTmp = false(nRadii, 1);
        idxToUse = idxEdgesTmp(1) : idxEdgesTmp(2);
        imgThreshRowTmp(idxToUse) = true;
        imgThresh(:, jAngle) = imgThreshRowTmp;
        idxEdges(:, jAngle, iFrame) = idxEdgesTmp;

    end

    % Invert the thresholded radon-transformed image, adjust
    % the size if necessary, and then normalise it
    imgInvTemp = iradon(imgThresh, argsIRadon{:}); %#ok<PFBNS>
    if doResizeInv
        imgInvTemp = imgInvTemp(rowsToUseInv, colsToUseInv);
    end
    imgInv(:,:,iFrame) = imgInvTemp./max(imgInvTemp(:));

    % Threshold the inverted image, and fill in any holes in 
    % the thresholded, inverted image
    imgInvThresh = imgInv(:,:,iFrame) > thresholdInv;
    imgInvThresh = imfill(imgInvThresh, 'holes');

    % Calculate the area of the largest contiguous region
    cc = bwconncomp(imgInvThresh, connectivity);
    ss = regionprops(cc);
    [areaPixels(iFrame, 1), maxIdx] = max([ss(:).Area]);

    % Create a binary image showing only the largest area
    % identified above
    lm = labelmatrix(cc);
    vesselMask(:, :, iFrame) = (lm == maxIdx);

    % Update the progress bar
    if ~isWorker
        if isParallel
            utils.progbarpar(fnPB, nFrames, 'msg', strMsg);
        else
            utils.progbar(1 - (iFrame-1)/nFrames, ...
                'msg', strMsg, 'doBackspace', true);
        end
    end

end

% Add the raw data
self.data = self.data.add_raw_data(time, areaPixels, ...
    vesselMask, imgNorm, imgInv, idxEdges);

% Close the progress bar
if ~isWorker && isParallel
    utils.progbarpar(fnPB, 0, 'msg', strMsg);
end

end