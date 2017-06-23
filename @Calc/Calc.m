classdef (Abstract) Calc < matlab.mixin.Copyable
%Calc - Superclass for Calc classes
%
%   Calc is an abstract superclass that implements (or requires
%   implementation in its subclasses via abstract methods or properties)
%   most functionality related to Calc objects.  Typically there is one
%   concrete subclass of Calc for every calculation algorithm, and it
%   contains the algorithm-specific code that is needed for the
%   calculation.
%
%   Calc is a subclass of matlab.mixin.Copyable, which is itself a subclass
%   of handle, meaning that Calc objects are actually references to the
%   data contained in the object.  This allows certain features that are
%   only possible with handle objects, such as events and certain GUI
%   operations.  However, it is important to use the copy method of
%   matlab.mixin.Copyable to create a new, independent object; otherwise
%   changes to a Calc object used in one place will also lead to changes in
%   another (perhaps undesired) place.
%
% Calc public properties
%   config  - A scalar Config object
%   data    - A scalar Data object
% 
% Calc public methods
%   Calc	- Calc class constructor
%   copy    - Copy MATLAB array of handle objects
%   plot    - Plot a figure
%   process - Run the processing
%
%   See also matlab.mixin.Copyable, handle, Config, Data, ProcessedImg

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
        %config - A scalar Config object
        %
        %   See also Config
        config
    end
    
    % ------------------------------------------------------------------ %
    
    properties (SetAccess = protected)
        %data - A scalar Data object
        %
        %   See also Data
        data
    end
    
    % ------------------------------------------------------------------ %
    
    properties (Abstract, Constant, Access = protected)
        
        %validConfig - A list of valid Config classes
        validConfig
        
        %validConfig - A list of valid Data casses
        validData
        
        %validPlotNames - A list of valid plot names
        validPlotNames
        
        % validProcessedImg - A list of valid ProcessedImg classes
        validProcessedImg
        
    end
    
    % ================================================================== %
    
    methods
        
        function CalcObj = Calc(varargin)
        %Calc - Calc class constructor
        %
        %   OBJ = Calc() prompts for all required information and creates a
        %   Calc object.
        %
        %   OBJ = Calc(CONFIG, DATA) uses the specified CONFIG and DATA
        %   objects to construct the Calc object. If any of the input
        %   arguments are empty, the constructor will prompt for any
        %   required information.  The input arguments must be objects
        %   which meet the requirements of the particular concrete subclass
        %   of Calc.
        %
        %   See also Config, Data
            
            % Parse arguments
            [configIn, dataIn] = utils.parse_opt_args({[], []}, varargin);
            
            % Check or choose config
            if isempty(configIn)
                CalcObj.config = CalcObj.choose_config();
            else
                % Do these checks here (rather than only in the set method)
                % to ensure we can rely on the copy method being present,
                % otherwise we might get weird errors
                confName = 'config';
                utils.checks.scalar(configIn, confName);
                utils.checks.object_class(configIn, ...
                    CalcObj.validConfig, confName);
                CalcObj.config = copy(configIn);
            end
            
            % Check or create data
            if isempty(dataIn)
                CalcObj.data = CalcObj.create_data();
            else
                CalcObj.data = dataIn;
            end
            
        end
        
        % -------------------------------------------------------------- %
        
        function self = set.config(self, config)
            
            % Check it's scalar
            varName = 'config';
            utils.checks.scalar(config, varName);
            
            % Check the class
            utils.checks.object_class(config, self.validConfig, varName);
            
            % Set the property
            self.config = config;
            
        end
        
        % -------------------------------------------------------------- %
        
        function self = set.data(self, data)
            
            % Check it's scalar
            varName = 'data';
            utils.checks.scalar(data, varName);
            
            % Check the class
            utils.checks.object_class(data, self.validData, varName);
            
            % Set the property
            self.data = data;
            
        end
        
    end
    
    % ================================================================== %
    
    methods (Abstract)
        
        %process - Run the processing
        self = process(self, objPI)
        
        %plot - Plot a figure
        varargout = plot(self, objPI, varargin)
        
    end
    
    % ================================================================== %
    
    methods (Access = protected)
        
        function configObj = choose_config(self)
        %choose_config - Choose (or create) an appropriate config object
            configObj = self.create_config();
        end
        
        % -------------------------------------------------------------- %
        
        function cpObj = copyElement(obj)
        %copyElement - Customised copyElement class method to ensure that
        %   the config property (a handle object) is recursively copied.
            
            % Make a shallow copy of the object
            cpObj = copyElement@matlab.mixin.Copyable(obj);
             
            % Make a deep copy of the config object
            cpObj.config = copy(obj.config);
             
        end
        
        % -------------------------------------------------------------- %
        
        function flag = check_state_plot(self)
            
            % Check it's a scalar
            if ~isscalar(self)
                error('Calc:Plot:NotScalar', ['At this time plotting ' ...
                    'is only possible for scalar Calc objects.'])
            end
            
            % Check if the CellScan has already been processed
            flag = 1;
            if ~strcmp(self.data.state, 'processed')
                warning('Calc:Plot:NotProcessed', ['The %s object ' ...
                    'must be processed before plotting. The current ' ...
                    'state is: "%s".'], class(self), self.data.state)
                flag = 0;
            end
            
        end
        
        % -------------------------------------------------------------- %
        
        function [hAx, plotName, idxStart] = check_plot_args(self, ...
                objPI, args)
            
            % Check the ProcessedImg
            self.check_objPI(objPI);
            
            % Call the utility function to do most of the work
            [hAx, plotName, idxStart] = utils.check_plot_args(...
                self.validPlotNames, args, 'axes');
            
        end
        
        % -------------------------------------------------------------- %
        
        function check_objPI(self, objPI)
            
            % Check the ProcessedImg
            utils.checks.object_class(objPI, self.validProcessedImg, ...
                'ProcessedImg object');
            utils.checks.scalar(objPI, 'ProcessedImg object');
            
        end
        
    end
    
    % ================================================================== %
    
    methods (Static, Abstract, Access = protected)
        
        %create_config - Create a Config object for the Calc object
        create_config()
        
        %create_data - Create a Data object for the Calc object
        create_data()
        
    end
    
    % ================================================================== %
    
end
