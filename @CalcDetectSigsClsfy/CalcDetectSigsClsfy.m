classdef CalcDetectSigsClsfy < CalcDetectSigs
%CalcDetectSigsClsfy - Class for detecting and classifying signals
%
%   The CalcDetectSigsClsfy class is a Calc class that detects and
%   classifies signals in previously identified ROIs.  The signals are
%   classified into up to three main categories: single peaks, plateaus,
%   and multi-peaks, based on their frequency components.  Single peaks
%   represent single higher frequency signals; plateaus represent single
%   lower frequency signals; and multi-peaks represent plateau signals that
%   also contain one or more single peaks. For further information about
%   this algorithm, please refer to <a href="matlab:web('http://dx.doi.org/10.1093/cercor/bhw366', '-browser')">Stobart et al. (2017)</a>, Cerebral Cortex,
%   doi:10.1093/cercor/bhw366.
%
%   CalcDetectSigsClsfy is a subclass of matlab.mixin.Copyable, which is
%   itself a subclass of handle, meaning that CalcDetectSigsClsfy objects
%   are actually references to the data contained in the object.  This
%   allows certain features that are only possible with handle objects,
%   such as events and certain GUI operations.  However, it is important to
%   use the copy method of matlab.mixin.Copyable to create a new,
%   independent object; otherwise changes to a CalcDetectSigsClsfy object
%   used in one place will also lead to changes in another (perhaps
%   undesired) place.
%
% CalcDetectSigsClsfy public properties
%   config          - A scalar ConfigDetectSigsClsfy object
%   data            - A scalar DataDetectSigsClsfy object
%   nColsDetect     - The number of columns needed for plotting
%
% CalcDetectSigsClsfy public methods
%   CalcDetectSigsClsfy  - CalcDetectSigsClsfy class constructor
%   copy            - Copy MATLAB array of handle objects
%   plot            - Plot a figure
%   process         - Run the processing
%
%   See also CalcDetectSigs, CalcDetectSigsDummy, Calc,
%   ConfigDetectSigsClsfy, DataDetectSigsClsfy, CellScan

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
    
    properties (Constant)
        %nColsDetect - The number of columns needed for plotting
        nColsDetect = 6;
    end
    
    % ------------------------------------------------------------------ %
    
    properties (Constant, Access = protected)
        
        %validConfig - Constant, protected property containing the name of
        %   the associated Config class
        validConfig = {'ConfigDetectSigsClsfy'};
        
        %validData - Constant, protected property containing the name of
        %   the associated Data class
        validData = {'DataDetectSigsClsfy'};
        
    end
    
    % ================================================================== %
    
    methods
        
        function cdscObj = CalcDetectSigsClsfy(varargin)
        %CalcDetectSigsClsfy - CalcDetectSigsClsfy class constructor
        %
        %   OBJ = CalcDetectSigsClsfy() prompts for all required
        %   information and creates a CalcDetectSigsClsfy object.
        %
        %   OBJ = CalcDetectSigsClsfy(CONFIG, DATA) uses the specified
        %   CONFIG and DATA objects to construct the CalcDetectSigsClsfy
        %   object. If any of the input arguments are empty, the
        %   constructor will prompt for any required information. The
        %   input arguments must be scalar ConfigDetectSigsClsfy and/or
        %   DataDetectSigsClsfy objects.
        %
        %   See also ConfigDetectSigsClsfy, DataDetectSigsClsfy
        
            % Parse arguments
            [configIn, dataIn] = utils.parse_opt_args({[], []}, varargin);
            
            % Call CalcDetectSigs (i.e. parent class) constructor
            cdscObj = cdscObj@CalcDetectSigs(configIn, dataIn);
            
        end
        
    end
    
    % ================================================================== %
    
    methods (Access = protected)
        
        function varargout = get_fBand(self, frameRate)
            
            fBP_norm = ...
                [self.config.spPassBandMin, self.config.spPassBandMax]/ ...
                (0.5*frameRate);
            
            pbRipple = 1; % dB
            sbAttenuation = 60; % dB
            
            if verLessThan('signal', '6.21')
                
                % Calculate the zeros, poles and gain of the filter
                [z, p, k] = ellip(self.config.spFilterOrder/2, ...
                    pbRipple, sbAttenuation, fBP_norm);
                % Convert to second order sections format
                [sos, g] = zp2sos(z,p,k);
                % Convert to a dfilt obejct
                Hd = dfilt.df2tsos(sos,g);
                varargout{1} = Hd;
                
            else
                fBand = designfilt('bandpassiir', ...
                    'FilterOrder', self.config.spFilterOrder, ...
                    'PassbandFrequency1', fBP_norm(1), ...
                    'PassbandFrequency2', fBP_norm(2), ...
                    'PassbandRipple', pbRipple, ...
                    'StopbandAttenuation1', sbAttenuation, ...
                    'StopbandAttenuation2', sbAttenuation);
                varargout{1} = fBand;
            end
            
        end
        
        % -------------------------------------------------------------- %

        self = detect_sigs(self, tracesNorm, frameRate, roiNames)
        
        % -------------------------------------------------------------- %
        
        varargout = peakClassMeasure(self, traceNorm, frameRate, fBand, ...
            roiName, doPlot, flagVersion)
        
        % -------------------------------------------------------------- %
        
        annotate_traces(self, objPI, hAxTraces, varargin)
        
        % -------------------------------------------------------------- %
        
        varargout = plot_clsfy(self, hAxes, varargin)
        
        % -------------------------------------------------------------- %
        
        varargout = plot_signals(self, objPI, varargin)
        
    end
    
    % ================================================================== %
    
    methods (Static, Access = protected)
        
        peakData = analyse_peak(trace, frameTime, pk, idx, width, ...
            prom, type, numPeaks)
        
        % -------------------------------------------------------------- %
        
        function flagVersion = check_version()
            
            className = 'CalcDetectSigsClsfy';
            featureSig = 'Signal_Toolbox';
            toolboxdirSig = 'signal';
            verSig = '6.22';
            flag = utils.verify_license(featureSig, className, ...
                toolboxdirSig, verSig);
            if flag < 1
                if verLessThan(toolboxdirSig, '6.21')
                    flagVersion = -2;
                else
                    flagVersion = -1;
                end
            else
                flagVersion = 0;
            end

        end
        
        % -------------------------------------------------------------- %
        
        function configObj = create_config()
        %create_config - Creates an object of the associated Config class
        
            configObj = ConfigDetectSigsClsfy();
        
        end
        
        % -------------------------------------------------------------- %
        
        function dataObj = create_data()
        %create_data - Creates an object of the associated Data class
        
            dataObj = DataDetectSigsClsfy();
        
        end
        
        % -------------------------------------------------------------- %
        
        [idxStart, idxEnd] = peakStartEnd(trace, peakLoc, peakHeight, ...
            peakProm, varargin)
        
    end
    
    % ================================================================== %
    
end
