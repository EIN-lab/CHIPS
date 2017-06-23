classdef DataDetectSigsClsfy < DataDetectSigs
%DataDetectSigsClsfy - Data from signal detection and classification
%
%   The DataDetectSigsClsfy class is a data class that is designed to
%   contain all the data output from CalcDetectSigsClsfy.
%
% DataDetectSigsClsfy public properties inherited from Data:
%   mask            - A mask combining all of the other masks
%   means           - A helper structure containing means of the data
%   nPlotsGood      - The number of plots in non-debug mode        
%   nPlotsDebug     - The number of plots in debug mode
%   state           - The current state
%   stdevs          - A helper structure containing stdevs of the data
%
% DataDetectSigsClsfy public properties
%   amplitude       - The amplitude of the peaks [dF/F]
%   fullWidth       - The estimated full peak width [s]
%   halfWidth       - The peak width at half maximum [s]
%   numPeaks        - The number of peaks per signal
%   peakAUC         - The peak area under the curve [dF/F*s]
%   peakStart       - The estimated peak start time [s]
%   peakStartHalf   - The peak half height start time [s]
%   peakTime        - The time of peak maximum [s]
%   peakType        - The peak type classification
%   prominence      - The peak prominence [dF/F]
%   roiName         - The ROI name
%
% DataDetectSigsClsfy public methods:
%   add_raw_data    - Add raw data to the Data object
%   add_processed_data - Add processed data to the Data object
%   add_mask_data   - Add mask data to the Data object
%   plot            - Plot a single graph from the data object
%   plot_graphs     - Plot multiple graphs from the data object
%   output_data     - Output the data
%
%   See also DataDetectSigsDummy, DataDetectSigs, Data,
%   CalcDetectSigsClsfy, CellScan

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
        
        %amplitude - The amplitude of the peaks [dF/F]
        %
        %   A cell vector of the absolute signal amplitude represented as
        %   fold change (dF/F).
        %
        %   See also CalcMeasureROIsClsfy.measure_ROIs
        amplitude
        
        %fullWidth - The estimated full peak width [s]
        %
        %   A cell vector of the estimated duration from peak start to end
        %   in seconds.
        %
        %   See also CalcMeasureROIsClsfy.measure_ROIs,
        %   CalcDetectSigsClsfy.peakStartEnd
        fullWidth
        
        %halfWidth - The peak width at half maximum [s]
        %
        %   A cell vector of the measured peak width at half maximal peak
        %   prominence in seconds.
        %
        %   See also CalcMeasureROIsClsfy.measure_ROIs, findpeaks
        halfWidth
        
        %numPeaks - The number of peaks per signal
        %
        %   A cell vector of the counted number of peaks (for signals
        %   classified as multi peaks)
        %
        %   See also CalcMeasureROIsClsfy.measure_ROIs
        numPeaks
        
        %peakAUC - The peak area under the curve [dF/F*s]
        %
        %   A cell vector of the estimated area under the peak as
        %   calculated by MATLAB's trapz() function.
        %
        %   See also CalcMeasureROIsClsfy.measure_ROIs, trapz
        peakAUC
        
        %peakTime - The time of peak maximum [s]
        %
        %   A cell vector of the frame time at which the peak reaches its
        %   maximum in seconds.
        %
        %   See also CalcMeasureROIsClsfy.measure_ROIs, findpeaks
        peakTime
        
        %peakStart - The estimated peak start time [s]
        %
        %   A cell vector of the estimated time at which the peak starts in
        %   seconds.
        %
        %   See also CalcMeasureROIsClsfy.measure_ROIs,
        %   CalcDetectSigsClsfy.peakStartEnd
        peakStart
        
        %peakStartHalf - The peak half height start time [s]
        %
        %   A cell vector of the estimated time at which the peak half
        %   height starts in seconds.
        %
        %   See also CalcMeasureROIsClsfy.measure_ROIs,
        %   CalcDetectSigsClsfy.peakStartEnd
        peakStartHalf
        
        %peakType - The peak type classification
        %
        %   A cell vector of the name of the peak type according to its
        %   classification as either a single peak, multi peak or plateau
        %   signal.
        %
        %   See also CalcMeasureROIsClsfy.measure_ROIs
        peakType
        
        %prominence - The peak prominence [dF/F]
        %
        %   A cell vector of the measured peak prominence represented as
        %   fold change (dF/F).
        %
        %   See also CalcMeasureROIsClsfy.measure_ROIs, findpeaks
        prominence
        
        % mask data
        
    end
    
    % ------------------------------------------------------------------ %
    
    properties (Constant, Access = protected)
        
        listRaw = {};
        listProcessed = {'peakType', 'numPeaks', 'amplitude', ...
            'prominence', 'peakAUC', 'peakTime', 'peakStart', ...
            'peakStartHalf', 'halfWidth', 'fullWidth', 'roiName'};
        listMask = {};
        
        listPlotDebug = {'peakAUC', 'amplitude', 'prominence', ...
            'numPeaks', 'peakTime', 'halfWidth'};
        labelPlotDebug = {'Area Under Peak [a.u.]', 'Amplitude [dF/F]', ...
            'Prominence [dF/F]', 'Number of peaks', 'Peak Time [s]', ...
            'Peak Width at Half Max [s]'}
        
        listPlotGood = {'peakAUC', 'amplitude', 'prominence', ...
            'numPeaks', 'peakTime', 'halfWidth'};
        labelPlotGood = {'Area Under Peak [a.u.]', 'Amplitude [dF/F]', ...
            'Prominence [dF/F]', 'Number of peaks', 'Peak Time [s]', ...
            'Peak Width at Half Max [s]'}
        
        listMean = {};
        
        listOutput = {'peakAUC', 'prominence', 'amplitude', ...
            'peakTime', 'peakStart', 'peakStartHalf', 'halfWidth', ...
            'fullWidth', 'numPeaks', 'peakType', 'roiName'};
        nameDataClass = 'Signal Detection (Clsfy)';
        suffixDataClass = 'sigDetectionClsfy';
        
    end
    
    % ================================================================== %
    
    methods
        
        function plot_graphs(self, varargin)
            
            % Check for the statistics toolbox
            feature = 'Statistics_Toolbox';
            className = 'DataDetectSigsClsfy:PlotGraphs';
            utils.verify_license(feature, className);
                        
            % Check axis handle is the correct class, create one if it
            % doesn't exist, and work out where the rest of the arguments
            % are
            hAxes = [];
            hasAxes = (nargin > 1) && all(ishghandle(varargin{1})) && ...
                all(isgraphics(varargin{1}, 'axes'));
            if hasAxes

                % Check we have enough arguments in this case
                narginchk(1, inf)

                % Pull out the axis
                hAxes = varargin{1};

            end
            
            % Create list of vars
            yVarList = self.listPlotDebug;
            nAxes = length(yVarList);
            yLabelList = self.labelPlotDebug;
            
            % Create axis handles, if necessary
            if isempty(hAxes)
                for iAx = nAxes:-1:1
                    hAxes(iAx) = utils.subplot_tight(1, nAxes, iAx, 0.05);
                end
            end
            
            % For each var...
            for iAx = nAxes:-1:1
                
                % Plot a boxplot 
                yVar = cell2mat(self.(yVarList{iAx}));
                boxplot(hAxes(iAx), yVar, 'widths', 1, 'colors', 'k', ...
                    'jitter', 2/3, 'symbol', 'kx')
                
                % Create a label
                ylabel(hAxes(iAx), yLabelList(iAx));
                
                % Remove the X axis labelling etc
                set(hAxes(iAx), 'XTick', [])
                set(hAxes(iAx), 'XTickLabel', '')
                
            end
            
        end
        
        % -------------------------------------------------------------- %
        
        function self = set.amplitude(self, val)
            
            % Check property is a cell array
            utils.checks.cell_array(val, 'amplitude')
            
            % Check property is a vector
            utils.checks.vector(val, 'amplitude')
            
            % Assign property
            self.amplitude = val;
        end
        
        % -------------------------------------------------------------- %
        
        function self = set.fullWidth(self, val)
            
            % Check property is a cell array
            utils.checks.cell_array(val, 'fullWidth')
            
            % Check property is a vector
            utils.checks.vector(val, 'fullWidth')
            
            % Assign property
            self.fullWidth = val;
        end
        
        % -------------------------------------------------------------- %
        
        function self = set.halfWidth(self, val)
            
            % Check property is a cell array
            utils.checks.cell_array(val, 'halfWidth')
            
            % Check property is a vector
            utils.checks.vector(val, 'halfWidth')
            
            % Assign property
            self.halfWidth = val;
        end
        
        % -------------------------------------------------------------- %
        
        function self = set.numPeaks(self, val)
            
            % Check property is a cell array
            utils.checks.cell_array(val, 'numPeaks')
            
            % Check property is a vector
            utils.checks.vector(val, 'numPeaks')
            
            % Assign property
            self.numPeaks = val;
        end
        
        % -------------------------------------------------------------- %
        
        function self = set.peakTime(self, val)
            
            % Check property is a cell array
            utils.checks.cell_array(val, 'peakTime')
            
            % Check property is a vector
            utils.checks.vector(val, 'peakTime')
            
            % Assign property
            self.peakTime = val;
        end
        
        % -------------------------------------------------------------- %
        
        function self = set.peakStart(self, val)
            
            % Check property is a cell array
            utils.checks.cell_array(val, 'peakStart')
            
            % Check property is a vector
            utils.checks.vector(val, 'peakStart')
            
            % Assign property
            self.peakStart = val;
        end
        
        % -------------------------------------------------------------- %
        
        function self = set.peakStartHalf(self, val)
            
            % Check property is a cell array
            utils.checks.cell_array(val, 'peakStartHalf')
            
            % Check property is a vector
            utils.checks.vector(val, 'peakStartHalf')
            
            % Assign property
            self.peakStartHalf = val;
        end
        
        % -------------------------------------------------------------- %
        
        function self = set.peakType(self, val)
            
            % Check property is a cell array
            utils.checks.cell_array(val, 'peakType')
            
            % Check property is a vector
            utils.checks.vector(val, 'peakType')
            
            % Assign property
            self.peakType = val;
        end
        
        % -------------------------------------------------------------- %
        
        function self = set.prominence(self, val)
            
            % Check property is a cell array
            utils.checks.cell_array(val, 'prominence')
            
            % Check property is a vector
            utils.checks.vector(val, 'prominence')
            
            % Assign property
            self.prominence = val;
        end
        
        % -------------------------------------------------------------- %
        
        function self = set.peakAUC(self, val)
            
            % Check property is a cell array
            utils.checks.cell_array(val, 'peakAUC')
            
            % Check property is a vector
            utils.checks.vector(val, 'peakAUC')
            
            % Assign property
            self.peakAUC = val;
        end
        
    end
    
    % ================================================================== %
        
end
