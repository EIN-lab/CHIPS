function varargout = funRawHyperbola(zoomIn, params)
%funRawHyperbola - A two parameter rectangular hyperbolic function
%
%   PXSIZE = funRawHyperbola(ZOOM, PARAMS)
%
%       PXSIZE = PARAMS(1) ./ ZOOM + PARAMS(2);
%
%   where PXSIZE is the calculated pixel size, ZOOM is the supplied values
%   for microscope zoom factor, and PARAMS is a length 2 vector of fitting
%   parameters.
%
%   [PXSIZE, STRFUN] = funRawHyperbola(...) also returns a string
%   describing the parameterised function.
%
%   See also CalibrationPixelSize.funRaw,
%   CalibrationPixelSize.funRawDummy, CalibrationPixelSize.pixelSize,
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

    % This hyperbolic function is apparently superior to an
    % exponential function.  Should probably check that it's valid.
    pixelSizeOut = params(1)./zoomIn + params(2);

    % Create strings from the function
    strFunOut = sprintf('y = %5.4f / x + %5.4f', params(1), ...
        params(2));

    % Assign the output arguments
    varargout{1} = pixelSizeOut;
    if nargout > 1
        varargout{2} = strFunOut;
    end

end