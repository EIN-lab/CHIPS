classdef ConfigVelocityLSPIV < Config
%ConfigVelocityLSPIV - Parameters for LSPIV-based velocity calculation
%
%   The ConfigVelocityLSPIV class is a configuration class that contains
%   the parameters necessary for calculating velocity based on the
%   Line-Scanning Particle Image Velocimetry (LS-PIV) algorithm. For more
%   information on the algorithm, please refer to the documentation of
%   CalcVelocityLSPIV, or <a href="matlab:web('http://dx.doi.org/10.1371/journal.pone.0038590', '-browser')">Kim et al. (2012)</a>, PLoS One 7(6):e38590.
%
%   ConfigVelocityLSPIV is a subclass of matlab.mixin.Copyable, which is
%   itself a subclass of handle, meaning that ConfigVelocityLSPIV objects
%   are actually references to the data contained in the object.  This
%   allows certain features that are only possible with handle objects,
%   such as events and certain GUI operations.  However, it is important to
%   use the copy method of matlab.mixin.Copyable to create a new,
%   independent object; otherwise changes to a ConfigVelocityLSPIV object
%   used in one place will also lead to changes in another (perhaps
%   undesired) place.
%
% ConfigVelocityLSPIV public properties
%   nOverlap        - The number of overlaps within an analysis window
%   nPixelsToFit    - The number of pixels around the peak to fit
%   pointsSNR       - The number of points in the bootstrap SNR estimate
%   shiftAmt        - The number of lines to shift when performing the xcorr
%   thresholdSNR    - The SNR threshold below which to exclude data
%   thresholdSTD	- The std dev multiple above which to exclude data
%   windowTime      - The length of an analysis window [ms]
%   
% ConfigVelocityLSPIV public methods
%   ConfigVelocityLSPIV - ConfigVelocityLSPIV class constructor
%   copy            - Copy MATLAB array of handle objects
%   create_calc     - Return a Calc object containing the Config object
%   get_dims        - Return the dimensions needed for the opt_config GUI
%   opt_config      - Optimise parameters using a GUI
%
% ConfigVelocityLSPIV static methods
%   from_preset     - Create a ConfigVelocityLSPIV object from a preset
%
% ConfigVelocityLSPIV public events:
%   ProcessNow      - Notifies listeners to process an object
%
%   See also ConfigVelocityRadon, Config, ConfigFrameScan,
%   CalcVelocityLSPIV, LineScanVel, FrameScan
    
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
        %   analysis window. [default = 50ms]
        %
        %   See also ConfigVelocityLSPIV.nOverlap, utils.split_into_windows
        windowTime = 50;
        
        %nOverlap - The number of overlaps within an analysis window
        %
        %   A scalar integer representing the number of overlaps that take
        %   place within one analysis window.  The start time of every
        %   window is separated by windowTime/nOverlap. [default = 4]
        %
        %   See also ConfigVelocityLSPIV.windowTime,
        %   utils.split_into_windows
        nOverlap = 4; % Number of overlaps per window
        
        % LS-PIV
        % -------------------------------------------------------------- %
        
        %shiftAmt - The number of lines to shift when performing the xcorr
        %
        %   A scalar integer representing the number of lines to shift when
        %   performing the cross correlation in Fourier space.  For
        %   example, when the value is 1 the image will be autocorrelated
        %   with the image starting on the next line; when the value is 10,
        %   the image will the be autocorrelated with the image starting 10
        %   lines later.
        %
        %   Larger values should be used when the RBCs are moving slowly,
        %   to improve the accuracy of the velocity detection; smaller
        %   values should be used when the RBCs are moving quickly, to
        %   ensure that the same RBCs are still present in the image and
        %   can be correlated with their previous position. [default = 1]
        shiftAmt = 1; % N of lines to shift when performing the fft-xcorr
        
        %nPixelsToFit - The number of pixels around the peak to fit
        %
        %   A scalar integer representing the number of pixels on each side
        %   of the maximum value to include in the Gaussian peak fitting.
        %   [default = 25 pixels]
        %
        %   See also utils.gaussian_peakfit
        nPixelsToFit = 10;
        
        % Post-processing
        % -------------------------------------------------------------- %
        
        %pointsSNR - The number of points in the bootstrap SNR estimate
        %
        %   A scalar integer representing the points to include in the
        %   bootstrap estimate of signal to noise ratio (SNR). 
        %   [default = 12]
        %
        %   See also ConfigVelocityLSPIV.thresholdSNR
        pointsSNR = 12;
        
        %thresholdSNR - The SNR threshold below which to exclude data
        %
        %   A scalar number representing the SNR value below which the
        %   velocity data will be considered 'bad' and flagged. 
        %   [default = 2]
        %
        %   See also ConfigVelocityLSPIV.pointsSNR, DataVelocity.maskSNR
        thresholdSNR = 1.5;
        
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
        
        classCalc = 'CalcVelocityLSPIV';
        
        optList = {...
            'Windows', {'windowTime', 'nOverlap'}; ...
            'LS-PIV', {'shiftAmt', 'nPixelsToFit'}; ...
            'Postprocessing', {'pointsSNR', 'thresholdSNR', ...
                'thresholdSTD'}};
            
    end
    
    % ================================================================== %
    
    methods
        
        function ConfigVelocityLSPIVObj = ConfigVelocityLSPIV(varargin)
        %ConfigVelocityLSPIV - ConfigVelocityLSPIV class constructor
        %
        %   OBJ = ConfigVelocityLSPIV() creates a ConfigVelocityLSPIV
        %   object OBJ with default values for all properties.
        %
        %   OBJ = ConfigVelocityLSPIV(..., 'property', value, ...) or
        %   OBJ = ConfigVelocityLSPIV(..., propStruct, ...) 
        %
        %   This syntax specifies values for the properties, either in the
        %   form of attribute-value pairs, or structures (or objects) where
        %   the field (property) names correspond to properties in the
        %   ConfigVelocityLSPIV class. The argument parsing is done by
        %   the utility function parsepropval (link below), so please
        %   consult the documentation for this function for more details.
        %
        %   See also utils.parsepropval,
        %   ConfigVelocityLSPIV.from_preset, ConfigVelocityRadon,
        %   Config, ConfigFrameScan, CalcVelocityLSPIV, LineScanVel,
        %   FrameScan, ICalcVelocityStreaks
                       
            % Call Config (i.e. parent class) constructor
            ConfigVelocityLSPIVObj = ...
                ConfigVelocityLSPIVObj@Config(varargin{:});
            
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
        
        function self = set.shiftAmt(self, val)
            utils.checks.prfsi(val, 'shiftAmt')
            self.shiftAmt = val;
        end
        
        % -------------------------------------------------------------- %
        
        function self = set.nPixelsToFit(self, val)
            utils.checks.prfsi(val, 'nPixelsToFit')
            self.nPixelsToFit = val;
        end
        
        % -------------------------------------------------------------- %
        
        function self = set.pointsSNR(self, val)
            utils.checks.prfsi(val, 'pointsSNR')
            self.pointsSNR = val;
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
