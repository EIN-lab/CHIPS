function install_zip(zipurl, dirName, varargin)
%install_zip - Install files from an online zip file
%
%   install_zip(ZIP_URL, DIRNAME) copies all files from the online zip file
%   specified by ZIP_URL to the subdirectory DIRNAME within the CHIPS root
%   directory (as returned by utils.CHIPS_rootdir).
%
%   install_zip(ZIP_URL, DIRNAME, FILES) copies only those files specified
%   by the cell array FILES.
%
%   install_zip(ZIP_URL, DIRNAME, FILES, MEX) also copies MEX files
%   specified by the cell array MEX.  Filenames in MEX should be specified
%   without extension, as the appropriate extension for the current
%   platform will be added by the built-in function mexext.
%
%   install_zip(ZIP_URL, DIRNAME, FILES, MEX, DIRBASE) uses the base
%   directory DIRBASE instead of utils.CHIPS_rootdir.
%
%   See also unzip, copyfile, utils.CHIPS_rootdir, mexext

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
narginchk(2, 5);

% Parse optional arguments
[otherFiles, mexFiles, baseDir] = utils.parse_opt_args(...
    {{}, {}, utils.CHIPS_rootdir}, varargin);

% Check the input arguments
utils.checks.cell_array(otherFiles);
utils.checks.cell_array(mexFiles);
utils.checks.single_row_char(baseDir);

%% Main part of the function

% Download and unzip the file
fprintf('\nDownloading and unzipping "%s"... ', zipurl)
fnOut = unzip(zipurl, tempdir);
fprintf('done.\n\n')

% Work out which files to copy, only copying the relevant mex files for
% this particular MATLAB installation
prefix = filesep;
if ~isempty(mexFiles)
    mexFiles = strcat(mexFiles, '.', mexext);
end
fileList = [mexFiles, otherFiles];

% If no files are specified, assume we want to copy everything
if isempty(fileList)
    fileList = fnOut;
    prefix = '';
end

% Check that the directory exists
dirInstall = fullfile(baseDir, dirName);
if ~isdir(dirInstall)
    mkdir(dirInstall)
end

% Copy the files to the directory
for iFile = 1:numel(fileList)
    idxMatch = ~cellfun(@isempty, ...
        strfind(fnOut, [prefix, fileList{iFile}]));
    iFileName = fnOut{idxMatch};
    [~, iFN_part] = fileparts(iFileName);
    fprintf('Copying "%s" to "%s"... ', iFN_part, dirInstall)
    [isOK, msg, msgID] = copyfile(iFileName, dirInstall, 'f');
    if ~isOK, warning(msgID, msg); end
    fprintf('done.\n')
end

end
