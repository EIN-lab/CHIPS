classdef CalcVelocityLSPIV < CalcVelocityStreaks
%CalcVelocityLSPIV - Class for calculating velocity using LSPIV
%
%   The CalcVelocityLSPIV class is Calc class that implements all basic
%   functionality related to calculating the velocity of images using the
%   line scanning particle imaging velocimetry (LSPIV) algorithm. For more
%   information on the algorithm, please refer to <a href="matlab:web('http://dx.doi.org/10.1371/journal.pone.0038590', '-browser')">Kim et al. (2012)</a>, 
%   PLoS One 7(6):e38590.
%
%   CalcVelocityLSPIV is a subclass of matlab.mixin.Copyable, which is
%   itself a subclass of handle, meaning that CalcVelocityLSPIV objects are
%   actually references to the data contained in the object.  This allows
%   certain features that are only possible with handle objects, such as
%   events and certain GUI operations.  However, it is important to use the
%   copy method of matlab.mixin.Copyable to create a new, independent
%   object; otherwise changes to a CalcVelocityLSPIV object used in one
%   place will also lead to changes in another (perhaps undesired) place.
%
% CalcVelocityLSPIV public properties
%   config          - A scalar ConfigVelocityLSPIV object
%   data            - A scalar DataVelocityLSPIV object
%
% CalcVelocityLSPIV public methods
%   CalcVelocityLSPIV - CalcVelocityLSPIV class constructor
%   copy            - Copy MATLAB array of handle objects
%   plot            - Plot a figure
%   process         - Run the processing
%
%   See also CalcVelocityRadon, CalcVelocityStreaks, Calc,
%   ConfigVelocityLSPIV, DataVelocityLSPIV, LineScanVel, FrameScan,
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
        validConfig = {'ConfigVelocityLSPIV'};
        validData = {'DataVelocityLSPIV'};
    end
    
    % ================================================================== %
    
    methods
        
        function CalcVelocityLSPIVObj = CalcVelocityLSPIV(varargin)
        %CalcVelocityLSPIV - CalcVelocityLSPIV class constructor
        %
        %   OBJ = CalcVelocityLSPIV() prompts for all required information
        %   and creates a CalcVelocityLSPIV object.
        %
        %   OBJ = CalcVelocityLSPIV(CONFIG, DATA) uses the specified CONFIG
        %   and DATA objects to construct the CalcVelocityLSPIV object. If
        %   any of the input arguments are empty, the constructor will
        %   prompt for any required information. The input arguments must
        %   be scalar ConfigVelocityLSPIV and/or DataVelocityLSPIV objects.
        %
        %   See also ConfigVelocityLSPIV, DataVelocityLSPIV
            
            % Parse arguments
            [configIn, dataIn] = utils.parse_opt_args({[], []}, varargin);
            
            % Call CalcVelocityStreaks (i.e. parent class) constructor
            CalcVelocityLSPIVObj = ...
                CalcVelocityLSPIVObj@CalcVelocityStreaks(configIn, dataIn);
            
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
            
            % Check the ProcessedImg
            self.check_objPI(objPI);
            
            % Split the data into big windows for faster/better processing
            windowTime = Inf;
            nOverlap = 1;
            bigWindows = objPI.split_into_windows(windowTime, nOverlap);
            
            % Pull out some properties
            pixelSize = objPI.rawImg.metadata.pixelSize;
            lineTime = objPI.rawImg.metadata.lineTime;
            t0 = objPI.rawImg.t0;
            
            % Turn off unneeded warnings for now
            [lastMsgPre, lastIDPre] = lastwarn();
            wngIDOff = 'GetWindow:ExtendWindow';
            wngState = warning('off', wngIDOff);
            
            % Split the data into smaller windows to extract out the time
            % and y position information
            [~, time, yPosition] = objPI.split_into_windows(...
                self.config.windowTime, self.config.nOverlap);
            time = time - t0;
            
            % Restore the warnings
            warning(wngState)
            utils.clear_unwanted_wngs(wngIDOff, lastMsgPre, lastIDPre)
            
            % Do the calculation
            self = self.calc_velocity(bigWindows, lineTime, ...
                time, yPosition);
            
            % Do the post-processing
            self = self.post_process_velocity(pixelSize, lineTime);
            
        end
        
    end
    
    % ================================================================== %
    
    methods (Access = protected)
        
        self = calc_velocity(self, windowsBig, lineTime, time, yPosition)
        
        % -------------------------------------------------------------- %
        
        self = post_process_velocity(self, pixelSize, lineTime)
        
        % -------------------------------------------------------------- %
        
        hAx = plot_windows(self, objPI, hAx, varargin)
        
    end
    
    % ================================================================== %
    
    methods (Static, Access = protected)
        
        function configObj = create_config()
            configObj = ConfigVelocityLSPIV();
        end
        
        % -------------------------------------------------------------- %
        
        function dataObj = create_data()
            dataObj = DataVelocityLSPIV();
        end
        
        % -------------------------------------------------------------- %
        
        [pixelShift, estSNR, windowCorrAvg] = ...
            calc_pixel_shift(windowCorrImg, nPixelsToFit)
        
        % -------------------------------------------------------------- %
        
        function windowCorrImg = calc_xcorr_img(windowData, shiftAmt)
            
            % Extract out two forms of the same data, including some zero
            % padding to ensure optimal cross correlation
            S1 = windowData(1 : end-shiftAmt,:);
            S2 = windowData(shiftAmt+1 : end, :);
            
            % Do the LS-PIV cross-correlation
            windowCorrImg = utils.xcorr_fft2(S1, S2);

            % Pad the image to ensure it's the same size as the original
            % image, which prevents problems with splitting into different
            % numbers of windows
            windowCorrImg = [zeros(shiftAmt, size(windowCorrImg, 2)); ...
                windowCorrImg];
            
        end
        
        % -------------------------------------------------------------- %
        
        [pixelShift, estSNR, xCorr] = loop_function(...
            funCalcXCorr, windowsBig, nOverlap, windowLines, ...
            nWindowsSmall, funCalcPixelShift, isParallel, ...
            iWinBig, nWinTotal, fnPB, strMsg)
        
    end
    
    % ================================================================== %
    
end
