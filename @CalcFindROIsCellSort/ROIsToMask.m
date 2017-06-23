function [maskFilters, maskSegments] = ROIsToMask(self)
%ROIsToMask - Create mask from ROI pixel data
%
%   [maskFilters, maskSegments] = ROIsToMask(OBJ) requires a
%   CalcFindROIsCellSort object and returns second stage of ROI
%   masks produced by the CellSort algorithm. The third stage is yet to be
%   exploited (i.e. segments).
%
%   See also CalcFindROIsCellSort

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
    maskFilters = sum(self.data.icFilters, 3);
    
    % Create stage 2 mask
    maskSegments = bwperim(any(self.data.icMask, 3));
       
end