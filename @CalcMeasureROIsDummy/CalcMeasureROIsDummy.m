classdef CalcMeasureROIsDummy < CalcMeasureROIs
%CalcMeasureROIsDummy - Class for basic ROI measurements
%
%   The CalcMeasureROIsDummy class is a Calc class that obtains basic
%   measurements from previously identified ROIs, especially the raw
%   traces, and traces normalised to a baseline period.
%
%   CalcMeasureROIsDummy is a subclass of matlab.mixin.Copyable, which is
%   itself a subclass of handle, meaning that CalcMeasureROIsDummy objects
%   are actually references to the data contained in the object.  This
%   allows certain features that are only possible with handle objects,
%   such as events and certain GUI operations.  However, it is important to
%   use the copy method of matlab.mixin.Copyable to create a new,
%   independent object; otherwise changes to a CalcMeasureROIsDummy object
%   used in one place will also lead to changes in another (perhaps
%   undesired) place.
%
% CalcMeasureROIsDummy public properties
%   config          - A scalar ConfigMeasureROIsDummy object
%   data            - A scalar DataMeasureROIsDummy object
%
% CalcMeasureROIsDummy public methods
%   CalcMeasureROIsDummy - CalcMeasureROIsDummy class constructor
%   copy            - Copy MATLAB array of handle objects
%   get_doHeatmap   - Decide whether to plot a heatmap instead of lines
%   get_plotROIs    - Check and/or return the ROI numbers to plot
%   plot            - Plot a figure
%   process         - Run the processing
%
%   See also CalcMeasureROIsMovingBL, CalcMeasureROIsZScore,
%   CalcMeasureROIs, Calc, ConfigMeasureROIsDummy, DataMeasureROIsDummy,
%   CellScan

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
        
        %validConfig - Constant, protected property containing the name of
        %   the associated Config class
        validConfig = {'ConfigMeasureROIsDummy'};
        
        %validData - Constant, protected property containing the name of
        %   the associated Data class
        validData = {'DataMeasureROIsDummy'};
        
    end
    
    % ================================================================== %
    
    methods
        
        function CalcMeasureROIsObj = CalcMeasureROIsDummy(varargin)
        %CalcMeasureROIsDummy - CalcMeasureROIsDummy class constructor
        %
        %   OBJ = CalcMeasureROIsDummy() prompts for all required
        %   information and creates a CalcMeasureROIsDummy object.
        %
        %   OBJ = CalcMeasureROIsDummy(CONFIG, DATA) uses the specified
        %   CONFIG and DATA objects to construct the CalcMeasureROIsDummy
        %   object. If any of the input arguments are empty, the
        %   constructor will prompt for any required information. The
        %   input arguments must be scalar ConfigMeasureROIsDummy and/or
        %   DataMeasureROIsDummy objects.
        %
        %   See also ConfigMeasureROIsDummy, DataMeasureROIsDummy
        
            % Parse arguments
            [configIn, dataIn] = utils.parse_opt_args({[], []}, varargin);
            
            % Call Calc (i.e. parent class) constructor
            CalcMeasureROIsObj = CalcMeasureROIsObj@CalcMeasureROIs(...
                configIn, dataIn);
            
        end
        
    end
    
    % ================================================================== %
    
    methods (Access = protected)
        
        function self = normalise_traces(self)
            
            % Work out how many ROIs there are, and if there are none, 
            % create some dummy data
            nFrames = numel(self.data.rawTrace);
            if ~isscalar(self.data.traces)
                nROIs = size(self.data.traces, 2);
                tracesNorm = nan(nFrames, nROIs);
            else
                nROIs = 0;
                tracesNorm = self.data.traces;
            end
            
            % Check some details for the baseline calculation
            baselineFrames = self.config.baselineFrames;
            maskOutside = baselineFrames > nFrames;
            hasFramesOutside = any(maskOutside);
            if hasFramesOutside
                warning(['CalcMeasureROIsDummy:NormaliseTraces:' ...
                    'NotEnoughBaselineFrames'], ['Some of the ' ...
                    'specified baseline frames are larger than the ' ...
                    'number of frames in the image (%d) and will ' ...
                    'therefore be ignored.'], nFrames)
                baselineFrames = baselineFrames(~maskOutside);
            end
            
            % Measure the normalised whole frame trace
            ignoreInf = true;
            [~, bgRaw] = utils.subtract_bg(self.data.rawTrace, ...
                self.config.backgroundLevel);
            blVal = utils.nansuite.nanmean(...
                self.data.rawTrace(baselineFrames), [], ignoreInf);
            blVal = blVal - bgRaw;
            if ~isfinite(blVal)
                warning('CalcMeasureROIs:measure_ROIs:NaNBaseline', ...
                    ['The baseline value is not finite.  Perhaps there ' ...
                    'was a problem with motion correction?'])
            end
            
            rawTraceNorm = ((self.data.rawTrace - bgRaw) - blVal) ./ blVal;
            
            % Loop through and calculate the normalised traces
            for iROI = 1:nROIs
            
                % Calculate the background level
                [~, bgLevel] = utils.subtract_bg(...
                    self.data.traces(:, iROI), ...
                    self.config.backgroundLevel);
                
                % Calculate the normalised traces
                traceBL = self.data.traces(baselineFrames, iROI);
                baselineVal = mean(traceBL(isfinite(traceBL)) - bgLevel);
                tracesNorm(:, iROI) = ...
                    ((self.data.traces(:, iROI) -  bgLevel) - ...
                    baselineVal)./baselineVal;
            
            end
            
            % Add the raw data
            self.data = self.data.add_processed_data(...
                rawTraceNorm, tracesNorm);
            
        end
        
    end
    
    % ================================================================== %
    
    methods (Static, Access = protected)
        
        function configObj = create_config()
        %create_config - Creates an object of the associated Config class

            configObj = ConfigMeasureROIsDummy();

        end
        
        % -------------------------------------------------------------- %
        
        function dataObj = create_data()
        %create_data - Creates an object of the associated Data class

            dataObj = DataMeasureROIsDummy();

        end
        
    end
    
    % ================================================================== %
    
end
