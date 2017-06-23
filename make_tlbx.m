function make_tlbx(varargin)
%make_tlbx - Create a MATLAB toolbox
%
%   make_tlbx() creates a MATLAB toolbox file, in the root directory, based
%   on the current master branch of the repository.
%
%   make_tlbx('branch', BRANCHNAME) creates the toolbox file based on the
%   BRANCHNAME branch in the repository.
%
%   make_tlbx requires MATLAB R2016a or newer to run, since the command
%   matlab.addons.toolbox.packageToolbox didn't exist in previous versions.
%   It also requires a version of git to be installed and available on the
%   system path, in order to run the git archive command.
%
%   See also system, unzip, matlab.addons.toolbox.packageToolbox, delete,
%   rmdir, utils.CHIPS_rootdir

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
    'branch'; ...
    'incVersion'; ...
    'fnToolbox';
    'makeDocs'
    };
pValues = {
    'master'; ...
    []; ...
    '';
    []
    };
dflts = cell2struct(pValues, pNames);
params = utils.parse_params(dflts, varargin{:});

% Check we have the appropriate licences
hasLicense = utils.verify_license('MATLAB', 'make_tlbx', 'matlab', '9.0');
if ~hasLicense
    error('make_tlbx:OldMatlab', ['MATLAB version R2016a or higher ', ...
        'is required to package toolboxes.'])
end

% Check the branch is correctly formatted
utils.checks.single_row_char(params.branch);
fprintf('\nUsing the "%s" branch...\n', params.branch)

% Prompt in case we've forgotten to increment the version number
if isempty(params.incVersion)
    listOpts = {'Build', 'Bug', 'Minor', 'Major'};
    strTitle = 'Which version number (if any) would you like to increment?';
    strPrompt = 'Select an option:';
    opts = [{'Do not increment'}, listOpts];
    defOption = 0;
    params.incVersion = utils.txtmenu({strTitle, strPrompt}, ...
        defOption, opts);
    fprintf('\n')
else
    utils.checks.scalar(params.incVersion, 'incVersion');
    utils.checks.integer(params.incVersion, 'incVersion');
end
doInc = params.incVersion > 0;

% Prompt in case we've forgotten to build the documentation
if isempty(params.makeDocs)
    fprintf(['Type any text to rebuild the documentation now, or ' ...
        'press enter to skip.\n']);
    strDocs = input('Input: ','s');
    params.makeDocs = ~isempty(strDocs);
    if ~params.makeDocs
        fprintf('\n')
    end
else
    utils.checks.scalar_logical_able(params.makeDocs, 'makeDocs');
end

% Check or setup the output filename for the toolbox

if ~isempty(params.fnToolbox)
    utils.checks.single_row_char(params.fnToolbox, 'fnToolbox');
end

% Work out whether to return before building
doReturn = doInc || params.makeDocs;

%%

% Increment the version, as appropriate
if doInc
	utils.inc_version(params.incVersion);
    warning('MakeTLBX:Increment', ['The version number has been ' ...
        'incremented, so you should commit the changes before ' ...
        'packaging the toolbox.'])
end

% Publish the documentation to html
if params.makeDocs
    make_docs()
    warning('MakeTLBX:MakeDocs', ['The documentation has been ' ...
        're-built, so you should commit the changes before ' ...
        'packaging the toolbox.'])
end

% Return if anything has changed
if doReturn
    return;
end

% Output a zip file of the appropriate branch 
fnZip = fullfile(utils.CHIPS_rootdir(), [params.branch '.zip']);
strMakeZip = sprintf('(cd "%s" && git archive --output "%s" %s)', ...
    utils.CHIPS_rootdir(), fnZip, params.branch);
fprintf('Creating zip file "%s"... ', fnZip);
[status, result] = system(strMakeZip);
if status ~= 0
    error('MakeTLBX:GitError', ...
        'The command "%s" returned the following error:\n\n%s', ...
        strMakeZip, result)
end
fprintf('done.\n')

% Unzip the file, then delete it
dirToolbox = fullfile(utils.CHIPS_rootdir, 'toolbox');
fprintf('Unzipping file "%s"... ', fnZip);
unzip(fnZip, dirToolbox);
delete(fnZip)
fprintf('done.\n')

% Prepare the toolbox project file and the version number
tokenPath = 'REPLACE_WITH_PATH';
fnPrj = fullfile(dirToolbox, 'CHIPS.prj');
utils.replace_in_file(fnPrj, fnPrj, tokenPath, dirToolbox);

% Create the toolbox, setting the version number
rootdir = utils.CHIPS_rootdir();
dirNow = pwd();
cd(dirToolbox)
strVersion = utils.CHIPS_version();
if isempty(params.fnToolbox)
    params.fnToolbox = fullfile(rootdir, ...
        sprintf('CHIPS_v%s.mltbx', strVersion));
end
fprintf('Creating toolbox "%s"... ', params.fnToolbox);
matlab.addons.toolbox.toolboxVersion(fnPrj, strVersion);
matlab.addons.toolbox.packageToolbox(fnPrj, params.fnToolbox)
fprintf('done.\n')
cd(dirNow)

% Delete the temporary directory
fprintf('Deleting temporary directory... ');
[status, strMsg, strMsdID] = rmdir(dirToolbox, 's');
if status ~= 1
    error(strMsdID, strMsg);
end
fprintf('done.\n')

end
