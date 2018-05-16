classdef CalcDetectSigsCellSort < CalcDetectSigs
%CalcDetectSigsCellSort - Class for detecting and classifying signals
%
%   The CalcDetectSigsCellSort class is a Calc class that detects and
%   classifies signals in previously identified ROIs. 
%
%   CalcDetectSigsCellSort is a subclass of matlab.mixin.Copyable, which is
%   itself a subclass of handle, meaning that CalcDetectSigsCellSort objects
%   are actually references to the data contained in the object.  This
%   allows certain features that are only possible with handle objects,
%   such as events and certain GUI operations.  However, it is important to
%   use the copy method of matlab.mixin.Copyable to create a new,
%   independent object; otherwise changes to a CalcDetectSigsCellSort object
%   used in one place will also lead to changes in another (perhaps
%   undesired) place.
%
% CalcDetectSigsCellSort public properties
%   config          - A scalar ConfigDetectSigsClsfy object
%   data            - A scalar DataDetectSigsClsfy object
%   nColsDetect     - The number of columns needed for plotting
%
% CalcDetectSigsCellSort public methods
%   CalcDetectSigsCellSort  - CalcDetectSigsCellSort class constructor
%   copy            - Copy MATLAB array of handle objects
%   plot            - Plot a figure
%   process         - Run the processing
%
%   See also CalcDetectSigs, CalcDetectSigsDummy, Calc,
%   ConfigDetectSigsClsfy, DataDetectSigsClsfy, CellScan

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
    
    properties (Constant)
        %nColsDetect - The number of columns needed for plotting
        nColsDetect = 6;
    end
    
    % ------------------------------------------------------------------ %
    
    properties (Constant, Access = protected)
        
        %validConfig - Constant, protected property containing the name of
        %   the associated Config class
        validConfig = {'ConfigDetectSigsCellSort'};
        
        %validData - Constant, protected property containing the name of
        %   the associated Data class
        validData = {'DataDetectSigsCellSort'};
        
    end
    
    % ================================================================== %
    
    methods
        
        function cdscObj = CalcDetectSigsCellSort(varargin)
        %CalcDetectSigsCellSort - CalcDetectSigsCellSort class constructor
        %
        %   OBJ = CalcDetectSigsCellSort() prompts for all required
        %   information and creates a CalcDetectSigsCellSort object.
        %
        %   OBJ = CalcDetectSigsCellSort(CONFIG, DATA) uses the specified
        %   CONFIG and DATA objects to construct the CalcDetectSigsCellSort
        %   object. If any of the input arguments are empty, the
        %   constructor will prompt for any required information. The
        %   input arguments must be scalar ConfigDetectSigsClsfy and/or
        %   DataDetectSigsClsfy objects.
        %
        %   See also ConfigDetectSigsClsfy, DataDetectSigsClsfy
        
            % Parse arguments
            [configIn, dataIn] = utils.parse_opt_args({[], []}, varargin);
            
            % Call CalcDetectSigs (i.e. parent class) constructor
            cdscObj = cdscObj@CalcDetectSigs(configIn, dataIn);
            
        end
                         
        % -------------------------------------------------------------- %
    end
    
    % ================================================================== %
    methods (Access = protected)
        
        self = detect_sigs(self, objPI, traces, frameRate, roiNames)
        
    % -------------------------------------------------------------- %
        
        function annotate_traces(~, ~, ~, varargin)
            warning('CalcDetectSigsCellSort:AnnotateTraces:NoClsfy', ...
                'This plot does not produce any output for this class')
        end
        
        % -------------------------------------------------------------- %
        
       function varargout = plot_clsfy(~, ~, ~)
            warning('CalcDetectSigsCellSort:PlotClsfy:NoClsfy', ...
                'This plot does not produce any output for this class')
            if nargout > 0
                varargout{1} = [];
            end
        end
        
        % -------------------------------------------------------------- %
        
        varargout = plot_signals(self, objPI, varargin)
        
        % -------------------------------------------------------------- %
        
        varargout = plot_ICAsigs(self, objPI, hAx, varargin)
        
        % -------------------------------------------------------------- %
    end
    
    % ================================================================== %

    methods (Static, Access = protected)
        
        function flagVersion = check_version()
            
            className = 'CalcDetectSigsCellSort';
            featureSig = 'Signal_Toolbox';
            toolboxdirSig = 'signal';
            verSig = '6.22';
            flag = utils.verify_license(featureSig, className, ...
                toolboxdirSig, verSig);
            if flag < 1
                if verLessThan(toolboxdirSig, '6.21')
                    flagVersion = -2;
                else
                    flagVersion = -1;
                end
            else
                flagVersion = 0;
            end

        end
        
                
        % -------------------------------------------------------------- %
        
        function configObj = create_config()
        %create_config - Creates an object of the associated Config class
        
            configObj = ConfigDetectSigsCellSort();
        
        end
        
        % -------------------------------------------------------------- %
        
        function dataObj = create_data()
        %create_data - Creates an object of the associated Data class
        
            dataObj = DataDetectSigsCellSort();
        
        end
        
        % -------------------------------------------------------------- %
    end
    
    % ================================================================== %
    
end
