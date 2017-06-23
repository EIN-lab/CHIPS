function [window, nWin, ctrLine] = get_window(imgLong, iWin, ...
    nOverlap, windowLines)
%get_window - Get a single analysis window
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
narginchk(4, 4);

% Get some basic dimensions
nLines = size(imgLong, 1);

% Check if we are asking for more rows than we have
nRows = size(imgLong, 1);
isTooManyRows = windowLines > nRows;
if isTooManyRows
    idTooBig = 'GetWindow:TooBigWindow';
    stateTooBig = warning('query', idTooBig);
    doTooBig = strcmpi(stateTooBig.state, 'on');
    if doTooBig
        warning(idTooBig, ['The requested number of ' ...
            'lines in the window is %d, but there are only %d rows in '...
            'total. This window will be smaller than requested.'], ...
            windowLines, nRows)
    end
end

% Calculate the number of windows we can fit in a frame by assuming that
% windowTime remains constant, but varying the amount of overlap between
% adjacent windows.
nWindowsExact = nOverlap*((nLines/windowLines) - 1) + 1;
nWin = max([1, round(nWindowsExact)]);

% Error if the requested window does not exist
if iWin > nWin
    error('GetWindow:WindowNumTooLarge', ['You have requested window ' ...
        '%d, but there are only %d windows in total'], iWin, nWin)
end

% Warn if the window will be extended
hasOneWindow = nWin == 1;
doExtendWindow = (nWindowsExact > 1) && hasOneWindow;
if doExtendWindow
    idExtend = 'GetWindow:ExtendWindow';
    stateExtend = warning('query', idExtend);
    doEmpty = strcmpi(stateExtend.state, 'on');
    if doEmpty
        warning(idExtend, ['The window size was extended ' ...
            'to include image data that would otherwise be wasted.'])
    end
end

% Use the whole frame if necessary / useful
if hasOneWindow

    nWin = 1;
    windowRowIdxs = [1 nLines];
    ctrLines = mean(windowRowIdxs);

else

    % Calculate the centre of each window
    windowCtrLines = linspace(0.5*windowLines+1, nLines - ...
        0.5*windowLines, nWin);
    ctrLines = round(2*windowCtrLines)/2;

    % Create a list of start/stop row indices for the windows
    windowRowIdxs = [...
        max([round(ctrLines(iWin) - ...
            0.5*windowLines), 1]), ...
        min([round(ctrLines(iWin) + ...
            0.5*windowLines-1), nLines])];

    % Check if I've screwed up
    if ~isequal(windowRowIdxs, round(windowRowIdxs))
        warning('GetWindows:NonRounded', ['The window indices are ' ...
            'not integers.  This is probably a bug; please see Matt.'])
        windowRowIdxs = round(windowRowIdxs);
    end

end

% Check if we are asking for more rows than we have
nRows = size(imgLong, 1);
isTooManyRows = windowRowIdxs(2) > nRows;
if isTooManyRows
    warning('Utils:GetWindow:NotEnoughRows', ['The requested window ' ...
        'end row is %d, but there are only %d rows in total.  This '...
        'window will be smaller than requested.'], ...
        windowRowIdxs(2), nRows)
    windowRowIdxs(2) = nRows;
end

% Return the current window
rowsToUse = windowRowIdxs(1) :  windowRowIdxs(2);
window(:, :, :) = imgLong(rowsToUse, :, :);

% Return the centreline
ctrLine = ctrLines(iWin);

end
