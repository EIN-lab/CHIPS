function self = post_process_velocity(self, pixelSize, lineTime)

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
    
% Calculate the absolute velocity from the streak angle, pixel size, and 
% line time
velocity = (pixelSize / lineTime) .* tand(self.data.theta);

% Calculate the line density from the flux and velocity measurements
lineDensity = self.data.flux ./ abs(velocity);

% Calculate
nWin = numel(velocity);
for iWin = nWin:-1:1
    rbcSpacingD{iWin, 1} = abs(velocity(iWin)).*self.data.rbcSpacingT{iWin};
end

% Mask points with a low SNR
maskSNR = self.data.estSNR < self.config.thresholdSNR;

% Mask infinite points
maskInfOrNaN = isinf(velocity) | isnan(velocity);

% Mask points with excessively high or low velocity (determined by the 
% number of standard deviations away from the median), ignoring those 
% points with low SNR in these calcultions.
medVelocity = median(velocity(~maskSNR & ~maskInfOrNaN));
stdVelocity = std(velocity(~maskSNR & ~maskInfOrNaN));
maskSTD = (velocity >= medVelocity + self.config.thresholdSTD* ...
    stdVelocity) | (velocity <= medVelocity - ...
    self.config.thresholdSTD*stdVelocity);

% Assign the data to the correct structure
self.data = self.data.add_processed_data(velocity, lineDensity, ...
    rbcSpacingD);
self.data = self.data.add_mask_data(maskSNR, maskSTD);

end