function inc_version(mode)
%inc_version - Increment the current version of CHIPS
%
%   inc_version(MODE) increments the current version of CHIPS that is
%   returned by the function CHIPS_version.  The input MODE must be a
%   scalar integer from 1 to 4, where the values have the following effect:
%
%     MODE  |  EFFECT
%     ------+-----------------------------------------------------------
%     1     |  Increment build version number only
%     2     |  Increment bug and build version
%     3     |  Increment minor and build version, reset bug to 0
%     4     |  Increment major and build version, reset bug and minor to 0
%
%   See also, utils.CHIPS_version

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

%% Argument parsing/checking

% Check we have an input argument
narginchk(1, 1);

% Check that the mode is valid
allowEq = true;
utils.checks.prfsi(mode, 'mode')
utils.checks.less_than(mode, 4, allowEq, 'mode');

% Work out what mode we're using
doIncBuild = mode == 1;
doIncBug = mode == 2;
doIncMinor = mode == 3;

%%

% Get the filename for the version file and read in the contents
fnVersion = fullfile(utils.CHIPS_rootdir, '+utils', 'CHIPS_version.m');
fID1 = fopen(fnVersion, 'r');
lines = textscan(fID1, '%s', 'Delimiter', '\n', 'Whitespace', '');
fclose(fID1);
lines = [lines{:}];

% Replace the build number
tokenBuild = 'verBuild = (\d+); %BUILD_VER';
lines = replace_token(lines, tokenBuild);

% Return here, if we're not doing anything
if doIncBuild
    write_version(fnVersion, lines)
    return
end

% Replace the bug version number, either by incrementing or reseting
tokenBug = 'verBug = (\d+); %BUG_VER';
if doIncBug
    lines = replace_token(lines, tokenBug);
    write_version(fnVersion, lines)
    return
else
    lines = replace_token(lines, tokenBug, '0');
end

% Replace the minor version number, either by incrementing or reseting
tokenMinor = 'verMinor = (\d+); %MINOR_VER';
if doIncMinor
    lines = replace_token(lines, tokenMinor);
    write_version(fnVersion, lines)
    return
else
    lines = replace_token(lines, tokenMinor, '0');
end

% Increment the major version number
tokenMajor = 'verMaj = (\d+); %MAJOR_VER';
lines = replace_token(lines, tokenMajor);
write_version(fnVersion, lines)

end

% ----------------------------------------------------------------------- %

function [linesOut, isSame] = replace_token(linesIn, token, strReplace)

% Identify the tokens
[verStrOld, tokenExtents] = regexp(linesIn, token, ...
    'tokens', 'tokenExtents');
idx = ~cellfun(@isempty, verStrOld);

% Throw an error if none or more than one line was found
nLines = sum(idx);
badNLines = nLines ~= 1;
if badNLines
    error('IncVersion:ReplaceToken:BadNLines', ['Exactly one line ' ...
        'should be identified in the version file, but %d were.'], nLines)
end

% Throw an error if none or more than one match was found
nMatches = numel(verStrOld{idx});
badNMatches = nMatches ~= 1;
if badNMatches
    error('IncVersion:ReplaceToken:BadNMatches', ['Exactly one match ' ...
        'should be identified in the version file, but %d were.'], nMatches)
end

% Work out the current (i.e. soon to be old) version
verNumNow = str2double(verStrOld{idx}{1});

% Work out the replacement string and do the replacement
doIncrement = (nargin < 3) || isempty(strReplace);
if doIncrement
    verStrNew = num2str(verNumNow + 1, '%d');
else
    verStrNew = strReplace;
end

% Do the replacement string
linesOut = linesIn;
tokenExtents = tokenExtents{idx}{1};
linesOut{idx} = [linesOut{idx}(1:(tokenExtents(1)-1)), verStrNew, ...
    linesOut{idx}((tokenExtents(2)+1):end)];

% Check to see if anything's changed
isSame = isequal(linesOut, linesIn);

end

% ---------------------------------------------------------------------- %

function write_version(fnVersion, lines)

% Overwrite the version script with the new details
fID = fopen(fnVersion, 'w');
fprintf(fID, '%s\n', lines{:});
fclose(fID);

end
