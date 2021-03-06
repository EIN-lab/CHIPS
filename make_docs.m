function make_docs(varargin)
%make_docs - Publish the documentation as html files
%
%   make_docs() publishes all m-files contained in the CHIPS_rootdir/doc/m/
%   directory to html files, which are output in the CHIPS_rootdir/doc/html
%   directory.
%
%   make_docs('outputDir', OUTPUTDIR) ouputs the published documentation to
%   OUTPUTDIR, rather than the directory above.
%
%   See also publish

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

% Setup the default parameter names and values
pNames = {
    'outputDir'
    };
pValues = {
    fullfile(utils.CHIPS_rootdir, 'doc', 'html')
    };
dflts = cell2struct(pValues, pNames);
params = utils.parse_params(dflts, varargin{:});

% Setup the options for publishing
options.format = 'html';
options.outputDir = params.outputDir;
options.createThumbnail = false;

% Define the directory for m-file documentation
dirDocM = fullfile(utils.CHIPS_rootdir, 'doc', 'm');

% Get a list of the m-files, and 
files = what(dirDocM);
mfiles = files.m;
nFiles = numel(mfiles);

% Loop through and publish all of the mfiles
pathOld = addpath(dirDocM);
fprintf('\n')
for iFile = 1:nFiles
    iFileName = fullfile(dirDocM, mfiles{iFile});
    fprintf('Publishing %s ... ', mfiles{iFile})
    publish(iFileName, options);
    fprintf('done.\n')
end
fprintf('\n')
path(pathOld);

% Close all figures
close all

end
