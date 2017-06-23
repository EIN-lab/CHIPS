classdef (Abstract) ProcessedImg < Processable & IRawImg
%ProcessedImg - Superclass for processed image classes
%
%   The ProcessedImg class is an abstract superclass that implements (or
%   requires implementation in its subclasses via abstract methods or
%   properties) most functionality related to processable image objects.
%
%   ProcessedImg is a subclass of matlab.mixin.Copyable, which is itself a
%   subclass of handle, meaning that ProcessedImg objects are actually
%   references to the data contained in the object.  This ensures memory is
%   used efficiently when ProcessedImg objects are contained in other
%   objects (e.g. ImgGroup objects). However, ProcessedImg objects can use
%   the copy method of matlab.mixin.Copyable to create new, independent
%   objects.
%
% ProcessedImg public properties:
%   name        - The object name
%   plotList    - The list of plot options for each Calc
%   rawImg      - A scalar RawImgHelper object
%   state       - The object state 
% 
% ProcessedImg public methods:
%   ProcessedImg - ProcessedImg abstract class constructor
%   copy        - Copy MATLAB array of handle objects
%   get_config  - Return the Config from this ProcessedImg object
%   opt_config  - Optimise the parameters in Config objects using a GUI
%   output_data	- Output the data
%   plot        - Plot a figure
%   process     - Process the elements of the ProcessedImg object
%
% ProcessedImg static methods:
%   reqChannelAll - The rawImg requires all of these channels
%   reqChannelAny - The rawImg requires at least one of these channels
%
% ProcessedImg public events:
%   NewRawImg	- Notifies listeners that the rawImg property was set
%
%   See also Processable, IRawImg, matlab.mixin.Copyable, handle,
%   RawImgHelper, Calc, Config, Data

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
        
        %state - The object state
        state
        
    end
    
    % ------------------------------------------------------------------ %
    
    properties (Dependent, Access=protected)
        
        %calcList - A list of Calc objects
        calcList
        
        %isComposite - Dependent, protected property referencing if the
        %   rawImg property contains a RawImgComposite object.
        isComposite
        
        %validPlotNames - A list of valid plotNames for plot(obj)
        validPlotNames
        
    end
    
    % ------------------------------------------------------------------ %
    
    properties (Abstract, Constant)
        
        %plotList - The list of plot options for each Calc
        plotList
        
    end

   
    % ================================================================== %
    
    methods
        
        function ProcessedImgObj = ProcessedImg(varargin)
        %ProcessedImg - ProcessedImg abstract class constructor
        %
        %   OBJ = ProcessedImg() prompts for all required information
        %   and creates a ProcessedImg object.
        %
        %   OBJ = ProcessedImg(NAME, RAWIMG) creates a ProcessedImg object
        %   based on the specified NAME and RAWIMG.  NAME must be a single
        %   row character array, and if it is empty the constructor will
        %   prompt to choose a name.  RAWIMG must be a RawImgHelper object
        %   and can be of any dimension, but the resulting ProcessedImg
        %   object will be size [1 numel(RAWIMG)]. If RAWIMG is empty,
        %   the constructor will prompt to select/create a new one.
        %
        %   See also RawImg, RawImgHelper, IRawImg, Processable,
        %   matlab.mixin.Copyable, handle
        
            % Parse arguments
            [nameIn, rawImgIn] = utils.parse_opt_args({'', []}, varargin);
            
            % Work out the current recursion depth
            doChooseFile = ~utils.is_deeper_than(...
                'ProcessedImg.ProcessedImg');
            
            % Call Processable (i.e. parent class) constructor
            ProcessedImgObj = ProcessedImgObj@Processable({''});
            
            % Choose rawImg, specifying a subset of channels to choose
            if doChooseFile && isempty(rawImgIn)
                rawImgType = '';
                fnIn = [];
                chOpts = [ProcessedImgObj.reqChannelAll, ...
                    ProcessedImgObj.reqChannelAny];
                rawImgIn = RawImg.from_files(rawImgType, fnIn, chOpts);
            end
            
            % Select the name, using some information from the RawImg
            if isempty(nameIn)
                nameIn = Processable.choose_name(rawImgIn);
            else
                
                % Put the name inside the cell for convenience later
                if ~iscell(nameIn)
                    nameIn = {nameIn};
                end
                
                % Repeat the name if it's scalar
                if isscalar(nameIn)
                    nameIn = repmat(nameIn, size(rawImgIn));
                end
                
            end
            
            % Check that the plotList
            ProcessedImgObj.check_plotList();
            
            % Attach a listener to update the properties when a new rawImg
            % is added to this object
            addlistener(ProcessedImgObj, 'NewRawImg', @IRawImg.new_rawImg);
            
            % Set the rawImg obj and name
            nImgs = numel(rawImgIn);
            for iRawImg = nImgs:-1:1
                if ~isempty(nameIn{iRawImg})
                    ProcessedImgObj(iRawImg).name = nameIn{iRawImg};
                    ProcessedImgObj(iRawImg).rawImg = rawImgIn(iRawImg);
                end
            end
            
        end
        
        % -------------------------------------------------------------- %
        
        varargout = process(self, useParallel, varargin)
        
        % -------------------------------------------------------------- %
        
        varargout = opt_config(self)
        
        % -------------------------------------------------------------- %
        
        varargout = output_data(self, fnCSV, varargin)
        
        % -------------------------------------------------------------- %
        
        function calcList = get.calcList(self)
        
            mco = metaclass(self);
            plist = mco.PropertyList;
            
            for iProp = numel(plist):-1:1
                
                isCalc(iProp) = ~plist(iProp).Dependent && ...
                    strcmp(plist(iProp).GetAccess, 'public') && ...
                    isa(self(1).(plist(iProp).Name), 'Calc');

            end
            
            calcList = {plist(isCalc).Name};
            
        end
        
        % -------------------------------------------------------------- %
        
        function isComposite = get.isComposite(self)
            if ~isempty(self.rawImg)
                isComposite = isa(self.rawImg, 'RawImgComposite');
            else
                isComposite = NaN;
            end
        end
        
        % -------------------------------------------------------------- %
        
        function state = get.state(self)
            
            % Get a list of the calcs for this object
            calcList0 = self.calcList;
            nCalcs = numel(calcList0);
            
            % Get the state of the calcs
            for iCalc = nCalcs:-1:1
                states{iCalc} = self.(calcList0{iCalc}).data.state;
            end
            
            % Work out the state possibilities
            isUnprocessed = all(strcmp('unprocessed', states));
            isProcessed = all(strcmp('processed', states));
            isPartial = all(ismember(states, {'processed', 'unprocessed'}));
            
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
        
        % -------------------------------------------------------------- %
        
        function validPlotNames = get.validPlotNames(self)
            
            fields = fieldnames(self.plotList);
            for iField = numel(fields):-1:1
                iFieldName = fields{iField};
                validPlotNames{iField} = self.plotList.(iFieldName);
            end
            validPlotNames = [validPlotNames{:}];
            
        end
        
    end
    
    % ================================================================== %
        
    methods (Hidden)
        
        varargout = plot_average(self, varargin)
        
        % -------------------------------------------------------------- %
        
        varargout = plot_trajs(self, varargin)
        
        % -------------------------------------------------------------- %
        
        function trajs = calc_trajs(self)
            
            % Call the function one by one if we have an array
            if ~isscalar(self)
                trajs = arrayfun(@calc_trajs, self);
                return
            end

            trajs = {ITraj.calc_traj(self.refImg, self.rawImg)};

        end
        
    end
    
    % ================================================================== %
    
    methods (Abstract)
        
        %get_config - Return the Config from this ProcessedImg object
        get_config(self)
        
    end

    % ================================================================== %
    
    methods (Access = protected)
        
        [hFig, plotName, idxStart] = check_plot_args(self, args)
        
        % -------------------------------------------------------------- %
        
        function cpObj = copyElement(obj)
        %copyElement - Customised copyElement class method to ensure that
        %   the rawImg property (a handle object) is recursively copied.
            
            % Make a preliminary copy of the object, including the 
            cpObj = copyElement@IRawImg(obj);
             
            % Make a deep copy of the Calc objects
            calcList0 = obj.calcList;
            for iCalc = 1:numel(calcList0)
                iCalcName = calcList0{iCalc};
                cpObj.(iCalcName) = copy(obj.(iCalcName));
            end
            
        end
        
        % -------------------------------------------------------------- %
        
        function check_state_plot(self)
            
            % Check if the CellScan has already been processed
            isProcessed = any(strcmp(self.state, ...
                {'processed', 'partially processed'}));
            if ~isProcessed
                error('ProcessedImg:NotProcessed', ['The object must ' ...
                    'be processed or partially processed before ' ...
                    'plotting. The current state is: "%s".'], self.state)
            end
            
        end
        
        % -------------------------------------------------------------- %
        
        check_plotList(self)
        
        % -------------------------------------------------------------- %
        
        channelToUse = choose_channel(self)
        
        % -------------------------------------------------------------- %
        
        function update_rawImg_props(self)
        %update_rawImg_props - Class method to ensure that all appropriate
        %   properties are updated when the rawImg property changes (e.g.
        %   when constructing an ImgGroup).
            
            % Call the function one by one if we have an array
            if ~isscalar(self)
                arrayfun(@update_rawImg_props, self);
                return
            end
            
            self.update_name()
            
        end
            
    end
    
    % ================================================================== %
    
    methods (Abstract, Access=protected)
        
        %process_sub - Abstract, protected class method to process an
        %   individual element of a ProcessedImg object array.
        process_sub(self, varargin)
        
    end
    
    % ================================================================== %
    
    methods (Static, Access = protected)
        
        function process_now(~, eventData)
        %process_now - Static method to process Calc objects as requested
        %   by the user via the Config.opt_config GUI.
        
            % Process the appropriate calc object
            eventData.objPI = eventData.objPI.process([], ...
                eventData.calcName);
            
        end
        
    end
    
    % ================================================================== %
    
end
