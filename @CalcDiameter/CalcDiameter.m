classdef (Abstract) CalcDiameter < Calc
%CalcDiameter - Superclass for CalcDiameter classes
%
%   CalcDiameter is an abstract superclass that implements (or requires
%   implementation in its subclasses via abstract methods or properties)
%   most functionality related to CalcDiameter objects.  Typically there is
%   one concrete subclass of CalcDiameter for every calculation algorithm,
%   and it contains the algorithm-specific code that is needed for the
%   calculation.
%
%   CalcDiameter is a subclass of matlab.mixin.Copyable, which is itself a
%   subclass of handle, meaning that CalcDiameter objects are actually
%   references to the data contained in the object.  This allows certain
%   features that are only possible with handle objects, such as events and
%   certain GUI operations.  However, it is important to use the copy
%   method of matlab.mixin.Copyable to create a new, independent object;
%   otherwise changes to a CalcDiameter object used in one place will also
%   lead to changes in another (perhaps undesired) place.
%
% CalcDiameter public properties
%   config          - A scalar Config object
%   data            - A scalar DataDiameter object
%
% CalcDiameter public methods
%   CalcDiameter    - CalcDiameter class constructor
%   copy            - Copy MATLAB array of handle objects
%   plot            - Plot a figure
%   process         - Run the processing
%
%   See also CalcDiameterLong, CalcDiameterXSect, CalcDiameterFWHM,
%   CalcDiameterTiRS, Calc, Config, DataDiameter, LineScanDiam, FrameScan,
%   XSectScan

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
        
        function CalcDiameterObj = CalcDiameter(varargin)
        %CalcDiameter - CalcDiameter class constructor
        %
        %   OBJ = CalcDiameter() prompts for all required information and
        %   creates a CalcDiameter object.
        %
        %   OBJ = CalcDiameter(CONFIG, DATA) uses the specified CONFIG
        %   and DATA objects to construct the CalcDiameter object. If any
        %   of the input arguments are empty, the constructor will prompt
        %   for any required information.  The input arguments must be
        %   objects which meet the requirements of the particular concrete
        %   subclass of CalcDiameter.
        %
        %   See also Config, DataDiameter
        
            % Parse arguments
            [configIn, dataIn] = utils.parse_opt_args({[], []}, varargin);
            
            % Call Calc (i.e. parent class) constructor
            CalcDiameterObj = CalcDiameterObj@Calc(configIn, dataIn);
            
        end
        
    end
    
    % ================================================================== %
    
    methods (Abstract, Access = protected)
        calc_diameter(self)
    end
    
    % ================================================================== %
    
end
