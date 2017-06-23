classdef ConfigFrameScan < ConfigMultiple
%ConfigFrameScan - Class containing Config objects for FrameScan
%
%   The ConfigFrameScan class is an abstract superclass that is designed to
%   contain more than one Config object to simplify construction of
%   FrameScan objects.  This ensures that a single Config object can be
%   passed to all FrameScan objects, which is required for the grouping
%   classes (e.g. ImgGroup) to function correctly.  Refer to the
%   configNames and configClasses properties to determine the name of the
%   dynamic properties containing the Config objects, and the Config
%   classes they are allowed to contain.
%
%   ConfigFrameScan is a subclass of matlab.mixin.Copyable, which is itself
%   a subclass of handle, meaning that ConfigFrameScan objects are actually
%   references to the data contained in the object.  This allows certain
%   features that are only possible with handle objects, such as events and
%   certain GUI operations.  However, it is important to use the copy
%   method of matlab.mixin.Copyable to create a new, independent object;
%   otherwise changes to a ConfigFrameScan object used in one place will
%   also lead to changes in another (perhaps undesired) place.
%
% ConfigFrameScan public properties
%   configClasses   - The list of allowed classes for the config objects
%   configNames     - The (dynamic) property names of the Config objects
%
% ConfigFrameScan public methods
%   ConfigFrameScan	- ConfigFrameScan class constructor
%   copy            - Copy MATLAB array of handle objects
%
%   See also ConfigMultiple, Config, matlab.mixin.Copyable, dynamicprops, 
%   FrameScan

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
    
    properties (Constant)
        
        %configClasses - The list of allowed classes for the config objects
        %
        %   configClasses is a cell array containing cell arrays of
        %   character arrays that correspond to the allowed class names for
        %   the corresponding configNames
        %
        %   See also ConfigFrameScan.configNames
        configClasses = {...
            {'ConfigVelocityRadon', 'ConfigVelocityLSPIV'}, ...
            {'ConfigDiameterFWHM'}};
        
        %configNames - The (dynamic) property names of the Config objects
        %
        %   configNames is a cell array containing character arrays that
        %   correspond to the (dynamic) property names that will contain
        %   the required config objects
        %
        %   See also ConfigFrameScan.configClasses
        configNames = {'configVelocity', 'configDiameter'};
        
    end
    
    % ================================================================== %
    
    methods
        
        function ConfigFrameScanObj = ConfigFrameScan(varargin)
        %ConfigFrameScan - ConfigFrameScan class constructor
        %
        %   OBJ = ConfigFrameScan() prompts for all required information
        %   and creates a ConfigFrameScan object.
        %
        %   OBJ = ConfigFrameScan(CONFIG_VEL, CONFIG_DIAM) or
        %   OBJ = ConfigFrameScan(CONFIG_DIAM, CONFIG_VEL)
        %   uses the specified CONFIG_VEL and/or CONFIG_DIAM to construct
        %   the ConfigFrameScan object. If any of the input arguments are
        %   empty, the constructor will prompt for any required
        %   information.
        %   CONFIG_VEL must be an object which is a subclass of
        %   ConfigVelocityStreaks.
        %   CONFIG_DIAM must be an object which is a subclass of
        %   ConfigDiameterLong.
        %
        %   See also ConfigVelocityRadon, ConfigVelocityLSPIV,
        %   ConfigDiameterFWHM, ConfigMultiple, FrameScan
        
        % Call ConfigMultiple (i.e. parent class) constructor
            ConfigFrameScanObj = ...
                ConfigFrameScanObj@ConfigMultiple(varargin{:});
            
        end
        
    end
    
    % ================================================================== %
    
end

