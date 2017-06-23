function [windows, ctrLines] = split_into_windows(imgLong, ...
    nOverlap, windowLines)
%split_into_windows - Split an image into analysis windows
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
narginchk(3, 3);

% Use the maximum possible number of lines if windowLines is Inf
if isinf(windowLines)
    windowLines = size(imgLong, 1);
end

% Loop through the windows
iWindow = 1;
while true
    
    if iWindow == 1;
        
        % Do the first window differently to work out the number of windows
        [windowTemp, nWindows, ctrLinesTemp] = ...
            utils.get_window(imgLong, iWindow, nOverlap, windowLines);
        
        % Turn off any annoying repetitive warnings, since they'll be the
        % same for the rest of the windows also
        wngState = warning('off', 'GetWindow:ExtendWindow');
        
        % Preallocate memory and assign the first window
        windows = repmat(zeros(size(windowTemp), class(imgLong)), ...
            [1, 1, 1, nWindows]);
        windows(:, :, :, 1) = windowTemp;
        
        % Preallocate memory and assign the first centerline
        ctrLines = zeros(nWindows, 1);
        ctrLines(iWindow) = ctrLinesTemp;
        
    else
        
        % Assign the remaining windows/centerlines directly 
        [windows(:, :, :, iWindow), ~, ctrLines(iWindow)] = ...
            utils.get_window(imgLong, iWindow, nOverlap, windowLines);
        
    end
    
    % Increment the window number
    iWindow = iWindow + 1;
    
    % Work out when to exit the loop
    if iWindow > nWindows
        break
    end
    
end

% Restore the warning state
warning(wngState);

% Remove the channels dimension if it is unnecessary
nChannels = size(windows, 3);
if nChannels == 1
    windows = squeeze(windows);
end

end
