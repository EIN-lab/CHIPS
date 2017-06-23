classdef CalcVelocityRadon < CalcVelocityStreaks
%CalcVelocityRadon - Class for calculating velocity via the Radon transform
%
%   The CalcVelocityRadon class is Calc class that implements all basic
%   functionality related to calculating the velocity of images using the
%   Radon transform algorithm. For more information on the algorithm,
%   please refer to <a href="matlab:web('http://dx.doi.org/10.1007/s10827-009-0159-1', '-browser')">Drew et al. (2010)</a>, J Comput Neurosci 29(1):5-11.
%
%   CalcVelocityRadon is a subclass of matlab.mixin.Copyable, which is
%   itself a subclass of handle, meaning that CalcVelocityRadon objects are
%   actually references to the data contained in the object.  This allows
%   certain features that are only possible with handle objects, such as
%   events and certain GUI operations.  However, it is important to use the
%   copy method of matlab.mixin.Copyable to create a new, independent
%   object; otherwise changes to a CalcVelocityRadon object used in one
%   place will also lead to changes in another (perhaps undesired) place.
%
% CalcVelocityRadon public properties
%   config          - A scalar ConfigVelocityRadon object
%   data            - A scalar DataVelocityRadon object
%
% CalcVelocityRadon public methods
%   CalcVelocityRadon - CalcVelocityRadon class constructor
%   copy            - Copy MATLAB array of handle objects
%   plot            - Plot a figure
%   process         - Run the processing
%
%   See also CalcVelocityLSPIV, CalcVelocityStreaks, Calc,
%   ConfigVelocityRadon, DataVelocityRadon, LineScanVel, FrameScan,
%   StreakScan, ICalcVelocityStreaks

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
    
    properties (Constant, Access = protected)
        validConfig = {'ConfigVelocityRadon'};
        validData = {'DataVelocityRadon'};
    end
    
    % ================================================================== %
    
    methods
        
        function CalcVelocityRadonObj = CalcVelocityRadon(varargin)
        %CalcVelocityRadon - CalcVelocityRadon class constructor
        %
        %   OBJ = CalcVelocityRadon() prompts for all required information
        %   and creates a CalcVelocityRadon object.
        %
        %   OBJ = CalcVelocityRadon(CONFIG, DATA) uses the specified CONFIG
        %   and DATA objects to construct the CalcVelocityRadon object. If
        %   any of the input arguments are empty, the constructor will
        %   prompt for any required information. The input arguments must
        %   be scalar ConfigVelocityRadon and/or DataVelocityRadon objects.
        %
        %   See also ConfigVelocityRadon, DataVelocityRadon
        
            % Parse arguments
            [configIn, dataIn] = utils.parse_opt_args({[], []}, varargin);
            
            % Call CalcVelocityStreaks (i.e. parent class) constructor
            CalcVelocityRadonObj = ...
                CalcVelocityRadonObj@CalcVelocityStreaks(configIn, dataIn);
            
        end
        
        % -------------------------------------------------------------- %
        
        function self = process(self, objPI)
        %process - Run the processing
        %
        %   OBJ = process(OBJ, OBJ_PI) runs the processing on the
        %   CalcVelocityRadon object OBJ using the StreakScan object
        %   OBJ_PI.
        %
        %   See also StreakScan.process, LineScanVel, FrameScan,
        %   StreakScan, ICalcVelocityStreaks
        
            % Check the number of input arguments
            narginchk(2, 2);
            
            % Check for the image and signal processing toolboxes
            featureImg = 'Image_Toolbox';
            className = 'CalcVelocityRadon';
            utils.verify_license(featureImg, className);
            featureSig = 'Signal_Toolbox';
            toolboxdirSig = 'signal';
            verSig = '6.22';
            isOldToolbox = utils.verify_license(featureSig, className, ...
                toolboxdirSig, verSig) < 1;
            
            % Check the ProcessedImg
            self.check_objPI(objPI);
            
            % Pull out some properties
            pixelSize = objPI.rawImg.metadata.pixelSize;
            lineTime = objPI.rawImg.metadata.lineTime;
            pixelTime = objPI.rawImg.metadata.pixelTime;
            if isempty(pixelTime)
                if ~isempty(objPI.rawImg.metadata.nPixelsPerLineOrig)
                    pixPerLine = objPI.rawImg.metadata.nPixelsPerLineOrig;
                else
                    pixPerLine = objPI.rawImg.metadata.nPixelsPerLine;
                end
                pixelTime = lineTime ./ pixPerLine;
                warning('CalcVelocityRadon:Process:NoPixelTime', ...
                    'No pixel time was found so using an assumed value.')
            end
            t0 = objPI.rawImg.t0;
            
            % Split the long data format into windows
            [windows, time, yPosition] = objPI.split_into_windows(...
                self.config.windowTime, self.config.nOverlap);
            time = time - t0;
            
            % Do the calculation
            self = self.calc_velocity(windows, time, yPosition, ...
                objPI.isDarkStreaks, pixelSize, lineTime, pixelTime, ...
                isOldToolbox);
            
            % Do the post-processing
            self = self.post_process_velocity(pixelSize, lineTime);
            
        end
        
    end
    % ================================================================== %
    
    methods (Access = protected)
        
        function self = calc_velocity(self, windows, time, yPosition, ...
                isDarkStreaks, pixelSize, lineTime, pixelTime, ...
                isOldToolbox)
            
            % Calculate the angle, flux, and estimated SNR
            [theta, estSNR, flux, thetaRangeMid, linearDens, ...
             rbcSpacingT] = self.calc_angles_radon(windows, ...
                isDarkStreaks, pixelSize, lineTime, pixelTime, ...
                isOldToolbox);
            
            % Assign the data to the correct structure
            self.data = self.data.add_raw_data(time, theta, flux, ...
                linearDens, rbcSpacingT, yPosition, estSNR, thetaRangeMid);
            
        end
        
        % -------------------------------------------------------------- %
        
        [theta, flux, estSNR, thetaRangeMid, linearDensity, rbcSpacingT] = ...
            calc_angles_radon(self, windows, isDarkStreaks, ...
                pixelSize, lineTime, pixelTime, isOldToolbox)
        
        % -------------------------------------------------------------- %
        
        varargout = calc_angle_radon(self, window, rangeTheta, ...
            isDarkStreaks, pixelSize, lineTime, pixelTime, ...
            isOldToolbox, varargin)
        
        % -------------------------------------------------------------- %
        
        [flux, peakLocs, imgSumAdj, linearDensity, rbcSpacingT, maskRBC] = ...
            calc_flux(self, radonTrans, maxVarTheta, idxMaxVarTheta, ...
                isDarkStreaks, pixelSize, pixelTime, lineTime, nLines, ...
                isOldToolbox, doPlotWindow)
        
        % -------------------------------------------------------------- %
        
        function thetaRange = makeCoarseRange(self, thetaOld)
            
            % A function to generate the coarse range of angles around 
            % a central angle
            
            thetaRange = thetaOld - self.config.rangeCoarse : ...
                self.config.incrCoarse : ...
                thetaOld + self.config.rangeCoarse;
            
            thetaRange = CalcVelocityRadon.maskRange(thetaRange);
            
        end
        
        % -------------------------------------------------------------- %
        
        function thetaRange = makeFineRange(self, thetaOld)
            
            % A function to generate the coarse range of angles around 
            % a central angle
            
            thetaRange = thetaOld - self.config.rangeFine : ...
                self.config.incrFine : ...
                thetaOld + self.config.rangeFine;
            
            thetaRange = CalcVelocityRadon.maskRange(thetaRange);
            
        end
        
        % -------------------------------------------------------------- %
        
        self = post_process_velocity(self, pixelSize, lineTime)
        
        % -------------------------------------------------------------- %
        
        hAx = plot_windows(self, objPI, hAx, varargin)
        
    end
    
    % ================================================================== %
    
    methods (Static, Access = protected)
        
        function configObj = create_config()
            configObj = ConfigVelocityRadon();
        end
        
        % -------------------------------------------------------------- %
        
        function dataObj = create_data()
            dataObj = DataVelocityRadon();
        end
        
        % -------------------------------------------------------------- %
        
        function thetaRange = maskRange(thetaRange)
            
            % Mask any out of range values
            thetaRange = thetaRange(thetaRange >= -90 & thetaRange <= 90);
            
        end
        
        % -------------------------------------------------------------- %
        
        plot_window(imgSum, peakLocs, xp, window, theta, maskRBC, ...
            pixelSize, windowTime, varargin)
        
    end
    
    % ================================================================== %
    
end
