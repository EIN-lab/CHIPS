function [windows, time, yPos] = split_into_windows(self, windowTime, ...
    nOverlap)
%split_into_windows  - Split the raw image data into windows
%
%   [WINDOWS, TT, YY] = split_into_windows(OBJ, T_WINDOW, N_OVERLAP) splits
%   the raw image data into a matrix WINDOWS, and also returns the time
%   value (TT) and vertical position (YY) associated with each window.
%
%   See also LineScanVel.channelStreak, LineScanVel.colsToUseVel,
%   ICalcVelocityStreaks, CalcVelocityStreaks

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

% Extract the lineTime
lineTime = self.rawImg.metadata.lineTime;

% Calculate the number of lines per window, based on the input
% and recalculate the actual windowTime
windowLines = round(windowTime/lineTime);
windowTime = windowLines*lineTime;

% Work out some columns to use
colsToUse = self.colsToUseVel(1) : self.colsToUseVel(2);

% Normalise the image to remove vertical differences
avgColVal = mean(self.rawImg.rawdata(:, colsToUse, self.channelStreak), 1);
imgLong = bsxfun(@minus, ...
    cast(self.rawImg.rawdata(:, colsToUse, self.channelStreak), ...
    class(avgColVal)), avgColVal);

% Create the windows
windows = utils.split_into_windows(imgLong, nOverlap, windowLines);
nWindows = size(windows, 3);

% Calculate the time associated with each window
time = 1E-3*windowTime*(0.5 + (1/nOverlap) * (0:nWindows-1)');

% Calculate the y position associated with each window
yPos = nan(nWindows, 1);

end