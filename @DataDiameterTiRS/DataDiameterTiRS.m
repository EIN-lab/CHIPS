classdef DataDiameterTiRS < DataDiameter
%DataDiameterTiRS - Data from TiRS diameter calculations
%
%   The DataDiameterTiRS class is a data class that is designed to
%   contain all the basic data output from CalcDiameterFWHM.
%
% DataDiameterTiRS public properties inherited from Data:
%   mask            - A mask combining all of the other masks
%   means           - A helper structure containing means of the data
%   nPlotsGood      - The number of plots in non-debug mode        
%   nPlotsDebug     - The number of plots in debug mode
%   state           - The current state
%   stdevs          - A helper structure containing stdevs of the data
%
% DataDiameterTiRS public properties
%   areaPixels      - The area of the vessel cross section [pixels]
%   diameter        - A time series vector of the vessel diameter [µm]
%   idxEdgesFWHM    - The indices of the FWHM edges in the Radon images
%   imgInvRadon     - The inverse Radon transformed image frames
%   imgRadon        - The Radon transformed image frames
%   maskSTD         - Points outside the std range
%   time            - The time series vector [s]
%   vesselEdges     - The indices of the edges of the vessel lumen
%   vesselMask      - A logical mask of the vessel lumen
%
% DataDiameterTiRS public methods:
%   add_raw_data    - Add raw data to the Data object
%   add_processed_data - Add processed data to the Data object
%   add_mask_data   - Add mask data to the Data object
%   plot            - Plot a single graph from the data object
%   plot_graphs     - Plot multiple graphs from the data object
%   output_data     - Output the data
%
%   See also DataDiameter, Data, CalcDiameterTiRS, XSectScan

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
        
        %areaPixels - The area of the vessel cross section [pixels]
        %
        %   See also DataDiameterTiRS.vesselMask,
        %   DataDiameterTiRS.vesselEdges
        areaPixels
        
        %idxEdgesFWHM - The indices of the FWHM edges in the Radon images
        %
        %   See also DataDiameterTiRS.imgRadon
        idxEdgesFWHM
        
        %imgInvRadon - The inverse Radon transformed image frames
        imgInvRadon
        
        %imgRadon - The Radon transformed image frames
        %
        %   See also DataDiameterTiRS.idxEdgesFWHM
        imgRadon
                
        %vesselEdges - The indices of the edges of the vessel lumen
        %   See also DataDiameterTiRS.vesselMask,
        %   DataDiameterTiRS.areaPixels
        vesselEdges
        
        %vesselMask - A logical mask of the vessel lumen
        %
        %   See also DataDiameterTiRS.areaPixels,
        %   DataDiameterTiRS.vesselEdges
        vesselMask
        
    end
    
    % ------------------------------------------------------------------ %
    
    properties (Constant, Access = protected)
        
        listRaw = {'time', 'areaPixels', 'vesselMask', 'imgRadon', ...
            'imgInvRadon', 'idxEdgesFWHM'};
        listProcessed = {'diameter', 'vesselEdges'};
        listMask = {'maskSTD'};
        
        listPlotDebug = {'diameter'};
        labelPlotDebug = {'Diameter [um]'};
        listPlotGood = {'diameter'};
        labelPlotGood = {'Diameter [um]'};
        
        listMean = {'diameter', 'areaPixels'};
        
        listOutput = {'time', 'diameter', 'areaPixels', 'maskSTD', ...
            'mask'};
        nameDataClass = 'Diameter (TiRS)';
        suffixDataClass = 'diameterTiRS';
        
    end
    
    % ================================================================== %
    
    methods
        
        function self = set.areaPixels(self, val)
            utils.checks.rfv(val, 'areaPixels');
            utils.checks.positive(val, 'areaPixels');
            utils.checks.integer(val, 'areaPixels');
            self.areaPixels = val;
        end
        
        % -------------------------------------------------------------- %
        
        function self = set.idxEdgesFWHM(self, val)
            utils.checks.finite(val, 'diamProfile');
            utils.checks.integer(val, 'diamProfile');
            utils.checks.equal(size(val, 1), 2, ...
                'The number of columns of idxEdgesFWHM', '2');
            self.idxEdgesFWHM = val;
        end
        
        % -------------------------------------------------------------- %
        
        function self = set.imgRadon(self, val)
            utils.checks.real_num(val, 'imgRadon');
            utils.checks.finite(val, 'imgRadon');
            self.imgRadon = val;
        end
        
        % -------------------------------------------------------------- %
        
        function self = set.imgInvRadon(self, val)
            utils.checks.real_num(val, 'imgInvRadon');
            utils.checks.finite(val, 'imgInvRadon');
            self.imgInvRadon = val;
        end
        
        % -------------------------------------------------------------- %
        
        function self = set.vesselMask(self, val)
            utils.checks.logical_able(val, 'vesselMask');
            self.vesselMask = val;
        end
        
        % -------------------------------------------------------------- %
        
        function self = set.vesselEdges(self, val)
            utils.checks.object_class(val, 'cell', 'vesselEdges');
            self.vesselEdges = val;
        end
        
    end
    
    % ================================================================== %
    
end
