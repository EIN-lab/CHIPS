classdef (Abstract) ConfigMeasureROIs < Config
%ConfigMeasureROIs - Superclass for ConfigMeasureROIs classes
%
%   The ConfigMeasureROIs class is an abstract superclass that implements
%   (or requires implementation in its subclasses via abstract methods or
%   properties) all basic functionality related to the configuration
%   parameters used when measuring ROIs regions of interest (ROIs).
%   Typically there is one concrete subclass of ConfigMeasureROIs for every
%   supported method of ROI detection.
%
%   ConfigMeasureROIs is a subclass of matlab.mixin.Copyable, which is
%   itself a subclass of handle, meaning that ConfigMeasureROIs objects are
%   actually references to the data contained in the object.  This allows
%   certain features that are only possible with handle objects, such as
%   events and certain GUI operations.  However, it is important to use the
%   copy method of matlab.mixin.Copyable to create a new, independent
%   object; otherwise changes to a ConfigMeasureROIs object used in one
%   place will also lead to changes in another (perhaps undesired) place.
%
% ConfigMeasureROIs public properties
%   backgroundLevel - The nth percentile to be used as background [%]
%   propagateNaNs   - Whether to propagate NaNs through ROI traces
%
% ConfigMeasureROIs public methods
%   ConfigMeasureROIs - ConfigMeasureROIs class constructor
%   copy            - Copy MATLAB array of handle objects
%   create_calc     - Return a Calc object containing the Config object
%   get_dims        - Return the dimensions needed for the opt_config GUI
%   opt_config      - Optimise parameters using a GUI
%
% ConfigMeasureROIs static methods
%   from_preset     - Create a ConfigMeasureROIs object from a preset
%
% ConfigMeasureROIs public events:
%   ProcessNow      - Notifies listeners to process an object
%
%   See also ConfigMeasureROIsDummy, ConfigMeasureROIsMovingBL,
%   ConfigMeasureROIsZScore, Config, ConfigCellScan, CalcMeasureROIs,
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
    
    properties
        
        %backgroundLevel - The nth percentile to be used as background [%]
        %
        %   An integer number specifying the nth percentile to be used to
        %   locate background in the baseline average picture.
        %   [default = 1%]
        %
        %   See also pctile, CalcFindROIsFLIKA
        backgroundLevel = 1; %percentile
        
        %propagateNaNs - Whether to propagate NaNs through ROI traces
        %
        %   A logical scalar that determines whether a NaN (or Inf) values
        %   from a single pixel propagate through the entire ROI. 
        %   [default = false]
        %
        %   See also CellScan
        propagateNaNs = false;
        
    end
    
    % ================================================================== %
    
    methods
        
        function cmrObj = ConfigMeasureROIs(varargin)
        %ConfigMeasureROIs - ConfigMeasureROIs class constructor
        %
        %   OBJ = ConfigMeasureROIs() creates a ConfigMeasureROIs object
        %   OBJ with default values for all properties.
        %
        %   OBJ = ConfigMeasureROIs(..., 'property', value, ...) or
        %   OBJ = ConfigMeasureROIs(..., propStruct, ...) 
        %
        %   This syntax specifies values for the properties, either in the
        %   form of attribute-value pairs, or structures (or objects) where
        %   the field (property) names correspond to properties in the
        %   ConfigMeasureROIs class. The argument parsing is done by the
        %   utility function parsepropval (link below), so please consult
        %   the documentation for this function for more details.
        %
        %   See also utils.parsepropval, ConfigMeasureROIs.from_preset,
        %   ConfigMeasureROIsDummy, ConfigMeasureROIsMovingBL,
        %   ConfigMeasureROIsZScore, Config, ConfigCellScan,
        %   CalcMeasureROIs, CellScan
                       
            % Call Config (i.e. parent class) constructor
            cmrObj = cmrObj@Config(varargin{:});
            
        end
        
        % -------------------------------------------------------------- %
        
        function self = set.backgroundLevel(self, val)
            
            % Check that the value is a positive, real, finite, scalar
            % integer
            utils.checks.greater_than(val, 0, true, 'backgroundLevel')
            utils.checks.finite(val, 'backgroundLevel')
            utils.checks.scalar(val, 'backgroundLevel')
            
            % Assign value
            self.backgroundLevel = val;
        end
        
        % -------------------------------------------------------------- %
        
        function self = set.propagateNaNs(self, val)
            
            % Check that the value is a scalar that is convertible to a
            % logical value
            utils.checks.scalar_logical_able(val, 'propagateNaNs')
            
            % Assign value
            self.propagateNaNs = logical(val);
            
        end
        
    end
    
    % ================================================================== %
    
end
