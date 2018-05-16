function [combinedImg, nROIs, barLabel] = plot_ROI_img(self, objPI, ...
    varargin)

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

% Check for the image processing toolboxes
featureImg = 'Image_Toolbox';
className = 'CalcFindROIsDummy:PlotFig';
utils.verify_license(featureImg, className);

% Setup the default parameter names and values, and parse the input params
pNames = {
    'AlphaSpec'; ...
    'CAxis'; ...
    'FilledROIs'; ...
    'FrameNum';
    'Group';
    'plotROIs';
    };
pValues = {
    0.6; ...
    []; ...
    true; ...
    []; ...
    false; ...
    [];
    };
dflts = cell2struct(pValues, pNames);
params = utils.parse_params(dflts, varargin{:});

% Extract the parameters from the ProcessedImg object
[refImg, isLS] = objPI.get_refImg(varargin{:});
pixelSize = objPI.rawImg.metadata.pixelSize;
[params.plotROIs, params.nROIs] = objPI.calcMeasureROIs.get_plotROIs(...
    params.plotROIs);

% Check the CAxis
params.CAxis = utils.checks.check_cAxis(params.CAxis, refImg);

% Select if we plot individual segments or groups
if ~params.Group
    roiMask = self.data.roiMask;
else
    roiMask = self.data.roiGroup;
end

% Special reshaping to plot linescan masks
wngState = warning();
if isLS
    roiMask = squeeze(roiMask);
    if self.is3D
        roiMask = roiMask';
    end
    
    % Suppress warnings due to linescan ROI
    warning('off', 'ResizeImg:Resizing');
    warning('off', 'ResizeImg:NonUniform');
end

% Check that scale of mask and data is the same
isSameSize = all(size(roiMask(:,:,1)) == size(refImg(:,:,1)));

% Perform rescaling, if necessary
if ~isSameSize
    [yDimOrig, xDimOrig] = size(refImg(:,:,1));
    roiMask = utils.resize_img(roiMask, [yDimOrig, xDimOrig]);
end

%Re-enable warnings
warning(wngState);

% Call a sub function to magically prepare the ROIs, either everything or
% only those ROIs that feature in the relevant frame
doOnlyFrame = ~isempty(params.FrameNum) && self.is3D;
if ~doOnlyFrame
    [roiImg, nROIs] = self.plot_ROI_layers(roiMask, varargin{:}, ...
        'nROIs', params.nROIs, 'plotROIs', params.plotROIs);
else
    cc = bwconncomp(roiMask);
    roiMaskLabel = labelmatrix(cc);    
    [roiImg, nROIs] = self.plot_ROI_layers(...
        roiMaskLabel(:,:,params.FrameNum), varargin{:}, ...
        'nROIs', params.nROIs, 'plotROIs', params.plotROIs);
end

% Prepare the reference image
hasCAxisLim = ~isempty(params.CAxis);
extraArgs = {};
if hasCAxisLim
    extraArgs = ['color', params.CAxis(end), extraArgs];
end
[refImgSc, barLabel] = utils.scaleBar(refImg, pixelSize, extraArgs{:});

% Combine the reference image and ROI overlay
if ~isempty(roiImg)
    combinedImg = roiImg + utils.sc_pkg.sc(refImgSc, 'gray', params.CAxis);
else
    combinedImg = utils.sc_pkg.sc(refImgSc, 'gray', params.CAxis);
end

% Set any saturated values to 1
maskTooBig = combinedImg(:) > 1;
combinedImg(maskTooBig) = 1;

end
