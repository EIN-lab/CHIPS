function varargout = CHIPS_version()
%CHIPS_version - Return the current version of CHIPS
%
%   VER = CHIPS_version() returns the current version number of CHIPS as a
%   character array.
%
%   [VER, MAJ, MIN, BUG, BUILD] = CHIPS_version() also returns the current
%   major, minor, bug, and build versions of CHIPS, as numbers.
%
%   See also utils.inc_version

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
narginchk(0, 0);

verMajor = 1; %MAJOR_VER
verMinor = 0; %MINOR_VER
verBug = 13; %BUG_VER
verBuild = 58; %BUILD_VER

verStr = sprintf('%d.%d.%d.%d', verMajor, verMinor, verBug, verBuild);

varargout{1} = verStr;
if nargout > 1
    varargout{2} = verMajor;
    varargout{3} = verMinor;
    varargout{4} = verBug;
    varargout{5} = verBuild;
end

end
