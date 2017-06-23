function roiImg = plot_3D_masks(varargin)
%plot_3D_masks - Helper function to plot 3D masks
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
narginchk(0, 3);

% Parse arguments
[masks, colorSpec, alphaSpec] = ...
    utils.parse_opt_args({[], [], []}, varargin(:));

% Check the masks
allowEqMasks = true;
utils.checks.not_empty(masks, 'masks')
utils.checks.greater_than(ndims(masks), 2, allowEqMasks, ...
    'number of dimensions of the mask');
utils.checks.less_than(ndims(masks), 3, allowEqMasks, ...
    'number of dimensions of the mask');
utils.checks.logical_able(masks, 'masks')
nMasks = size(masks, 3);

% Check the colorSpec
if isempty(colorSpec)
    colorSpec = hsv(nMasks);
else
    
    utils.checks.equal(size(colorSpec, 2), 3, ...
        'number of columns in colorSpec');
    
    if size(colorSpec, 1) == 1
        colorSpec = repmat(colorSpec, [nMasks, 1]);
    end
    
    nColours = size(colorSpec, 1);
    allowEqColour = true;
    utils.checks.greater_than(nColours, nMasks, allowEqColour, ...
        'number of colours');
    
end

% Check the alphaSpec
if isempty(alphaSpec)
    alphaSpec = 0.6;
else
    allowEqAlpha = true;
    utils.checks.scalar(alphaSpec, 'alpha value');
    utils.checks.real_num(alphaSpec, 'alpha value');
    utils.checks.finite(alphaSpec, 'alpha value');
    utils.checks.greater_than(alphaSpec, 0, allowEqAlpha, 'alpha value');
    utils.checks.less_than(alphaSpec, 1, allowEqAlpha, 'alpha value');
end

%%

% Loop through the individual masks
emptyMask = zeros(size(masks(:,:,1)));
roiAlpha = emptyMask;
roiImg = utils.sc_pkg.sc(emptyMask, 'gray');
for iMask = nMasks:-1:1
    
    % Semi-manually alpha composite the ROI masks together
    newMask = masks(:,:,iMask);
    newAlpha = newMask.*alphaSpec;
    newImg = utils.sc_pkg.sc(emptyMask, colorSpec(iMask, :), newMask);
    [roiImg, roiAlpha] = utils.alpha_comp_over(newImg, roiImg, ...
        newAlpha, roiAlpha);

end

% Apply the final alpha channel
roiImg = bsxfun(@times, roiImg, roiAlpha);

end
