classdef ConfigFindROIsAuto < Config
%ConfigFindROIsAuto - Parameters for automatic ROI identification
%
%   The ConfigFindROIsAuto class is an abstract configuration class that
%   contains the general parameters necessary for region of interest (ROI)
%   identification.  Further parameters are found in the concrete
%   subclasses of ConfigFindROIsAuto
%
%   ConfigFindROIsAuto is a subclass of matlab.mixin.Copyable, which is
%   itself a subclass of handle, meaning that ConfigFindROIsAuto objects
%   are actually references to the data contained in the object.  This
%   allows certain features that are only possible with handle objects,
%   such as events and certain GUI operations.  However, it is important to
%   use the copy method of matlab.mixin.Copyable to create a new,
%   independent object; otherwise changes to a ConfigFindROIsAuto object
%   used in one place will also lead to changes in another (perhaps
%   undesired) place.
%
% ConfigFindROIsAuto public properties
%   discardBorderROIs - Whether to ignore ROIs touching the image border
%   inpaintIters    - The number of iterations to use when inpainting
%   maxROIArea      - The largest expected signal area [µm^2]
%   minROIArea      - The smallest expected signal area [µm^2]
%   
% ConfigFindROIsAuto public methods
%   ConfigFindROIsAuto - ConfigFindROIsAuto class constructor
%   copy            - Copy MATLAB array of handle objects
%   create_calc     - Return a Calc object containing the Config object
%   get_dims        - Return the dimensions needed for the opt_config GUI
%   opt_config      - Optimise parameters using a GUI
%
% ConfigFindROIsAuto static methods
%   from_preset     - Create a config object from a preset
%
% ConfigFindROIsAuto public events:
%   ProcessNow      - Notifies listeners to process an object
%
%   See also ConfigFindROIsFLIKA, ConfigFindROIsCellSort, ConfigFindROIs,
%   Config, ConfigCellScan, CalcFindROIs, CellScan

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
        
        % Mask treatment parameters
        % -------------------------------------------------------------- %
        
        %inpaintIters - The number of iterations to use when inpainting
        %
        %   An iterative method is used when inpainting (filling in) NaN
        %   and Inf values. The parameter inpaintIters is a positive,
        %   scalar integer specifying the number of iterations to perform.
        %   [default = 5]
        %
        %   See also utils.inpaintn
        inpaintIters = 5;
        
        %discardBorderROIs - Whether to ignore ROIs touching the image border
        %
        %   A boolean flag to specify, whether or not to discard ROIs that
        %   touch the border, as the signals in those ROIs might not be
        %   recorded completely. [default = false]
        %
        %   See also CalcFindROIsFLIKA
        discardBorderROIs = false;
        
        %maxROIArea - The largest expected signal area [µm^2]
        %
        %   The largest expected signal area in µm^2. Regions of interest
        %   (ROIs) that are larger than this threshold will be discarded.
        %   [default = 2500µm^2]
        %
        %   See also ConfigFindROIsAuto.maxROIArea
        maxROIArea = 2500;
        
        %minROIArea - The smallest expected signal area [µm^2]
        %
        %   The smallest expected signal area in µm^2. Regions of interest
        %   (ROIs) that are smaller than this threshold will be discarded.
        %   [default = 4µm^2]
        %
        %   See also ConfigFindROIsAuto.maxROIArea
        minROIArea = 4;
        
    end
    
    % ================================================================== %
    
    methods
        
        function ConfigFindROIsAutoObj = ConfigFindROIsAuto(varargin)
        %ConfigFindROIsAuto - ConfigFindROIsAuto class constructor
        %
        %   OBJ = ConfigFindROIsAuto() creates a ConfigFindROIsAuto
        %   object OBJ with default values for all properties.
        %
        %   OBJ = ConfigFindROIsAuto(..., 'property', value, ...) or
        %   OBJ = ConfigFindROIsAuto(..., propStruct, ...) 
        %
        %   This syntax specifies values for the properties, either in the
        %   form of attribute-value pairs, or structures (or objects) where
        %   the field (property) names correspond to properties in the
        %   ConfigFindROIsAuto class. The argument parsing is done by the
        %   utility function parsepropval (link below), so please consult
        %   the documentation for this function for further details.
        %
        %   See also utils.parsepropval, ConfigFindROIs, Config,
        %   ConfigCellScan
            
            % Call Config (i.e. parent class) constructor
            ConfigFindROIsAutoObj = ConfigFindROIsAutoObj@Config(...
                varargin{:});
            
        end
        
        % -------------------------------------------------------------- %
        
        function self = set.discardBorderROIs(self, val)
            
            % Check value can be converted to logical
            utils.checks.scalar_logical_able(val, 'discardBorderROIs')
            
            % Convert to logical and assign value
            self.discardBorderROIs = logical(val);
        end
        
        % -------------------------------------------------------------- %
        
        function self = set.inpaintIters(self, val)
            
            % Check that the value is a positive, real, finite, scalar
            % integer
            utils.checks.prfsi(val, 'inpaintIters')
            
            % Assign value
            self.inpaintIters = val;
        end
        
        % -------------------------------------------------------------- %
        
        function self = set.maxROIArea(self, val)
            
            % Check that the value is a positive, real, finite, scalar
            % number
            utils.checks.prfs(val, 'maxROIArea')
            
            % Assign value
            self.maxROIArea = val;
        end
        
        % -------------------------------------------------------------- %
        
        function self = set.minROIArea(self, val)
            
            % Check that the value is a positive, real, finite, scalar
            % number
            utils.checks.prfs(val, 'minROIArea')
            
            % Assign value
            self.minROIArea = val;
        end
        
    end
    
    % ================================================================== %
    
end
