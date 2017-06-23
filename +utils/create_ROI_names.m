function roiNames = create_ROI_names(maskROIs, varargin)
%create_ROI_names - Helper function to create ROI names
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

% Check the number of input arguments
narginchk(1, 2);

% Parse optional arguments
[is3D] = utils.parse_opt_args({false}, varargin);

% Accept 2D and 3D masks
nDimsMask = ndims(maskROIs);
isOKSize = (nDimsMask >= 2) && (nDimsMask <= 3);
if ~isOKSize
    error('Utils:CreateROINames:WrongFormat', ...
        'The ROI mask must be a 2D or 3D image.')
end

% Check for the image processing toolbox
feature = 'Image_Toolbox';
className = 'CalcDiameterTiRS';
utils.verify_license(feature, className);

% Count the number of ROIs
switch nDimsMask
    case 2
        
        % In the 2D case, this is the connected components of the 2D mask
        roiInfo = bwconncomp(maskROIs);
        nROIs = roiInfo.NumObjects;
        
    case 3
        
        if ~is3D
            % In the 2p5D case, this is the frames of the 3D mask
            nROIs = size(maskROIs, 3);
        else
            % In the 3D case, this is the connected components of the 3D mask
            roiInfo = bwconncomp(maskROIs);
            nROIs = roiInfo.NumObjects;
        end
        
end

if nROIs < 1
    roiNames = {'none'};
else
    roiNames = cell(nROIs, 1);
end

for iROI = 1:nROIs
    
    % Extract the first pixel index for the current ROI
    switch nDimsMask
        case 2
            [yIdx, xIdx] = ind2sub(size(maskROIs), ...
                roiInfo.PixelIdxList{iROI}(1));
        case 3
            
            if ~is3D
                [yIdx, xIdx] = find(maskROIs(:,:,iROI), 1, 'first');
            else
                % In the 3D case, this is the connected components of the 3D mask
                linIdx = roiInfo.PixelIdxList{iROI}(1);
                [yIdx, xIdx, tIdx] = ind2sub(size(maskROIs), linIdx);
            end
    end
    
    if ~is3D
        roiNames{iROI} = sprintf('roi%04d_%04d_%04d', iROI, yIdx, xIdx);
    else
        roiNames{iROI} = sprintf('roi%04d_%04d_%04d_%04d', ...
            iROI, yIdx, xIdx, tIdx);
    end    
end

end
