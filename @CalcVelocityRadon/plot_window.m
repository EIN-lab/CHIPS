function plot_window(imgSum, peakLocs, xp, window, theta, maskRBC, ...
    pixelSize, windowTime, varargin)

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
    
% Parse extra inputs
[doPlotScale] = utils.parse_opt_args({true}, varargin);

% Trim the ends off the imgSum and xp
maskImgSum = imgSum == 0;
idxStart = find(~maskImgSum, 1, 'first');
idxEnd =  find(~maskImgSum, 1, 'last');
imgSum = imgSum(idxStart:idxEnd);
xp = xp(idxStart:idxEnd);
maskRBC = maskRBC(idxStart:idxEnd);

% Adjust the peakLocs since we've trimmed the imgSum and xp
peakLocs = peakLocs - idxStart + 1;

% Scale the imgSum etc so it fit's nicely on the window
nPoints = numel(maskRBC);
scaleFactor = 0.3*size(window, 1);
offsetY = 0.5*size(window, 1);
offsetX = 0.5*size(window, 2);
maskPlasma = ones(1, nPoints);
maskPlasma(maskRBC) = NaN;
imgSumScaledX = xp + offsetX;
imgSumScaledY = -scaleFactor*imgSum/max(imgSum) + offsetY;

% Setup the rotation
centreRotation = [0.5*fliplr(size(window)) 0];
axisRotation = [0 0 1];

% Setup the scale
if doPlotScale
    
    scaleLength = 1;
    lineTime = windowTime/size(window, 1); % ms
    scaleTime = 25;

    scaleLengthPixels = scaleLength/pixelSize;
    scaleTimePixels = scaleTime/lineTime;
    cornerLoc = [5, size(window, 1)-5];

end

% Plot the window itself
imagesc(window), colormap('gray')
hold on

% Plot and rotate the traces
hImgSum = plot(imgSumScaledX, imgSumScaledY, 'm-', 'LineWidth', 2);
hAxis = plot(imgSumScaledX, offsetY*maskPlasma, 'c-', 'LineWidth', 2);
hPeaks = plot(imgSumScaledX(peakLocs), imgSumScaledY(peakLocs), 'c+', ...
    'MarkerSize', 10);
nPeaks = numel(peakLocs);
for iStreak = nPeaks:-1:1
    hStreaks(iStreak) = plot(imgSumScaledX(peakLocs(iStreak))*ones(2,1), ...
        offsetY*[0.5, 1.5], 'c:', 'LineWidth', 1);
end
rotate(hImgSum, axisRotation, -theta, centreRotation)
rotate(hAxis, axisRotation, -theta, centreRotation)
rotate(hPeaks, axisRotation, -theta, centreRotation)
if nPeaks > 0
    rotate(hStreaks, axisRotation, -theta, centreRotation)
end

% Plot the scale
if doPlotScale
    plot(cornerLoc(1) + [0 scaleLengthPixels], cornerLoc(2)*ones(2,1), ...
        'w-', 'LineWidth', 4) % horizontal scale bar
    plot(cornerLoc(1)*ones(2,1), cornerLoc(2)+[0 -scaleTimePixels], ...
        'w-', 'LineWidth', 4)
end

axis image, axis off
hold off

end