function varargout = plot_ref_helper(self, varargin)

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

% Parse the optional arguments
defChs = 1:self.rawImg.metadata.nChannels;
imgChs = utils.parse_opt_args({defChs}, varargin);
if isempty(imgChs)
    imgChs = defChs;
end
            
% Prepare an image for choosing the columns
imgData = mean(self.rawImg.rawdata(:, :, imgChs, :), 4);
imgData = utils.combine_img_chs(imgData);

sizeImgData = size(imgData);
if nargout > 0
    varargout{1} = sizeImgData(1:2);
end

% Plot the basic image stuff
hImgData = imagesc(imgData);
hold on
axis tight, axis image, axis off
colormap('gray')

alphaSpec = 0.2;

% Output the image handle if needed
if nargout > 1
    varargout{2} = hImgData;
end

% Plot the masks we've already selected
for iType = 1:size(self.masks, 2)

    % Pull out the current colour
    colorSpec = self.colorSpecList(iType, :);
    
    if isempty(self.masks{iType})
        continue
    end
    
    % Plot the ROIs using the utility function
    roiMasks = cat(3, self.masks{iType}{:});
    utils.plot_3D_masks(roiMasks, colorSpec, alphaSpec);

end

hold off

end