function self = post_process_diameter(self, pixelWidth, pixelSize)

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
    
% Calculate the absolute diameter from the pixelWidth and pixel size
diameter = pixelSize*pixelWidth;

% Mask points with excessively high or low velocity (determined 
% by the number of standard deviations away from the median)
medDiameter = median(diameter);
stdDiameter = std(diameter);
maskSTD = (diameter >= medDiameter + self.config.thresholdSTD* ...
    stdDiameter) | (diameter <= medDiameter - ...
    self.config.thresholdSTD*stdDiameter);

% Assign the data to the correct object
self.data = self.data.add_processed_data(diameter);
self.data = self.data.add_mask_data(maskSTD);

end