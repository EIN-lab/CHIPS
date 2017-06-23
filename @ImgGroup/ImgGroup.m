classdef ImgGroup < Processable
%ImgGroup - Class to contain groups of processable objects
%
%   The ImgGroup class implements most functionality related to groups of
%   Processable objects.
%
%   Please see the <a href="matlab:web(fullfile(utils.CHIPS_rootdir, 'doc', 'html', 'ig_ImgGroup.html'))">ImgGroup quick start guide</a> for additional documentation
%   and examples.
%
% ImgGroup public properties:
%   children    - A cell array containing the Processable child objects
%   name        - The object name
%   nChildren   - The number of children in the object
%   state       - The object state
% 
% ImgGroup public methods:
%   ImgGroup    - ImgGroup class constructor
%   add         - Add children to the object
%   copy        - Copy MATLAB array of handle objects
%   get_config  - Return the Configs from this object
%   opt_config  - Optimise the parameters in Config objects using a GUI
%   output_data - Output the data
%   plot        - Plot a figure for each child object
%   process     - Process the child objects
%
% ImgGroup static methods:
%   from_files  - Create an ImgGroup object from a list of files
%
%   See also ImgGroup/ImgGroup, Processable, ProcessedImg,
%   matlab.mixin.Copyable, handle

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
        %children - A cell array containing the Processable child objects
        %
        %   The children property of ImgGroup is a cell array containing
        %   the Processable child objects.  These child objects can be
        %   either ProcessedImg object arrays or ImgGroup object arrays
        %   (i.e. nested ImgGroups are possible).
        %
        %   See also ImgGroup.nChildren, ImgGroup.add
        children = {};
    end
    
    % ------------------------------------------------------------------ %
    
    properties (Dependent)
        
        %nChildren - The number of children in the object
        %
        %   The nChildren property of ImgGroup is a dependent property that
        %   counts the number of children contained in the ImgGroup object
        %   such that nChildren = numel(ImgGroupObj.children);
        %
        %   See also ImgGroup.children
        nChildren
        
        %state - The object state
        state
        
    end
    
    % ================================================================== %
    
    methods
        
        function ImgGroupObj = ImgGroup(varargin)
        %ImgGroup - ImgGroup class constructor
        %
        %   OBJ = ImgGroup() prompts for any required information and
        %   creates an ImgGroup object.
        %
        %   OBJ = ImgGroup(ARG1, ARG2, ...) prompts for any required
        %   information to create an ImgGroup object, then passes the
        %   arguments ARG1, ARG2, ... to the ImgGroup.add function to add
        %   to the ImgGroup object. See the link below for further
        %   documentation.
        %
        %   ARG1 = ImgGroup(NAME, ...) specifies a name for the ImgGroup
        %   object.  NAME must be a single row character array, or a cell
        %   array containging a single row character array.
        %
        %   Please see the <a href="matlab:web(fullfile(utils.CHIPS_rootdir, 'doc', 'html', 'ig_ImgGroup.html'))">ImgGroup quick start guide</a> for additional
        %   documentation and examples.
        %
        %   See also ImgGroup.add, Processable
            
            % Check the first argument to see if it's the name
            nameIn = '';
            idxStart = 1;
            hasName = nargin > 0 && (ischar(varargin{1}) || ...
                iscell(varargin{1}) || isempty(varargin{1}));
            if hasName
                nameIn = varargin{1};
                if ischar(nameIn)
                    nameIn = {nameIn};
                end
                idxStart = 2;
            end
            
            % Work out the current recursion depth
            isRecursive = utils.is_deeper_than('ImgGroup.ImgGroup');
            
            % Check the name
            isEmptyName = isempty(nameIn);
            if ~isRecursive && isEmptyName
                nameIn = ImgGroup.choose_name();
            end
            
            % Call Processable (i.e. parent class) constructor
            ImgGroupObj = ImgGroupObj@Processable(nameIn);
            
            % Exit here if we're being called recursively
            if isRecursive, return; end
            
            % Pass all other arguments to add
            extraArgs = varargin(idxStart:end);
            nArgs = length(extraArgs);
            if nArgs > 0
                ImgGroupObj.add(extraArgs{:});
            end
            
        end
        
        % -------------------------------------------------------------- %
        
        add(self, varargin)
        
        % -------------------------------------------------------------- %
        
        configOut = get_config(self)
        
        % -------------------------------------------------------------- %
        
        varargout = opt_config(self)
        
        % -------------------------------------------------------------- %
        
        varargout = plot(self, varargin)
        
        % -------------------------------------------------------------- %
        
        self = process(self, useParallel, varargin)
        
        % -------------------------------------------------------------- %
        
        varargout = output_data(self, fnCSV, varargin)
        
        % -------------------------------------------------------------- %
        
        function set.children(self, children)
            
            % Set non-cells to cells automatically
            if ~iscell(children)
                children = {children};
            end
            
            if ~isempty(children)
            
                % Check it's a ProcessedImg
                isAllProcessedImg = all(...
                    cellfun(@(obj) isa(obj, 'Processable'), children));
                if ~isAllProcessedImg
                    error('ImgGroup:Children:NotProcessable', ['All child ' ...
                        'image objects must be subclasses of Processable'])
                end
            
            end
            
            % Add the property
            self.children = children;
            
        end
        
        % -------------------------------------------------------------- %
        
        function nChildren = get.nChildren(self)
            nChildren = numel(self.children);
        end
        
        % -------------------------------------------------------------- %
        
        function state = get.state(self)
            
            % Get the state of the calcs
            for iChild = self.nChildren:-1:1
                states{iChild} = self.children{iChild}.state;
            end
            
            % Work out the state possibilities
            isUnprocessed = all(strcmp('unprocessed', states));
            isProcessed = all(strcmp('processed', states));
            isPartial = all(ismember(states, ...
                {'processed', 'partially processed', 'unprocessed'}));
            
            if isUnprocessed
                state = 'unprocessed';
            elseif isProcessed
                state = 'processed';
            elseif isPartial
                state = 'partially processed';
            else
                state = 'error';
            end
            
        end
        
    end
    
    % ================================================================== %
    
    methods (Hidden)
        
        trajs = calc_trajs(self, varargin)
        
        % -------------------------------------------------------------- %
        
        varargout = plot_average(self, varargin)
        
        % -------------------------------------------------------------- %
        
        varargout = plot_trajs(self, varargin)
        
    end
    
    % ================================================================== %
    
    methods (Access = protected)
        
        function cpObj = copyElement(obj)
        %copyElement - Customised copyElement class method to ensure that
        %   the ImgGroup children (handle objects) are recursively copied.
            
            % Make a shallow copy of the object
            cpObj = copyElement@matlab.mixin.Copyable(obj);
             
            % Make a deep copy of the children
            for iChild = 1:obj.nChildren
                cpObj.children{iChild} = copy(obj.children{iChild});
            end
             
        end
        
    end
    
    % ================================================================== %
    
    methods (Static)
        
        ImgGroupObj = from_files(varargin)
        
    end
    
    % ================================================================== %
    
    methods (Static, Access = protected)
        
        nameOut = choose_name()
        
        % -------------------------------------------------------------- %
        
        hProcessable = create_constructor_processable(varargin)
        
        % -------------------------------------------------------------- %
        
        childrenOut = from_files_sub(rawImgType, configIn, procImgType)
        
        % -------------------------------------------------------------- %
        
        childrenOut = from_rawImgs(rawImgArray, configIn, hProcessable)
        
    end
    
    % ================================================================== %
    
end
