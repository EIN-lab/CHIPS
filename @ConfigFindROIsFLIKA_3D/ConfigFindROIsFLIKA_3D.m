classdef ConfigFindROIsFLIKA_3D < ConfigFindROIsFLIKA
%ConfigFindROIsFLIKA_3D - Parameters for 3D FLIKA-based ROI identification
%
%   The ConfigFindROIsFLIKA_3D class is a configuration class that contains
%   the parameters necessary for two-dimensional FLIKA-based region of
%   interest (ROI) identification. For further information
%   about FLIKA, please refer to <a href="matlab:web('http://dx.doi.org/10.1016/j.ceca.2014.06.003', '-browser')">Ellefsen et al. (2014)</a>, Cell Calcium
%   56(3):147-156.
%
%   Note: The run time of the FLIKA algorithm is strongly influenced by the
%   number of image frames that occur in the time maxRiseTime -
%   minRiseTime.  If performance is slow, it is recommended to reduce the
%   difference between these two parameter values.
%
%   ConfigFindROIsFLIKA_3D is a subclass of matlab.mixin.Copyable, which
%   is itself a subclass of handle, meaning that ConfigFindROIsFLIKA_3D
%   objects are actually references to the data contained in the object.
%   This allows certain features that are only possible with handle
%   objects, such as events and certain GUI operations.  However, it is
%   important to use the copy method of matlab.mixin.Copyable to create a
%   new, independent object; otherwise changes to a
%   ConfigFindROIsFLIKA_3D object used in one place will also lead to
%   changes in another (perhaps undesired) place.
%
% ConfigFindROIsFLIKA_3D public properties
%   backgroundLevel - The nth percentile to be used as background [%]
%   baselineFrames  - The frames to be used as baseline
%   dilateT         - The temporal distance for dilating active pixels [s]
%   dilateXY        - The spatial radius for dilating active pixels [µm]
%   discardBorderROIs - Whether to ignore ROIs touching the image border
%   erodeT          - The temporal distance for eroding active pixels [s]
%   erodeXY         - The spatial radius for eroding active pixels [µm]
%   freqPassBand    - The high-pass filter pass band frequency [Hz]
%   inpaintIters    - The number of iterations to use when inpainting
%   maxRiseTime     - The longest time the signal takes to peak [s]
%   maxROIArea      - The largest expected signal area [µm^2]
%   minRiseTime     - The shortest time the signal takes to peak [s]
%   minROIArea      - The smallest expected signal area [µm^2]
%   minROITime      - The shortest expected signal duration [s]
%   sigmaT          - The width of the temporal moving average filter [s]
%   sigmaXY         - The width of the spatial gaussian filter [µm]
%   thresholdPuff   - The threshold used to determine puffing pixels
%   
% ConfigFindROIsFLIKA_3D public methods
%   ConfigFindROIsFLIKA_3D - ConfigFindROIsFLIKA_3D class constructor
%   copy            - Copy MATLAB array of handle objects
%   create_calc     - Return a Calc object containing the Config object
%   get_dims        - Return the dimensions needed for the opt_config GUI
%   opt_config      - Optimise parameters using a GUI
%
% ConfigFindROIsFLIKA_3D static methods
%   from_preset     - Create a config object from a preset
%
% ConfigFindROIsFLIKA_3D public events:
%   ProcessNow      - Notifies listeners to process an object
%
%   See also ConfigFindROIsFLIKA_2D, ConfigFindROIsFLIKA_2p5D,
%   ConfigFindROIsFLIKA, ConfigFindROIsDummy, Config, ConfigCellScan,
%   CalcFindROIsFLIKA_3D, CellScan

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
                        
        %minROITime - The shortest expected signal duration [s]
        %
        %   The shortest expected signal duration in seconds. Signals
        %   shorter than this threshold will be discarded. 
        %   [default = 1s]
        %
        %   See also CalcFindROIsFLIKA
        minROITime = 1;
        
    end
    
    % ------------------------------------------------------------------ %
    
    properties (Constant, Access = protected)
        
        %classCalc - Constant, protected property containing the name of
        %   the associated Calc class
        classCalc = 'CalcFindROIsFLIKA_3D';
        
        optList = {'Filtering', {'freqPassBand', 'sigmaXY', 'sigmaT'}; ...
            'Erosion/Dilation', {'dilateXY', 'dilateT', ...
                'erodeXY', 'erodeT'}; ...
            'Selection', {'thresholdPuff', 'minRiseTime', ...
                'maxRiseTime', 'minROIArea', 'maxROIArea', 'minROITime'}; ...
            'General', {'baselineFrames', 'backgroundLevel', ...
                'inpaintIters', 'discardBorderROIs'}};
        
    end
    
    % ================================================================== %
    
    methods 
        
        function ConfigFindROIsFLIKA_3Dobj = ConfigFindROIsFLIKA_3D(varargin)
        %ConfigFindROIsFLIKA_3D - ConfigFindROIsFLIKA_3D class constructor
        %
        %   OBJ = ConfigFindROIsFLIKA_3D() creates a ConfigFindROIsFLIKA_3D
        %   object OBJ with default values for all properties.
        %
        %   OBJ = ConfigFindROIsFLIKA_3D(..., 'property', value, ...) or
        %   OBJ = ConfigFindROIsFLIKA_3D(..., propStruct, ...) 
        %
        %   This syntax specifies values for the properties, either in the
        %   form of attribute-value pairs, or structures (or objects) where
        %   the field (property) names correspond to properties in the
        %   ConfigFindROIsFLIKA_3D class. The argument parsing is done by
        %   the utility function parsepropval (link below), so please
        %   consult the documentation for this function for further
        %   details.
        %
        %   See also utils.parsepropval,
        %   ConfigFindROIsFLIKA_3D.from_preset, ConfigFindROIsFLIKA_2D,
        %   ConfigFindROIsFLIKA_2p5D, ConfigFindROIsDummy,
        %   ConfigFindROIsFLIKA, Config, ConfigCellScan
            
            % Call Config (i.e. parent class) constructor
            ConfigFindROIsFLIKA_3Dobj = ...
                ConfigFindROIsFLIKA_3Dobj@ConfigFindROIsFLIKA(varargin{:});
            
        end
                
        % -------------------------------------------------------------- %
        
        function self = set.minROITime(self, val)
            
            % Check that the value is a positive, real, finite, scalar
            % number
            utils.checks.prfs(val, 'minROITime')
            
            % Assign value
            self.minROITime = val;
        end
        
    end
    
    % ================================================================== %
    
    methods (Static)
        
        function obj = from_preset(strPreset, varargin)
        %from_preset - Create a config object from a preset
        %
        %   OBJ = ConfigFindROIsFLIKA.from_preset(PRESET) creates a config
        %   object from the specified preset.  PRESET must be a single row
        %   character array.  So far, the following presets exist, based on
        %   the behaviour of different Calcium sensors:
        %
        %       'ca_cyto_astro' -> Cytosolic calcium sensor in astrocytes,
        %           as used in the EIN-Lab.
        %
        %       'ca_neuron'     -> Cytosolic calcium sensor in neurons, as
        %           used in the EIN-Lab.
        %
        %       'ca_memb_astro' -> Membrane-tagged calcium sensor in
        %           astrocytes, as used in the EIN-Lab.
        %
        %   OBJ = ConfigFindROIsFLIKA.from_preset(PRESET, ARG1, ARG2, ...)
        %   passes all additional arguments to the ConfigFindROIsFLIKA
        %   object constructor.  This can be useful for creating slight
        %   modifications of the preset configurations.
        %
        %   See also ConfigFindROIsFLIKA,
        %   ConfigFindROIsFLIKA.ConfigFindROIsFLIKA
            
            % Check we have enough arguments
            narginchk(1, inf)
        
            % Check that the preset is a single row character array
            if ~isempty(strPreset)
                utils.checks.single_row_char(strPreset, 'preset');
            end
            
            % Call the superclass to do some magic, then create the object
            presetArgs = ConfigFindROIsFLIKA.get_preset_args(strPreset);
            wngState = warning('off', 'ParsePropVal:UnknownAttr');
            obj = ConfigFindROIsFLIKA_3D(presetArgs, varargin{:});
            warning(wngState)
            
        end
        
    end
    
    % ================================================================== %
    
end
