function self = post_process_diameter(self, pixelSize)

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
    
    % Calculate the diameter in um from the pixel Area
    diameter = pixelSize.*sqrt((4*self.data.areaPixels)./pi);

    % Trace the vessel edges
    nFrames = length(diameter);
    vesselEdges = cell(size(diameter));
    conn = 8;   
    for iFrame = 1:nFrames
        vesselEdges(iFrame, 1) = bwboundaries(...
            self.data.vesselMask(:, :, iFrame), conn, 'noholes');
    end

    % Mask points with excessively high or low velocity (determined 
    % by the number of standard deviations away from the median)
    medDiameter = median(diameter);
    stdDiameter = std(diameter);
    maskSTD = (diameter >= medDiameter + self.config.thresholdSTD* ...
        stdDiameter) | (diameter <= medDiameter - ...
        self.config.thresholdSTD*stdDiameter);

    % Add the processed data and mask(s)
    self.data = self.data.add_processed_data(diameter, ...
        vesselEdges);
    self.data = self.data.add_mask_data(maskSTD);

end