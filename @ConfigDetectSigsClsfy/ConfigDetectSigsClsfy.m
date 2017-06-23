classdef ConfigDetectSigsClsfy < ConfigDetectSigs
%ConfigDetectSigsClsfy - Parameters for detecting and classifying signals
%
%   The ConfigDetectSigsClsfy class is a configuration class that contains
%   the parameters necessary for detecting and classifying signals from ROI
%   traces. For further information about this algorithm, please refer to 
%   <a href="matlab:web('http://dx.doi.org/10.1093/cercor/bhw366', '-browser')">Stobart et al. (2017)</a>, Cerebral Cortex, doi:10.1093/cercor/bhw366.
%
% ConfigDetectSigsClsfy public properties
%   backgroundLevel - The nth percentile to be used as background [%]
%   baselineFrames  - The frames to be used as baseline
%   excludeNaNs     - Whether to exclude ROI traces with NaNs
%   lpWindowTime    - The window duration for the low pass filter [s]
%   propagateNaNs   - Whether to propagate NaNs through ROI traces
%   spFilterOrder   - The order of the single peak band pass filter
%   spPassBandMax   - The max frequency to identify single peaks [Hz]
%   spPassBandMin   - The min frequency to identify single peaks [Hz]
%   thresholdLP     - The threshold for detecting low frequency peaks
%   thresholdSP     - The threshold for detecting single peaks
%
% ConfigDetectSigsClsfy public methods
%   ConfigDetectSigsClsfy - ConfigDetectSigsClsfy class constructor
%   copy            - Copy MATLAB array of handle objects
%   create_calc     - Return a Calc object containing the Config object
%   get_dims        - Return the dimensions needed for the opt_config GUI
%   opt_config      - Optimise parameters using a GUI
%
% ConfigDetectSigsClsfy static methods
%   from_preset     - Create a ConfigDetectSigsClsfy object from a preset
%
% ConfigDetectSigsDummy public events:
%   ProcessNow      - Notifies listeners to process an object
%
%   See also ConfigDetectSigsDummy, ConfigDetectSigs, Config,
%   ConfigCellScan, CalcDetectSigsClsfy, CellScan

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
        
        %baselineFrames - The frames to be used as baseline
        %
        %   The indices of the frames to be used as the baseline period. If
        %   a scalar, 1:baselineFrames will be used. The baseline period
        %   will be used for determining the signal detection thresholds.
        %   [default = 1:30]
        %
        %   See also CellScan
        baselineFrames = 1:30;
        
        %excludeNaNs - Whether to exclude ROI traces with NaNs
        %
        %   A logical scalar that determines whether a NaN (or Inf) values
        %   from a single pixel leads to exclusion of a whole ROI trace. 
        %   [default = true]
        %
        %   See also CellScan
        excludeNaNs = true;
        
        %lpWindowTime - The window duration for the low pass filter [s]
        %
        %   A scalar that specifies the length of the window to use for the
        %   moving average (i.e. "low pass") filter, in seconds. 
        %   [default = 5]
        %
        %   See also utils.moving_average
        lpWindowTime = 5;
        
        %propagateNaNs - Whether to propagate NaNs through ROI traces
        %
        %   A logical scalar that determines whether a NaN (or Inf) values
        %   from a single pixel propagate through the entire ROI. 
        %   [default = true]
        %
        %   See also CellScan
        propagateNaNs = true;
        
        %spFilterOrder - The order of the single peak band pass filter
        %
        %   An even integer scalar the specifies what order of bandpass
        %   filter to use when filtering to identify the single peaks.
        %   Shorter filters (lower order) will have less well defined
        %   bands, but longer filters (higher order) will have longer roll
        %   on times (meaning that data at the start and end of the traces
        %   could be not so reliable). [default = 6]
        %
        %   See also ConfigMeasureROIsClsfy.spPassBandMin,
        %   ConfigMeasureROIsClsfy.spPassBandMax, designfilt
        spFilterOrder = 6;
        
        %spPassBandMax - The max frequency to identify single peaks [Hz]
        %
        %   A positive real scalar that specifies the maximum frequency for
        %   the band pass filter.  Peaks that are below this frequency (and
        %   above spPassBandMin) will be classified as single peaks, and
        %   those higher than this frequency band will be considered noise.
        %   [default = 1/5]
        %
        %   See also ConfigMeasureROIsClsfy.spPassBandMin,
        %   ConfigMeasureROIsClsfy.spFilterOrder, designfilt
        spPassBandMax = 1/5; % Hz
        
        %spPassBandMin - The min frequency to identify single peaks [Hz]
        %
        %   A positive real scalar that specifies the minimum frequency for
        %   the band pass filter.  Peaks that are above this frequency (and
        %   below spPassBandMax) will be classified as single peaks, and
        %   those lower than this frequency band will be classified as
        %   either plateaus or multipeaks. [default = 1/40]
        %
        %   See also ConfigMeasureROIsClsfy.spPassBandMax,
        %   ConfigMeasureROIsClsfy.spFilterOrder, designfilt
        spPassBandMin = 1/40; % Hz
        
        %thresholdLP - The threshold for detecting low frequency peaks
        %
        %   A scalar that specifies the multiple of the baseline standard
        %   deviation that will be used to detect plateau and multipeak
        %   signals (i.e. low frequency peaks). [default = 5]
        %
        %   See also ConfigMeasureROIsClsfy.lpWindowTime, findpeaks
        thresholdLP = 7;
        
        %thresholdSP - The threshold for detecting single peaks
        %
        %   A scalar that specifies the multiple of the baseline standard
        %   deviation that will be used to detect single peaks. 
        %   [default = 5]
        %
        %   See also ConfigMeasureROIsClsfy.spFilterOrder,
        %   ConfigMeasureROIsClsfy.spPassBandMin,
        %   ConfigMeasureROIsClsfy.spPassBandMax, findpeaks
        thresholdSP = 7;;
        
    end
    
    % ------------------------------------------------------------------ %
    
    properties (Constant, Access = protected)
        
        %classCalc - Constant, protected property containing the name of
        %   the associated Calc class
        classCalc = 'CalcDetectSigsClsfy';
        
        optList = {'Filters', {'thresholdLP', 'thresholdSP', ...
                'lpWindowTime', 'spPassBandMin', 'spPassBandMax', ...
                'spFilterOrder'}; ...
            'General', {'backgroundLevel', 'excludeNaNs', 'propagateNaNs'}};
        
    end
    
    % ================================================================== %
    
    methods
        
        function cdscObj = ConfigDetectSigsClsfy(varargin)
        %ConfigDetectSigsClsfy - ConfigDetectSigsClsfy class constructor
        %
        %   OBJ = ConfigDetectSigsClsfy() creates a ConfigDetectSigsClsfy
        %   object OBJ with default values for all properties.
        %
        %   OBJ = ConfigDetectSigsClsfy(..., 'property', value, ...) or
        %   OBJ = ConfigDetectSigsClsfy(..., propStruct, ...) 
        %
        %   This syntax specifies values for the properties, either in the
        %   form of attribute-value pairs, or structures (or objects) where
        %   the field (property) names correspond to properties in the
        %   ConfigDetectSigsClsfy class. The argument parsing is done by
        %   the utility function parsepropval (link below), so please
        %   consult the documentation for this function for more details.
        %
        %   See also utils.parsepropval,
        %   ConfigDetectSigsClsfy.from_preset, ConfigDetectSigsDummy,
        %   ConfigDetectSigs, Config, ConfigCellScan, CalcDetectSigsClsfy,
        %   CellScan
        
            % Call Config (i.e. parent class) constructor
            cdscObj = cdscObj@ConfigDetectSigs(varargin{:});
            
        end
        
        % -------------------------------------------------------------- %
        
        function self = set.backgroundLevel(self, val)
            
            % Check that the value is a positive, real, finite, scalar
            % integer
            utils.checks.prfs(val, 'backgroundLevel')
            
            % Assign value
            self.backgroundLevel = val;
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
        
        % -------------------------------------------------------------- %
        
        function self = set.excludeNaNs(self, val)
            
            % Check that the value is a scalar that is convertible to a
            % logical value
            utils.checks.scalar_logical_able(val, 'excludeNaNs')
            
            % Assign value
            self.excludeNaNs = logical(val);
            
        end
        
        % -------------------------------------------------------------- %
        
        function self = set.lpWindowTime(self, val)
            
            % Check that the value is a positive, real, finite, scalar
            utils.checks.prfs(val, 'lpWindowTime')
            
            % Assign value
            self.lpWindowTime = val;
        end
        
        % -------------------------------------------------------------- %
        
        function self = set.propagateNaNs(self, val)
            
            % Check that the value is a scalar that is convertible to a
            % logical value
            utils.checks.scalar_logical_able(val, 'propagateNaNs')
            
            % Assign value
            self.propagateNaNs = logical(val);
            
        end
        
        % -------------------------------------------------------------- %
        
        function self = set.spFilterOrder(self, val)
            
            % Check that the value is a positive, real, finite, scalar
            % integer
            utils.checks.prfsi(val, 'spFilterOrder')
            utils.checks.even(val, 'spFilterOrder')
            
            % Assign value
            self.spFilterOrder = val;
        end
        
        % -------------------------------------------------------------- %
        
        function self = set.spPassBandMin(self, val)
            
            % Check that the value is a positive, real, finite, scalar
            % integer
            utils.checks.prfs(val, 'spPassBandMin')
            if ~isempty(self.spPassBandMax)
                utils.checks.less_than(val, self.spPassBandMax, ...
                    false, 'spPassBandMin');
            end
            
            % Assign value
            self.spPassBandMin = val;
        end
        
        % -------------------------------------------------------------- %
        
        function self = set.spPassBandMax(self, val)
            
            % Check that the value is a positive, real, finite, scalar
            % integer
            utils.checks.prfs(val, 'spPassBandMax')
            if ~isempty(self.spPassBandMin)
                utils.checks.greater_than(val, self.spPassBandMin, ...
                    false, 'spPassBandMax');
            end
            
            % Assign value
            self.spPassBandMax = val;
        end
        
        % -------------------------------------------------------------- %
        
        function self = set.thresholdLP(self, val)
            
            % Check that the value is a positive, real, finite, scalar
            utils.checks.prfs(val, 'thresholdLP')
            
            % Assign value
            self.thresholdLP = val;
        end
        
        % -------------------------------------------------------------- %
        
        function self = set.thresholdSP(self, val)
            
            % Check that the value is a positive, real, finite, scalar
            utils.checks.prfs(val, 'thresholdSP')
            
            % Assign value
            self.thresholdSP = val;
        end
                
    end
    
    % ================================================================== %
    
    methods (Static)
        
        function obj = from_preset(strPreset, varargin)
        %from_preset - Create a ConfigDetectSigsClsfy object from a preset
        %
        %   OBJ = ConfigDetectSigsClsfy.from_preset(PRESET) creates a
        %   config object from the specified preset.  PRESET must be a
        %   single row character array.  So far, the following presets
        %   exist, based on the behaviour of different Calcium sensors:
        %
        %       'ca_cyto_astro' -> Cytosolic calcium sensor in astrocytes,
        %           as used in the EIN-Lab.
        %
        %       'ca_neuron'     -> Cytosolic calcium sensor in neurons, as
        %           used in the EIN-Lab.
        %
        %   OBJ = ConfigDetectSigsClsfy.from_preset(PRESET, ARG1, ARG2, ...)
        %   passes all additional arguments to the ConfigDetectSigsClsfy
        %   object constructor.  This can be useful for creating slight
        %   modifications of the preset configurations.
        %
        %   See also ConfigDetectSigsClsfy,
        %   ConfigDetectSigsClsfy.ConfigDetectSigsClsfy
            
            % Check we have enough arguments
            narginchk(1, inf)
        
            % Check that the preset is a single row character array
            if ~isempty(strPreset)
                utils.checks.single_row_char(strPreset, 'preset');
            end
            
            % Call the superclass to do some magic, then create the object
            presetArgs = ConfigDetectSigsClsfy.get_preset_args(strPreset);
            wngState = warning('off', 'ParsePropVal:UnknownAttr');
            obj = ConfigDetectSigsClsfy(presetArgs, varargin{:});
            warning(wngState)
            
        end
        
    end
    
    % ================================================================== %
    
    methods (Static, Access=protected)
        
        function presetArgs = get_preset_args(strPreset)
            
             switch lower(strPreset)
                
                % Preset for GFAP-GCaMP6s
                case 'ca_cyto_astro'
                    presetArgs = ...
                        ConfigDetectSigsClsfy.preset_args_ca_cyto_astro();
                % Preset for SYN-RCaMP1.07
                case 'ca_neuron'
                    presetArgs = ...
                        ConfigDetectSigsClsfy.preset_args_ca_neuron();
                % Unknown preset    
                otherwise
                    
                    warning(...
                        'ConfigDetectSigsClsfy:FromPreset:UnknownPreset', ...
                        ['Unknown preset "%s".  Starting from default ' ...
                        'values.'], strPreset)
                    presetArgs = struct();
                
             end
            
        end
        
        % -------------------------------------------------------------- %
        
        function presetArgs = preset_args_ca_cyto_astro()
            
            presetArgs.backgroundLevel = 1;
            presetArgs.baselineFrames = 30;
            presetArgs.excludeNaNs = 0;
            presetArgs.propagateNaNs = 1;
            presetArgs.lpWindowTime = 10;
            presetArgs.spFilterOrder = 6;
            presetArgs.spPassBandMin = 0.001;
            presetArgs.spPassBandMax = 0.3;
            presetArgs.thresholdLP = 8;
            presetArgs.thresholdSP = 2.5;
            
        end
        
        % -------------------------------------------------------------- %
        
        function presetArgs = preset_args_ca_neuron()
            
            presetArgs.backgroundLevel = 3;
            presetArgs.baselineFrames = 55;
            presetArgs.excludeNaNs = 0;
            presetArgs.propagateNaNs = 1;
            presetArgs.lpWindowTime = 10;
            presetArgs.spFilterOrder = 6;
            presetArgs.spPassBandMin = 0.19;
            presetArgs.spPassBandMax = 0.32;
            presetArgs.thresholdLP = 2.5;
            presetArgs.thresholdSP = 1.5;
            
        end
        
    end
    
    % ================================================================== %

end
