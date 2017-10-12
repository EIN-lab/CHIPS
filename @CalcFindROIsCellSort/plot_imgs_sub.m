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
        refImg = objPI.get_refImg(varargin{:});
        params.CAxis = utils.checks.check_cAxis(params.CAxis, refImg);
        refImgRGB = utils.sc_pkg.sc(refImg, 'gray', params.CAxis);

        % Extract the masks and turn them into overlays
        [maskFilters, maskSegments] = ROIsToMask(self);
        normVal = max([max(maskFilters(maskFilters(:) > 0)), ...
            abs(min(maskFilters(maskFilters(:) < 0)))]);
        maskFiltersNorm = maskFilters./normVal;
        cLims = [0, normVal];
        cmapHot = utils.cubehelix(256, 0.5, 0.3, 2.3, 1, ...
            [0.3, 0.7], [0.15, 0.85]);
        cmapCool = utils.cubehelix(256, 0, -0.3, 2.3, 1, ...
            [0.3, 0.7], [0.15, 0.85]);
        pixelOverlay = ...
            utils.sc_pkg.sc(maskFiltersNorm, cLims, cmapHot, ...
                'w', maskFilters <= 0) + ...
            utils.sc_pkg.sc(-maskFiltersNorm, cLims, cmapCool, ...
                'w', maskFilters >= 0);
        groupOverlay = utils.sc_pkg.sc(zeros(size(maskSegments)), ...
            cmapHot(128,:), maskSegments);
        
        % Plot the Stage-1 mask - All the filters summed together
                pixelAlpha = abs(maskFiltersNorm)*params.AlphaSpec;
        [pixelImg, pixelAlpha] = utils.alpha_comp_over(...
            pixelOverlay, refImgRGB, pixelAlpha, ones(size(maskFilters)));
        pixelImg = bsxfun(@times, pixelImg, pixelAlpha);
        pixelImg(pixelImg>1) = 1;
        imagesc(pixelImg, 'Parent', hAxes(1));
        title(hAxes(1), 'IC Filters');
        axis(hAxes(1), 'image')
        axis(hAxes(1), 'off')
        
        % Plot the Stage-2 - All the ICs
        groupAlpha = (maskSegments > 0)*params.AlphaSpec;
        [groupImg, groupAlpha] = utils.alpha_comp_over(groupOverlay, refImgRGB, groupAlpha, ones(size(maskSegments)));
        groupImg = bsxfun(@times, groupImg, groupAlpha);
        groupImg(groupImg>1) = 1;
        imagesc(groupImg, 'Parent', hAxes(2))
        title(hAxes(2), 'IC Mask (Not Segmented)')
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
    self.plot(objPI, hAxRef, 'rois');
    
    % Link the axes
    linkaxes(hAxes, 'xy')

end
