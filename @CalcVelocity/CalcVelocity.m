classdef (Abstract) CalcVelocity < Calc
%CalcVelocity - Superclass for CalcVelocity classes
%
%   CalcVelocity is an abstract superclass that implements (or requires
%   implementation in its subclasses via abstract methods or properties)
%   most functionality related to CalcVelocity objects.  Typically there is
%   one concrete subclass of CalcVelocity for every calculation algorithm,
%   and it contains the algorithm-specific code that is needed for the
%   calculation.
%
%   CalcVelocity is a subclass of matlab.mixin.Copyable, which is itself a
%   subclass of handle, meaning that CalcVelocity objects are actually
%   references to the data contained in the object.  This allows certain
%   features that are only possible with handle objects, such as events and
%   certain GUI operations.  However, it is important to use the copy
%   method of matlab.mixin.Copyable to create a new, independent object;
%   otherwise changes to a CalcVelocity object used in one place will also
%   lead to changes in another (perhaps undesired) place.
%
% CalcVelocity public properties
%   config          - A scalar Config object
%   data            - A scalar DataVelocity object
%   nColsDetect     - The number of columns needed for plotting
%
% CalcVelocity public methods
%   CalcVelocity    - CalcVelocity class constructor
%   copy            - Copy MATLAB array of handle objects
%   plot            - Plot a figure
%   process         - Run the processing
%
%   See also CalcVelocityStreaks, CalcVelocityPIV, Calc, Config,
%   DataVelocity, DCScan, LineScanVel, FrameScan, StreakScan

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
    
    methods
        
        function CalcVelocityObj = CalcVelocity(varargin)
        %CalcVelocity - CalcVelocity class constructor
        %
        %   OBJ = CalcVelocity() prompts for all required information and
        %   creates a CalcVelocity object.
        %
        %   OBJ = CalcVelocity(CONFIG, DATA) uses the specified CONFIG
        %   and DATA objects to construct the CalcVelocity object. If any
        %   of the input arguments are empty, the constructor will prompt
        %   for any required information.  The input arguments must be
        %   objects which meet the requirements of the particular concrete
        %   subclass of CalcVelocity.
        %
        %   See also Config, DataVelocity
        
            % Parse arguments
            [configIn, dataIn] = utils.parse_opt_args({[], []}, varargin);
            
            % Call Calc (i.e. parent class) constructor
            CalcVelocityObj = CalcVelocityObj@Calc(configIn, dataIn);
            
        end
        
    end
    
    % ================================================================== %
    
    methods (Abstract, Access = protected)
        calc_velocity(self)
    end
    
    % ================================================================== %
    
end
