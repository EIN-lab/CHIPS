function varargout = progbarpar(varargin)
%progbarpar - Helper function to create/update a parallel progress bar
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

%% Input argument checking

% Setup the default parameter names and values
pNames = {
    'msg'; ...
    'showBar'; ...
    };
pValues = {
    ''; ...
    true; ...
    };
dflts = cell2struct(pValues, pNames);

% Check to see where the parameters start in the argument list
idxStart = check_params(varargin, pNames);

% Parse any remaining input arguments
params = utils.parsepropval(dflts, varargin{idxStart:end});

% Check that the message isn't too long
isTooLong = numel(params.msg) > 48;
if isTooLong
    params.msg = params.msg(1:48);
end

params.widthBar = 60 - (numel(params.msg) + 2);

% Work out if we're supposed to initialise the temporary file
hasDir = (nargin > 0) && isdir(varargin{1});
hasParamsFirst = ~isempty(idxStart) && (idxStart == 1);
doInit = (nargin == 0) || hasDir || hasParamsFirst;

%% Initialise the temporary file, if required

if doInit
    
    % Create the temporary filename in either the temporary directory, or
    % the one specified by the user
    if ~hasDir
        fnFile = tempname();
    else
        dirTemp = varargin{1};
        fnFile = tempname(dirTemp);
    end
    
    % Create the file (and implicitly check that we can create it) 
    fnFile = [fnFile '.bin'];
    fID = fopen(fnFile, 'w');
    if fID<0
        error('ParProgBar:BadFOpen', ['Could not create the ' ...
            'temporary file "%s". Do you have write permission?'], fnFile);
    end
    fclose(fID);
    
    % Display or output the initial progress
    doDisp = nargout < 2;
    if doDisp
        utils.progbar(0, params, 'doBackspace', false)
    else
        varargout{1} = 0;
    end
    
    % Reset the last warnings, both on the local and parallel workers to
    % ensure the progress bar is formatted nicely
    lastwarn('');
    utils.clear_worker_wngs()
    
    % Return the temporary filename
    varargout{1} = fnFile;
    return
    
end

%% Continue input argument checking

% Check we have enough input arguments
narginchk(2, Inf)

fnFile = varargin{1};
% check it is a valid filename/exists and we can open it
fID = fopen(fnFile, 'a+');

NN = varargin{2};
% Check it's a positive scalar number

% Work out if we need to output anything
doDisp = nargout == 0;

%% Terminate the progress bar and tidy up the file etc

doTerm = NN == 0;
if doTerm
    
    % Close and delete the temporary file
    fclose(fID);
    delete(fnFile)
    
    % Display or output the final progress
    if doDisp
        utils.progbar(1, params)
    else
        varargout{1} = 1;
    end

    % Return back out of the function
    return
    
end

%%

% Write the current iteration
precision = 'uint8';
count = fwrite(fID, 1, precision);
if count == 0
    warning()
end

% Rewind to the start of the file and read the progress
fseek(fID, 0, 'bof');
rawData = fread(fID, Inf, precision);

% Calculate, display, and/or output the progress
progressDec = numel(rawData)/NN;
if doDisp
    utils.progbar(progressDec, params)
else
    varargout{1} = progressDec;
end

% Close the file
fclose(fID);

end

%% ---------------------------------------------------------------------- %

function idxStart = check_params(argsIn, pNames)
% Find out where in the argument list the parameters start

% Extract out only character arrays
isChar = cellfun(@ischar, argsIn);
idxChar = find(isChar);

% Find where the parameters list starts
isParam = ismember(argsIn(isChar), pNames);
idxParam = find(isParam, 1, 'first');
idxStart = idxChar(idxParam);

end
