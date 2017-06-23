function varargout = funRawDummy(zoomIn, varargin)
%funRawDummy - A dummy function
%
%   PXSIZE = funRawDummy(ZOOM) returns an array of ones the same
%   size as ZOOM.  This is useful when there is no calibration defined as
%   means that the final results will be in units of pixels rather than
%   units of length (e.g. micrometers)
%
%   PXSIZE = funRawDummy(ZOOM, PXSIZE_IN) returns an array of PXSIZE_IN
%   instead of ones.  This is useful for imaging systems with fixed lenses
%   and no ability to zoom.
%
%   [PXSIZE, STRFUN] = funRawHyperbola(...) also returns a string
%   describing the function, i.e. 'y = 1'.
%
%   See also CalibrationPixelSize.funRaw,
%   CalibrationPixelSize.funRawHyperbola, CalibrationPixelSize.pixelSize,
%   CalibrationPixelSize.zoom

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

    % Parse the optional arguments
    params = utils.parse_opt_args({1}, varargin);

    % This is a dummy function that returns only the number of
    % pixels.  It can be used when the calibration is not known
    pixelSizeOut = params(1)*ones(size(zoomIn));

    % Create strings from the function
    strFunOut = sprintf('y = %5.4f ', params(1));

    % Assign the output arguments
    varargout{1} = pixelSizeOut;
    if nargout > 1
        varargout{2} = strFunOut;
    end

end