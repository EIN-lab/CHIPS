function checkaddpath(dirPath)
%checkaddpath - Check a directory is on the path, and add it if needed
%
%   checkaddpath(DIR) checks that the directory DIR, a subdirectory of the
%   CHIPS root directory, is on the matlab path and, if it is not, adds it.
%
%   See also utils.CHIPS_rootdir, path, addpath

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

dirFull = fullfile(utils.CHIPS_rootdir, dirPath);
idxStart = strfind(path(), dirFull);
if isempty(idxStart)
    addpath(dirFull)
end
    
end
