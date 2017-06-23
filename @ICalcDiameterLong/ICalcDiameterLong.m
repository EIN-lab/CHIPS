classdef (HandleCompatible) ICalcDiameterLong 
%ICalcDiameterLong - Interface for classes that calculate diameter
%
%   The ICalcDiameterLong class is an abstract superclass that implements
%   (or requires implementation in its subclasses via abstract methods or
%   properties) functionality related to calculating diameter using a long
%   section of the vessel.
%
% ICalcDiameterLong public methods:
%   get_diamProfile - Get the profile needed to calculate diameter
%
%   See also LineScanDiam, FrameScan, CalcDiameterLong

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
    
    properties (Abstract, Dependent, Access = protected)
        lineRate
    end
    
    % ================================================================== %
    
    methods (Abstract)
        %get_diamProfile - Get the profile needed to calculate diameter
        [diamProfile, lineRate] = get_diamProfile(self)
    end
    
    % ================================================================== %
    
end
