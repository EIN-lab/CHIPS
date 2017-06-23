function mask = choose_mask_circle(self, imgType)
%choose_mask_circle - Protected class method to choose an individual
%   circular mask

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

roiFun = @() imellipse('PositionConstraintFcn', ...
    @(x) [x(1) x(2) min(x(3),x(4))*[1 1]]);
roiType = 'circle';
mask = self.choose_mask_imroi(imgType, roiFun, roiType);

end