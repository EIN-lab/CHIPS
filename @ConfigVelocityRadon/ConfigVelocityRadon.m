classdef  ConfigVelocityRadon < Config
%ConfigVelocityRadon - Parameters for Radon-based velocity calculation
%
%   The ConfigVelocityRadon class is a configuration class that contains
%   the parameters necessary for calculating velocity based on the Radon
%   transform algorithm. For more information on the algorithm, please
%   refer to the documentation of CalcVelocityRadon, or <a href="matlab:web('http://dx.doi.org/10.1007/s10827-009-0159-1', '-browser')">Drew et al. (2010)</a>, 
%   J Comput Neurosci 29(1):5-11.
%
%   ConfigVelocityRadon is a subclass of matlab.mixin.Copyable, which is
%   itself a subclass of handle, meaning that ConfigVelocityRadon objects
%   are actually references to the data contained in the object.  This
%   allows certain features that are only possible with handle objects,
%   such as events and certain GUI operations.  However, it is important to
%   use the copy method of matlab.mixin.Copyable to create a new,
%   independent object; otherwise changes to a ConfigVelocityRadon object
%   used in one place will also lead to changes in another (perhaps
%   undesired) place.
%
% ConfigVelocityRadon public properties
%   incrCoarse      - The difference between coarse theta values [degrees]
%   incrFine        - The difference between fine theta values [degrees]
%   maxNCoarse      - The maximum number of coarse Radon attempts
%   maxNFull        - The maximum number of full Radon attempts
%   minPeakDist     - The minimum seperation between RBCs [µm]
%   nOverlap        - The number of overlaps within an analysis window
%   pointsSNR       - The number of points in the bootstrap SNR estimate
%   rangeCoarse     - The range of coarse theta values [degrees]
%   rangeFine       - The range of fine theta values [degrees]
%   thetaMax        - The maximum theta value allowed [degrees]
%   thetaMin        - The minimum theta value allowed [degrees]
%   thresholdProm   - The prominince threshold for detecting RBCs
%   thresholdSNR    - The SNR threshold below which to exclude data
%   thresholdSTD    - The std dev multiple above which to exclude data
%   tolCoarse       - The tolerance to switch from coarse to fine [degrees]
%   windowTime      - The length of an analysis window [ms]
%   
% ConfigVelocityRadon public methods
%   ConfigVelocityRadon - ConfigVelocityRadon class constructor
%   copy            - Copy MATLAB array of handle objects
%   create_calc     - Return a Calc object containing the Config object
%   get_dims        - Return the dimensions needed for the opt_config GUI
%   opt_config      - Optimise parameters using a GUI
%
% ConfigVelocityRadon static methods
%   from_preset     - Create a ConfigVelocityRadon object from a preset
%
% ConfigVelocityRadon public events:
%   ProcessNow      - Notifies listeners to process an object
%
%   See also ConfigVelocityLSPIV, Config, ConfigFrameScan,
%   CalcVelocityRadon, LineScanVel, FrameScan
    
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
        
        % SplitIntoWindows
        % -------------------------------------------------------------- %
        
        %windowTime - The length of an analysis window [ms]
        %
        %   A positive scalar number representing the time duration of one
        %   analysis window. This parameter makes it possible to trade
        %   reduced time resolution for increased signal to noise ratio,
        %   and vice versa. The windowTime should be higher in cases where
        %   the flux is lower, and vice versa. [default = 50ms]
        %
        %   See also ConfigVelocityRadon.nOverlap, utils.split_into_windows
        windowTime = 50;
        
        %nOverlap - The number of overlaps within an analysis window
        %
        %   A scalar integer representing the number of overlaps that take
        %   place within one analysis window.  The start time of every
        %   window is separated by windowTime/nOverlap. [default = 4]
        %
        %   See also ConfigVelocityRadon.windowTime,
        %   utils.split_into_windows
        nOverlap = 4; % Number of overlaps per window
        
        
        % Radon
        % -------------------------------------------------------------- %
        
        %thetaMax - The maximum theta value allowed [degrees]
        %
        %   The maximum allowed theta value. [default = 90 degrees]
        %
        %   See also ConfigVelocityRadon.thetaMin
        thetaMax = +90;
        
        %thetaMin - The minimum theta value allowed [degrees]
        %
        %   The minimum allowed theta value. [default = -90 degrees]
        %   
        %   See also ConfigVelocityRadon.thetaMax
        thetaMin = -90;
        
        %incrCoarse - The difference between coarse theta values [degrees]
        %
        %   A scalar representing the incremental difference between values
        %   in the coarse theta range.  [default = 1 degree]
        %
        %   The coarse theta range is determined by the following formula:
        %
        %       theta - rangeCoarse : incrCoarse : theta - rangeCoarse
        %
        %   See also ConfigVelocityRadon.rangeCoarse
        incrCoarse = 1; 
        
        %incrFine - The difference between fine theta values [degrees]
        %
        %   A scalar representing the incremental difference between values
        %   in the fine theta range.  [default = 0.1 degree]
        %
        %   The fine theta range is determined by the following formula:
        %
        %       theta - rangeFine : incrFine : theta - rangeFine
        %
        %   See also ConfigVelocityRadon.rangeFine
        incrFine = 0.1; 
        
        %rangeCoarse - The range of coarse theta values [degrees]
        %
        %   A scalar representing the maximum range away from the central
        %   theta value for coarse calculations. [default = 10 degrees]
        %
        %   The coarse theta range is determined by the following formula:
        %
        %       theta - rangeCoarse : incrCoarse : theta - rangeCoarse
        %
        %   See also ConfigVelocityRadon.incrCoarse
        rangeCoarse = 10;
        
        %rangeFine - The range of fine theta values [degrees]
        %
        %   A scalar representing the maximum range away from the central
        %   theta value for fine calculations. [default = 10 degrees]
        %
        %   The fine theta range is determined by the following formula:
        %
        %       theta - rangeFine : incrFine : theta - rangeFine
        %
        %   See also ConfigVelocityRadon.incrFine
        rangeFine = 3;
        
        %tolCoarse - The tolerance to switch from coarse to fine [degrees]
        %
        %   A scalar representing the distance away from the previous theta
        %   value within which the algorithm will switch to fine
        %   calculation. [default = 8]
        %
        %   See also ConfigVelocityRadon.rangeCoarse
        tolCoarse = 8; 
        
        %maxNCoarse - The maximum number of coarse Radon attempts
        %
        %   A scalar integer representing the maximum number of coarse
        %   theta ranges to calculate over.  If the algorithm exceeds this
        %   limit, it will do a calculation over the full theta range.
        %   [default = 2]
        %
        %   See also ConfigVelocityRadon.maxNFull
        maxNCoarse = 2;
        
        %maxNFull - The maximum number of full Radon attempts
        %
        %   A scalar integer representing the maximum number of full
        %   theta ranges to calculate over.  If the algorithm exceeds this
        %   limit, it will skip directly to the fine calculation.
        %   [default = 1]
        %
        %   See also ConfigVelocityRadon.maxNCoarse
        maxNFull = 1;
        
        
        % Flux
        % -------------------------------------------------------------- %
        
        %minPeakDist - The minimum seperation between RBCs [µm]
        %
        %   A scalar number representing the minimum distance streaks must
        %   be seperated by to be considered seperate cells.  This is used
        %   as the 'MinPeakDistance' argument when calling findpeaks.
        %   [default = 5µm]
        %
        %   See also findpeaks
        minPeakDist = 5;
        
        %thresholdProm - The prominince threshold for detecting RBCs
        %
        %   A scalar between 0 and 1 representing the minimum proportion of
        %   the signal range that a peak must exceed in order to be
        %   detected as an RBC.  This is used as the 'MinPeakProminence'
        %   argument when calling findpeaks. [default = 0.3]
        %
        %   See also findpeaks
        thresholdProm = 0.3;
        
        % Post-processing
        % -------------------------------------------------------------- %
        
        %pointsSNR - The number of points in the bootstrap SNR estimate
        %
        %   A scalar integer representing the points to include in the
        %   bootstrap estimate of signal to noise ratio (SNR). 
        %   [default = 12]
        %
        %   See also ConfigVelocityRadon.thresholdSNR
        pointsSNR = 12;
        
        %thresholdSNR - The SNR threshold below which to exclude data
        %
        %   A scalar number representing the SNR value below which the
        %   velocity data will be considered 'bad' and flagged. 
        %   [default = 3]
        %
        %   See also ConfigVelocityRadon.pointsSNR, DataVelocity.maskSNR
        thresholdSNR = 3;
        
        %thresholdSTD - The std dev multiple above which to exclude data
        %
        %   A scalar number representing the number of standard deviations
        %   away from the median at which the velocity data will be
        %   considered 'bad' and flagged. [default = 3]
        %
        %   See also DataVelocity.maskSTD
        thresholdSTD = 3;
        
    end
    
    % ------------------------------------------------------------------ %
    
    properties (Constant, Access = protected)
        
        classCalc = 'CalcVelocityRadon';
        
        optList = {...
            'Windows', {'windowTime', 'nOverlap'}; ...
            'Radon', {'thetaMax', 'thetaMin', 'incrCoarse', 'incrFine', ...
                'rangeCoarse', 'rangeFine', 'tolCoarse', ...
                'maxNCoarse', 'maxNFull'}; ...
            'Flux', {'minPeakDist', 'thresholdProm'}; ...
            'Postprocessing', {'pointsSNR', 'thresholdSNR', ...
                'thresholdSTD'}};
        
    end
    
    % ================================================================== %
    
    methods
        
        function ConfigVelocityRadonObj = ConfigVelocityRadon(varargin)
        %ConfigVelocityRadon - ConfigVelocityRadon class constructor
        %
        %   OBJ = ConfigVelocityRadon() creates a ConfigVelocityRadon
        %   object OBJ with default values for all properties.
        %
        %   OBJ = ConfigVelocityRadon(..., 'property', value, ...) or
        %   OBJ = ConfigVelocityRadon(..., propStruct, ...) 
        %
        %   This syntax specifies values for the properties, either in the
        %   form of attribute-value pairs, or structures (or objects) where
        %   the field (property) names correspond to properties in the
        %   ConfigVelocityRadon class. The argument parsing is done by
        %   the utility function parsepropval (link below), so please
        %   consult the documentation for this function for more details.
        %
        %   See also utils.parsepropval,
        %   ConfigVelocityRadon.from_preset, ConfigVelocityLSPIV,
        %   Config, ConfigFrameScan, CalcVelocityRadon, LineScanVel,
        %   FrameScan, ICalcVelocityStreaks
                       
            % Call Config (i.e. parent class) constructor
            ConfigVelocityRadonObj = ...
                ConfigVelocityRadonObj@Config(varargin{:});
            
        end
        
        % -------------------------------------------------------------- %
        
        function self = set.windowTime(self, val)
            utils.checks.prfs(val, 'windowTime')
            self.windowTime = val;
        end
        
        % -------------------------------------------------------------- %
        
        function self = set.nOverlap(self, val)
            utils.checks.prfsi(val, 'nOverlap')
            self.nOverlap = val;
        end
        
        % -------------------------------------------------------------- %
        
        function self = set.incrCoarse(self, val)
            utils.checks.prfs(val, 'incrCoarse')
            self.incrCoarse = val;
        end
        
        % -------------------------------------------------------------- %
        
        function self = set.incrFine(self, val)
            utils.checks.prfs(val, 'incrFine')
            self.incrFine = val;
        end
        
        % -------------------------------------------------------------- %
        
        function self = set.rangeCoarse(self, val)
            utils.checks.prfs(val, 'rangeCoarse')
            self.rangeCoarse = val;
        end
        
        % -------------------------------------------------------------- %
        
        function self = set.rangeFine(self, val)
            utils.checks.prfs(val, 'rangeFine')
            self.rangeFine = val;
        end
        
        % -------------------------------------------------------------- %
        
        function self = set.tolCoarse(self, val)
            utils.checks.prfs(val, 'tolCoarse')
            self.tolCoarse = val;
        end
        
        % -------------------------------------------------------------- %
        
        function self = set.maxNCoarse(self, val)
            utils.checks.prfsi(val, 'maxNCoarse')
            self.maxNCoarse = val;
        end
        
        % -------------------------------------------------------------- %
        
        function self = set.maxNFull(self, val)
            utils.checks.prfsi(val, 'maxNFull')
            self.maxNFull = val;
        end
        
        % -------------------------------------------------------------- %
        
        function self = set.pointsSNR(self, val)
            utils.checks.prfsi(val, 'pointsSNR')
            self.pointsSNR = val;
        end
        
        % -------------------------------------------------------------- %
        
        function self = set.minPeakDist(self, val)
            utils.checks.prfsi(val, 'minPeakDist')
            self.minPeakDist = val;
        end
        
        % -------------------------------------------------------------- %
        
        function self = set.thresholdProm(self, val)
            utils.checks.prfs(val, 'thresholdProm')
            utils.checks.less_than(val, [], [], 'thresholdProm')
            self.thresholdProm = val;
        end
        
        % -------------------------------------------------------------- %
        
        function self = set.thresholdSNR(self, val)
            utils.checks.prfs(val, 'thresholdSNR')
            self.thresholdSNR = val;
        end
        
        % -------------------------------------------------------------- %
        
        function self = set.thresholdSTD(self, val)
            utils.checks.prfs(val, 'thresholdSTD')
            self.thresholdSTD = val;
        end
        
    end
    
    % ================================================================== %
    
end
