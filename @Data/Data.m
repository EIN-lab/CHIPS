classdef (Abstract) Data
%Data - Superclass for Data classes
%
%   The Data class is an abstract superclass that implements (or requires
%   implementation in its subclasses via abstract methods or properties)
%   most functionality related to Data objects.  Typically there is one
%   concrete subclass of Data for every concrete subclass of Calc, and the
%   Data object stores the algorithm-specific output data that is generated
%   by the corresponding Calc class.
%
% Data public properties:
%   mask            - A mask combining all of the other masks
%   means           - A helper structure containing means of the data
%   nPlotsGood      - The number of plots in non-debug mode        
%   nPlotsDebug     - The number of plots in debug mode
%   state           - The current state
%   stdevs          - A helper structure containing stdevs of the data
% 
% Data public methods:
%   Data            - Data class constructor
%   add_raw_data    - Add raw data to the Data object
%   add_processed_data - Add processed data to the Data object
%   add_mask_data   - Add mask data to the Data object
%   plot            - Plot a single graph from the data object
%   plot_graphs     - Plot multiple graphs from the data object
%   output_data     - Output the data
%
%   See also Calc, Config

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
    
    properties (Dependent)
        
        %mask - A mask combining all of the other masks
        %
        %   The mask property of Data is a dependent property where each
        %   element of the mask is true if the corresponding element in any
        %   of the mask variables is true.  This can be useful to select or
        %   exclude all data that has been masked.
        %
        %   See also Data.listMask
        mask
        
        %means - A helper structure containing means of the data
        %
        %   The means property of Data is a dependent property containing a
        %   structure of means of other fields of the Data.  The means
        %   structure contains two top level fields (raw and masked)
        %   representing the raw means and the masked means (i.e. means
        %   calculated from the non-masked data).  Only those fields listed
        %   in the protected property listMean appear in the structure.
        %
        %   See also Data.stdevs, Data.listMean, Data.mask
        means
               
        %nPlotsGood - The number of plots in non-debug mode
        nPlotsGood
        
        %nPlotsDebug - The number of plots in debug mode
        nPlotsDebug
        
        %state - The current state
        %
        %   The state property of Data is a dependent property representing
        %   the current state of the data object.  The possible values are:
        %   
        %       empty ->	The object does not contain any data
        %
        %       raw ->      The object contains only raw data
        %
        %       processed -> The object contains raw and processed data
        %
        %       done ->     The object contains raw, processed and mask data 
        %
        %       error ->    The object is in an unexpected state
        %
        %   See also Data.listRaw, Data.listProcessed, Data.listMask
        state
        
        %stdevs - A helper structure containing stdevs of the data
        %
        %   The stdevs property of Data is a dependent property containing
        %   a structure of standard deviations of other fields of the Data.
        %   The stdevs structure contains two top level fields (raw and
        %   masked) representing the raw stdevs and the masked stdevs (i.e.
        %   stdevs calculated from the non-masked data).  Only those fields
        %   listed in the protected property listMean appear in the
        %   structure.
        %
        %   See also Data.means, Data.listMean, Data.mask
        stdevs
        
    end
    
    % ------------------------------------------------------------------ %
    
    properties (Dependent, Access = protected)
        
        %listAll - A list of all data properties, excluding irrelevant ones
        listAll
        
    end
    
    % ------------------------------------------------------------------ %
    
    properties (Abstract, Constant, Access = protected)
        
        %listRaw - A list of all raw properties
        %
        %   See also Data.add_raw_data
        listRaw
        %listProcessed - A list of all processed properties
        %
        %   See also Data.add_processed_data
        listProcessed
        %listMask - A list of all mask properties
        %
        %   See also Data.add_mask_data
        listMask
        
        %listPlotGood - A list of properties to plot in non-debug mode
        %
        %   See also Data.plot_graphs
        listPlotGood
        %labelPlotGood - A list of labels for plots in non-debug mode 
        %
        %   See also Data.plot_graphs
        labelPlotGood
        
        %listPlotGood - A list of properties to plot in debug mode 
        %
        %   See also Data.plot_graphs
        listPlotDebug
        %labelPlotGood - A list of labels for plots in debug mode
        %
        %   See also Data.plot_graphs
        labelPlotDebug
        
        %listMean - A list of properties to calculate the mean for
        %
        %   See also Data.means, Data.stdevs
        listMean
        
        %listOutput - A list of properties to output
        %
        %   See also Data.output_data
        listOutput
        
        %nameDataClass - A name for the data class
        nameDataClass
        
        %suffixDataClass - A suffix to use when outputing the data
        %
        %   See also Data.output_data
        suffixDataClass
        
    end
    
    % ================================================================== %
    
    methods
        
        function DataObj = Data()
            %Data - Data class constructor
            
            % Check we've listed all properties
            listSpec = [DataObj.listRaw, DataObj.listProcessed, ...
                DataObj.listMask];
            hasCompleteLists = isequal(sort(DataObj.listAll(:)), ...
                sort(listSpec(:)));
            if ~hasCompleteLists
                error('Data:IncompleteLists', ['The lists of properties ' ...
                    'specified for this function are incomplete.  Check ' ...
                    'that all properties have been placed in a list.'])
            end
            
        end
        
        % -------------------------------------------------------------- %
        
        self = add_raw_data(self, varargin)
        
        % -------------------------------------------------------------- %
        
        self = add_processed_data(self, varargin)
        
        % -------------------------------------------------------------- %
        
        self = add_mask_data(self, varargin)
        
        % -------------------------------------------------------------- %
        
        varargout = plot(self, varargin)
        
        % -------------------------------------------------------------- %
        
        varargout = plot_graphs(self, varargin)
        
        % -------------------------------------------------------------- %
        
        varargout = output_data(self, fnCSV, varargin)
        
        % -------------------------------------------------------------- %
        
        function listAll = get.listAll(self)
        
            listAll = properties(self);
            listAll = listAll(~ismember(listAll, ...
                {'state', 'mask', 'means', 'stdevs', ...
                'nPlotsGood', 'nPlotsDebug'}));
            
        end
        
        % -------------------------------------------------------------- %
        
        function means = get.means(self)
            
            % Create an empty structure 
            [means, listFields, nFields] = self.create_stats_struct();
            
            % Loop through the fields and calculate the raw & masked means
            for iField = 1:nFields
                
                iFieldName = listFields{iField};
                
                % Skip any non-numeric fields
                if ~isnumeric(self.(iFieldName))
                    means.raw.(iFieldName) = [];
                    means.masked.(iFieldName) = [];
                    continue
                end
                
                % Calculate the raw mean, only if we have data
                hasData = ~isempty(self.(iFieldName));
                if hasData
                    means.raw.(iFieldName) = Data.calc_goodmean(...
                        self.(iFieldName));
                end
                
                % Calculate the masked mean if we have data and a mask
                hasMask = ~isempty(self.mask);
                if hasData && hasMask
                    for iCol = size(self.(iFieldName), 2):-1:1
                        means.masked.(iFieldName)(:, iCol) = ...
                            Data.calc_goodmean(...
                            self.(iFieldName)(~self.mask(:, iCol), iCol));
                    end
                end
                
            end
            
        end
        
        % -------------------------------------------------------------- %
        
        function nPlotsGood = get.nPlotsGood(self)
            nPlotsGood = numel(self.listPlotGood);
        end
        
        % -------------------------------------------------------------- %
        
        function nPlotsDebug = get.nPlotsDebug(self)
            nPlotsDebug = numel(self.listPlotDebug);
        end
        
        % -------------------------------------------------------------- %
        
        function mask = get.mask(self)
            
            % Set the mask to empty
            mask = logical([]);
            
            % Automatically generate the correct mask
            nMasks = length(self.listMask);
            if nMasks > 0
                
                % Set the mask to the only mask
                mask = self.(self.listMask{1});
                
                if nMasks > 1
                    
                    for iMask = 2:nMasks
                        % Set the mask to include all masks
                        mask = mask | self.(self.listMask{iMask});
                    end
                    
                end
            end
        
        end
        
        % -------------------------------------------------------------- %
        
        function state = get.state(self)
            
            % Work out if we've got all the raw properties
            hasRaw = self.check_all_props(self.listRaw);
            
            % Work out if we've got all the processed properties
            hasProcessed = self.check_all_props(self.listProcessed);
            
            % Work out if we've got all the mask properties
            hasMask = self.check_all_props(self.listMask);
            
            % Work out if we're empty
            isEmpty = self.check_empty_props(self.listAll);
            
            % Work out the state possibilities
            isReady = hasRaw && hasProcessed && hasMask;
            
            if isEmpty
                state = 'unprocessed';
            elseif isReady
                state = 'processed';
            else
                state = 'error';
            end
            
        end
        
        % -------------------------------------------------------------- %
        
        function stdevs = get.stdevs(self)
            
            % Create an empty structure 
            [stdevs, listFields, nFields] = self.create_stats_struct();
            
            % Loop through the fields and calculate the raw & masked means
            for iField = 1:nFields
                
                iFieldName = listFields{iField};
                
                % Skip any non-numeric fields
                if ~isnumeric(self.(iFieldName))
                    stdevs.raw.(iFieldName) = [];
                    stdevs.masked.(iFieldName) = [];
                    continue
                end
                
                % Calculate the raw mean, only if we have data
                hasData = ~isempty(self.(iFieldName));
                if hasData
                    stdevs.raw.(iFieldName) = Data.calc_goodstdev(...
                        self.(iFieldName));
                end
                
                % Calculate the masked mean if we have data and a mask
                hasMask = ~isempty(self.mask);
                if hasData && hasMask
                    stdevs.masked.(iFieldName) = Data.calc_goodstdev(...
                        self.(iFieldName)(~self.mask));
                end
                
            end
            
        end
        
    end
    
    % ================================================================== %
    
    methods (Hidden)
        
        function plot_average(self, varargin)
            
            % Parse arguments
            isDebug = utils.parse_opt_args({true}, varargin);
            
            xDataIn = 'time';
            yVarListIn = [];
            yLabelListIn = [];
            doInverse = false;
            fPlot = @plot;
            doAverage = true;
            
            self.plot_graphs(xDataIn, yVarListIn, ...
                yLabelListIn, isDebug, doInverse, fPlot, doAverage);
            
        end
        
    end
    
    % ================================================================== %
    
    methods (Access = protected)
        
        function hasAll = check_all_props(self, propsList)
        %check_all_props - Check that all properties are not empty
            
            nProps = length(propsList);
            hasAll = true;
            for iProp = 1:nProps
                if isempty(self.(propsList{iProp}))
                    hasAll = false;
                    break
                end
            end
            
        end
        
        % -------------------------------------------------------------- %
        
        [dataOut, varargout] = check_data(self, dataIn, varargin)
        
        % -------------------------------------------------------------- %
        
        function isEmpty = check_empty_props(self, propsList)
        %check_empty_props - Check that all properties are empty
            
            isEmpty = true;
            nProps = length(propsList);
            if nProps > 0
                for iProp = 1:nProps
                    if ~isempty(self.(propsList{iProp}))
                        isEmpty = false;
                        break
                    end
                end
            else
                isEmpty = false;
            end
            
        end
        
        % -------------------------------------------------------------- %
        
        function [stats_struct, listFields, nFields] = ...
                create_stats_struct(self)
        %create_stats_struct - Create a structure to store statistics
            
            % Find the fields we want to calculate means of, excluding time
            listFields = self.listMean;
            nFields = length(listFields);
            
            % Create an empty structure
            testCell = [listFields; repmat({[]}, [1, nFields])];
            emptyMeans = struct(testCell{:});
            stats_struct = struct('raw', emptyMeans, 'masked', emptyMeans);
            
        end
        
        % -------------------------------------------------------------- %
        
        function hdrCell = get_headers(self, ~)
            % This the the normal case; can be overloaded in special cases
            hdrCell = self.listOutput;
        end
        
        % -------------------------------------------------------------- %
        
        dataInterp = interp_masked(self, dataRaw)
        
    end
    
    % ================================================================== %
    
    methods (Static, Access = protected)
        
        function maskGood = calc_goodmask(data)
        %calc_goodmask - Calculates a mask to select good points
            
            if ~isnumeric(data)
                maskGood = [];
                return
            end
            
            maskInf = isinf(data);
            maskNaN = isnan(data);
            
            maskGood = ~maskInf & ~maskNaN;
            
        end
        
        % -------------------------------------------------------------- %
        
        function goodmean = calc_goodmean(data)
        %calc_goodmean - Calculates the mean of good points
            
            if ~isnumeric(data)
                goodmean = [];
                return
            end
            
            maskGood = Data.calc_goodmask(data);
            for iCol = size(data, 2):-1:1
                goodmean(:, iCol) = mean(data(maskGood(:, iCol), iCol), 1);
            end
            
        end
        
        % -------------------------------------------------------------- %
        
        function goodstdev = calc_goodstdev(data)
        %calc_goodstdev - Calculates the stdev of good points
            
            if ~isnumeric(data)
                goodstdev = [];
                return
            end
            
            maskGood = Data.calc_goodmask(data);
            for iCol = size(data, 2):-1:1
                goodstdev(:, iCol) = std(data(maskGood(:, iCol), iCol), 0, 1);
            end
            
        end
        
    end
    
    % ================================================================== %
    
end
