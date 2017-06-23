classdef (Abstract) ConfigMultiple < ConfigHelper & dynamicprops
%ConfigMultiple - Superclass for multiple config container objects
%
%   The ConfigMultiple class is an abstract superclass that is designed to
%   contain more than one Config object for those ProcessedImg objects that
%   contain more than one Calc object.  This ensures that a single Config
%   object can be passed to all ProcessedImg objects, which is required for
%   the grouping classes (e.g. ImgGroup) to function correctly.
%
%   ConfigMultiple is a subclass of matlab.mixin.Copyable, which is itself
%   a subclass of handle, meaning that ConfigMultiple objects are actually
%   references to the data contained in the object.  This allows certain
%   features that are only possible with handle objects, such as events and
%   certain GUI operations.  However, it is important to use the copy
%   method of matlab.mixin.Copyable to create a new, independent object;
%   otherwise changes to a ConfigMultiple object used in one place will
%   also lead to changes in another (perhaps undesired) place.
%
%   In addition, ConfigMultiple is also a subclass of dynamicprops, and
%   uses the functionality of this class to create dynamic properties based
%   on the specific needs of the relevant concrete subclass.
%
% ConfigMultiple public properties
%   configClasses   - The list of allowed classes for the config objects
%   configNames     - The (dynamic) property names of the Config objects
%
% ConfigMultiple public methods
%   ConfigMultiple  - ConfigMultiple class constructor
%   copy            - Copy MATLAB array of handle objects
%
%   See also ConfigHelper, matlab.mixin.Copyable, dynamicprops, handle,
%   Config, Calc

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
    
    properties (Abstract, Constant)
        
        %configClasses - The list of allowed classes for the config objects
        %
        %   configClasses is a cell array containing cell arrays of
        %   character arrays that correspond to the allowed class names for
        %   the corresponding configNames
        %
        %   See also ConfigMultiple.configNames
        configClasses
        
        %configNames - The (dynamic) property names of the Config objects
        %
        %   configNames is a cell array containing character arrays that
        %   correspond to the (dynamic) property names that will contain
        %   the required config objects
        %
        %   See also ConfigMultiple.configClasses
        configNames
        
    end
    
    % ------------------------------------------------------------------ %
    
    properties (Access = protected)
        
        %metaProps - A container to store the meta.DynamicProperty objects
        %
        %   See also meta.DynamicProperty
        metaProps = {};
        
    end
    
    % ================================================================== %
    
    methods
        
        function ConfigMultObj = ConfigMultiple(varargin)
        %ConfigMultiple - ConfigMultiple class constructor
        %
        %   OBJ = ConfigMultiple() prompts for all required information and
        %   creates a ConfigCellScan object.
        %
        %   OBJ = ConfigMultiple(CONFIG1, CONFIG2, ...) uses the specified
        %   CONFIG objects to construct the ConfigMultiple object. If any
        %   of the input arguments are empty, the constructor will prompt
        %   for any required information.  The input arguments must be
        %   objects which meet the requirements of the particular concrete
        %   subclass of ConfigMultiple.
            
            % Extract the number of configs that this object is supposed to
            % deal with
            nConfigs = numel(ConfigMultObj.configNames);
            
            % Check the number of arguments in
            narginchk(0, nConfigs)
            
            % Pre-allocate empty 'configs' representing the inputs
            configsIn = repmat({[]}, [1, nConfigs]);
            
            % Extract any config arguments that were supplied
            for iConfigIn = 1:nargin
                configsIn{iConfigIn} = varargin{iConfigIn}; 
            end
            
            % Pre-allocate logical arrays to assist with matching arguments
            isMatch = repmat({false([1, nConfigs])}, [1, nConfigs]);
            
            % Loop through all the configs dealt with by this class
            for iConfig = 1:nConfigs
                
                % Extract the name for the current config
                iConfigName = ConfigMultObj.configNames{iConfig};
                
                % Extract out how many possibilites there are for the
                % current config property, and loop through them
                i_nClasses = numel(ConfigMultObj.configClasses{iConfig});
                for jClass = 1:i_nClasses
                    
                    % Extract out the current config class name
                    jClassName = ...
                        ConfigMultObj.configClasses{iConfig}{jClass};
                    
                    % Check if any of the inputs match this class
                    isMatch{iConfig} = isMatch{iConfig} | ...
                        cellfun(@(obj) isa(obj, jClassName), configsIn);
                    
                end
                
                % Add up the number of matches for this config
                i_nConfigs = sum(isMatch{iConfig});
                if i_nConfigs == 0
                    
                    % If there are no matches, choose one from the
                    % available options (prompting the user if necessary.
                    iConfigObj = ConfigMultObj.choose_config(iConfig);
                    
                elseif i_nConfigs == 1
                    
                    % If there's only one, 
                    iConfigObj = configsIn{isMatch{iConfig}};
                    
                else
                    
                    % Throw an error if there are too many matches
                    error('ConfigMultiple:TooManyMatches', ['More ' ...
                        'than one config matching "%s" was supplied.'], ...
                        iConfigName)
                    
                end
                
                % Create a dynamic property based on this name, and assign
                % the config to it
                ConfigMultObj.metaProps{iConfig} = ...
                    ConfigMultObj.addprop(iConfigName);
                ConfigMultObj.(iConfigName) = iConfigObj;
                
                % Change the NonCopyable behaviour of the dynamic property
                % so that we can copy it if required.  This is inside a try
                % statement because NonCopyable does not exist on older
                % MATLAB versions
                if ~verLessThan('matlab', '8.6')
                    ConfigMultObj.metaProps{iConfig}.NonCopyable = false;
                end
                
            end
            
        end
        
    end
    
    % ================================================================== %
    
    methods (Access = protected)
        
        function confObj = choose_config(self, iConfig)
            
            % Prepare a list of the config options
            listMethods = self.configClasses{iConfig};
            nOpts = numel(listMethods);
            
            if nOpts == 1
                
                % Choose the only option
                strClassName = listMethods{1};
                
            elseif nOpts > 1
                
                 % Choose method to find ROIs
                strTitle = sprintf('Which %s would you like to use?', ...
                    self.configNames{iConfig});
                strPrompt = sprintf('Select a %s, please:', ...
                    self.configNames{iConfig});
                imgOptions = [{''}, listMethods];
                defOption = 1;
                methodNum = utils.txtmenu({strTitle, strPrompt}, ...
                    defOption, imgOptions);
                strClassName = listMethods{methodNum};
                
            else
                
                error('ConfigMultiple:ChooseConfig:NoOpts', ['There ' ...
                    'are no options for the %s.  Contact a developer!'], ...
                    self.configNames{iConfig})
                
            end
            
            % Create the config object
            fConf = str2func(strClassName);
            confObj = fConf();
            
        end
        
        % -------------------------------------------------------------- %
        
        function cpObj = copyElement(obj)
        %copyElement - Customised copyElement class method to ensure that
        %   the config properties (handle objects) are recursively copied.
            
            % Make a shallow copy of the object
            cpObj = copyElement@matlab.mixin.Copyable(obj);
             
            % Make a deep copy of the config objects
            nConfigs = numel(obj.configNames);
            for iConfig = 1:nConfigs
                cpObj.(obj.configNames{iConfig}) = ...
                    copy(obj.(obj.configNames{iConfig}));
            end
             
        end
        
    end
    
    % ================================================================== %
    
end
