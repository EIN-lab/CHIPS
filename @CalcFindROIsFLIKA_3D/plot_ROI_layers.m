function [roiImg, nROIs] = plot_ROI_layers(self, roiMask, varargin)

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

% Setup the default parameter names and values
pNames = {
    'FrameNum'; ...
    'plotROIs' ...
    };
pValues = {
    []; ...
    []
    };
dflts = cell2struct(pValues, pNames);
params = utils.parse_params(dflts, varargin{:});

% Plot only the frame
if ~isempty(params.FrameNum)
    [roiImg, nROIs] = plot_ROI_layers@CalcFindROIsFLIKA(self, ...
        roiMask, varargin{:});
    return
end

% Create the roiMask
cc_3D = bwconncomp(roiMask);
roiMask_2p5D = false(cc_3D.ImageSize(1:2));

% Loop through the individual ROIs
for iROINum = numel(params.plotROIs):-1:1
    
    % Pull out the actual ROI number
    iROI = params.plotROIs(iROINum);
    
    % Compute x and y indices from PixelIdxList
    [yIdx, xIdx, ~] = ind2sub(cc_3D.ImageSize, cc_3D.PixelIdxList{iROI});
    dummyImg_2D = false(cc_3D.ImageSize(1:2));
    dummyImg_2D(sub2ind(size(dummyImg_2D), yIdx, xIdx)) = true;
    
    % Create the temporary ROI mask like a 2.5D mask
    roiMask_2p5D(:,:,iROI) = dummyImg_2D;
end

% Call the superclass method to do most of the work
[roiImg, nROIs] = plot_ROI_layers@CalcFindROIsFLIKA(self, roiMask_2p5D, ...
    varargin{:});

end