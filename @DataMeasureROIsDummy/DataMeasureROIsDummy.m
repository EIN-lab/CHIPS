classdef DataMeasureROIsDummy < DataMeasureROIs
%DataMeasureROIsDummy - Data from basic ROI measurements
%
%   The DataMeasureROIsDummy class is a data class that is designed to
%   contain all the basic data output from CalcMeasureROIs.
%
% DataMeasureROIsDummy public properties inherited from Data:
%   mask            - A mask combining all of the other masks
%   means           - A helper structure containing means of the data
%   nPlotsGood      - The number of plots in non-debug mode        
%   nPlotsDebug     - The number of plots in debug mode
%   state           - The current state
%   stdevs          - A helper structure containing stdevs of the data
%
% DataMeasureROIsDummy public properties
%   rawTrace	- A vector of whole frame intensity over time [a.u.]
%   rawTraceNorm - A time series of normalised whole frame intensity [a.u.] 
%   roiNames    - The ROI names
%   time        - A vector indicating the time point for each frame [s]
%   traces      - The intensity over time for each ROI [a.u.]
%   tracesExist - Whether or not the trace exists at a given time
%   tracesNorm  - The normalised intensity over time for each ROI [a.u.]
%
% DataMeasureROIsDummy public methods:
%   add_raw_data    - Add raw data to the Data object
%   add_processed_data - Add processed data to the Data object
%   add_mask_data   - Add mask data to the Data object
%   plot            - Plot a single graph from the data object
%   plot_graphs     - Plot multiple graphs from the data object
%   output_data     - Output the data
%
%   See also DataMeasureROIs, DataMeasureROIsClsfy, CalcMeasureROIsDummy,
%   Data, CellScan

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
        
        listRaw = {'rawTrace', 'roiNames' 'time', 'traces', 'tracesExist'};
        listProcessed = {'rawTraceNorm', 'tracesNorm'};
        listMask = {};
        
        listPlotDebug = {'traces'};
        labelPlotDebug = {'Traces [a.u.]'};
        
        listPlotGood = {'traces'};
        labelPlotGood = {'Traces [a.u.]'};
        
        listMean = {};
        
        listOutput = {'time', 'rawTrace', 'rawTraceNorm', ...
            'traces', 'tracesNorm'};
        nameDataClass = 'ROIs Measurement (Dummy)';
        suffixDataClass = 'roiMeasurementDummy';
        
    end
    
    % ================================================================== %
    
    methods (Access = protected)
        
        function hdrCell = get_headers(self, delimiter)
            
            % This a special case, where we want the ROI names 
            hdrCell(1:3) = self.listOutput(1:3);
            hdrTraces = sprintf([self.listOutput{4} '_%s' delimiter], ...
                self.roiNames{:});
            hdrCell{4} = hdrTraces(1:end-1);
            hdrTracesNorm = sprintf([self.listOutput{5}, '_%s' delimiter], ...
                self.roiNames{:});
            hdrCell{5} = hdrTracesNorm(1:end-1);
            
        end
        
    end
    
    % ================================================================== %
        
end
