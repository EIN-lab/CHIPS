classdef ConfigDiameterFWHM < Config
%ConfigDiameterFWHM - Parameters for FWHM-based diameter calculation
%
%   The ConfigDiameterFWHM class is a configuration class that contains the
%   parameters necessary for calculating diameters based on the full width
%   at half maximum (FWHM) approach.
%
% ConfigDiameterFWHM public properties
%   lev50           - Normalised height at which to measure the diameter
%   maxRate         - The maximum rate at which to calculate diameter [Hz]
%   thresholdSTD    - The std dev multiple at which to exclude data
%   
% ConfigDiameterFWHM public methods
%   ConfigDiameterFWHM - ConfigDiameterFWHM class constructor
%   copy            - Copy MATLAB array of handle objects
%   create_calc     - Return a Calc object containing the Config object
%   get_dims        - Return the dimensions needed for the opt_config GUI
%   opt_config      - Optimise parameters using a GUI
%
% ConfigDiameterFWHM static methods
%   from_preset     - Create a ConfigDiameterFWHM object from a preset
%
% ConfigDiameterFWHM public events:
%   ProcessNow      - Notifies listeners to process an object
%
%   See also Config, ConfigFrameScan, CalcDiameterFWHM, LineScanDiam,
%   FrameScan, ICalcDiameterLong

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
        
        %lev50 - Normalised height at which to measure the diameter
        %
        %   A scalar number between 0 and 1 representing the normalised
        %   height of the diameter profile to use for measuring the
        %   diameter.  For example: when lev50 = 0.5, the measurement
        %   represents the FWHM; when lev50 = 0.75, the measurement
        %   represents the full width at 3/4 maximum. [default = 0.5]
        %
        %   See also utils.fwhm
        lev50 = 0.5; % 
        
        %maxRate - The maximum rate at which to calculate diameter [Hz]
        %
        %   A scalar number corresponding to the maximum rate at which
        %   diameter should be calculated.  If the data acquisition rate
        %   exceeds the maxRate, the diameter profiles will be averaged to
        %   the nearest rate less than maxRate.  This parameter makes it
        %   possible to trade reduced time resolution for improved signal
        %   to noise ratio, and vice versa. [default = 20Hz]
        maxRate = 20;
        
        %thresholdSTD - The std dev multiple at which to exclude data
        %
        %   A scalar number representing the number of standard deviations
        %   away from the median at which the diameter data will be
        %   considered 'bad' and flagged. [default = 3]
        %
        %   See also DataDiameter.maskSTD
        thresholdSTD = 3; 
        
    end
    
    % ------------------------------------------------------------------ %
    
    properties (Constant, Access = protected)
        
        classCalc = 'CalcDiameterFWHM';
        
        optList = {...
            'FWHM', {'lev50', 'maxRate'}; ...
            'Postprocessing', {'thresholdSTD'}};
            
    end
    
    % ================================================================== %
    
    methods
        
        function ConfigDiameterFWHMObj = ConfigDiameterFWHM(varargin)
        %ConfigDiameterFWHM - ConfigDiameterFWHM class constructor
        %
        %   OBJ = ConfigDiameterFWHM() creates a ConfigDiameterFWHM object
        %   OBJ with default values for all properties.
        %
        %   OBJ = ConfigDiameterFWHM(..., 'property', value, ...) or
        %   OBJ = ConfigDiameterFWHM(..., propStruct, ...) 
        %
        %   This syntax specifies values for the properties, either in the
        %   form of attribute-value pairs, or structures (or objects) where
        %   the field (property) names correspond to properties in the
        %   ConfigDetectSigsDummy class. The argument parsing is done by
        %   the utility function parsepropval (link below), so please
        %   consult the documentation for this function for more details.
        %
        %   See also utils.parsepropval, ConfigDiameterFWHM.from_preset,
        %   Config, ConfigFrameScan, CalcDiameterFWHM, LineScanDiam,
        %   FrameScan, ICalcDiameterLong
                       
            % Call Config (i.e. parent class) constructor
            ConfigDiameterFWHMObj = ...
                ConfigDiameterFWHMObj@Config(varargin{:});
            
        end
        
        % -------------------------------------------------------------- %
        
        function self = set.maxRate(self, val)
            utils.checks.prfs(val, 'maxRate')
            self.maxRate = val;
        end
        
        % -------------------------------------------------------------- %
        
        function self = set.lev50(self, val)
            utils.checks.prfs(val, 'lev50')
            utils.checks.less_than(val, [], [], 'lev50')
            self.lev50 = val;
        end
        
        % -------------------------------------------------------------- %
        
        function self = set.thresholdSTD(self, val)
            utils.checks.prfs(val, 'thresholdSTD')
            self.thresholdSTD = val;
        end
        
    end
    
    % ================================================================== %
    
end
