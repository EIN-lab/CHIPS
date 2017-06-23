classdef (Abstract) Processable < matlab.mixin.Copyable & ITraj 
%Processable - Superclass for Processable classes
%
%   The Processable class is an abstract superclass that implements (or
%   requires implementation in its subclasses via abstract methods or
%   properties) most functionality related to Processable objects.
%
%   Processable is a subclass of matlab.mixin.Copyable, which is itself a
%   subset of handle, meaning that Processable objects are actually
%   references to the data contained in the object.  This ensures memory is
%   used efficiently when Processable objects are contained in other
%   objects. However, Processable objects can use the copy method of
%   matlab.mixin.Copyable to create new, independent objects.
%
% Processable public properties:
%   name            - The object name
%   state           - The object state 
% 
% Processable public methods:
%   Processable     - Processable class constructor
%   copy            - Copy MATLAB array of handle objects
%   output_data     - Output the data
%   plot            - Plot a figure
%   process         - Process the elements of the object
%
%   See also matlab.mixin.Copyable, handle

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
        %name - The object name
        name
    end
    
    % ------------------------------------------------------------------ %
    
    properties (Abstract, Dependent)
        %state - The object state
        state
    end
    
    % ------------------------------------------------------------------ %
    
    properties (Access = protected)
        %name_sub - Protected property to contain the actual Processable
        %   object name.  I can't remember entirely why it's done like
        %   this, but I think it's related to some strange recursion error.
        name_sub
    end
    
    % ================================================================== %
    
    methods
        
        function ProcessableObj = Processable(varargin)
        %Processable - Processable class constructor
            
            % Parse arguments
            nameIn = utils.parse_opt_args({''}, varargin);
            
            % Ensure nameIn is a cell array
            if ~iscell(nameIn)
                nameIn = {nameIn};
            end
            
            % Set the name
            nFiles = length(nameIn);
            for iRawImg = nFiles:-1:1
                if ~isempty(nameIn{iRawImg})
                    ProcessableObj(iRawImg).name = nameIn{iRawImg};
                end
            end
            
        end
        
        % -------------------------------------------------------------- %
        
        function set.name(self, name)
            utils.checks.single_row_char(name, 'name');
            self.name_sub = name;
        end
        
        % -------------------------------------------------------------- %
        
        function name = get.name(self)
            name = self.name_sub;
        end
        
    end
    
    % ================================================================== %
    
    methods (Abstract)
        
        %output_data - Output the data
        output_data(self, fnCSV, varargin)
        
        %plot - Plot a figure
        varargout = plot(self, varargin)
        
    end
    
    % ================================================================== %
    
    methods (Abstract, Hidden)
        
        %plot_average - Plot an average figure
        varargout = plot_average(self, varargin)
        
    end
    
    % ================================================================== %
    
    methods (Abstract)
        
        %process - Process the elements of an object
        varargout = process(self, useParallel, varargin)
        
    end
    
    % ================================================================== %
    
    methods (Static, Access = protected)
        
        function [hConstructor, isCancelled, strType] = ...
            choose_Processable(varargin)

            % Parse optional arguments
            [doAllowCancel, doProcessedImg] = ...
                utils.parse_opt_args({false, false}, varargin);
            
            if ~doProcessedImg
                strSuperclass = 'Processable';
                strTitleSub = [strSuperclass 'Image'];
            else
                strSuperclass = 'ProcessedImg';
                strTitleSub = strSuperclass;
            end

            % Setup empty output arguments
            strType = '';
            hConstructor = @() disp([]);

            % Create a list of all the non-abstract subclasses of RawImg
            subclasses = utils.find_subclasses(strSuperclass);

            if ~doAllowCancel
                imgOptions = [{''}, subclasses];
                defOption = 1;
                strTitle = ['What type of ' strTitleSub ' would you ' ...
                'like to create?'];
            else
                strTitle = [];
                imgOptions = [{'<Finished>'}, subclasses];
                defOption = 0;
            end

            % Ask the user to choose which image type to use
            imgType = utils.txtmenu({strTitle, 'Select a class:'}, ...
                defOption, imgOptions);

            % Work out if the user cancelled
            isCancelled = doAllowCancel && (imgType == 0);

            if ~isCancelled

                % Create a handle to the ProcessedImg subclass constructor
                strType = imgOptions{imgType+1};
                hConstructor = str2func(strType);

            end

        end
        
        % -------------------------------------------------------------- %
        
        function name = choose_name(varargin)
            
            % Parse arguments
            rawImgIn = utils.parse_opt_args({[]}, varargin);
            
            % Setup a default name
            defName = datestr(now, 'yyyy-mm-dd_HH:MM:SS');
            
            % Check if there is a raw image
            hasRawImg = ~isempty(rawImgIn);
            if hasRawImg
                
                name = {rawImgIn(:).name};
                
                for iRawImg = 1:numel(rawImgIn)
                    if isempty(name{iRawImg})
                        name{iRawImg} = defName;
                    end
                end
                
            else
                
                name = {defName};
                
                if ~isempty(rawImgIn) && ~isscalar(rawImgIn)
                    name = repmat(name, size(rawImgIn));
                end
                
            end
            
        end
        
    end
    
    % ================================================================== %
    
end
