classdef (HandleCompatible) ICalcVelocityStreaks 
%ICalcVelocityStreaks - Interface for classes that calculate velocity
%
%   The ICalcVelocityStreaks class is an abstract superclass that
%   implements (or requires implementation in its subclasses via abstract
%   methods or properties) functionality related to calculating velocity
%   using a streak scan images.
%
% ICalcVelocityStreaks public methods:
%   split_into_windows  - Split the raw image data into windows
%
%   See also LineScanVel, FrameScan, CalcVelocityStreaks

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

    % ================================================================== %
    
    methods (Abstract)
        %split_into_windows  - Split the raw image data into windows
        [windows, time, yPosition] = split_into_windows(self, ...
                windowTime, nOverlap);
    end
    
    % ================================================================== %
    
end
