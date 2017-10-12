function [flux, peakLocs, imgSum, linearDensity, rbcSpacingT, maskRBC] = ...
    calc_flux(self, radonTrans, theta, idxMaxVarTheta, isDarkStreaks, ...
        pixelSize, pixelTime, lineTime, nLines, isOldToolbox, doPlotWindow)

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
    
% Take an projection along theta direction
imgSum = radonTrans(:, idxMaxVarTheta);

% Include only the peaks that we're interested in
if isDarkStreaks
    % Dark streaks (i.e. values below 0) in the case of labelled plasma
    imgSum = -imgSum;
end

% Adjust the threshold to account for the angle that we're summing along.
thresholdDist = cosd(abs(theta)) * self.config.minPeakDist/pixelSize;

% Work out a rough estimate of peak prominence
thresholdProm = self.config.thresholdProm*(max(imgSum) - min(imgSum));

% Find the peak locations, excluding ones that are too close together
if ~isOldToolbox
	findpeakArgs = {'MinPeakDistance', thresholdDist, ...
        'MinPeakProminence', thresholdProm, ...
        'MinPeakWidth', 0.5*thresholdDist};
    [~, peakLocs, peakWidthsRaw] = findpeaks(imgSum, findpeakArgs{:});
else
    findpeakArgs = {'MinPeakDistance', max(floor(thresholdDist), 1), ...
        'MinPeakHeight', thresholdProm};
    [~, peakLocs] = findpeaks(imgSum, findpeakArgs{:});
    peakWidthsRaw = nan(size(peakLocs));
end
peakLocs = peakLocs(:);

% Prepare a mask showing the peak extents
maskRBC = [];
if doPlotWindow
    idxLess = peakLocs - 0.5*peakWidthsRaw;
    idxMore = peakLocs + 0.5*peakWidthsRaw;
    idxAll = repmat(1:numel(imgSum), numel(peakLocs), 1);
    maskMore = bsxfun(@gt, idxAll, idxLess);
    maskLess = bsxfun(@lt, idxAll, idxMore);
    maskRBC = any(maskMore & maskLess, 1);
end

% Calculate the flux in units of cells per second
windowTime = lineTime*nLines;
flux = length(peakLocs) / (windowTime * 1E-3);

% Calculate the linear density in terms of fractional time
peakWidthsRawAdj = peakWidthsRaw./cosd(theta); % pixels x
dt = peakWidthsRawAdj .* (pixelTime*10^-3); % ms
velocity = (pixelSize / lineTime) .* tand(theta); % um/ms = mm/s
peakWidthsAdj = peakWidthsRawAdj - ((velocity.*dt)./pixelSize); % pixels x
peakWidths = peakWidthsAdj.*cosd(theta); % pixels x' (rotated)
linearDensity = sum(peakWidths) / ...
    (find(imgSum, 1, 'last') - find(imgSum, 1, 'first') + 1); % mm/mm

% Calculate the spacing in units of ms
rbcSpacingT = (lineTime * sind(abs(theta)) .* ...
    (peakLocs(2:end) - peakLocs(1:end-1)))';

end
