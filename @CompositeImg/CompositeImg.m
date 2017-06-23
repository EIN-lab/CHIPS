classdef CompositeImg < ImgGroup & IRawImg
%CompositeImg - Class to contain groups of images from the same raw image
%
%   The CompositeImg class implements most functionality related to groups
%   of ProcessedImg objects that are derived from the same RawImg object.
%   This allows efficient use of memory, since the same RawImg object does
%   not need to be duplicated to be analysed in different ways.
%
%   Please see the <a href="matlab:web(fullfile(utils.CHIPS_rootdir, 'doc', 'html', 'ig_CompositeImg.html'))">CompositeImg quick start guide</a> for additional
%   documentation and examples.
%
% CompositeImg public properties:
%   children    - A cell array containing the Processable child objects
%   imgTypes    - The unique child object image types
%   masks       - The masks used to create the child object RawImg
%   name        - The object name
%   nChildren   - The number of children in the object
%   rawImg      - A scalar RawImgHelper object
%   state       - The object state
% 
% CompositeImg public methods:
%   CompositeImg - CompositeImg class constructor
%   add         - Add children to the object
%   copy        - Copy MATLAB array of handle objects
%   get_config  - Return the Configs from this object
%   opt_config  - Optimise the parameters in Config objects using a GUI
%   output_data - Output the data
%   plot        - Plot a figure for each child object
%   process     - Process the child objects
%
% CompositeImg static methods:
%   from_files  - Create a CompositeImg object from a list of files
%   reqChannelAll - The rawImg requires all of these channels
%   reqChannelAny - The rawImg requires at least one of these channels
%
% CompositeImg public events:
%   NewRawImg	- Notifies listeners that the rawImg property was set
%
%   See also CompositeImg.CompositeImg, RawImgComposite, Processable,
%   ImgGroup, IRawImg, matlab.mixin.Copyable, handle

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
        
        %imgTypes - The unique child object image types
        %
        %   The imgTypes property of CompositeImg is a dependent property
        %   containing a list of the unique image types (i.e. class) of the
        %   children.  The elements of imgTypes are character arrays
        %   resulting from calling the class function on the chld objects.
        %   imgTypes is a cell array of size [1, m], where m is the number
        %   of unique image types found in the children.
        %
        %   See also CompositeImg.children, class
        imgTypes
        
        %masks - The masks used to create the child object RawImg
        %
        %   The masks property of CompositeImg is a dependent property
        %   containing a list of the masks used to construct the
        %   RawImgComposite objects that are used in the children.  masks
        %   is a cell array of size [1, m], where m is the number of unique
        %   image types found in the children.  Each element of masks is
        %   another cell array of size [1, n(i)], where n(i) is the number
        %   of children of type imgTypes{i}.
        %
        %   See also CompositeImg.children, CompositeImg.imgTypes,
        %   RawImgComposite
        masks
        
    end
    
    % ================================================================== %
    
    properties (Constant, Access = protected)
        
        %colorSpecList - A list of colors used for plot_ref
        colorSpecList = [...
            0, 0, 1; % blue
            0, 1, 0; % green
            1, 1, 0; % yellow
            1, 0, 1; % magenta
            1, 0, 0; % red
            ];
        
    end
    
    % ================================================================== %
    
    methods
        
        function CompositeImgObj = CompositeImg(varargin)
        %CompositeImg - CompositeImg class constructor
        %
        %   OBJ = CompositeImg() prompts for any required information and
        %   creates a CompositeImg object.
        %
        %   OBJ = CompositeImg(NAME, RAWIMG) creates a CompositeImg object
        %   based on the specified NAME and RAWIMG. Either of the arguments
        %   can be replaced by [] to prompt for the required information.
        %
        %   NAME must be a single row character array, and if it is empty
        %   the constructor will prompt to choose a name.
        %   RAWIMG must be a RawImgHelper object and can be of any
        %   dimension, but the resulting CompositeImg object will be size
        %   [1 numel(RAWIMG)]. If RAWIMG is empty, the constructor will
        %   prompt to select/create a new one.
        %
        %   If RAWIMG is not scalar, the values for the other arguments are
        %   assumed to apply to all elements of RAWIMG.  This is true
        %   whether the arguments are specified explicitly, or implicitly
        %   (i.e. via interactive prompt).  To choose or specify individual
        %   values for the other arguments, either create the CompositeImg
        %   objects individually and combine into an array, or use the
        %   ImgGroup class.
        %
        %   OBJ = CompositeImg(NAME, RAWIMG, ARG1, ARG2, ...) prompts for
        %   any required information to create a CompositeImg object, then
        %   passes the arguments ARG1, ARG2, ... to the CompositeImg.add
        %   function to add to the CompositeImg object. See the link below
        %   for further documentation.
        %
        %   Please see the <a href="matlab:web(fullfile(utils.CHIPS_rootdir, 'doc', 'html', 'ig_CompositeImg.html'))">CompositeImg quick start guide</a> for additional
        %   documentation and examples.
        %
        %   See also CompositeImg.add, ImgGroup, Processable
            
            % Parse arguments
            wngState = warning('off', 'ParseOptArgs:TooManyInputs');
            [nameIn, rawImgIn] = utils.parse_opt_args({'', []}, varargin);
            warning(wngState)
            
            % Work out the current recursion depth
            isRecursive = utils.is_deeper_than(...
                'CompositeImg.CompositeImg');
            
            % Choose rawImg
            if ~isRecursive && isempty(rawImgIn)
                rawImgIn = RawImg.from_files();
            end
            
            % Use the name from the RawImg if no name is specified
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
            
            % Call ImgGroup (i.e. parent class) constructor
            CompositeImgObj = CompositeImgObj@ImgGroup(nameIn);
            
            % Attach a listener to update the properties when a new rawImg
            % is added to this object
            addlistener(CompositeImgObj, 'NewRawImg', @IRawImg.new_rawImg);
            
            % Assign the rawImg obj
            nImgs = length(rawImgIn);
            for iRawImg = nImgs:-1:1
                if ~isempty(nameIn{iRawImg})
                    CompositeImgObj(iRawImg).rawImg = rawImgIn(iRawImg);
                end
            end 
            
            % Exit here if we're being called recursively
            if isRecursive, return; end
            
            % Add stuff, if we've supplied enough arguments
            if nargin > 2
                CompositeImgObj.add(varargin{3:end});
            end
            
        end
        
        % -------------------------------------------------------------- %
        
        add(self, varargin)
        
        % -------------------------------------------------------------- %
        
        function imgTypes = get.imgTypes(self)
            
            imgTypesAll = cell(1, self.nChildren);
            for iChild = 1:self.nChildren
                imgTypesAll{iChild} = class(self.children{iChild});
            end
            imgTypes = unique(imgTypesAll);
            
        end
        
        % -------------------------------------------------------------- %
        
        function masks = get.masks(self)
            
            typesList = self.imgTypes;
            nTypes = length(typesList);
            masks = cell(1, nTypes);
            
            for iType = 1:nTypes
                
                masks{1, iType} = {};
                kImg = 1;
                
                for jChild = 1:self.nChildren
                
                    isCorrectClass = isa(self.children{jChild}, ...
                        typesList{iType});
                    if isCorrectClass
                        
                        masks{1, iType}{kImg} = ...
                            self.children{jChild}.rawImg.mask;
                        kImg = kImg + 1;
                        
                    end
                    
                end
                
            end
            
        end
        
    end
    
    % ================================================================== %
    
    methods (Hidden)
        
        varargout = plot_average(self, varargin)
                
        % -------------------------------------------------------------- %
        
        plot_ref(self)
        
    end
    
    % ================================================================== %
    
    methods (Access = protected)
        
        mask = choose_mask(self, imgType, varargin)
        
        % -------------------------------------------------------------- %
        
        mask = choose_mask_columns(self, strBoundary)
        mask = choose_mask_rows(self, strBoundary)
        
        % -------------------------------------------------------------- %
        
        mask = choose_mask_imroi(self, imgType, roiFun, roiType)
        
        mask = choose_mask_rectangle(self, imgType)
        mask = choose_mask_square(self, imgType)
        mask = choose_mask_polygon(self, imgType)
        mask = choose_mask_ellipse(self, imgType)
        mask = choose_mask_circle(self, imgType)
        mask = choose_mask_freehand(self, imgType)
        
        % -------------------------------------------------------------- %
        
        mask = choose_mask_altLines(self, isEven)
        
        % -------------------------------------------------------------- %
        
        mask = choose_mask_channels(self, imgType, varargin)
        
        % -------------------------------------------------------------- %
        
        masks = choose_masks(self, imgTypes)
        
        % -------------------------------------------------------------- %
        
        cpObj = copyElement(obj)
        
        % -------------------------------------------------------------- %
        
        children = create_children(self, imgTypes, masksIn, configIn)
        
        % -------------------------------------------------------------- %
        
        varargout = plot_ref_helper(self, imgChannel)
        
        % -------------------------------------------------------------- %
        
        varargout = plot_imgData(self, imgChannel, strFigTitle)
        
        % -------------------------------------------------------------- %
        
        update_rawImg_props(self)
        
    end
    
    % ================================================================== %
    
    methods (Static)
        
        CompositeImgObj = from_files(varargin)
        
        % -------------------------------------------------------------- %
        
        function chList = reqChannelAll()
        %reqChannelAll - The rawImg requires all of these channels
            chList = {};
        end
        
        % -------------------------------------------------------------- %
        
        function chList = reqChannelAny()
        %reqChannelAny - The rawImg requires at least one of these channels
            chList = {};
        end
        
    end
    
    % ================================================================== %
    
    methods (Static, Access = protected)
        
        imgTypes = choose_imgtypes(varargin)
        
        % -------------------------------------------------------------- %
        
        function objOut = loadobj(structIn)
        %loadobj - Overload the loadobj method for CompositeImg objects
            
            % Create the basic object, which also attaches the listener
            objOut = CompositeImg(structIn.name_sub, structIn.rawImg);
            
            % Update the children.  We do it here because CompositeImg/add
            % does not currently accept ProcessedImg arguments
            objOut.children = structIn.children;
            
            % Update the remaining properties
            if ~isempty(structIn.refImg)
                objOut.refImg = structIn.refImg;
            end
            
        end
        
    end
    
    % ================================================================== %
    
end

