classdef RawImgComposite < RawImgHelper & IRawImg
%RawImgComposite - Class implementing 'composite' raw images
%
%   The RawImgComposite class implements functionality related to
%   'composite' RawImg objects. RawImgComposite objects reference a subset
%   of a 'normal' RawImg object, as opposed to 'normal' RawImg objects that
%   correspond directly to a single image.  This means that minimal
%   additional memory is needed even when processing multiple (possibly
%   overlapping) subsets of the same RawImg object.
%
% RawImgComposite public properties:
%   mask        - The mask defining which part of the rawImg to use
%   metadata    - The image metadata
%   name        - The object name
%   rawdata     - The raw image data
%   rawImg      - A scalar RawImgHelper object
%   t0          - The image time that should be treated as t=0 [s]
% 
% RawImgComposite public methods:
%   RawImgComposite - RawImgComposite class constructor
%   check_ch    - Check that the appropriate channels are present
%   copy        - Copy MATLAB array of handle objects
%   get_ch_name - Get channel names from channel numbers
%   has_ch      - Determine if particular channels are present
%   to_long     - Convert the images to long format
%
% RawImgComposite static methods:
%   reqChannelAll - The rawImg requires all of these channels
%   reqChannelAny - The rawImg requires at least one of these channels
%
% RawImgComposite public events:
%   NewRawImg	- Notifies listeners that the rawImg property was set
%
%   See also RawImgHelper, IRawImg, RawImg, RawImgDummy, Metadata,
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
        
        %mask - The mask defining which part of the rawImg to use
        %
        %   The mask property of RawImgComposite contains a binary mask
        %   which is used to extract the relevent subset of the rawdata
        %   from the original RawImg.  The mask must be convertible to a
        %   logical array. The mask can be either 2 or 3 dimensional, but
        %   in both cases must be the same size as the corresponding
        %   dimensions in the RawImg. (Note: the 3rd dimension represents
        %   the image channel, not the image frame.) If the mask is empty,
        %   the RawImgComposite is not masked, and is basically the same
        %   as the original RawImg object.
        %
        %   See also RawImgComposite.rawImg, RawImgComposite.rawdata
        mask
        
    end
    
    % ------------------------------------------------------------------ %
    
    properties (Dependent)
        
        %name - The object name
        %
        %   The name property of RawImgComposite is a dependent property
        %   that references the raw image name. The name is automatically
        %   extracted from the original RawImg.
        %
        %   See also RawImg.name, RawImgComposite.rawImg
        name
        
        %rawdata - The raw image data
        %
        %   The rawdata property of RawImgComposite is a dependent
        %   property that references the raw image data.  The data is
        %   automatically extracted from the original RawImg using the
        %   RawImgComposite mask.
        %
        %   See also RawImg.rawdata, RawImgComposite.mask,
        %   RawImgComposite.rawImg
        rawdata
        
        %t0 - The image time that should be treated as t=0 [s]]
        %
        %   The t0 property of RawImgComposite is a dependent property
        %   that references the raw image t0. The t0 is automatically
        %   extracted from the original RawImg.
        %
        %   See also RawImg.t0
        t0
        
    end
    
    % ------------------------------------------------------------------ %
    
    properties (Dependent, Access = protected)
        
        %rawdata_recursive - Protected property used to avoid some annoying
        %   recursion errors.
        rawdata_recursive
        
        %name_recursive - Protected property used to avoid some annoying
        %   recursion errors.
        name_recursive
        
        %t0_recursive - Protected property used to avoid some annoying
        %   recursion errors.
        t0_recursive
        
    end
    
    % ================================================================== %
  
    methods
        
        function RawImgCompositeObj = RawImgComposite(varargin)
        %RawImgComposite - RawImgComposite class constructor
        %
        %   OBJ = RawImgComposite() prompts for all required information
        %   and creates a RawImgComposite object.
        %
        %   OBJ = RawImgComposite(RAWIMG, MASK) creates a RawImgComposite
        %   object based on the specified RawImg and mask.  RAWIMG must be
        %   a scalar RawImgHelper object, and MASK must be convertible to a
        %   logical array and of a size to match the rawdata of rawImg.  If
        %   RAWIMG is empty, the constructor will prompt to select/create a
        %   new one; if MASK is empty, RAWIMG is left unchanged.
        %
        %   See also RawImg, RawImgHelper, IRawImg, matlab.mixin.Copyable,
        %   handle, RawImgComposite.rawImg, RawImgComposite.mask
            
            % Parse optional arguments
            [rawImgIn, maskIn] = utils.parse_opt_args({[], []}, varargin);
            
            % Assign the RawImg
            if isempty(rawImgIn)
                RawImgCompositeObj.rawImg = RawImg.from_files();
            else
                RawImgCompositeObj.rawImg = rawImgIn;
            end
            
            % Attach a listener to update any other RawImgComposite
            % objects that share the same RawImg
            addlistener(RawImgCompositeObj.rawImg, 'ToLong', ...
                @(src, evt) RawImgCompositeObj.to_long_mask(src, evt));
            
            % Assign the mask
            if ~isempty(maskIn)
                RawImgCompositeObj.mask = maskIn;
            end
            
            % Assign the metadata
            RawImgCompositeObj.assign_metadata();
            
        end
        
        % -------------------------------------------------------------- %
        
        function to_long(self)
        %to_long - Convert the images to long format
        %
        %   to_long(OBJ) converts the rawdata of the RawImgComposite
        %   object to long format.  That is, the image lines are rearranged
        %   into a single, long image frame.  This is useful when working
        %   with image types that are line-based instead of frame-based
        %   (e.g. line scans).
        %
        %   See also utils.reshape_to_long, RawImg.to_long, RawImg.ToLong.
            
            % Reshape the image to long (i.e. making it one long image)
            self.rawImg.to_long();
            
        end
        
        % -------------------------------------------------------------- %
        
        function name = get.name(self)
            name = self.name_recursive;
        end
        
        % -------------------------------------------------------------- %
        
        function name_recursive = get.name_recursive(self)
            if ~isempty(self.rawImg)
                name_recursive = [self.rawImg.name '-composite'];
            else
                name_recursive = [];
            end
        end
        
        % -------------------------------------------------------------- %
        
        function rawdata = get.rawdata(self)
            rawdata = self.rawdata_recursive;
        end
        
        % -------------------------------------------------------------- %
        
        function rawdata_recursive = get.rawdata_recursive(self)
            
            % This is the default rawdata
            rawdata_recursive = [];
            
            % Get the raw rawdata from the rawImg, if we have one
            hasRawImg = ~isempty(self.rawImg);
            if hasRawImg
                rawdata_recursive = self.rawImg.rawdata;
            end
            
            hasMask =  ~isempty(self.mask);
            if hasMask
                
                % Remove any masked channels from the data
                maskTemp = self.mask;
                if ~ismatrix(self.mask)
                    chToCut = ~any(reshape(maskTemp, ...
                        [], 1, size(maskTemp, 3)), 1);
                    maskTemp(:,:,chToCut) = [];
                    rawdata_recursive(:, :, chToCut, :) = [];
                end
                
                % Remove any masked rows and columns from the data
                rawdata_recursive(~any(maskTemp, 2), :, :, :) = []; % rows
                rawdata_recursive(:, ~any(maskTemp, 1), :, :) = []; % columns
                
            end
            
        end
        
        % -------------------------------------------------------------- %
        
        function t0 = get.t0(self)
            t0 = self.t0_recursive;
        end
        
        % -------------------------------------------------------------- %
        
        function t0_recursive = get.t0_recursive(self)
            if ~isempty(self.rawImg)
                t0_recursive = self.rawImg.t0;
            else
                t0_recursive = [];
            end
        end
        
        % -------------------------------------------------------------- %
        
        function set.mask(self, mask)
            
            % Find out if we're setting this value for the first time, or
            % if we're changing it
            wasEmpty = isempty(self.mask);
            
            % Check that the mask is logical
            utils.checks.logical_able(mask);
            
            % Check that the mask is the correct dimensions
            maskDims = ndims(mask);
            doCheckDims = ~isempty(self.rawImg) && ...
                ~isempty(self.rawImg.rawdata);
            if doCheckDims
                if maskDims <= 2
                    utils.checks.same_size(mask, ...
                        self.rawImg.rawdata(:,:, 1, 1));
                else
                    utils.checks.same_size(mask, ...
                        self.rawImg.rawdata(:,:, :, 1));
                end
            end
            
            % Check the mask is neither empty, a scalar, or a vector
            maskTemp = mask;
            if maskDims > 2
                chToCut = ~any(reshape(mask, [], 1, size(mask, 3)), 1);
                maskTemp(:,:,chToCut) = [];
            end
            maskTemp( ~any(maskTemp, 2), :) = [];  %rows
            maskTemp( :, ~any(maskTemp, 1)) = [];  %columns
            isBadDims = isempty(maskTemp) || isscalar(maskTemp) || ...
                isvector(maskTemp);
            if isBadDims
                strSize = sprintf('%d ', size(maskTemp));
                error('RawImgComposite:NonArrayMask', ['The mask must ' ...
                    'contain an image array or stack, and you have ' ...
                    'provided one of size: [%s].'], strSize(1:end-1))
            end
            
            % Assign the mask
            self.mask = mask;
            
            % Assign the metadata, in case it's changed now
            if ~wasEmpty
                self.assign_metadata();
            end
            
        end
        
    end
    
    % ================================================================== %
    
    methods (Access = protected)
        
        function cpObj = copyElement(obj)
        %copyElement - Customised copyElement class method to ensure that
        %   the additional listener is added.
            
            % Make a copy of the object using the superclass method
            cpObj = copyElement@IRawImg(obj);
             
            % Attach a listener to update any other RawImgComposite
            % objects that share the same RawImg
            addlistener(obj.rawImg, 'ToLong', ...
                @(src, evt) obj.to_long_mask(src, evt));
             
        end
        
        % -------------------------------------------------------------- %
        
        function to_long_mask(self, varargin)
            
            % Parse optional arguments
            [~, ~] = utils.parse_opt_args({[], []}, varargin);
            
            % Update the mask
            nReps = size(self.rawImg.rawdata, 1)/size(self.mask, 1);
            self.mask = repmat(self.mask, [nReps, 1]);
            
        end
        
        % -------------------------------------------------------------- %
        
        function update_rawImg_props(self)
        %update_rawImg_props - Class method to ensure that all appropriate
        %   properties are updated when the rawImg property changes (e.g.
        %   when constructing an ImgGroup). In this case, we only need to
        %   update the metadata
            
            % Update the metadata
            self.assign_metadata()
            
        end
        
        % -------------------------------------------------------------- %
        
        function assign_metadata(self)
        %assign_metadata - Class method to update the metadata when the 
        %   rawImg property changes.
            
            % Extract the original metadata from the RawImg
            hasRawImg = ~isempty(self.rawImg) && ...
                ~isempty(self.rawImg.metadata);
            if ~hasRawImg
                return
            end
            
            % Extract the relevant original properties from the metadata
            acqIn = self.rawImg.metadata.get_acq();
            calibrationIn = self.rawImg.metadata.calibration;
            
            % Ensure the sizes match the newly masked RawImg
            imgSize = size(self.rawdata);
            
            % Ensure the channels match
            channelsIn = self.rawImg.metadata.channels;
            if ismatrix(self.mask)

                channelsOut = channelsIn;

            else
                
                % Find out which channels we're keeping
                chKeep = find(all(reshape(self.mask, ...
                    [], 1, size(self.mask, 3)), 1));
                
                % Find out which channels we have, and sort them
                chNamesAvail = fieldnames(channelsIn);
                cc = struct2cell(channelsIn);
                chNumsAvail = [cc{:}];
                [~, idxSort] = sort(chNumsAvail);
                chNamesAvail = chNamesAvail(idxSort);
                nChAvail = length(chNamesAvail);
                
                % Eliminate those channels we're not keeping
                chAdj = 1;
                for iCh = 1:nChAvail
                    if ismember(iCh, chKeep)
                        channelsOut.(chNamesAvail{iCh}) = chAdj;
                        chAdj = chAdj + 1;
                    end
                end
                
            end
            
            % Turn off unneeded warnings for now
            [lastMsgPre, lastIDPre] = lastwarn();
            wngIDOff = 'Metadata:SetSizes:NonSquare';
            wngState = warning('off', wngIDOff);
                
            % Create and assign the new metadata
            self.metadata = Metadata(imgSize, acqIn, ...
                channelsOut, calibrationIn);
            
            % Restore the warnings
            warning(wngState)
            utils.clear_unwanted_wngs(wngIDOff, lastMsgPre, lastIDPre)
            
        end
        
    end
    
    % ================================================================== %
    
    methods (Static)
        
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
        
        function objOut = loadobj(structIn)
        %loadobj - Overload the loadobj method for RawImgComposite objects
            
            % Create the basic object, which also attaches the listener
            objOut = RawImgComposite(structIn.rawImg, structIn.mask);
            
            % Update the remaining properties
            if ~isempty(structIn.refImg)
                objOut.refImg = structIn.refImg;
            end
            
        end
        
    end
    
    % ================================================================== %
    
end

