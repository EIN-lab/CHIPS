function plot_imgs_sub(self, objPI, hAxes, varargin)

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
        'CAxis'; ...
        'isDebug'
        };
    pValues = {
        0.6; ...
        []; ...
        true
        };
    dflts = cell2struct(pValues, pNames);
    params = utils.parse_params(dflts, varargin{:});

    % Part 2: ROIs detection and exclusion
    if params.isDebug
        
        % Convert the reference image to RGB
        [refImg, isLS] = objPI.get_refImg(varargin{:});
        params.CAxis = utils.checks.check_cAxis(params.CAxis, refImg);
        refImgRGB = utils.sc_pkg.sc(refImg, 'gray', params.CAxis);

        % Extract the masks 
        [pixelMask, groupMask, ~] = ROIsToMask(self);
        
        % Transpose linescan masks
        if isLS
            pixelMask = pixelMask';
            groupMask = groupMask';
            
            % Cheat a bit to display the masks
            refImgDims = size(refImgRGB);
            pixelMask = imresize(pixelMask, [refImgDims(1), refImgDims(2)]);
            groupMask = imresize(groupMask, [refImgDims(1), refImgDims(2)]);
        end
        
        %Turn masks into overlays
        cmapHot = utils.cubehelix(256, 0.2, 0.5, 2.25, 0.8, ...
            [0.25, 0.9], [0.2, 0.9]);
        pixelOverlay = utils.sc_pkg.sc(...
            pixelMask, cmapHot, 'w', pixelMask == 0);
        groupOverlay = utils.sc_pkg.sc(zeros(size(groupMask)), ...
            cmapHot(64,:), groupMask);
        
        % Plot the puffing pixel image
        pixelAlpha = (pixelMask > 0)*params.AlphaSpec;
        [pixelImg, pixelAlpha] = utils.alpha_comp_over(...
            pixelOverlay, refImgRGB, pixelAlpha, ones(size(pixelMask)));
        pixelImg = bsxfun(@times, pixelImg, pixelAlpha);
        imagesc(pixelImg, 'Parent', hAxes(1));
        title(hAxes(1), 'Puffing Pixels');
        axis(hAxes(1), 'image')
        axis(hAxes(1), 'off')

        % Plot the grouped pixel image
        groupAlpha = (groupMask > 0)*params.AlphaSpec;
        [groupImg, groupAlpha] = utils.alpha_comp_over(...
            groupOverlay, refImgRGB, groupAlpha, ones(size(groupMask)));
        groupImg = bsxfun(@times, groupImg, groupAlpha);
        imagesc(groupImg, 'Parent', hAxes(2))
        title(hAxes(2), 'Grouped Pixels')
        axis(hAxes(2), 'image')
        axis(hAxes(2), 'off')

        % Specify the axis for the reference image
        hAxRef = hAxes(3);

    else

        % Disable unused axes
        axis(hAxes([1,3]), 'off')

        % Specify the axis for the reference image
        hAxRef = hAxes(2);

    end

    % Call the superclass method to plot the ROIs
    self.plot(objPI, hAxRef, 'rois', varargin{:});
    
    % Link the axes
    linkaxes(hAxes, 'xy')

end