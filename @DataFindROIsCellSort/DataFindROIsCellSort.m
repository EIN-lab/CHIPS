classdef DataFindROIsCellSort < DataFindROIs
%DataFindROIsCellSort - Data from stICA-based ROI identification
%
%   The DataFindROIsCellSort class contains the data generated by
%   CalcFindROIsCellSort.
%
% DataFindROIsCellSort public properties inherited from Data:
%   mask            - A mask combining all of the other masks
%   means           - A helper structure containing means of the data
%   nPlotsGood      - The number of plots in non-debug mode        
%   nPlotsDebug     - The number of plots in debug mode
%   state           - The current state
%   stdevs          - A helper structure containing stdevs of the data
%
% DataFindROIsCellSort public properties:
%   area            - The ROI areas [�m^2]
%   centroidX       - The ROI centroids in the x direction [pixel indices]
%   centroidY       - The ROI centroids in the y direction [pixel indices]
%   icFilters       - X x Y x nIC matrix of ICA spatial filters
%   icMask          - The identified independent components
%   icTraces        - nIC x T matrix of ICA traces
%   pcFilters       - X x Y x nPCs matrix of PCA spatial filters
%   roiFilters      - X x Y x nROIs matrix of ICA spatial filters
%   roiIdxs         - The linear pixel indices for all ROIs
%   roiMask         - The identified ROIs
%   roiNames        - The ROI names
%   segmentlabel    - Origins of segments as indices of ICA filters
%   tAverage        - A temporal average over all frames of image
%   time            - A vector indicating time point for each frame [s]
%
% DataFindROIsCellSort public methods:
%   add_raw_data    - Add raw data to the Data object
%   add_processed_data - Add processed data to the Data object
%   add_mask_data   - Add mask data to the Data object
%   plot            - Plot a single graph from the data object
%   plot_graphs     - Plot multiple graphs from the data object
%   output_data     - Output the data
%
%   See also DataFindROIs, Data, CalcFindROIsCellSort, CellScan

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
        
        % --------------------------------------------------------------- %
        % Raw Data
        % --------------------------------------------------------------- %
        
        %icFilters - X x Y x nICs matrix of ICA spatial filters
        %
        %   Matrix of shape [numRows, numCols, nICs] containing filters
        %   corresponding to regions of segmented ICs. The filters are
        %   obtained as real numbers (similar to roiFilters), but
        %   correspond approximately to the regions defined by icMask.
        %
        %   See also DataFindROIsCellSort.icMask,
        %   DataFindROIsCellSort.roiFilters,
        %   utils.cellsort.CellsortSegmentation
        icFilters
        
        %icTraces - nICs x T matrix of ICA traces
        %
        %   nIC is the number of Independent Components (ICs) used in
        %   computation, it is usually equal to number of Principal
        %   Components (PCs) the image was decomposed to. T is temporal
        %   dimension and corresponds to number of frames.
        %   
        %   See also utils.cellsort.CellsortSegmentation,
        %   utils.cellsort.CellsortICA, utils.cellsort.CellsortPCA
        icTraces
        
        %pcFilters - X x Y x nPCs matrix of PCA spatial filters
        %
        %   Matrix of shape [numRows, numCols, nPCs] containing filters
        %   corresponding to PCs. The filters are obtained as real numbers
        %   (similar to roiFilters).
        %
        %   See also DataFindROIsCellSort.icFilters,
        %   DataFindROIsCellSort.roiFilters,
        %   utils.cellsort.CellsortSegmentation
        pcFilters
        
        %tAverage - A temporal average over all frames of image
        %
        %   The values are stored in 2D array of size [nrows, ncols].
        %
        %   See also utils.cellsort.CellsortPCA
        tAverage
        
        %time - A vector indicating the time point for each frame [s]
        %
        %   The vector indicates the time in seconds relative to the first
        %   frame at which each subsequent frame was recorded.
        %
        %   See also Metadata.frameRate
        time
        
        % --------------------------------------------------------------- %
        % Processed Data
        % --------------------------------------------------------------- %
                
        %icMask - The identified independent components
        %
        %   A logical array representing the independent components (ICs).
        %   icMask can be either 2D or 3D array.
        %
        %   See also utils.cellsort.CellsortSegmentation
        icMask
        
        %roiFilters - X x Y x nROIs matrix of ICA spatial filters
        %
        %   Matrix of shape [numRows, numCols, nROIs] containing filters
        %   corresponding to regions of interest. The filters are obtained
        %   as real numbers (similar to icFilters), but correspond
        %   approximately to the regions defined by roiMask.
        %
        %   See also DataFindROIsCellSort.roiMask,
        %   DataFindROIsCellSort.icFilters,
        %   utils.cellsort.CellsortSegmentation
        roiFilters
        
        %segmentlabel - Origins of segments as indices of ICA filters
        %
        %   If a filter has conected components, these are broken into
        %   segments and segmentlabel tracks their origin.
        %
        %   See also utils.cellsort.CellsortSegmentation, bwlabel
        segmentlabel
        
    end
    
    % -------------------------------------------------------------- %
    
    properties (Constant, Access = protected)
        
        %listRaw - Constant, protected property containing a list of
        %   raw data property names.
        listRaw = {'icFilters', 'icTraces', 'pcFilters', 'tAverage', 'time'};
        
        %listProcessed - Constant, protected property containing a list of
        %   processed data property names.
        listProcessed = {'area', 'centroidX', 'centroidY', 'icMask', ...
            'roiFilters', 'roiIdxs', 'roiMask', 'roiNames', 'segmentlabel'};

        %listMask - Constant, protected property containing a list of
        %   mask data property names.
        listMask = {};
        
        %listPlotDebug - Constant, protected property containing a list of
        %   property names to be used for plotting when in debugging mode.
        listPlotDebug = {};
        
        %labelPlotDebug - Constant, protected property containing a list of
        %   labels to be used for plotting when in debugging mode.
        labelPlotDebug = {};
        
        %listPlotGood - Constant, protected property containing a list of
        %   property names to be used for standard plotting.
        listPlotGood = {};
        
        %labelPlotGood - Constant, protected property containing a list of
        %   labels to be used for standard plotting.
        labelPlotGood = {};
        
        %listMean - Constant, protected property containing a list of
        %   property names to be used to calculate the mean from.
        %
        %   See also Data.means
        listMean = {};
        
        %listOutput - Constant, protected property containing a list of
        %   property names, which can be written to the output CSV file.
        %
        %   See also Data.output_data
        listOutput = {'roiNames', 'area', 'centroidX', 'centroidY', ...
            'segmentlabel'};
        
        %nameDataClass - Constant, protected property containing a
        %   label, which identifies the original Data class and will be
        %   written to the output CSV file.
        %
        %   See also Data.output_data
        nameDataClass = 'ROIs Location (CellSort)';
        
        %suffixDataClass - Constant, protected property containing a
        %   label, which will be added to the output CSV filename.
        %
        %   See also Data.output_data
        suffixDataClass = 'roiLocationCellSort';
        
    end
    
    % ================================================================== %
    
    methods
        
        function self = set.icTraces(self, val)
            
            % Check property contains only real numerics
            utils.checks.real_num(val, 'icTraces')
            
             % Check property has expected number of dimensions
            utils.checks.num_dims(val, 2, 'icTraces')
            
            % Assign property
            self.icTraces = val;
            
        end
        
        % -------------------------------------------------------------- %
        
        function self = set.icFilters(self, val)
            
            % Check property can be converted to a logical
            utils.checks.real_num(val, 'icFilters')
            
            % Check property has expected number of dimensions
            strVal = 'number of mask dimensions';
            utils.checks.not_empty(val, strVal)
            nDimsVal = ndims(val);
            allowEq = true;
            utils.checks.greater_than(nDimsVal, 2, allowEq, strVal);
            utils.checks.less_than(nDimsVal, 3, allowEq, strVal);
            
            % Assign the property
            self.icFilters = val;
            
        end
        
        % -------------------------------------------------------------- %
        
        function self = set.icMask(self, val)
            
            % Check property can be converted to a logical
            utils.checks.logical_able(val, 'icMask')
            
            % Check property has expected number of dimensions
            strVal = 'number of mask dimensions';
            utils.checks.not_empty(val, strVal)
            nDimsVal = ndims(val);
            allowEq = true;
            utils.checks.greater_than(nDimsVal, 2, allowEq, strVal);
            utils.checks.less_than(nDimsVal, 3, allowEq, strVal);
            
            % Convert property to logical and assign
            self.icMask = logical(val);
            
        end
        
        % -------------------------------------------------------------- %
        
        function self = set.pcFilters(self, val)
            
            % Check property can be converted to a logical
            utils.checks.real_num(val, 'pcFilters')
            
            % Check property has expected number of dimensions
            strVal = 'number of mask dimensions';
            utils.checks.not_empty(val, strVal)
            nDimsVal = ndims(val);
            allowEq = true;
            utils.checks.greater_than(nDimsVal, 2, allowEq, strVal);
            utils.checks.less_than(nDimsVal, 3, allowEq, strVal);
            
            % Assign the property
            self.pcFilters = val;
            
        end
        
        % -------------------------------------------------------------- %
        
        function self = set.tAverage(self, val)
            
            % Check property is a real, finite, scalar
            utils.checks.real_num(val, 'tAverage')
            utils.checks.num_dims(val, 2, 'tAverage')
            
            % Assign property
            self.tAverage = val;
        end
        
        % -------------------------------------------------------------- %
        
        function self = set.roiFilters(self, val)
            
            % Check property can be converted to a logical
            utils.checks.real_num(val, 'roiFilters')
            
            % Check property has expected number of dimensions
            strVal = 'number of mask dimensions';
            utils.checks.not_empty(val, strVal)
            nDimsVal = ndims(val);
            allowEq = true;
            utils.checks.greater_than(nDimsVal, 2, allowEq, strVal);
            utils.checks.less_than(nDimsVal, 3, allowEq, strVal);
            
            % Assign the property
            self.roiFilters = val;
            
        end
        
        % -------------------------------------------------------------- %
        
        function self = set.segmentlabel(self, val)
            
            utils.checks.vector(val, 'segmentlabel')
            maskNotNaNInf = ~isnan(val) & ~isinf(val);
            utils.checks.integer(val(maskNotNaNInf), 'segmentlabel')
            utils.checks.positive(val(maskNotNaNInf), 'segmentlabel')

            % Assign property
            self.segmentlabel = val(:);
        end
        
        % -------------------------------------------------------------- %
        
        function self = set.time(self, val)
            
            % Check property is a vector containing real, finite numerics
            utils.checks.rfv(val, 'time')
            
            % Assign property
            self.time = val(:);
        end
        
    end
    
    % ================================================================== %
    
end
