classdef DataFindROIsFLIKA < DataFindROIs
%DataFindROIsFLIKA - Data from FLIKA-based ROI identification
%
%   The DataFindROIsFLIKA class is an abstract superclass that implements
%   (or requires implementation in its subclasses via abstract methods or
%   properties) all basic functionality related to storing data from FLIKA
%   based ROI identification. Typically there is one concrete subclass of
%   DataFindROIsFLIKA for every concrete subclass of CalcFindROIsFLIKA, and
%   the DataFindROIsFLIKA object stores the algorithm-specific output data
%   that is generated by the corresponding CalcFindROIsFLIKA class.
%
% DataFindROIsFLIKA public properties inherited from Data:
%   mask            - A mask combining all of the other masks
%   means           - A helper structure containing means of the data
%   nPlotsGood      - The number of plots in non-debug mode        
%   nPlotsDebug     - The number of plots in debug mode
%   state           - The current state
%   stdevs          - A helper structure containing stdevs of the data
%
% DataFindROIsFLIKA public properties:
%   area            - The ROI areas [�m^2]
%   blackLevel      - The calculated image black level
%   baselineAverage - A Z-projection image of the baseline period 
%   centroidX       - The ROI centroids in the x direction [pixel indices]
%   centroidY       - The ROI centroids in the y direction [pixel indices]
%   puffGroupMask   - Stage 2 ROI mask (grouped regions)
%   puffPixelMask   - Stage 1 ROI mask (individual pixels)
%   puffSignificantMask - Stage 3 ROI mask (significant regions)
%   roiIdxs         - The linear pixel indices for all ROIs
%   roiMask         - The identified ROIs
%   roiNames        - The ROI names
%
% DataFindROIsFLIKA public methods:
%   add_raw_data    - Add raw data to the Data object
%   add_processed_data - Add processed data to the Data object
%   add_mask_data   - Add mask data to the Data object
%   plot            - Plot a single graph from the data object
%   plot_graphs     - Plot multiple graphs from the data object
%   output_data     - Output the data
%
%   See also DataFindROIsFLIKA_2D, DataFindROIsFLIKA_2p5D,
%   DataFindROIsFLIKA_3D, DataFindROIsDummy, Data, CalcFindROIsFLIKA,
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
    
    properties
        
        %raw data
        
        %blackLevel - The calculated image black level
        %
        %   This scalar represents the n-th percentile value of the image,
        %   determined by the background level set in ConfigFindROIsFLIKA
        %
        %   See also ConfigFindROIsFLIKA.backgroundLevel,
        %   DataFindROIsFLIKA.baselineAverage, prctile
        blackLevel
        
        %baselineAverage - A Z-projection image of the baseline period
        %
        %   The image represents a temporal average projection of the
        %   baseline period whose length is determined in
        %   ConfigFindROIsFLIKA.
        %
        %   See also ConfigFindROIsFLIKA.baselineFrames
        baselineAverage
        
        %puffGroupMask - Stage 2 ROI mask (grouped regions)
        %
        %   The 3D ROI mask resulting from grouping individual puffing
        %   pixels into spatiotemporal regions of interest.
        %
        %   See also CalcFindROIsFLIKA, DataFindROIsFLIKA.puffPixelMask,
        %   DataFindROIsFLIKA.puffSignificantMask
        puffGroupMask
        
        %puffPixelMask - Stage 1 ROI mask (individual pixels)
        %
        %   The 3D pixel mask indicating single pixels that showed a
        %   signal.
        %
        %   See also CalcFindROIsFLIKA, DataFindROIsFLIKA.puffGroupMask,
        %   DataFindROIsFLIKA.puffSignificantMask
        puffPixelMask
        
        %puffSignificantMask - Stage 3 ROI mask (significant regions)
        %
        %   The 3D ROI mask containing only the final regions of interest.
        %
        %   See also CalcFindROIsFLIKA, DataFindROIsFLIKA.puffGroupMask,
        %   DataFindROIsFLIKA.puffSignificantMask
        puffSignificantMask
        
        % mask data
        
    end
    
    % ================================================================== %
    
    methods
        
        function self = set.blackLevel(self, val)
            
            % Check property is a real, finite, scalar
            utils.checks.scalar(val, 'blackLevel')
            utils.checks.real_num(val, 'blackLevel')
            utils.checks.finite(val, 'blackLevel')
            
            % Convert property to logical and assign
            self.blackLevel = val;
        end
        
        % -------------------------------------------------------------- %
        
        function self = set.baselineAverage(self, val)
            
            % Check property contains only real numerics
            utils.checks.real_num(val, 'baselineAverage')
            
            % Check property has expected number of dimensions
            utils.checks.num_dims(val, 2, 'baselineAverage')
            
            % Assign property
            self.baselineAverage = val;
        end
        
        % -------------------------------------------------------------- %
        
        function self = set.puffGroupMask(self, val)
            
            % Check property has expected number of dimensions
            utils.checks.num_dims(val, 3, 'puffGroupMask')
            
            % Check property can be converted to a logical
            utils.checks.logical_able(val, 'puffGroupMask')
            
            % Convert property to logical and assign
            self.puffGroupMask = logical(val);
        end
        
        % -------------------------------------------------------------- %
        
        function self = set.puffPixelMask(self, val)
            
            % Check property has expected number of dimensions
            utils.checks.num_dims(val, 3, 'puffPixelMask')
            
            % Check property can be converted to a logical
            utils.checks.logical_able(val, 'puffPixelMask')
            
            % Convert property to logical and assign
            self.puffPixelMask = logical(val);
        end
        
        % -------------------------------------------------------------- %
        
        function self = set.puffSignificantMask(self, val)
            
            % Check property has expected number of dimensions
            utils.checks.num_dims(val, 3, 'puffSignificantMask')
            
            % Check property can be converted to a logical
            utils.checks.logical_able(val, 'puffSignificantMask')
            
            % Convert property to logical and assign
            self.puffSignificantMask = logical(val);
        end
        
    end
    
    % ================================================================== %
    
end
