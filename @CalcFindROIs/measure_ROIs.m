function [traces, tracesExist] = measure_ROIs(self, objPI)
%measure_ROIs - Measure the ROIs and return the traces
%
%   [TRACES, TRACES_EXIST] = measure_ROIs(OBJ, OBJ_PI) measure the ROIS
%   contained in the CalcFindROIs object OBJ using the CellScan object
%   OBJ_PI and returns an array of TRACES, as well as a mask specifying if
%   the TRACES_EXIST.
%
%   See also CalcMeasureROIs.process, CalcMeasureROIs, CellScan.process,
%   CellScan

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
narginchk(2, 2);

% Check the ProcessedImg
self.check_objPI(objPI);

% Get necessary data from calcFindROIs
is3D = self.is3D;
roiMask = self.data.roiMask;

% Pull out any properties that we'll need and reshape data if necessary
propagateNaNs = objPI.calcMeasureROIs.config.propagateNaNs;
[isLS] = self.get_LS(objPI);
if isLS
    [~, imgSeq] = self.get_LS(objPI, 'mode', 'full');
else
    imgSeq = squeeze(objPI.rawImg.rawdata(:,:,objPI.channelToUse,:));
end
%%

% Check for the image processing toolbox
feature = 'Image_Toolbox';
className = 'CalcMeasureROIs:MeasureROIs';
utils.verify_license(feature, className);

% Accept 2D and 3D masks
nDimsMask = ndims(roiMask);
isOKSize = (nDimsMask >= 2) && (nDimsMask <= 3);
if ~isOKSize
    error('CalcMeasureROIs:measure_ROIs:WrongFormat', ...
        'The ROI mask must be a 2D or 3D image.')
end

% Check that scale of mask and data is the same
isSameSize = all(size(roiMask(:,:,1)) == size(imgSeq(:,:,1)));
if ~isSameSize
    
    % Rescale the mask
    [yDimOrig, xDimOrig] = size(imgSeq(:,:,1));
    roiMask = utils.resize_img(roiMask, [yDimOrig, xDimOrig]);
    
end

% Count the number of ROIs
switch nDimsMask
    case 2
        
        % In the 2D case, this is the connected components of the 2D mask
        roiInfo = bwconncomp(roiMask);
        nROIs = roiInfo.NumObjects;
        
    case 3
        
        if ~is3D
            % In the 2p5D case, this is the frames of the 3D mask
            nROIs = size(roiMask, 3);
        else
            % In the 3D case, this is the connected components of the 3D mask
            roiInfo = bwconncomp(roiMask);
            nROIs = roiInfo.NumObjects;
        end
        
end

% Preallocate memory
nFrames = size(imgSeq, 3);
traces = nan(nFrames, nROIs);
tracesExist = true;
if is3D
    tracesExist = false(nFrames, nROIs);
end

% Initialise a progress bar
isWorker = utils.is_on_worker();
if ~isWorker
    strMsg = 'Measuring ROIs';
    utils.progbar(0, 'msg', strMsg);
end

if nROIs < 1

    % Setup the warnings
    idNoROIs = 'CalcFindROIs:MeasureROIs:NoROIs';
    stateNoROIs = warning('query', idNoROIs);
    doNoROIs = strcmpi(stateNoROIs.state, 'on');
    if doNoROIs
        warning(idNoROIs, ['No traces could be added, because no ROIs ' ...
            'were identified.'])
    end
    
    % Assign dummy values when there's no ROI
	traces = 0;
    tracesExist = false;
    
    % Update the progress bar
    if ~isWorker
        utils.progbar(1, 'msg', strMsg, 'doBackspace', true);
    end
    
    % Quit out of here for now
    return

end

% Convert image to double
imgSeq = double(imgSeq);

% Measure the ROIs
for iROI = 1:nROIs

    % Create a list of pixel indices for the current ROI
    if ~is3D

        switch nDimsMask
            case 2
                [yIdx, xIdx] = ind2sub(size(roiMask), ...
                    roiInfo.PixelIdxList{iROI});
            case 3
                [yIdx, xIdx] = find(roiMask(:,:,iROI));
        end

        % Measure the current ROI
        traces(:, iROI) = CalcFindROIs.measure_ROI(imgSeq, xIdx, yIdx, ...
            propagateNaNs);

    else

        % Calculate the traces during the period that the ROI is defined,
        % based on all the identified pixels
        [yIdx, xIdx, tIdx] = ind2sub(size(roiMask), ...
            roiInfo.PixelIdxList{iROI});
        [tVals, ~, tC] = unique(tIdx);
        traceArray = imgSeq(roiInfo.PixelIdxList{iROI});
        traces(tVals, iROI) = accumarray(tC, traceArray, [], @mean);
        tracesExist(tVals, iROI) = true;

        % Measure the trace before and after the ROI is defined based on
        % the ROI shape at its start and end
        minT = min(tVals);
        maxT = max(tVals);
        maskFirst = tIdx == minT;
        maskLast = tIdx == maxT;
        traces(1:minT-1, iROI) = CalcFindROIs.measure_ROI(...
            imgSeq(:,:,1:minT-1), xIdx(maskFirst), yIdx(maskFirst), ...
            propagateNaNs);
        traces(maxT+1:end, iROI) = CalcFindROIs.measure_ROI(...
            imgSeq(:,:,maxT+1:end), xIdx(maskLast), yIdx(maskLast), ...
            propagateNaNs);

    end

    % Update the progress bar
    if ~isWorker
        utils.progbar(iROI/nROIs, 'msg', strMsg, 'doBackspace', true);
    end

end

end