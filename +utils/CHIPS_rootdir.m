function dir = CHIPS_rootdir()
%CHIPS_rootdir - Return the CHIPS root directory
%
%   DIR = CHIPS_rootdir() returns the root directory of CHIPS.
%
%   See also utils.GetFullPath.GetFullPath, path, fileparts, filesep

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

fn = which(['utils.' mfilename]);
[dirUtils, ~] = fileparts(fn);
dir = utils.GetFullPath.GetFullPath(fullfile(dirUtils, ['..' filesep]));

end
