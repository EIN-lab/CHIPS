function [roiImg, nROIs] = plot_ROI_layers(~, roiMask, varargin)

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
    'AlphaSpec'; ...
    'FilledROIs'; ...
    'FrameNum';
    'nROIs';
    'plotROIs' ...
    };
pValues = {
    0.6; ...
    true; ...
    []; ...
    [];
    []
    };
roiImg = [];

dflts = cell2struct(pValues, pNames);
params = utils.parse_params(dflts, varargin{:});

nDimsMask = ndims(roiMask);
switch nDimsMask
    case 2
        
        % Work out if the mask is labelled or logical
        isLogical = islogical(roiMask);

        % Pull out the perimeter of the ROIs if requested
        if ~params.FilledROIs
            roiMaskP = bwperim(roiMask);
            if isLogical
                roiMask = roiMaskP;
            else
                roiMask(~roiMaskP) = 0;
            end
        end
        
        % 
        if isLogical
            bb = bwconncomp(roiMask);
            if isempty(params.nROIs)
                params.nROIs = bb.NumObjects;
            end
        else
            if isempty(params.nROIs)
                params.nROIs = max(roiMask(:));
            end
        end
        
        if params.nROIs > 0
            
            % Prepare a colormap
            cmap = utils.get_ROI_cmap(params.nROIs);
            
            % Work out the mask
            if isLogical
                imgLabeled = labelmatrix(bb);
            else
                imgLabeled = roiMask;
            end
            
            % Filter out so we only have the desired ROIs
            if ~isempty(params.plotROIs)
                isGood = ismember(imgLabeled, params.plotROIs);
                imgLabeled(~isGood) = 0;
            end
            
            % Prepare the RGB image and colour maps, ensuring the colours
            % are consistent between frames
            imgLabeledRGB = label2rgb(imgLabeled, cmap, 'k');

            % Overlay the ROIs, then adjust the transparency            
            roiImg = utils.sc_pkg.sc(imgLabeledRGB) .* params.AlphaSpec;
            
        end
        
    case 3

        if isempty(params.nROIs)
            params.nROIs = size(roiMask, 3);
        end
        
        if params.nROIs > 0
            
            % Prepare a colormap
            cmap = utils.get_ROI_cmap(params.nROIs);
            
            % Filter out so we only have the desired ROIs
            if ~isempty(params.plotROIs)
                roiMask = roiMask(:,:,params.plotROIs);
                cmap = cmap(params.plotROIs,:);
            end

            % Pull out the perimeter of the ROIs if requested
            if ~params.FilledROIs
                for iROI = 1:params.nROIs
                    roiMask(:,:,iROI) = ...
                        bwperim(roiMask(:,:,iROI));
                end
            end

            % Plot the masks
            
            roiImg = utils.plot_3D_masks(roiMask, cmap, params.AlphaSpec);

        end

end

% Return the output argument
nROIs = params.nROIs;

end