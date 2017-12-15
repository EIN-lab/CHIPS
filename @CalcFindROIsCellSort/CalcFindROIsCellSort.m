classdef CalcFindROIsCellSort < CalcFindROIs
%CalcFindROIsCellSort - Class for ICA ROI identification (2D)
%
%   The CalcFindROIsCellSort class is a Calc class that implements a 
%   spatio-temporal Independent Component Analysis (stICA) algorithm for
%   ROI identification, also known as CellSort. For further information 
%   about CellSort, please refer to <a href="matlab:web('http://dx.doi.org/10.1016/j.neuron.2009.08.009', '-browser')">Mukamel et al. (2009)</a>, 
%   Neuron 63(6):747–760 or the <a href="matlab:web('doc/html/cellsort/index.html')">local documentation</a>.
%
% CalcFindROIsCellSort public properties
%   config          - A scalar ConfigFindROIsCellSort object
%   data            - A scalar DataFindROIsCellSort object
%
% CalcFindROIsCellSort public methods
%   CalcFindROIsCellSort - CalcFindROIsCellSort class constructor
%   copy            - Copy MATLAB array of handle objects
%   get_roiMask     - Extract ROI mask
%   measure_ROIs    - Measure the ROIs and return the traces
%   plot            - Plot a figure
%   process         - Run the processing
%
%   See also CalcFindROIs, Calc, ConfigFindROIsCellSort,
%   DataFindROIsCellSort, CellScan

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
    
    properties (Access = protected)
        
        %is3D - Whether or not the ROI mask is 3D
        is3D = false;
        
        %isLS - Whether or not the RawImg is a linescan
        isLS = false;
        
        %CovEvals - largest eigenvalues of the covariance matrix
        %
        % See also utils.cellsort.CellsortPCA
        CovEvals
        
        %PCuse - vector of indices of PCs
        %
        %   The vector contains indices of the PCs to be kept for dimensional
        %   reduction.
        PCuse
        
    end
    
    % ------------------------------------------------------------------ %
    
    properties (Constant, Access = protected)
        
        strMsg = 'Finding ROIs';
        
        %validConfig - Constant, protected property containing the name of
        %   the associated Config class
        validConfig = {'ConfigFindROIsCellSort'};
        
        %validConfig - Constant, protected property containing the name of
        %   the associated Config class
        validData = {'DataFindROIsCellSort'};
        
    end
    
    % ================================================================== %
    
    methods
        
        function CalcCellSortObj = CalcFindROIsCellSort(varargin)
        %CalcFindROIsCellSort - CalcFindROIsCellSort class constructor
        %
        %   OBJ = CalcFindROIsCellSort() prompts for all required
        %   information and creates a CalcFindROIsCellSort object.
        %
        %   OBJ = CalcFindROIsCellSort(CONFIG, DATA) uses the specified
        %   CONFIG and DATA objects to construct the CalcFindROIsCellSort
        %   object. If any of the input arguments are empty, the
        %   constructor will prompt for any required information. The input
        %   arguments must be scalar ConfigFindROIsCellSort and/or
        %   DataFindROIsCellSort objects.
        %
        %   See also ConfigFindROIsCellSort, DataFindROIsCellSort
        
            % Parse arguments
            [configIn, dataIn] = utils.parse_opt_args({[], []}, varargin);
            
            % Call CalcFindROIs (i.e. parent class) constructor
            CalcCellSortObj = ...
                CalcCellSortObj@CalcFindROIs(configIn, dataIn);
            
        end
        
        % -------------------------------------------------------------- %
        
        function [traces, tracesExist] = measure_ROIs(self, objPI)
        %measure_ROIs - Measure the ROIs and return the traces
        %
        %   [TRACES, TRACES_EXIST] = measure_ROIs(OBJ, OBJ_PI) measure the
        %   ROIS contained in the CalcFindROIsCellSort object OBJ using the
        %   CellScan object OBJ_PI and returns an array of TRACES, as well
        %   as a mask specifying if the TRACES_EXIST.
        %
        %   See also CalcMeasureROIs.process, CalcMeasureROIs,
        %   CellScan.process, CellScan
        
            % Check the number of input arguments
            narginchk(2, 2);

            % Check the ProcessedImg
            self.check_objPI(objPI);
        
            % Check for edge case where we have no ROIs
            hasNoROIs = (size(self.data.roiMask, 3) == 1) && ...
                strcmpi(self.data.roiNames{1}, 'none') && ...
                isnan(self.data.area);
            if hasNoROIs
                
                % Setup the warnings
                idNoROIs = 'CalcFindROIsCellSort:MeasureROIs:NoROIs';
                stateNoROIs = warning('query', idNoROIs);
                doNoROIs = strcmpi(stateNoROIs.state, 'on');
                if doNoROIs
                    warning(idNoROIs, ['No traces could be added, ' ...
                        'because no ROIs were identified.'])
                end
                
                % Assign dummy values when there's no ROI
                traces = 0;
                tracesExist = false;
                
                % Update the progress bar
                isWorker = utils.is_on_worker();
                if ~isWorker
                    strMsgM = 'Measuring ROIs';
                    utils.progbar(1, 'msg', strMsgM, 'doBackspace', true);
                end
                
                % Quit out of here for now
                return
                
            end
        
            % Pull out any data from the objPI that we need
            imgSeq = double(squeeze(...
                objPI.rawImg.rawdata(:,:,objPI.channelToUse,:)));
            
            % Extract the traces and specify that they always exist
            ica_segments = permute(self.data.roiFilters, [3, 1, 2]);
            traces = utils.cellsort.CellsortApplyFilter(imgSeq, ...
                ica_segments, self.config.fLims, self.data.tAverage)';
            tracesExist = true;
            
        end
        
    end
    
    % ================================================================== %
    
    methods (Access = protected)
        
        self = find_ROIs(self, objPI)
            
        % -------------------------------------------------------------- %
        
        [maskFilters, maskSegments] = ROIsToMask(self)
        
        % -------------------------------------------------------------- %
        
        varargout = plot_ICAtraces(self, objPI, hAx, varargin)
        
        % -------------------------------------------------------------- %
        
        varargout = plot_PCspectrum(self, objPI, hAx, varargin)
        
        % -------------------------------------------------------------- %
        
        function varargout = plot_pcs(self, ~, varargin)
            
            hFig = figure();
            map = utils.cubehelix(256, 0.25, -0.9, 1.25, 1, [0, 0.99]);
            pcFilters = permute(self.data.pcFilters, [1, 2, 4, 3]);
            utils.sc_pkg.imdisp(pcFilters, 'Map', map, ...
                'Size', [3, 4], 'Border', 0.01, 'FigureHandle', hFig); 
            if nargout > 0
                varargout{1} = hFig;
            end
            
        end
        
        % -------------------------------------------------------------- %
                
        plot_imgs_sub(self, objPI, hAxes, varargin)
        
        % -------------------------------------------------------------- %
        
        function validConfig = get_validConfig(~)
            validConfig = {'ConfigFindROIsCellSort'};
        end
            
        % -------------------------------------------------------------- %
        
        function self = add_data(self, icMask, roiFilters, roiMask, ...
                roiNames, stats, segmentlabel)
            
            % Store processed data
            centroids = reshape([stats(:).Centroid], 2, [])';
            self.data = self.data.add_processed_data([stats(:).Area]', ...
                centroids(:,1), centroids(:,2), icMask, roiFilters, ...
                {stats(:).PixelIdxList}', roiMask, roiNames, segmentlabel);
            
        end
        
    end
    
    % ================================================================== %
    
    methods (Static, Access = protected)
        
        function configObj = create_config()
        %create_config - Creates an object of the associated Config class
        
            configObj = ConfigFindROIsCellSort();
        
        end
        
        % -------------------------------------------------------------- %
        
        function dataObj = create_data()
        %create_data - Creates an object of the associated Data class
            
            dataObj = DataFindROIsCellSort();
        
        end
        
    end
    
    % ================================================================== %
    
end
