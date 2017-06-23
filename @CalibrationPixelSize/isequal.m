function rr = isequal(self, varargin)
%isequal - Test CalibrationPixelSize objects for equality
%
%   isequal(OBJ1, OBJ2) tests scalar CalibrationPixelSize objects OBJ1 and
%   OBJ2 for equality, returning logical 1 (true) if the two objects are
%   identical, or logical 0 (false) if they are not.
%
%   isequal(OBJ1, OBJ2, OBJ3, ...) returns logical 1 if all the input
%   arguments are equal, and logical 0 otherwise.
%
%   See also CalibrationPixelSize, CalibrationPixelSize.eq, eq

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

    % Check the number of inputs
    narginchk(2, inf)

    % Check that the input object is scalar
    if ~isscalar(self)
        error('CalibrationPixelSize:IsEqual:NonScalarSelf', ...
            ['This function currently supports only scalar ' ...
            'objects'])
    end

    % Assume rr is false to start with
    rr = false(size(varargin));

    % Recursively loop through all the input arguments
    for iArg = 1:numel(varargin)
        rr(iArg) = eq(self, varargin{iArg});
    end

    % Only set the output to true if all arguments are equal
    rr = all(rr);

end