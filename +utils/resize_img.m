function img = resize_img(img, szImg, varargin)
%resize_img - Convenience function to resize an image, with warnings
%
%   IMG = resize_img(IMG, [NUMROWS NUMCOLS]) resizes the image IMG so that
%   it has the specified number of rows and columns.
%
%   IMG = resize_img(IMG, [NUMROWS NUMCOLS], METHOD) specifies a method to
%   use for resizing.  METHOD must be in the format expected by the
%   function imresize.  See the link to the function below for more
%   details. [default = 'bilinear']
%
%   See also imresize, utils.downsample

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

%% Check input arguments

% Check the number of input arguments
narginchk(2, 3);

% Parse optional arguments
method = utils.parse_opt_args({'bilinear'}, varargin);

% Check the input image
utils.checks.object_class(img, {'numeric', 'logical'}, 'image')
utils.checks.greater_than(ndims(img), 2, 1, 'Number of image dimensions')
utils.checks.less_than(ndims(img), 4, 1, 'Number of image dimensions')

% Check the image size
utils.checks.object_class(szImg, {'numeric'}, 'image size')
utils.checks.vector(szImg, 'image size')
utils.checks.numel(szImg, 2, 'image size')
utils.checks.positive(szImg, 'image size')
utils.checks.integer(szImg, 'image size')

%% Main part of the function

% Don't do anything if 
isCorrectSize = (size(img, 1) == szImg(1)) && ...
    (size(img, 2) == szImg(2));
if isCorrectSize
    return
end

% Check for the image and signal processing toolboxes
featureImg = 'Image_Toolbox';
className = 'ResizeImg';
utils.verify_license(featureImg, className);

% Give an initial warning about resizing, but only if we're not on a
% parallel worker
isWorker = utils.is_on_worker();
if ~isWorker
    warning('ResizeImg:Resizing', 'The image provided has to be rescaled');
end

% Calculate the scaling factor
scalingFactor = [szImg(1), szImg(2)]./[size(img,1), size(img,2)];

% Resize the image, giving an additional warning if we have to resize
% using a different aspect ratio
szOld = size(img);
isUniformScale = scalingFactor(1) == scalingFactor(2);
if isUniformScale
    img = imresize(img, scalingFactor(1), method);
else
    if ~isWorker
        warning('ResizeImg:NonUniform', ['Distorion is possible due to ' ...
            'different aspect ratios between the images.'])
    end
    img = imresize(img, scalingFactor.*size(img(:,:,1,1)), method);
end

% Check that the image size seems reasonable, to correct for a possible bug
% in R2013a imresize (no longer present in R2014b) whereby it combines the
% dimensions after 3 into the third dimension
szNew = size(img);
isWeird = ~isequal(szOld(3:end), szNew(3:end));
if isWeird
    img = reshape(img, [szNew(1:2), szOld(3:end)]);
end

end