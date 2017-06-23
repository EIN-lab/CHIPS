classdef ConfigFindROIsDummy < Config
%ConfigFindROIsDummy - Parameters for basic ROI identification
%
%   The ConfigFindROIsDummy class is a configuration class that contains
%   the parameters necessary for dummy ROI finding.
%
%   ConfigFindROIsDummy is a subclass of matlab.mixin.Copyable, which is
%   itself a subclass of handle, meaning that ConfigFindROIsDummy objects
%   are actually references to the data contained in the object.  This
%   allows certain features that are only possible with handle objects,
%   such as events and certain GUI operations.  However, it is important to
%   use the copy method of matlab.mixin.Copyable to create a new,
%   independent object; otherwise changes to a ConfigFindROIsDummy object
%   used in one place will also lead to changes in another (perhaps
%   undesired) place.
%
% ConfigFindROIsDummy public properties
%   roiMask         - A logical ROI mask
%   roiNames        - A cell vector of ROI names
%
% ConfigFindROIsDummy public methods
%   ConfigFindROIsDummy - ConfigFindROIsDummy class constructor
%   copy            - Copy MATLAB array of handle objects
%   create_calc     - Return a Calc object containing the Config object
%   get_dims        - Return the dimensions needed for the opt_config GUI
%   opt_config      - Optimise parameters using a GUI
%
% ConfigFindROIsDummy static methods
%   from_Image      - Load ROIs from ImageJ RoiSet.zip
%   from_mask       - Load ROIs from a mask or binary image
%   from_preset     - Create a config object from a preset
%
% ConfigFindROIsDummy public events:
%   ProcessNow      - Notifies listeners to process an object
%
%   See also ConfigFindROIsFLIKA, Config, ConfigCellScan,
%   CalcFindROIsDummy, CellScan

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
        
        %roiMask - A logical ROI mask
        %
        %   A logical mask that represents the regions of interest. roiMask
        %   defaults to a scalar logical which represents a simple whole
        %   frame analysis. [default = true]
        %
        %   See also ConfigFindROIsDummy.from_mask,
        %   ConfigFindROIsDummy.from_ImageJ
        roiMask = true;
        
        %roiNames - A cell vector of ROI names
        %
        %   A cell vector containing ROI names. roiNames are empty by
        %   default and get assigned during measurement, except for ImageJ
        %   ROIs, where the user can already specify names while selecting
        %   the regions in ImageJ. [default = {''}]
        %
        %   See also ConfigFindROIsDummy.from_ImageJ
        roiNames = {''};
    end
    
    % ------------------------------------------------------------------ %
    
    properties (Constant, Access = protected)
        
        %classCalc - Constant, protected property containing the name of
        %   the associated Calc class
        classCalc = 'CalcFindROIsDummy';
        
        optList = {};
        
    end
    
    % ================================================================== %
    
    methods
        
        function cfrdObj = ConfigFindROIsDummy(varargin)
        %ConfigFindROIsDummy - ConfigFindROIsDummy class constructor
        %
        %   OBJ = ConfigFindROIsDummy() creates a ConfigFindROIsDummy
        %   object OBJ with default values for all properties.
        %
        %   OBJ = ConfigFindROIsDummy(..., 'property', value, ...) or
        %   OBJ = ConfigFindROIsDummy(..., propStruct, ...) 
        %
        %   This syntax specifies values for the properties, either in the
        %   form of attribute-value pairs, or structures (or objects) where
        %   the field (property) names correspond to properties in the
        %   ConfigFindROIsDummy class. The argument parsing is done by
        %   the utility function parsepropval (link below), so please
        %   consult the documentation for this function for more details.
        %
        %   See also utils.parsepropval, ConfigFindROIsDummy.from_preset,
        %   ConfigFindROIsFLIKA, Config, ConfigCellScan, CalcFindROIsDummy,
        %   CellScan
        
            % Call Config (i.e. parent class) constructor
            cfrdObj = cfrdObj@Config(varargin{:});
            
        end
        
        % -------------------------------------------------------------- %
        
        function self = set.roiMask(self, val)
            
            % Check property can be converted to a logical
            utils.checks.logical_able(val, 'roiMask')
            
            % Convert property to logical and assign
            self.roiMask = logical(val);
            
        end
        
    end
    
    % ================================================================== %
    
    methods (Static)
        
        cfrdObj = from_mask(varargin)
        
        % -------------------------------------------------------------- %
        
        cfrdObj = from_ImageJ(varargin)
        
    end
    
    % ================================================================== %
    
end
