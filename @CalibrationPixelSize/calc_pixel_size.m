function pixelSizeOut = calc_pixel_size(self, zoomIn, imgSizeIn)
%calc_pixel_size - Calculate the pixel size
%
%   PXSIZE = calc_pixel_size(OBJ, ZOOM, IMGSIZE) calculates the pixel size
%   (PXSIZE) for a given calibration object (OBJ), zoom values (ZOOM) and
%   image size (IMGSIZE). ZOOM must be an array of positive real numbers,
%   and IMGSIZE must be a scalar integer.
%
%   See also Metadata.zoom, Metadata.pixelSize

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
%   along with this program.  If not, see <http://www.gnu.org/licenses/>

    % Check we have the correct number of arguments
    narginchk(3, 3)

    % Check we have a fitted function
    goodFunFitted = ~isempty(self.funFitted) && ...
        isa(self.funFitted, 'function_handle');
    if ~goodFunFitted
        error('CalibrationPixelSize:BadFunFitted', ['The ' ...
            'calibration function is either empty or invalid.'])
    end

    % Check zoom in is real and numeric
    utils.checks.real_num(zoomIn, 'zoom');
    utils.checks.positive(zoomIn, 'zoom');

    % Check imgSizeIn is an integer scalar
    utils.checks.scalar(imgSizeIn, 'imgSizeIn');
    utils.checks.integer(imgSizeIn, 'imgSizeIn');

    % Calculate the pixel size
    if isfinite(self.imgSize)
        pixelSizeOut = (self.imgSize/imgSizeIn)*self.funFitted(zoomIn);
    else
        pixelSizeOut = self.funFitted(zoomIn);
    end

end