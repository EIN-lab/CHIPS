classdef DataDiameterFWHM < DataDiameter
%DataDiameterFWHM - Data from FWHM diameter calculations
%
%   The DataDiameterFWHM class is a data class that is designed to
%   contain all the basic data output from CalcDiameterFWHM.
%
% DataDiameterFWHM public properties inherited from Data:
%   mask            - A mask combining all of the other masks
%   means           - A helper structure containing means of the data
%   nPlotsGood      - The number of plots in non-debug mode        
%   nPlotsDebug     - The number of plots in debug mode
%   state           - The current state
%   stdevs          - A helper structure containing stdevs of the data
%
% DataDiameterFWHM public properties
%   diameter        - A time series vector of the vessel diameter [µm]
%   diamProfile     - The intensity profile across the vessel diameter
%   idxEdges        - The pixel indices at the vessel edges
%   maskSTD         - Points outside the std range
%   time            - The time series vector [s]
%
% DataDiameterFWHM public methods:
%   add_raw_data    - Add raw data to the Data object
%   add_processed_data - Add processed data to the Data object
%   add_mask_data   - Add mask data to the Data object
%   plot            - Plot a single graph from the data object
%   plot_graphs     - Plot multiple graphs from the data object
%   output_data     - Output the data
%
%   See also DataDiameter, Data, CalcDiameter, LineScanDiam, FrameScan

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
        
        %diamProfile - The intensity profile across the vessel diameter
        %
        %   See also DataDiameterFWHM.idxEdges
        diamProfile
        
        %idxEdges - The pixel indices at the vessel edges
        %
        %   See also DataDiameterFWHM.diamProfile
        idxEdges
        
    end
    
    % ------------------------------------------------------------------ %
    
    properties (Constant, Access = protected)
        
        listRaw = {'time', 'diamProfile', 'idxEdges'};
        listProcessed = {'diameter'};
        listMask = {'maskSTD'};
        
        listPlotDebug = {'diameter'};
        labelPlotDebug = {'Diameter [um]'};
        listPlotGood = {'diameter'};
        labelPlotGood = {'Diameter [um]'};
        
        listMean = {'diameter'};
        
        listOutput = {'time', 'diameter', 'maskSTD', 'mask'};
        nameDataClass = 'Diameter (FWHM)';
        suffixDataClass = 'diameterFWHM';
        
    end
    
    % ================================================================== %
    
    methods
        
        function self = set.diamProfile(self, val)
            utils.checks.finite(val, 'diamProfile');
            utils.checks.real_num(val, 'diamProfile');
            utils.checks.greater_than(val, 0, true, 'diamProfile')
            self.diamProfile = val;
        end
        
        % -------------------------------------------------------------- %
        
        function self = set.idxEdges(self, val)
            maskNotNaN = ~isnan(val);
            utils.checks.real_num(val(maskNotNaN), 'idxEdges');
            utils.checks.positive(val(maskNotNaN), 'idxEdges');
            utils.checks.equal(size(val, 2), 2, ...
                'The number of columns of idxEdges', '2');
            self.idxEdges = val;
        end
        
    end
    
    % ================================================================== %
    
end
