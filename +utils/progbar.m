function varargout = progbar(progressDec, varargin)
%progbar - Helper function to create/update a progress bar
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

% Check we have enough input arguments
narginchk(1, Inf)

% Setup the default parameter names and values
pNames = {
    'msg'; ...
    'showBar'; ...
    'doBackspace'; ...
    'widthBar'
    };
pValues = {
    ''; ...
    true; ...
    progressDec > 0; ...
    60
    };
dflts = cell2struct(pValues, pNames);

% Parse any remaining input arguments
wngState = warning('off', 'ParsePropVal:UnknownAttr');
params = utils.parsepropval(dflts, varargin{:});
warning(wngState);

% Check that the message isn't too long
isTooLong = numel(params.msg) > 48;
if isTooLong
    params.msg = params.msg(1:48);
end
params.widthBar = 60 - (numel(params.msg) + 2);

% Work out if we need to output anything
doDisp = nargout == 0;

%% Add in a buffer of spaces to prevent warnings getting overwritten

[lastmsg, ~] = lastwarn();
hasWarning = ~isempty(lastmsg);
doBuffer = doDisp && params.doBackspace && hasWarning;
if doBuffer
    [~, nBspace] = get_fmtStr(params.msg, params.showBar, params.widthBar);
    fprintf(repmat(' ', [1, nBspace + numel(params.msg)]));
    lastwarn('')
elseif hasWarning
    lastwarn('')
end

%%

% Calculate, display, and/or output the progress
if doDisp
    progressStr = format_str(100*progressDec, params.msg, ...
        params.doBackspace, params.showBar, params.widthBar);
    disp(progressStr)
else
    varargout{1} = progressDec;
end

end

%% ---------------------------------------------------------------------- %

function progressStr = format_str(progressPct, msgStr, doBackspace, ...
    showBar, widthBar)

% Get the format string for the different cases of msgStr
[fmtStr, nBspace] = get_fmtStr(msgStr, showBar, widthBar);

% Get the bar string
barStr = get_progbar(progressPct, showBar, widthBar);

% Add the backspaces at the front of the string, if necessary
if doBackspace
    fmtStr = [repmat(char(8), 1, nBspace + numel(msgStr)), fmtStr];
end

% Format the final string
progressStr = sprintf(fmtStr, msgStr, round(progressPct), barStr);

end

%% ---------------------------------------------------------------------- %

function [fmtStr, nBspace] = get_fmtStr(msgStr, showBar, widthBar)
% Get the format string for the different cases of msgStr

if ~isempty(msgStr)
    fmtStr = '%s: %3.0f%%%s';
    nBspace = 7;
else
    fmtStr = '%s%3.0f%%%s';
    nBspace = 5;
end

if showBar
    nBspace = nBspace + widthBar + 4;
end

end

%% ---------------------------------------------------------------------- %

function barStr = get_progbar(progressPct, showBar, widthBar)

% Give an empty bar if we don't want one
if ~showBar
    barStr = '';
    return
end

currPos = round(progressPct*widthBar/100);

isEnd = currPos == widthBar;
if isEnd
    barStr = [' [' repmat('=', 1, currPos+1), ']'];
else
    barStr = [' [', repmat('=', 1, currPos), '>', ...
        repmat(' ', 1, widthBar - currPos), ']'];
end

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
