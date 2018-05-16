classdef DataDetectSigsCellSort < DataDetectSigs
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
%   spmat    - nIC x T sparse binary matrix, containing 1 at the time frame of each
%              spike
%   spt      - List of all spike times
%   spc      - List of the indices of ICsegments for each spike
%   spc_rois - Names of rois that the spikes come from
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
        
        %spmat - Times of spikes for all time frames
        %
        %   nIC x T sparse binary matrix, containing 1 at the time frame of
        %   each spike
        %
        spmat
        
        %spt - list of all spike times
        %
        %   list of all spike times
        %
        spt
        
        %spc - list of the indices of ICsegments for each spike
        %
        %   list of the indices of ICsegments for each spike
        %
        spc
        
        %spc_rois - Names of rois that the spikes come from
        %
        %   Cell array containing names of rois that the spikes come from,
        %   for each spike.
        %
        spc_rois
        
        
    end
    
    % ------------------------------------------------------------------ %
    
    properties (Constant, Access = protected)
        
        listRaw = {};
        listProcessed = {'spmat', 'spt', 'spc', 'roiName', 'spc_rois'};
        listMask = {};
        
        listPlotDebug = {'spt', 'spc'};
        labelPlotDebug = {}
        
        listPlotGood = {'spt', 'spc'};
        labelPlotGood = {}
        
        listMean = {'spt', 'spc'};
        
        listOutput = {'spt', 'spc'};
        nameDataClass = 'Signal Detection (CellSort)';
        suffixDataClass = 'sigDetectionCellSort';
        
    end
    
    % ================================================================== %
    
    methods
        
        function plot_graphs(self, varargin)
            
            % Check for the statistics toolbox
            feature = 'Statistics_Toolbox';
            className = 'DataDetectSigsCellSort:PlotGraphs';
            utils.verify_license(feature, className);
                        
            % Check axis handle is the correct class, create one if it
            % doesn't exist, and work out where the rest of the arguments
            % are
            hAxes = [];
            hasAxes = (nargin > 1) && all(ishghandle(varargin{1})) && ...
                all(strcmp(get(varargin{1}, 'type'), 'axes'));
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
        
        function self = set.spmat(self, val)
            
            % Check that binary only
            utils.checks.logical_able(val, 'spmat');
            
            % Assign property
            self.spmat = val;
        end
        
        % -------------------------------------------------------------- %
        
        function self = set.spt(self, val)
            
            % Check that list/array, not negative
            utils.checks.positive(val, 'spt');
            
            % Assign property
            self.spt = val;
        end
        
        % -------------------------------------------------------------- %
        
        function self = set.spc(self, val)
            
            utils.checks.positive(val, 'spc');
            utils.checks.integer(val, 'spc');
            
            
            % Assign property
            self.spc = val;
        end
        
        % -------------------------------------------------------------- %
        function self = set.spc_rois(self, val)
            
            utils.checks.cell_array(val, 'spc_rois');            
            
            % Assign property
            self.spc_rois = val;
        end
        
    end
    
    % ================================================================== %
        
end
