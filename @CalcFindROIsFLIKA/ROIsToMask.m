function [pixelMask, groupMask, significantMask] = ROIsToMask(self)
%ROIsToMask - Create mask from ROI pixel data
%
%   [pixelMask, groupMask, significantMask] = ROIsToMask(OBJ) requires a
%   CalcFindROIsFLIKA object and returns three subsequent stages of ROI
%   masks produced by the FLIKA algorithm.
%
%   See also CalcFindROIsFLIKA

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

    % Create stage 1 mask
    pixelMask = sum(self.data.puffPixelMask, 3);
    
    % Create stage 2 mask
    groupMask = max(self.data.puffGroupMask, [], 3);
    groupMask = bwperim(groupMask);
    
    % Create stage 3 mask
    significantMask = max(self.data.roiMask, [], 3);
    significantMask = bwperim(significantMask);
    
end