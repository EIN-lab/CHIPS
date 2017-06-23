classdef ConfigFindROIsFLIKA < ConfigFindROIsAuto
%ConfigFindROIsFLIKA - Parameters for FLIKA-based ROI identification
%
%   The ConfigFindROIsFLIKA class is a configuration class that contains
%   the parameters necessary for FLIKA-based region of interest (ROI)
%   identification. For further information about FLIKA, please refer 
%	to <a href="matlab:web('http://dx.doi.org/10.1016/j.ceca.2014.06.003', '-browser')">Ellefsen et al. (2014)</a>, Cell Calcium 56(3):147-156.
%
%   Note: The run time of the FLIKA algorithm is strongly influenced by the
%   number of image frames that occur in the time maxRiseTime -
%   minRiseTime.  If performance is slow, it is recommended to reduce the
%   difference between these two parameter values.
%
%   ConfigFindROIsFLIKA is a subclass of matlab.mixin.Copyable, which is
%   itself a subclass of handle, meaning that ConfigFindROIsFLIKA objects
%   are actually references to the data contained in the object.  This
%   allows certain features that are only possible with handle objects,
%   such as events and certain GUI operations.  However, it is important to
%   use the copy method of matlab.mixin.Copyable to create a new,
%   independent object; otherwise changes to a ConfigFindROIsFLIKA object
%   used in one place will also lead to changes in another (perhaps
%   undesired) place.
%
% ConfigFindROIsFLIKA public properties
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
%   sigmaT          - The width of the temporal moving average filter [s]
%   sigmaXY         - The width of the spatial gaussian filter [µm]
%   thresholdPuff   - The threshold used to determine puffing pixels
%   
% ConfigFindROIsFLIKA public methods
%   ConfigFindROIsFLIKA - ConfigFindROIsFLIKA class constructor
%   copy            - Copy MATLAB array of handle objects
%   create_calc     - Return a Calc object containing the Config object
%   get_dims        - Return the dimensions needed for the opt_config GUI
%   opt_config      - Optimise parameters using a GUI
%
% ConfigFindROIsFLIKA static methods
%   from_preset     - Create a config object from a preset
%
% ConfigFindROIsFLIKA public events:
%   ProcessNow      - Notifies listeners to process an object
%
%   See also ConfigFindROIsFLIKA_2D, ConfigFindROIsFLIKA_2p5D,
%   ConfigFindROIsFLIKA_3D, ConfigFindROIsDummy, Config, ConfigCellScan,
%   CalcFindROIsFLIKA, CellScan

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
        
        % Imaging parameters
        % -------------------------------------------------------------- %
        
        %baselineFrames - The frames to be used as baseline
        %
        %   The indices of the frames to be used as the baseline period. If
        %   a scalar, 1:baselineFrames will be used. The baseline period
        %   will be used for background subtraction and might act as
        %   reference image if not specified otherwise. [default = 1:30]
        %
        %   See also CellScan
        baselineFrames = 1:30;
        
        % FLIKA parameters
        % -------------------------------------------------------------- %
        
        %sigmaXY - The width of the spatial gaussian filter [µm]
        %
        %   The sigmaXY defines the width of the spatial gaussian filter
        %   that is used to blur each frame. The numeric scalar is defined
        %   as the standard deviation of the gaussian distribution in µm.
        %   [default = 2µm]
        %
        %   See also fspecial, conv2, CalcFindROIsFLIKA
        sigmaXY = 2;
        
        %sigmaT - The width of the temporal moving average filter [s]
        %
        %   The sigmaT defines the width of the temporal moving average
        %   filter that is used to blur the time vector for each pixel
        %   individually. [default = 1s]
        %
        %   See also smooth, CalcFindROIsFLIKA
        sigmaT = 1;
        
        %freqPassBand - The high-pass filter pass band frequency [Hz]
        %
        %   The freqPassBand defines the frequency at which the high pass
        %   filter pass band starts.  This filter is used to select the
        %   baseline standard deviation to normalise the signals. 
        %   [default = 0.15Hz]
        %
        %   See also designfilt, CalcFindROIsFLIKA
        freqPassBand = 0.15;
        
        %thresholdPuff - The threshold used to determine puffing pixels
        %
        %   The number of standard deviations that is used to calculate the
        %   moving threshold for the boxcar scan window. [default = 7]
        %
        %   See also CalcFindROIsFLIKA.detectPuffingPixels,
        %   CalcFindROIsFLIKA
        thresholdPuff = 7;
        
        %minRiseTime - The shortest time the signal takes to peak [s]
        %
        %   The shortest expected time to peak defines the start of the
        %   boxcar scan window. For illustrations, please refer to 
        %   <a href="matlab:web(...
        %   'http://dx.doi.org/10.1016/j.ceca.2014.06.003', ...
        %   '-browser')">Ellefsen et al. (2014)</a>. [default = 0.5s]
        %
        %   Note: The run time of the FLIKA algorithm is strongly
        %   influenced by the number of image frames that occur in the time
        %   maxRiseTime - minRiseTime.  If performance is slow, it is
        %   recommended to reduce the difference between these two
        %   parameter values.
        %
        %   See also ConfigFindROIsFLIKA.maxRiseTime,
        %   CalcFindROIsFLIKA.detectPuffingPixels, CalcFindROIsFLIKA
        minRiseTime = 0.5;
        
        %maxRiseTime - The longest time the signal takes to peak [s]
        %
        %   The longest expected time to peak defines the width of the
        %   boxcar scan window. For illustrations, please refer to 
        %   <a href="matlab:web(...
        %   'http://dx.doi.org/10.1016/j.ceca.2014.06.003', ...
        %   '-browser')">Ellefsen et al. (2014)</a>. [default = 10s]
        %
        %   Note: The run time of the FLIKA algorithm is strongly
        %   influenced by the number of image frames that occur in the time
        %   maxRiseTime - minRiseTime.  If performance is slow, it is
        %   recommended to reduce the difference between these two
        %   parameter values.
        %
        %   See also CalcFindROIsFLIKA.detectPuffingPixels,
        %   CalcFindROIsFLIKA
        maxRiseTime = 10;
        
        %dilateXY - The spatial radius for dilating active pixels [µm]
        %
        %   The grouping radius for pixels in µm. The smaller the radius,
        %   the closer individual active pixels need to be to be considered
        %   originating from the same signal event. [default = 2µm]
        %
        %   See also CalcFindROIsFLIKA.groupPuffs, CalcFindROIsFLIKA
        dilateXY = 2;
        
        %dilateT - The temporal distance for dilating active pixels [s]
        %
        %   The time distance for grouping pixels, in seconds. The shorter
        %   the duration, the closer individual active pixels need to be to
        %   be considered originating from the same signal event. 
        %   [default = 0.5s]
        %
        %   See also CalcFindROIsFLIKA.groupPuffs, CalcFindROIsFLIKA
        dilateT = 0.5;
        
        %erodeXY - The spatial radius for eroding active pixels [µm]
        %
        %   The erosion radius for pixels in µm. The larger the radius, the
        %   more individual signal events will be separated from one
        %   another in space. [default = 0µm]
        %
        %   See also CalcFindROIsFLIKA.groupPuffs, CalcFindROIsFLIKA
        erodeXY = 0;
        
        %erodeT - The temporal distance for eroding active pixels [s]
        %
        %   The time distance for eroding pixels. The longer the duration,
        %   the more individual signal events will be separated from one
        %   another in time. [default = 0µm]
        %
        %   See also CalcFindROIsFLIKA.groupPuffs, CalcFindROIsFLIKA
        erodeT = 0;
        
        %backgroundLevel - The nth percentile to be used as background [%]
        %
        %   An integer number specifying the nth percentile to be used to
        %   locate background in the baseline average picture.
        %   [default = 1%]
        %
        %   See also pctile, CalcFindROIsFLIKA
        backgroundLevel = 1; %percentile
        
    end
    
    % ================================================================== %
    
    methods
        
        function ConfigFLIKAObj = ConfigFindROIsFLIKA(varargin)
        %ConfigFindROIsFLIKA - ConfigFindROIsFLIKA class constructor
        %
        %   OBJ = ConfigFindROIsFLIKA() creates a ConfigFindROIsFLIKA
        %   object OBJ with default values for all properties.
        %
        %   OBJ = ConfigFindROIsFLIKA(..., 'property', value, ...) or
        %   OBJ = ConfigFindROIsFLIKA(..., propStruct, ...) 
        %
        %   This syntax specifies values for the properties, either in the
        %   form of attribute-value pairs, or structures (or objects) where
        %   the field (property) names correspond to properties in the
        %   ConfigFindROIsFLIKA class. The argument parsing is done by the
        %   utility function parsepropval (link below), so please consult
        %   the documentation for this function for further details.
        %
        %   See also utils.parsepropval, ConfigFindROIsFLIKA.from_preset,
        %   ConfigFindROIsFLIKA_2D, ConfigFindROIsFLIKA_2p5D,
        %   ConfigFindROIsFLIKA_3D, ConfigFindROIsDummy,
        %   ConfigFindROIsAuto, Config, ConfigCellScan
            
            % Call Config (i.e. parent class) constructor
            ConfigFLIKAObj = ConfigFLIKAObj@ConfigFindROIsAuto(varargin{:});
            
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
            
            % Check that the length is greater than a number
            utils.checks.length(val, 6, 'baselineFrames', 'greater')
            
            % Assign value
            self.baselineFrames = val(:);
        end
        
        % -------------------------------------------------------------- %
        
        function self = set.sigmaXY(self, val)
            
            % Check that the value is greater than zero and a real, finite,
            % scalar number
            allowEq = true;
            utils.checks.scalar(val, 'sigmaXY')
            utils.checks.greater_than(val, 0, allowEq, 'sigmaXY')
            utils.checks.rfv(val, 'sigmaXY')            
            
            % Assign value
            self.sigmaXY = val;
        end
        
        % -------------------------------------------------------------- %
        
        function self = set.sigmaT(self, val)
            
            % Check that the value is a positive, real, finite, scalar
            % number
            allowEq = true;
            utils.checks.scalar(val, 'sigmaT')
            utils.checks.greater_than(val, 0, allowEq, 'sigmaT')
            utils.checks.rfv(val, 'sigmaT')
            
            % Assign value
            self.sigmaT = val;
        end
        
        % -------------------------------------------------------------- %
        
        function self = set.thresholdPuff(self, val)
            
            % Check that the value is a positive, real, finite, scalar
            % number
            utils.checks.prfs(val, 'thresholdPuff')
            
            % Assign value
            self.thresholdPuff = val;
        end
        
        % -------------------------------------------------------------- %
        
        function self = set.minRiseTime(self, val)
            
            % Check that the value is a positive, real, finite, scalar
            % number
            utils.checks.prfs(val, 'minRiseTime')
            
            % Assign value
            self.minRiseTime = val;
        end
        
        % -------------------------------------------------------------- %
        
        function self = set.maxRiseTime(self, val)
            
            % Check that the value is a positive, real, finite, scalar
            % number
            utils.checks.prfs(val, 'maxRiseTime')
            
            % Assign value
            self.maxRiseTime = val;
        end
        
        % -------------------------------------------------------------- %
        
        function self = set.dilateXY(self, val)
            
            % Check that the value is a positive, real, finite, scalar
            % number
            allowEq = true;
            utils.checks.scalar(val, 'dilateXY')
            utils.checks.greater_than(val, 0, allowEq, 'dilateXY')
            utils.checks.rfv(val, 'dilateXY')
            
            % Assign value
            self.dilateXY = val;
        end
        
        % -------------------------------------------------------------- %
        
        function self = set.dilateT(self, val)
            
            % Check that the value is a positive, real, finite, scalar
            % number
            allowEq = true;
            utils.checks.scalar(val, 'dilateT')
            utils.checks.greater_than(val, 0, allowEq, 'dilateT')
            utils.checks.rfv(val, 'dilateT')
            
            
            % Assign value
            self.dilateT = val;
        end
        
        % -------------------------------------------------------------- %
        
        function self = set.erodeXY(self, val)
            
            % Check that the value is a positive, real, finite, scalar
            % number
            allowEq = true;
            utils.checks.scalar(val, 'erodeXY')
            utils.checks.greater_than(val, 0, allowEq, 'erodeXY')
            utils.checks.rfv(val, 'erodeXY')
            
            % Assign value
            self.erodeXY = val;
        end
        
        % -------------------------------------------------------------- %
        
        function self = set.erodeT(self, val)
            
            % Check that the value is a positive, real, finite, scalar
            % number
            allowEq = true;
            utils.checks.scalar(val, 'erodeT')
            utils.checks.greater_than(val, 0, allowEq, 'erodeT')
            utils.checks.rfv(val, 'erodeT')
            
            
            % Assign value
            self.erodeT = val;
        end
        
        % -------------------------------------------------------------- %
        
        function self = set.backgroundLevel(self, val)
            
            % Check that the value is a positive, real, finite, scalar
            % number
            utils.checks.prfs(val, 'backgroundLevel')
            
            % Assign value
            self.backgroundLevel = val;
        end
        
    end
    
    % ================================================================== %
    
    methods (Static, Access=protected)
        
        function presetArgs = get_preset_args(strPreset)
            
             switch lower(strPreset)
                
                % Preset for GFAP-GCaMP6s
                case 'ca_cyto_astro'
                    presetArgs = ...
                        ConfigFindROIsFLIKA.preset_args_ca_cyto_astro();
                % Preset for SYN-RCaMP1.07
                case 'ca_neuron'
                    presetArgs = ...
                        ConfigFindROIsFLIKA.preset_args_ca_neuron();
                % Preset for lck-GCaMP6f
                case 'ca_memb_astro'
                    presetArgs = ...
                        ConfigFindROIsFLIKA.preset_args_ca_memb_astro();
                % Unknown preset    
                otherwise
                    
                    warning(...
                        'ConfigFindROIsFLIKA:FromPreset:UnknownPreset', ...
                        ['Unknown preset "%s".  Starting from default ' ...
                        'values.'], strPreset)
                    presetArgs = struct();
                
             end
            
        end
        
        % -------------------------------------------------------------- %
        
        function presetArgs = preset_args_ca_cyto_astro()
            
            presetArgs.baselineFrames = 1:30;
            presetArgs.sigmaXY = 3.1719;
            presetArgs.sigmaT = 2.0270;
            presetArgs.minRiseTime = 0.6759;
            presetArgs.maxRiseTime = 20.2770;
            presetArgs.minROIArea = 3.7832;
            presetArgs.minROITime = 1.3514;
            presetArgs.dilateXY = 9.4580;
            presetArgs.dilateT = 1.3518;
            presetArgs.threshold2D = 0.2;
            presetArgs.erodeXY = 3.1719;
            presetArgs.erodeT = 2.1146;
            
        end
        
        % -------------------------------------------------------------- %
        
        function presetArgs = preset_args_ca_neuron()
            
            presetArgs.baselineFrames = 1:55;
            presetArgs.sigmaXY = 2;
            presetArgs.sigmaT = 2;
            presetArgs.minRiseTime = 0.1689;
            presetArgs.maxRiseTime = 4;
            presetArgs.minROIArea = 25;
            presetArgs.minROITime = 0.1689;
            presetArgs.dilateXY = 9;
            presetArgs.dilateT = 5;
            presetArgs.thresholdPuff = 2.5;
            presetArgs.threshold2D = 0.33;
            presetArgs.erodeXY = 4;
            presetArgs.erodeT = 2;
            
        end
        
        % -------------------------------------------------------------- %
        
        function presetArgs = preset_args_ca_memb_astro()
            
            presetArgs.baselineFrames = 1:30;
            presetArgs.sigmaXY = 5.6748;
            presetArgs.sigmaT = 0.2534;
            presetArgs.minRiseTime = 0.0845;
            presetArgs.maxRiseTime = 0.8446;
            presetArgs.minROIArea = 3.7832*3.7832;
            presetArgs.minROITime = 0.1689;
            presetArgs.dilateXY = 7.5664;
            presetArgs.dilateT = 0.1689;
            presetArgs.thresholdPuff = 8;
            presetArgs.threshold2D = 0.2;
            presetArgs.erodeXY = 1.0573;
            presetArgs.erodeT = 2.1146;
            
        end
        
    end
    
    % ================================================================== %
    
end
