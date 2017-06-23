function classlist = find_classlist()
%find_classlist - Return the list of non-default classes on the path
%
%   This function is not intended to be called directly.

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

% Capture the current path
pathIn = path;

% Capture the default path
restoredefaultpath
pathDef = path;
path(pathIn);

% Work out those directories that are not in the default path
pathInSplit = regexp(pathIn, pathsep, 'split');
pathDefSplit = regexp(pathDef, pathsep, 'split');
maskIsDef = ismember(pathInSplit, pathDefSplit);
pathNonDef = pathInSplit(~maskIsDef);
if ~ismember(pwd, pathNonDef)
    pathNonDef = [pwd, pathNonDef];
end
nPathDirs = length(pathNonDef);

% Prepare a list of all class related files in the non-default directories
fnListPath = {};
for iDir = 1:nPathDirs
    iFNList = what(pathNonDef{iDir});
    fnListPath = [fnListPath, iFNList.m(:)', iFNList.classes(:)']; %#ok<AGROW>
end

% Strip off any path in front of the name
[~, fnlist] = cellfun(@fileparts, fnListPath, 'UniformOutput', false);

% Ensure the files are all actually classes
maskClass = cellfun(@(cc) exist(cc, 'class'), fnlist) > 0;
classlist = fnlist(maskClass);
    
end
