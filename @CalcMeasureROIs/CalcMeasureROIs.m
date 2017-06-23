classdef (Abstract) CalcMeasureROIs < Calc
%CalcMeasureROIs - Superclass for CalcMeasureROIs classes
%
%   CalcMeasureROIs is an abstract superclass that implements (or requires
%   implementation in its subclasses via abstract methods or properties)
%   most functionality related to CalcMeasureROIs objects.  Typically there
%   is one concrete subclass of CalcMeasureROIs for every calculation
%   algorithm, and it contains the algorithm-specific code that is needed
%   for the calculation.
%
%   CalcMeasureROIs is a subclass of matlab.mixin.Copyable, which is itself
%   a subclass of handle, meaning that CalcMeasureROIs objects are actually
%   references to the data contained in the object.  This allows certain
%   features that are only possible with handle objects, such as events and
%   certain GUI operations.  However, it is important to use the copy
%   method of matlab.mixin.Copyable to create a new, independent object;
%   otherwise changes to a CalcMeasureROIs object used in one place will
%   also lead to changes in another (perhaps undesired) place.
%
% CalcMeasureROIs public properties
%   config          - A scalar ConfigMeasureROIs object
%   data            - A scalar DataMeasureROIs object
%
% CalcMeasureROIs public methods
%   CalcMeasureROIs - CalcMeasureROIs class constructor
%   copy            - Copy MATLAB array of handle objects
%   get_doHeatmap   - Decide whether to plot a heatmap instead of lines
%   get_plotROIs    - Check and/or return the ROI numbers to plot
%   plot            - Plot a figure
%   process         - Run the processing
%
%   See also CalcMeasureROIsDummy, CalcMeasureROIsMovingBL,
%   CalcMeasureROIsZScore, Calc, ConfigMeasureROIs, DataMeasureROIs,
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
        nTracesHeatmap = 15;
        validPlotNames = {'traces'};
        validProcessedImg = {'CellScan'};
    end
    
    % ================================================================== %
    
    methods
        
        function CalcMeasureROIsObj = CalcMeasureROIs(varargin)
        %CalcMeasureROIs - CalcMeasureROIs class constructor
        %
        %   OBJ = CalcMeasureROIs() prompts for all required information
        %   and creates a CalcMeasureROIs object.
        %
        %   OBJ = CalcMeasureROIs(CONFIG, DATA) uses the specified CONFIG
        %   and DATA objects to construct the CalcMeasureROIs object. If
        %   any of the input arguments are empty, the constructor will
        %   prompt for any required information.  The input arguments must
        %   be objects which meet the requirements of the particular
        %   concrete subclass of CalcMeasureROIs.
        %
        %   See also ConfigMeasureROIs, DataMeasureROIs
            
            % Parse arguments
            [configIn, dataIn] = utils.parse_opt_args({[], []}, varargin);
            
            % Call Calc (i.e. parent class) constructor
            CalcMeasureROIsObj = CalcMeasureROIsObj@Calc(configIn, dataIn);
            
        end
        
        % -------------------------------------------------------------- %
        
        function doHeatmap = get_doHeatmap(self, doHeatmap, nROIs)
        %get_doHeatmap - Decide whether to plot a heatmap instead of lines
        %
        %   DO_HEATMAP = get_doHeatmap(OBJ, DO_HEATMAP, N_ROIS) decides
        %   whether to plot the traces in the form of a lines (better for
        %   small numbers of traces) or a heatmap (better for larger
        %   numbers of traces). DO_HEATMAP must be supplied as a scalar
        %   boolean, or an empty array, and N_ROIS is the number of ROIs
        %   that will be plotted.  DO_HEATMAP will only change when it is
        %   supplied as an empty value.
        %
        %   See also CalcMeasureROIs.plot, CalcMeasureROIs.get_plotROIs, 
        %   DataMeasureROIs

            % Set up the doHeatmap parameter based on how many ROIs we are
            % choosing to plot
            if isempty(doHeatmap)

                % Set the default based on the number of ROIs we have
                if nROIs > self.nTracesHeatmap
                    doHeatmap = true;
                else
                    doHeatmap = false;
                end
                
            else
                
                % Check the value
                utils.checks.scalar_logical_able(doHeatmap, 'doHeatmap');
                doHeatmap = logical(doHeatmap);

            end
            
        end
        
        % -------------------------------------------------------------- %
        
        [plotROIs, nROIs] = get_plotROIs(self, plotROIs)
        
        % -------------------------------------------------------------- %
        
        function self = process(self, objPI)
        %process - Run the processing
        %
        %   OBJ = process(OBJ, OBJ_PI) runs the processing on the
        %   CalcDetectSigs object OBJ using the CellScan object OBJ_PI.
        %
        %   See also CellScan.process, CellScan
        
            % Check the number of input arguments
            narginchk(2, 2);
        
            % Check the ProcessedImg
            self.check_objPI(objPI);
            
            % Measure the ROIs
            self = self.measure_ROIs(objPI);
            
            % Normalise the traces
            self = normalise_traces(self);
            
        end
        
        % -------------------------------------------------------------- %
        
        varargout = plot(self, objPI, varargin)
                
    end
        
    % ================================================================== %
    
    methods (Access = protected)
        
        function [time, rawTrace] = get_rawTrace(self, objPI)
            
            % Pull out any properties that we'll need
            frameRate = objPI.rawImg.metadata.frameRate;
            t0 = objPI.rawImg.t0;
            
            % Get data from RawImg
            imgSeq = squeeze(...
                objPI.rawImg.rawdata(:,:,objPI.channelToUse,:));
            imgSeq = double(imgSeq);
            nFrames = size(imgSeq, 3);
            
            % Create the time vector
            time = ((0.5:nFrames-0.5)./frameRate)' - t0;
            
            % Measure the whole frame trace
            ignoreInf = true;
            if self.config.propagateNaNs
                rawTrace = squeeze(mean(mean(imgSeq, 1), 2));
            else
                rawTrace = squeeze(utils.nansuite.nanmean(...
                    utils.nansuite.nanmean(imgSeq, 1, ignoreInf), ...
                        2, ignoreInf));
            end
            
        end
        
        % -------------------------------------------------------------- %
        
        function self = measure_ROIs(self, objPI)
            
            % Get the roiNames
            roiNames = objPI.calcFindROIs.data.roiNames;
            
            % Get the raw trace (i.e. the average of the whole frame)
            [time, rawTrace] = self.get_rawTrace(objPI);
            
            % Get the remaining traces
            [traces, tracesExist] = objPI.calcFindROIs.measure_ROIs(objPI);
            
            % Add the raw data
            self.data = self.data.add_raw_data(rawTrace, roiNames, ...
                time, traces, tracesExist);
        
        end
        
        % -------------------------------------------------------------- %
        
        varargout = plot_traces(self, objPI, hAxTraces, varargin)
        
        % -------------------------------------------------------------- %
        
        traces = plot_traces_lines(self, traces, hAxTraces, params)
        
        % -------------------------------------------------------------- %
        
        traces = plot_traces_heatmap(self, traces, hAxTraces, params)
        
    end
    
    % ================================================================== %
    
    methods (Abstract, Access = protected)
        
        self = normalise_traces(self)
        
    end
    
    % ================================================================== %
    
    methods (Static, Access = protected)
        
        function hAxTraces = get_hAxTraces(hAxTraces, nAxes, doWholeFrame)
            
            if isempty(hAxTraces)
                
                % Adjust the number of axes so it doesn't get too crazy-big
                nAxesToUse = min([nAxes, 22]);

                % Create them if necessary
                mTraces = [0.05, 0.03];
                if doWholeFrame
                    nAxesToUse = nAxesToUse+1;
                    hAxTraces(1) = utils.subplot_tight(...
                        nAxesToUse, 1, 1:2, mTraces);
                    if nAxesToUse > 2
                        hAxTraces(2) = utils.subplot_tight(...
                            nAxesToUse, 1, 3:nAxesToUse, mTraces);
                    end
                else
                    hAxTraces(1) = utils.subplot_tight(...
                        nAxesToUse, 1, 1, mTraces);
                end

            else
                
                % Otherwise check that they're axes and there are enough of them
                utils.checks.hghandle(hAxTraces, 'axes', 'hAxes');
                wngState = warning('off', 'Utils:Checks:Numel:IsScalar');
                if doWholeFrame
                    utils.checks.numel(hAxTraces, min([nAxes, 2]), ...
                        'axes')
                else
                    utils.checks.numel(hAxTraces, min([nAxes, 1]), ...
                        'axes')
                end
                warning(wngState)
                
            end
    
        end
        
    end
    
    % ================================================================== %
    
end
