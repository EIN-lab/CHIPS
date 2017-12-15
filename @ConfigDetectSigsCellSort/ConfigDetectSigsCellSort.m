classdef ConfigDetectSigsCellSort < ConfigDetectSigs
%ConfigDetectSigsCellSort - Parameters for detecting and classifying signals
%
%   The ConfigDetectSigsCellSort class is a configuration class that contains
%   the parameters necessary for detecting and classifying signals from ROI
%   traces. For further information about this algorithm, please refer to 
%   <a href="matlab:web('http://dx.doi.org/10.1016/j.neuron.2009.08.009', '-browser')">Mukamel et al. (2009)</a>, 
%   Neuron 63(6):747–760 or the <a href="matlab:web('doc/html/cellsort/index.html')">local documentation</a>.
%
% ConfigDetectSigsCellSort public properties
%   mode            - Mode of plotting
%   spike_thresh    - Threshold for spike detection
%   deconvtau       - Time constant for temporal deconvolution
%   normalization   - Type of normalization to apply to ICA signals
%   plottype        - Type of spike plot to use
%   ratebin         - Controls size of time bins for spike rate computation
%   ICuse           - Which ICs to plot
%   background      - What to overlay origins of signals on
%
% ConfigDetectSigsCellSort public methods
%   ConfigDetectSigsCellSort - ConfigDetectSigsCellSort class constructor
%   copy            - Copy MATLAB array of handle objects
%   create_calc     - Return a Calc object containing the Config object
%   get_dims        - Return the dimensions needed for the opt_config GUI
%   opt_config      - Optimise parameters using a GUI
%
% ConfigDetectSigsCellSort static methods
%   from_preset     - Create a ConfigDetectSigsCellSort object from a preset
%
% ConfigDetectSigsDummy public events:
%   ProcessNow      - Notifies listeners to process an object
%
%   See also ConfigDetectSigsDummy, ConfigDetectSigs, Config,
%   ConfigCellScan, CalcDetectSigsClsfy, CellScan

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
        
        %mode - mode of plotting
        %
        %   Either 'series' or 'contour', 'series' shows each spatial
        %   filter separately; 'contour'displays a single plot with
        %   contours for all spatial filters superimposed on the mean
        %   fluorescence image.
        %
        %   See also plot_ICAsigs, CalcFindROIsCellSort.plot_ICAtraces
        mode = 'contour';
        
        %spike_thresh - Threshold for spike detection
        %
        %   Threshold for spike detection.
        %
        %   See also plot_ICAsigs, utils.cellsort.CellsortFindspikes
        spike_thresh = 2;
        
        %deconvtau - Time constant for temporal deconvolution
        %
        %   Time constant for temporal deconvolution (Butterworth
        %   filter); if deconvtau=0 or [], no deconvolution is performed
        %
        %   See also utils.cellsort.CellsortFindspikes
        deconvtau = 0;
        
        %normalization - type of normalization to apply to ICA signals
        %
        %   Type of normalization to apply to ica_sig; 0 - no
        %   normalization; 1 - divide by standard deviation and subtract mean
        %
        %   See also utils.cellsort.CellsortFindspikes
        normalization = 1;
        
        %plottype - type of spike plot to use
        %
        %   plottype - type of spike plot to use [default = 2]:
        %         plottype = 1: plot cellular signals
        %         plottype = 2: plot cellular signals together with spikes
        %         plottype = 3: plot spikes only
        %         plottype = 4: plot spike rate over time
        %
        %   See also utils.cellsort.CellsortFindspikes, plot_ICAsigs
        plottype = 2;
        
        %ratebin - Controls size of time bins for spike rate computation
        %
        %   Size of spike bin is ratebin * dt, where dt is inverse
        %   framerate. Relevat for plottype = 4.
        %
        %   See also utils.cellsort.CellsortFindspikes, plot_ICAsigst
        ratebin = 1;
        
        %ICuse - Which ICs to plot
        %
        %   Array including indices of ICs to plot. 
        %   [default = 1 : number_of_ICs]
        ICuse = []
        
        %background - What to overlay origins of signals on
        %
        %   Flag indiciating which image to use for overlaying signals onto
        %       1 - temporal fluorescence average over all frames [default]
        %       2 - average over all icFilters
        background = 1
        
    end
    
    % ------------------------------------------------------------------ %
    
    properties (Constant, Access = protected)
        
        %classCalc - Constant, protected property containing the name of
        %   the associated Calc class
        classCalc = 'CalcDetectSigsCellSort';
        
        optList = {'FindSpikes', {'normalization', 'deconvtau', ...
                'spike_thresh'}; ...
            'Plotting', {'mode', 'plottype', 'ratebin', 'ICuse', 'background'}};
        
    end
    
    % ================================================================== %
    
    methods
        
        function cdscObj = ConfigDetectSigsCellSort(varargin)
        %ConfigDetectSigsCellSort - ConfigDetectSigsCellSort class constructor
        %
        %   OBJ = ConfigDetectSigsCellSort() creates a ConfigDetectSigsCellSort
        %   object OBJ with default values for all properties.
        %
        %   OBJ = ConfigDetectSigsCellSort(..., 'property', value, ...) or
        %   OBJ = ConfigDetectSigsCellSort(..., propStruct, ...) 
        %
        %   This syntax specifies values for the properties, either in the
        %   form of attribute-value pairs, or structures (or objects) where
        %   the field (property) names correspond to properties in the
        %   ConfigDetectSigsCellSort class. The argument parsing is done by
        %   the utility function parsepropval (link below), so please
        %   consult the documentation for this function for more details.
        %
        %   See also utils.parsepropval,
        %   ConfigDetectSigsCellSort.from_preset, ConfigDetectSigsDummy,
        %   ConfigDetectSigs, Config, ConfigCellScan, CalcDetectSigsClsfy,
        %   CellScan
        
            % Call Config (i.e. parent class) constructor
            cdscObj = cdscObj@ConfigDetectSigs(varargin{:});
            
        end
        
        % -------------------------------------------------------------- %
        
        function self = set.deconvtau(self, val)
            
            % Check that boolean
            
            % Assign value
            self.deconvtau = logical(val);
        end
        
        % -------------------------------------------------------------- %
        
        function self = set.mode(self, val)
            
            % Check that string
            % Check that one of 'series', 'contours', may do partial
            % matching
            
            
            % Assign value
            self.mode = val;
        end
        
        % -------------------------------------------------------------- %
        
        function self = set.normalization(self, val)
            
            % Check that boolean
            utils.checks.integer(val, 'ratebin')
            utils.checks.logical_able(val, 'ratebin')
            
            % Assign value
            self.normalization = logical(val);
            
        end
        
        % -------------------------------------------------------------- %
        
        function self = set.plottype(self, val)
            
            % Check that integer between 1 and 4 inclusive
            utils.checks.integer(val, 'ratebin')
            utils.checks.positive(val, 'ratebin')
            utils.checks.less_than(val, 4, true, 'ratebin')
            
            % Assign value
            self.plottype = val;
        end
        
        % -------------------------------------------------------------- %
        
        function self = set.spike_thresh(self, val)
            
            % Check that the float or int in some reasonable range
            utils.checks.positive(val, 'ratebin')
            
            % Assign value
            self.spike_thresh = val;
            
        end
        
        % -------------------------------------------------------------- %
        
        function self = set.ratebin(self, val)
            
            % Check that int or float
            % probably shouldn't be much more or less than 10 * 1/frame_rate
            utils.checks.integer(val, 'ratebin')
            utils.checks.positive(val, 'ratebin')
            
            % Assign value
            self.ratebin = val;
        end
        
        % -------------------------------------------------------------- %
        
        function self = set.ICuse(self, val)
            
            if ~isempty(val)
                % Convert to a range of frames
                if isscalar(val)
                    val = 1:val;
                end

                % Check that the value is a single row integer
                utils.checks.integer(val, 'ICuse')
                utils.checks.vector(val, 'ICuse')
                utils.checks.positive(val, 'ICuse')

                % Check that the length is greater than a number
                utils.checks.length(val, 2, 'ICuse', 'greater')
            end
            
            % Assign value
            self.ICuse = val(:);
        end
         % -------------------------------------------------------------- %
        function self = set.background(self, val)
            
            % Check that int and one of 1 or 2
            utils.checks.integer(val, 'ICuse')
            utils.checks.less_than(val, 2, true, 'background')
            
            % Assign value
            self.background = val;
        end
                
    end
    
    % ================================================================== %
    
    methods (Static)
        
    end
    
    % ================================================================== %
    
    
    % ================================================================== %

end
