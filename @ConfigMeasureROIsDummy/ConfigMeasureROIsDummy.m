classdef ConfigMeasureROIsDummy < ConfigMeasureROIs
%ConfigMeasureROIsDummy - Parameters for basic measuring of signals
%
%   The ConfigMeasureROIsDummy class is a dummy configuration class that is
%   used when only taking basic measurements from ROIs.
%
%   ConfigMeasureROIsDummy is a subclass of matlab.mixin.Copyable, which is
%   itself a subclass of handle, meaning that ConfigMeasureROIsDummy
%   objects are actually references to the data contained in the object.
%   This allows certain features that are only possible with handle
%   objects, such as events and certain GUI operations.  However, it is
%   important to use the copy method of matlab.mixin.Copyable to create a
%   new, independent object; otherwise changes to a ConfigMeasureROIsDummy
%   object used in one place will also lead to changes in another (perhaps
%   undesired) place.
%
% ConfigMeasureROIsDummy public properties
%   backgroundLevel - The nth percentile to be used as background [%]
%   baselineFrames  - The frames to be used as baseline
%   propagateNaNs   - Whether to propagate NaNs through ROI traces
%
% ConfigMeasureROIsDummy public methods
%   ConfigMeasureROIsDummy - ConfigMeasureROIsDummy class constructor
%   copy            - Copy MATLAB array of handle objects
%   create_calc     - Return a Calc object containing the Config object
%   get_dims        - Return the dimensions needed for the opt_config GUI
%   opt_config      - Optimise parameters using a GUI
%
% ConfigMeasureROIsDummy static methods
%   from_preset     - Create a ConfigMeasureROIsDummy object from a preset
%
% ConfigMeasureROIsDummy public events:
%   ProcessNow      - Notifies listeners to process an object
%
%   See also ConfigMeasureROIsMovingBL, ConfigMeasureROIsZScore,
%   ConfigMeasureROIs, Config, ConfigCellScan, CalcMeasureROIsDummy,
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
        
        %baselineFrames - The frames to be used as baseline
        %
        %   The indices of the frames to be used as the baseline period. If
        %   a scalar, 1:baselineFrames will be used. The baseline period
        %   will be used for calculation of change in fluorescence (dF/F).
        %   [default = 1:30]
        %
        %   See also CellScan
        baselineFrames = 1:30;
        
    end
    
    % ------------------------------------------------------------------ %
    
    properties (Constant, Access = protected)
        
        %classCalc - Constant, protected property containing the name of
        %   the associated Calc class
        classCalc = 'CalcMeasureROIsDummy';
        
        optList = {'General', {'baselineFrames'}};
        
    end
    
    % ================================================================== %
    
    methods
        
        function ConfigMeasureROIsObj = ConfigMeasureROIsDummy(varargin)
        %ConfigMeasureROIsDummy - ConfigMeasureROIsDummy class constructor
        %
        %   OBJ = ConfigMeasureROIsDummy() creates a ConfigMeasureROIsDummy
        %   object OBJ with default values for all properties.
        %
        %   OBJ = ConfigMeasureROIsDummy(..., 'property', value, ...) or
        %   OBJ = ConfigMeasureROIsDummy(..., propStruct, ...) 
        %
        %   This syntax specifies values for the properties, either in the
        %   form of attribute-value pairs, or structures (or objects) where
        %   the field (property) names correspond to properties in the
        %   ConfigMeasureROIsDummy class. The argument parsing is done by
        %   the utility function parsepropval (link below), so please
        %   consult the documentation for this function for more details.
        %
        %   See also utils.parsepropval,
        %   ConfigMeasureROIsDummy.from_preset, ConfigMeasureROIsMovingBL,
        %   ConfigMeasureROIsZScore, ConfigMeasureROIs, Config,
        %   ConfigCellScan, CalcMeasureROIsDummy, CellScan
                       
            % Call Config (i.e. parent class) constructor
            ConfigMeasureROIsObj = ...
                ConfigMeasureROIsObj@ConfigMeasureROIs(varargin{:});
            
        end
        
        % -------------------------------------------------------------- %
        
        function self = set.baselineFrames(self, val)
            
            % Convert to a range of frames
            if isscalar(val)
                val = 1:val;
            end
                
            % Check that the value is a single row integer
            utils.checks.integer(val, 'baselineFrames')
            utils.checks.vector(val, 'baselineFrames')
            utils.checks.positive(val, 'baselineFrames')
            
            % Assign value
            self.baselineFrames = val(:);
        end
        
    end
    
    % ================================================================== %
    
end
