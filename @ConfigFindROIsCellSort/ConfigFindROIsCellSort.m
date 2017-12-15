classdef ConfigFindROIsCellSort < ConfigFindROIsAuto
%ConfigFindROIsCellSort - Parameters for stICA-based ROI identification
%
%   The CalcFindROIsCellSort class is a Config class that implements the 
%   Spatio-temporal Independent Component Analysis (stICA) algorithm for ROI 
%   identification. For further information about stICA, please refer to 
%   <a href="matlab:web('http://dx.doi.org/10.1016/j.neuron.2009.08.009', '-browser')">Mukamel et al. (2009)</a>, Neuron 63(6):747–760 or the <a href="matlab:web('doc/html/cellsort/index.html')">local documentation</a>.
%
% ConfigFindROIsCellSort public properties
%   badFrames   - List of frame indices to be excluded from analysis
%   discardBorderROIs - Whether to ignore ROIs touching the image border
%   fLims       - The first and last frame to be analysed
%   inpaintIters- The number of iterations to use when inpainting
%   maxIters    - Maximum number of iterations for ICA
%   maxROIArea	- The largest expected signal area [µm^2]
%   minROIArea	- The smallest expected signal area [µm^2]
%   mu          - Relative weight of temporal information in stICA
%   nPCs        - Number of principal components used in decomposition
%   PCuse       - Vector of indices of PCs to use for ICA
%   rndSeed     - Random seed for reproducible fast ICA algorithm
%   sigma       - Standard deviation of Gaussian smoothing kernel [pixels]
%   termTol     - Termination tolerance for ICA
%   thresholdSeg - Threshold for segmenting spatial filters
%   
% ConfigFindROIsCellSort public methods
%   ConfigFindROIsCellSort - ConfigFindROIsCellSort class constructor
%   copy            - Copy MATLAB array of handle objects
%   create_calc     - Return a Calc object containing the Config object
%   get_dims        - Return the dimensions needed for the opt_config GUI
%   opt_config      - Optimise parameters using a GUI
%
% ConfigFindROIsCellSort static methods
%   from_preset     - Create a config object from a preset
%
% ConfigFindROIsCellSort public events:
%   ProcessNow      - Notifies listeners to process an object
%
%   See also ConfigFindROIsDummy, Config, CalcFindROIsCellSort, CellScan

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
        
        %badFrames - List of frame indices to be excluded from analysis
        %
        %   If empty, all frames are used for analysis. [default = []]
        badFrames  = [];
        
        %fLims - The first and last frame to be analysed
        %
        %   Two element vector specifiying the first and last frame in the
        %   image sequence that should be analysed.  If empty, all frames
        %   will be analysed. [default = []]
        fLims = [];
        
        %maxIters - Maximum number of iterations for ICA
        %
        %   Maximum number of iterations for algorithm that finds
        %   independent components. [default = 500]
        %
        %   See also utils.cellsort.CellsortICA
        maxIters = 500;
        
        %mu - Relative weight of temporal information in stICA
        %
        %   A parameter (between 0 and 1) specifying weight of temporal
        %   information in spatio-temporal ICA (stICA). Appropriate mu is
        %   to be chosen as function of several factors including frame
        %   rate, number of cells in FOV and spiking rate. [default = 0.15]
        %   
        %   See also utils.cellsort.CellsortICA
        mu = 0.15; % The paper suggests that 0.1-0.2 is a good value.
        
        %nPCs - Number of principal components used in decomposition
        %
        %   Ideally these should allow for both: considerable
        %   dimensionality reduction and high percentage of explained
        %   variance. Depending on the noisiness of input image, it may not
        %   be possible to achieve both. [default = 100]
        %   
        %   See also utils.cellsort.CellsortPCA, pca
        nPCs = 100;
        
        % PCuse - Vector of indices of PCs to use for ICA
        %
        %   The vector contains indices of the PCs to be kept for
        %   dimensional reduction.
        %
        % See also CalcFindROIsCellSort.nPCs
        PCuse = [];
        
        %rndSeed - Random seed for reproducible fast ICA algorithm
        %
        %   Random seed determines the state of pseudrandom number
        %   generator. Needs to be kept fixed to obtain consistent results.
        %   If rndSeed is empty the seed will not be changed. [default = 1]
        %   
        %   See also rng, randn
        rndSeed = 1;
        
        %sigma - Standard deviation of Gaussian smoothing kernel [pixels]
        %
        %   The smoothing filter is used during segmentation of
        %   spatio-temporal ICA filters to components corresponding to
        %   individual cells. Value is given in pixels. [default = 3]
        %
        %   See also utils.cellsort.CellsortSegmentation, fspecial
        sigma = 3;
        
        %termTol - Termination tolerance for ICA
        %
        %   Fractional change in output at which to end iteration of the
        %   fixed point algorithm that finds independent components.
        %
        %   See also utils.cellsort.CellsortICA
        termTol = 1e-6;
        
        %thresholdSeg - Threshold for segmenting spatial filters
        %
        %   Spatial filters are used during segmentation of spatio-temporal
        %   ICA filters to obtain a binary mask. Value is given in units
        %   of s.d. [default = 2]
        %
        %   See also utils.cellsort.CellsortSegmentation, greythresh
        thresholdSeg = 2;
        
    end
    
     % ------------------------------------------------------------------ %
     
    properties (Constant, Access = protected)
        
        %classCalc - Constant, protected property containing the name of
        %   the associated Calc class
        classCalc = 'CalcFindROIsCellSort';
        
        optList = {'PCA', {'nPCs', 'PCuse', 'fLims', 'badFrames', ...
                'inpaintIters'}; ...
            'ICA', {'maxIters', 'mu', 'rndSeed', 'termTol'}; ...
            'Segmentation', {'minROIArea', 'maxROIArea', 'sigma', ...
                'thresholdSeg', 'discardBorderROIs'}};
        
    end

	% ================================================================== %
     
    methods 
        
        function ConfigCellSortObj = ConfigFindROIsCellSort(varargin)
        %ConfigFindROIsCellSort - ConfigFindROIsCellSort class constructor
        %
        %   OBJ = ConfigFindROIsCellSort() creates a Config object OBJ with
        %   default values for all properties.
        %
        %   OBJ = ConfigFindROIsCellSort(..., 'property', value, ...) or
        %   OBJ = ConfigFindROIsCellSort(..., propStruct, ...) 
        %
        %   This syntax specifies values for the properties, either in the
        %   form of attribute-value pairs, or structures (or objects) where
        %   the field (property) names correspond to properties in the
        %   ConfigFindROIsCellSort class. The argument parsing is done by
        %   the utility function parsepropval (link below), so please
        %   consult the documentation for this function for further
        %   details.
        %
        %   See also utils.parsepropval,
        %   ConfigFindROIsCellSort.from_preset, ConfigFindROIsCellSort,
        %   ConfigFindROIsFLIKA, ConfigFindROIsDummy, ConfigFindROIsAuto,
        %   Config, ConfigCellScan
            
            % Call Config (i.e. parent class) constructor
            ConfigCellSortObj = ...
                ConfigCellSortObj@ConfigFindROIsAuto(varargin{:});
            
        end
        
        % -------------------------------------------------------------- %
        
        function self = set.badFrames(self, val)
            
            if ~isempty(val)
                utils.checks.length(val,get.numFrames,'badFrames','smaller')
                utils.checks.rfv(val, 'badFrames');
            end
            
            % Assign value
            self.badFrames = val(:);
        end
        
        % -------------------------------------------------------------- %
        
        function self = set.fLims(self, val)
            
            if ~isempty(val)
                allowEq = true;
                numFrames_crop = val(2) - val(1);
                utils.checks.less_than(self.numFrames, numFrames_crop,...
                    allowEq, 'fLims')
                utils.checks.rfv(val, 'fLims');
            end
            
            % Assign value
            self.fLims = val(:);
        end
        
        % -------------------------------------------------------------- %
        
        function self = set.maxIters(self,val)
            
            if ~isempty(val)
                utils.checks.scalar(val, 'maxIters')
                % Check that the number of allowed iterations is reasonable
                utils.checks.less_than(val, 1e5, [], 'maxIters')
            end
            % Assign value
            self.maxIters = val(:);
        end
        
        % -------------------------------------------------------------- %
        
        function self = set.mu(self,val)
            
            % Check that the value is a positive, real, finite, scalar
            % number
            allowEq = true;
            utils.checks.scalar(val, 'mu')
            utils.checks.greater_than(val, 0, allowEq, 'mu')
            utils.checks.less_than(val, 1, allowEq, 'mu')
            utils.checks.rfv(val, 'mu')
            % Assign value
            self.mu = val(:);
            
        end
        
        % -------------------------------------------------------------- %
        
        function self = set.nPCs(self, val)
            
            if ~isempty(val)
                % Check that the value is a single row integer
                utils.checks.integer(val, 'nPCs')
                utils.checks.positive(val, 'nPCs')
            end
                        
            % Assign value
            self.nPCs = val(:);
        end
        
        % -------------------------------------------------------------- %
        
        function self = set.PCuse(self, val)
            
            % Convert to a range of frames
            if isscalar(val)
                val = 1:val;
            end
                
            % Check that the value is a single row integer
            utils.checks.integer(val, 'PCuse')
            utils.checks.vector(val, 'PCuse')
            utils.checks.positive(val, 'PCuse')
            
            % Check that the length is greater than a number
            utils.checks.length(val, 2, 'PCuse', 'greater')
            
            % Assign value
            self.PCuse = val(:);
        end
        
        % -------------------------------------------------------------- %
               
        function self = set.rndSeed(self, val)
            
            if ~isempty(val)
                % Check that the value is a single row integer
                utils.checks.integer(val, 'rndSeed')
                utils.checks.positive(val, 'rndSeed')
            end
                        
            % Assign value
            self.rndSeed = val(:);
        end
        
        % -------------------------------------------------------------- %
        
        function self = set.sigma(self, val)
            
            if ~isempty(val)
                utils.checks.integer(val, 'sigma')
                utils.checks.positive(val, 'sigma');
            end
            % Assign value
            self.sigma = val(:);
        end
        
        % -------------------------------------------------------------- %
        
        function self = set.termTol(self,val)
            
            if ~isempty(val)
                utils.checks.scalar(val, 'termTol')
                % Check that numerical tolerance is of reasonable scale
                utils.checks.less_than(val, 1e-2, [], 'termTol')
            end
            % Assign value
            self.termTol = val(:);
        end
        
        % -------------------------------------------------------------- %
        
        function self = set.thresholdSeg(self, val)
            
            if ~isempty(val)
                utils.checks.prfs(val, 'thresholdSeg')
            end
            % Assign value
            self.thresholdSeg = val(:);
        end
        
    end
    
    % ================================================================== %
    
end
