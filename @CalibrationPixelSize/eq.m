function rr = eq(aa, bb)
%eq - Test two CalibrationPixelSize objects for equality
%
%   eq(OBJ1, OBJ2) tests scalar CalibrationPixelSize objects OBJ1 and OBJ2
%   for equality, returning logical 1 (true) if the two objects are
%   identical, or logical 0 (false) if they are not.
%
%   See also CalibrationPixelSize, CalibrationPixelSize.isequal, eq

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
    narginchk(2, 2)

    % Check that the input object is scalar
    if ~isscalar(aa)
        error('CalibrationPixelSize:eq:NonScalarSelf', ['This ' ...
            'function currently supports only scalar objects'])
    end

    % Assume rr is false to start with
    rr = false;

    % Check that the input object is scalar
    if ~isscalar(bb)
        error('CalibrationPixelSize:eq:NonScalarObj', ['This ' ...
            'function currently supports only scalar objects'])
    end

    % Check the input is a CalibrationPixelSize object
    ME = utils.checks.object_class(bb, class(aa));
    if ~isempty(ME), return, end

    % Loop through all the properties and check for equality,
    % stopping the loop as soon as we find anything not equal
    fns = properties(aa);
    for iFN = 1:numel(fns)
        ee = isequal(aa.(fns{iFN}), bb.(fns{iFN}));
        if any(~ee)
            return
        end
    end

    % Only set the output to true if we've made it all the way here
    rr = true;

end