function adjImgData = adj_traj_delay(delayTime, imgData, pixelTime, ...
    xChannel, yChannel)

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

if delayTime == 0
    adjImgData = imgData;
    return
end

% Work out how many pixels to shift the trajectory
nPixels = ceil(delayTime/pixelTime);

% Convert imgData to double
imgData = double(imgData);

% Create an empty array of the correct size and data type
[nRows, nCols, nChannels, nFrames] = size(imgData);
hConstructor = str2func(class(imgData));
adjImgData = hConstructor(zeros(nRows, nCols - nPixels, nChannels, ...
    nFrames));

% Fill up the new fluorescence channels
rowsToUse = 1 : nRows;
nFluoChannels = min([xChannel, yChannel]) - 1;
for iChan = 1:nFluoChannels
    adjImgData(:, :, iChan, :) = imgData(rowsToUse, ...
        1 : nCols - nPixels, iChan, :);
end

% Define the constants for interpolation
colsToUse = 1 : nCols;
timeRaw = pixelTime*(colsToUse);
timeToInterpAt = pixelTime*(1 : nCols - nPixels) + delayTime;

% Fill up the trajectory channels with the interpolated values      
for iFrame = 1:nFrames
    for jRow = rowsToUse

        adjImgData(jRow, :, xChannel, iFrame) = interp1(timeRaw, ...
            imgData(jRow, colsToUse, xChannel, iFrame), timeToInterpAt);
        adjImgData(jRow, :, yChannel, iFrame) = interp1(timeRaw, ...
            imgData(jRow, colsToUse, yChannel, iFrame), timeToInterpAt);

    end
end

end