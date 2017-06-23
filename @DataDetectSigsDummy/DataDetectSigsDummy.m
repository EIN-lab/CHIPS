classdef DataDetectSigsDummy < DataDetectSigs
%DataDetectSigsDummy - Data from dummy signal detection
%
%   The DataDetectSigsDummy class is a data class that is designed to
%   contain all the basic data output from CalcDetectSignalsDummy.
%
% DataDetectSigsDummy public properties inherited from Data:
%   mask            - A mask combining all of the other masks
%   means           - A helper structure containing means of the data
%   nPlotsGood      - The number of plots in non-debug mode        
%   nPlotsDebug     - The number of plots in debug mode
%   state           - The current state
%   stdevs          - A helper structure containing stdevs of the data
%
% DataDetectSigsDummy public properties
%   roiName         - The ROI name
%
% DataDetectSigsDummy public methods:
%   add_raw_data    - Add raw data to the Data object
%   add_processed_data - Add processed data to the Data object
%   add_mask_data   - Add mask data to the Data object
%   plot            - Plot a single graph from the data object
%   plot_graphs     - Plot multiple graphs from the data object
%   output_data     - Output the data
%
%   See also DataDetectSigsClsfy, DataDetectSigs, Data,
%   CalcDetectSigsDummy, CellScan

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
        
        listRaw = {};
        listProcessed = {'roiName'};
        listMask = {};
        
        listPlotDebug = {};
        labelPlotDebug = {}
        
        listPlotGood = {};
        labelPlotGood = {}
        
        listMean = {};
        
        listOutput = {};
        nameDataClass = 'Signal Detection (Dummy)';
        suffixDataClass = 'sigDetectionDummy';
        
    end
    
    % ================================================================== %
    
    methods
        
    end
    
    % ================================================================== %
        
end
