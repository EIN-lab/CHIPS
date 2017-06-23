classdef (Abstract) Config < ConfigHelper
%Config - Superclass for Config classes
%
%   Config is an abstract superclass that implements (or requires
%   implementation in its subclasses via abstract methods or properties)
%   most functionality related to Config objects.  Typically there is one
%   concrete subclass of Config for every concrete subclass of Calc, and
%   the Config object contains the algorithm-specific parameters that are
%   needed for the corresponding Calc class to function.
%
%   Config is a subclass of matlab.mixin.Copyable, which is itself a
%   subclass of handle, meaning that Config objects are actually references
%   to the data contained in the object.  This allows certain features that
%   are only possible with handle objects, such as events and certain GUI
%   operations.  However, it is important to use the copy method of
%   matlab.mixin.Copyable to create a new, independent object; otherwise
%   changes to a Config object used in one place will also lead to changes
%   in another (perhaps undesired) place.
%   
% Config public methods
%   Config          - Config class constructor
%   copy            - Copy MATLAB array of handle objects
%   create_calc     - Return a Calc object containing the Config object
%   get_dims        - Return the dimensions needed for the opt_config GUI
%   opt_config      - Optimise parameters using a GUI
%
% Config static methods
%   from_preset     - Create a Config object from a preset
%
% Config public events:
%   ProcessNow      - Notifies listeners to process an object
%
%   See also matlab.mixin.Copyable, handle, Calc

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
    
    properties (Abstract, Constant, Access = protected)
        
        %classCalc - The Calc class corresponding to this Config class
        classCalc
        
        %optList - The list of parameters that can be optimised, grouped
        %   into different sections (for ease of use)
        optList
        
    end
    
    % ------------------------------------------------------------------ %
    
    properties (Dependent, Access = protected)
        
        %isOptimisable - Can this Config be optimised?
        isOptimisable
        
        %nOptPanels - The number of panels in the opt_config GUI
        nOptPanels
        
        %nOptProps - The total number of properties in the opt_config GUI
        nOptProps
        
    end
        
    % ================================================================== %
    
    events
        
        %ProcessNow - Notifies listeners to process an object
        ProcessNow
        
    end
    
    % ================================================================== %
    
    methods
        
        function ConfigObj = Config(varargin)
        %Config - Config class constructor
        %
        %   OBJ = Config() creates a Config object OBJ with default values
        %   for all properties.
        %
        %   OBJ = Config(..., 'property', value, ...) or
        %   OBJ = Config(..., propStruct, ...) 
        %
        %   This syntax specifies values for the properties, either in the
        %   form of attribute-value pairs, or structures (or objects) where
        %   the field (property) names correspond to properties in the
        %   Config class. The argument parsing is done by the utility
        %   function parsepropval (link below), so please consult the
        %   documentation for this function for more details.
        %
        %   See also utils.parsepropval, Config.from_preset, Config,
        %   ConfigMultiple, Calc, ProcessedImg
            
            % Create a config object from the properties supplied
            ConfigObj = utils.parsepropval(ConfigObj, varargin{:});
            
            % Check that the config is ok
            ConfigObj.check_optList()
            
        end
        
        % -------------------------------------------------------------- %
        
        function CalcObj = create_calc(self)
        %create_calc - Return a Calc object containing the Config object
        %
        %   CALC = create_calc(OBJ) returns the appropriate calc object
        %   CALC corresponding to the class of the config object OBJ.  The
        %   config property of CALC is set to OBJ.  This function is
        %   primarily designed to be used in ProcessedImg object
        %   constructors.
        %
        %   See also Calc.config, Calc, Config
        
            % Create a dummy Config object the same class as self, so that
            % this function also works for non-scalar objects
            hConstructorConfig = str2func(class(self));
            ConfigObj = hConstructorConfig();
            
            % Create a calc object array of the appropriate class, as 
            % defined in the classCalc property of the Config object.
            hConstructorCalc = str2func(ConfigObj.classCalc);
            for iElem = numel(self):-1:1
                CalcObjCell{iElem} = hConstructorCalc(copy(self));
            end
            CalcObj = [CalcObjCell{:}];
            CalcObj = reshape(CalcObj, size(self));
	
        end
        
        % -------------------------------------------------------------- %
        
        function dims = get_dims(self)
        %get_dims - Return the dimensions needed for the opt_config GUI
        %
        %   DIMS = get_dims(OBJ) returns a data structure where the fields
        %   correspond to a dimension name and it's associated value.
        %   These dimensions are needed to construct the GUI used when
        %   calling the opt_config method.
        %
        %   See also Config.opt_config, ProcessedImg.opt_config
            
            dims.edgePanel = 5;
            dims.wEdgeProp = 8;
            dims.wStr = 150;
            dims.wEdit = 50;
            dims.hText = 20;

            dims.wButton = 60;

            dims.yStartProp = 4;
            dims.yIncProp = 20;
            dims.yIncPanel = 2;
            dims.yOffPanTitle = 15;

            dims.wPanel = dims.wStr + dims.wEdit + 2*dims.wEdgeProp + ...
                2*dims.edgePanel;

            dims.panelHeight = dims.edgePanel*3 + 2*dims.hText + ...
                self.nOptProps*dims.hText + self.nOptPanels*(...
                dims.yStartProp*2 + dims.yOffPanTitle) + ...
                (self.nOptPanels-1)*dims.yIncPanel;
            dims.panelWidth = dims.edgePanel*2 + dims.wPanel;

        end
        
        % -------------------------------------------------------------- %
        
        varargout = opt_config(self, objPI, calcName, varargin)
        
        % -------------------------------------------------------------- %
        
        function isOptimisable = get.isOptimisable(self)
            isOptimisable = ~isempty(self.optList);
        end
        
        % -------------------------------------------------------------- %
        
        function nOptPanels = get.nOptPanels(self)
            if self.isOptimisable
                nOptPanels = size(self.optList, 1);
            else
                nOptPanels = 0;
            end
        end
        
        % -------------------------------------------------------------- %
        
        function nOptProps = get.nOptProps(self)
            if self.isOptimisable
                nOptProps = sum(cellfun(@numel, self.optList(:, 2)));
            else
                nOptProps = 0;
            end
        end
        
    end
    
    % ================================================================== %
    
    methods (Access = protected)
        check_optList(self)
    end
    
    % ================================================================== %
    
    methods (Static)
        
        function obj = from_preset(strPreset, varargin) %#ok<INUSD,STOUT>
        %from_preset - Create a Config object from a preset
        %
        %   OBJ = Config.from_preset(PRESET) creates a config object from
        %   the specified preset.  PRESET must be a single row character
        %   array.
        %
        %   OBJ = Config.from_preset(PRESET, ARG1, ARG2, ...) passes all
        %   additional arguments to the appropriate config object
        %   constructor.  This can be useful for creating slight
        %   modifications of the preset configurations.
        %
        %   See also Config, Config.Config
            
            error('Config:FromPreset:NoPreset', ['No presets are ' ...
                'defined for this class. Please construct the config ' ...
                'object by calling the constructor (i.e. class name) ' ...
                'directly.'])
            
        end
        
    end
    
    % ================================================================== %
    
end
