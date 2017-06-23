function [img_out, cmaps] = combine_img_chs(img)
%combine_img_chs - Combine multichannel images to a truecolour RGB image
%
%   IMG_out = combine_img_chs(IMG) combines the MxNxCxP image IMG into a
%   MxNx3xP truecolour RGB image in the range [0, 1].  MxN are the
%   dimensions of the image(s), C is the number of channels, and P the
%   number of images.
%
%   This function currently supports images with up to 4 channels, and is
%   designed solely for display (rather than analysis) purposes.
%
%   Depending on the number of input channels, the following colours will
%   be used in the output image, in this order:
%   1 ch: monochrome (black and white)
%   2 ch: green and red
%   3 ch: blue, green and red
%   4 ch: blue, green, red, magenta
%
%   [IMG_out, cmaps] = combine_img_chs(IMG) also returns the 8 bit
%   colourmaps used for each of the channels.  The size of cmaps is
%   256x3xC.
%
%   See also utils.stack_slider, utils.select_fp_masks, utils.sc_pkg.sc,
%   utils.makeColorMap

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
narginchk(1, 1);

% Check the input image
utils.checks.object_class(img, {'numeric'}, 'image sequence')
utils.checks.greater_than(ndims(img), 2, 1, 'Number of image dimensions')
utils.checks.less_than(ndims(img), 4, 1, 'Number of image dimensions')
img = double(img);

% Establish the base colour channels (based on colorbrewer, but brighter)
mapColours = [...
    076, 175, 255;      % blue
    112, 255, 108;      % green
    255, 047, 047;      % red
    238, 122, 255] ...  % purple
        ./255;

% Choose the appropriate colour combinations depending on the number of chs
[~, ~, nChs, ~] = size(img);
switch nChs
    case 1
        mapColours = [1, 1, 1];
    case 2
        mapColours = mapColours([2, 3], :);
    case 3
        mapColours = mapColours([1, 2, 3], :);
    case 4
        % don't need to do anything!
    otherwise
        error('CombineImgChs:TooManyChs', ...
            'Images with more than 4 channels are not currently supported')
end

% Combine the channels with an appropriate set of colors
for iCh = nChs:-1:1
    
    % Create the colormap for this image channel
    cmaps(:,:,iCh) = utils.makeColorMap([0 0 0], mapColours(iCh, :), 256);
    
    % Create the image for this channel
    img_out(:,:,:,:,iCh) = utils.sc_pkg.sc(img(:,:,iCh,:), cmaps(:,:,iCh));
    
end

% Combine the image channels, and correct for cases where the colours are
% saturated
img_out = sum(img_out, 5);
img_out(img_out > 1) = 1;

end