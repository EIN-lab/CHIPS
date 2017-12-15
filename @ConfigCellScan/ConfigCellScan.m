classdef ConfigCellScan < ConfigMultiple
%ConfigCellScan - Class containing Config objects for CellScan
%
%   The ConfigCellScan class is an abstract superclass that is designed to
%   contain more than one Config object to simplify construction of
%   CellScan objects.  This ensures that a single Config object can be
%   passed to all CellScan objects, which is required for the grouping
%   classes (e.g. ImgGroup) to function correctly.  Refer to the
%   configNames and configClasses properties to determine the name of the
%   dynamic properties containing the Config objects, and the Config
%   classes they are allowed to contain.
%
%   ConfigCellScan is a subclass of matlab.mixin.Copyable, which is itself
%   a subclass of handle, meaning that ConfigCellScan objects are actually
%   references to the data contained in the object.  This allows certain
%   features that are only possible with handle objects, such as events and
%   certain GUI operations.  However, it is important to use the copy
%   method of matlab.mixin.Copyable to create a new, independent object;
%   otherwise changes to a ConfigCellScan object used in one place will
%   also lead to changes in another (perhaps undesired) place.
%
% ConfigCellScan public properties
%   configClasses   - The list of allowed classes for the config objects
%   configNames     - The (dynamic) property names of the Config objects
%
% ConfigCellScan public methods
%   ConfigCellScan	- ConfigCellScan class constructor
%   copy            - Copy MATLAB array of handle objects
%
%   See also ConfigMultiple, Config, matlab.mixin.Copyable, dynamicprops, 
%   CellScan

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
        %   See also ConfigCellScan.configNames
        configClasses = {...
            {'ConfigFindROIsDummy', 'ConfigFindROIsFLIKA', ...
            'ConfigFindROIsCellSort'}, ...
            {'ConfigMeasureROIsDummy', 'ConfigMeasureROIsZScore', ...
                'ConfigMeasureROIsMovingBL'}, ...
            {'ConfigDetectSigsDummy', 'ConfigDetectSigsClsfy', ...
            'ConfigDetectSigsCellSort'}};
        % MH 16/11/20170- Valid pairs might be a better solution
        
        %configNames - The (dynamic) property names of the Config objects
        %
        %   configNames is a cell array containing character arrays that
        %   correspond to the (dynamic) property names that will contain
        %   the required config objects
        %
        %   See also ConfigCellScan.configClasses
        configNames = {'configFindROIs', 'configMeasureROIs', ...
            'configDetectSigs'};
        
    end
    
    % ================================================================== %
    
    methods
        
        function ConfigCellScanObj = ConfigCellScan(varargin)
        %ConfigCellScan - ConfigCellScan class constructor
        %
        %   OBJ = ConfigCellScan() prompts for all required information and
        %   creates a ConfigCellScan object.
        %
        %   OBJ = ConfigCellScan(CONF_FIND, CONF_MEASURE, CONF_DETECT) uses
        %   the specified CONF_FIND and/or CONF_MEASURE and/or CONF_DETECT
        %   to construct the ConfigCellScan object. The arguments can be in
        %   any order, and if any of the input arguments are empty, the
        %   constructor will prompt for any required information.
        %   CONF_FIND must be an object which is a subclass of
        %   ConfigFindROIs.
        %   CONF_MEASURE must be an object which is a subclass of
        %   ConfigMeasureROIs.
        %   CONF_DETECT must be an object which is a subclass of
        %   ConfigDetectSigs
        %
        %   See also ConfigFindROIsFLIKA, ConfigFindROIsDummy,
        %   ConfigMeasureROIsClsfy, ConfigMeasureROIsDummy,
        %   ConfigDetectSigsDummy, ConfigDetectSigsClsfy, ConfigMultiple,
        %   CellScan
        
            % Call ConfigMultiple (i.e. parent class) constructor
            ConfigCellScanObj = ...
                ConfigCellScanObj@ConfigMultiple(varargin{:});
            
        end
                
    end
        
end
