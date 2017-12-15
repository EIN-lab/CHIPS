classdef CalcDetectSigsDummy < CalcDetectSigs
%CalcDetectSigsDummy - Class for dummy signal detection
%
%   CalcDetectSigsDummy is a CalcDetectSigs class that performs dummy
%   signal detection.  That is, it simply acts as a placeholder for cases
%   where signal detection is not required.
%
%   CalcDetectSigsDummy is a subclass of matlab.mixin.Copyable, which is
%   itself a subclass of handle, meaning that CalcDetectSigsDummy objects
%   are actually references to the data contained in the object.  This
%   allows certain features that are only possible with handle objects,
%   such as events and certain GUI operations.  However, it is important to
%   use the copy method of matlab.mixin.Copyable to create a new,
%   independent object; otherwise changes to a CalcDetectSigsDummy object
%   used in one place will also lead to changes in another (perhaps
%   undesired) place.
%
% CalcDetectSigsDummy public properties
%   config          - A scalar ConfigDetectSigsDummy object
%   data            - A scalar DataDetectSigsDummy object
%   nColsDetect     - The number of columns needed for plotting
%
% CalcDetectSigsDummy public methods
%   CalcDetectSigsDummy  - CalcDetectSigsDummy class constructor
%   copy            - Copy MATLAB array of handle objects
%   plot            - Plot a figure
%   process         - Run the processing
%
%   See also CalcDetectSigs, CalcDetectSigsClsfy, Calc,
%   ConfigDetectSigsDummy, DataDetectSigsDummy, CellScan

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
        nColsDetect = 3;
    end
    
    % ------------------------------------------------------------------ %
    
    properties (Constant, Access = protected)
        
        %validConfig - Constant, protected property containing the name of
        %   the associated Config class
        validConfig = {'ConfigDetectSigsDummy'};
        
        %validData - Constant, protected property containing the name of
        %   the associated Data class
        validData = {'DataDetectSigsDummy'};
    end
    
    % ================================================================== %
    
    methods
        
        function cdsdObj = CalcDetectSigsDummy(varargin)
        %CalcDetectSigsDummy - CalcDetectSigsDummy class constructor
        %
        %   OBJ = CalcDetectSigsDummy() prompts for all required
        %   information and creates a CalcDetectSigsDummy object.
        %
        %   OBJ = CalcDetectSigsDummy(CONFIG, DATA) uses the specified
        %   CONFIG and DATA objects to construct the CalcDetectSigsDummy
        %   object. If any of the input arguments are empty, the
        %   constructor will prompt for any required information.  The
        %   input arguments must be scalar ConfigDetectSigsDummy and/or
        %   DataDetectSigsDummy objects.
        %
        %   See also ConfigDetectSigsDummy, DataDetectSigsDummy
        
            % Parse arguments
            [configIn, dataIn] = utils.parse_opt_args({[], []}, varargin);
            
            % Call Calc (i.e. parent class) constructor
            cdsdObj = cdsdObj@CalcDetectSigs(configIn, dataIn);
            
        end      
        
    end
    
    % ================================================================== %
    
    methods (Access = protected)
        
        function self = detect_sigs(self, ~, ~, ~, roiNames)
            % Add the processed data
            self.data = self.data.add_processed_data(roiNames);
        end
        
        % -------------------------------------------------------------- %
        
        function annotate_traces(~, ~, ~, varargin)
            warning('CalcDetectSigsDummy:AnnotateTraces:NoClsfy', ...
                'This plot does not produce any output for this class')
        end
        
        % -------------------------------------------------------------- %
        
        function varargout = plot_clsfy(~, ~, ~)
            warning('CalcDetectSigsDummy:PlotClsfy:NoClsfy', ...
                'This plot does not produce any output for this class')
            if nargout > 0
                varargout{1} = [];
            end
        end

        % -------------------------------------------------------------- %
        
        function varargout = plot_signals(~, ~, varargin)
            warning('CalcDetectSigsDummy:PlotSigs:NoClsfy', ...
                'This plot does not produce any output for this class')
            if nargout > 0
                varargout{1} = [];
            end
        end
        
    end
    
    % ================================================================== %
    
    methods (Static, Access = protected)
        
        function configObj = create_config()
        %create_config - Creates an object of the associated Config class
        
            configObj = ConfigDetectSigsDummy();
            
        end
        
        % -------------------------------------------------------------- %
        
        function dataObj = create_data()
        %create_data - Creates an object of the associated Data class
        
            dataObj = DataDetectSigsDummy();
            
        end
        
    end
    
    % ================================================================== %
    
end
