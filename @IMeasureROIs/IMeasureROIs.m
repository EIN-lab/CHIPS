classdef (HandleCompatible) IMeasureROIs 
%IMeasureROIs - Interface for classes that measure ROI traces
%
%   The IMeasureROIs class is an abstract superclass that implements (or
%   requires implementation in its subclasses via abstract methods or
%   properties) functionality related to measuring the ROI masks (or
%   filters) and returning the traces.
%
% IMeasureROIs public methods:
%   measure_ROIs    - Measure the ROI masks and return the traces
%
%   See also CalcFindROIs, CalcMeasureROIs

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
        %measure_ROIs - Measure the ROI masks and return the traces
        [traces, tracesExist] = measure_ROIs(self, objPI)
    end
    
    % ================================================================== %
    
end
