classdef (Abstract) RawImg < RawImgHelper
%RawImg - Superclass for all 'normal' raw image classes
%
%   The RawImg class is an abstract superclass that implements (or requires
%   implementation in its subclasses via abstract methods or properties)
%   most functionality related to 'normal' RawImg objects. 'Normal' RawImg
%   objects are those that correspond directly to a single image, as
%   opposed to RawImgComposite objects, which instead reference a subset of
%   a 'normal' RawImg object.
%
%   RawImg is a subclass of matlab.mixin.Copyable, which is itself a subset
%   of handle, meaning that RawImg objects are actually references to the
%   data contained in the object.  This ensures memory is used efficiently
%   when RawImg objects are contained in other objects (e.g. ProcessedImg
%   objects). However, RawImg objects can use the copy method of
%   matlab.mixin.Copyable to create new, independent objects.
%
% RawImg public properties:
%   filename        - The original image filename
%   isDenoised      - Has the image been denoised?
%   isMotionCorrected - Has the image been motion corrected?
%   metadata        - The image metadata
%   metadata_original - The image metadata in its original format
%   name            - The object name
%   rawdata         - The raw image data
%   t0              - The image time that should be treated as t=0 [s]
% 
% RawImg public methods:
%   RawImg          - RawImg class constructor
%   ch_calc         - Perform mathematical calculations on image channels
%   ch_calc_ratio   - Calculate the ratio of two image channels
%   ch_calc_sum2    - Calculate the sum of two image channels
%   check_ch        - Check that the appropriate channels are present
%   copy            - Copy MATLAB array of handle objects
%   denoise         - Denoise the images
%   downsample      - Downsample the images in space and/or time
%   exclude_frames  - Excludes the specified frame(s) from the image
%   get_ch_name     - Get channel names from channel numbers
%   get_mc          - Get the motion correction information
%   has_ch          - Determine if particular channels are present
%   motion_correct  - Motion correct the images
%   plot            - Plot a figure
%   split1          - Split the image data along a given dimension
%   to_long         - Convert the images to long format
%   unmix_chs       - Unmix image channels
%
% RawImg static methods:
%   cat_data        - Concatenate the data from RawImg objects
%   from_files      - Create a RawImg object from a list of files
%
% RawImg public events:
%   ToLong          - Notifies listeners that the to_long method was called
%
%   See also RawImgHelper, RawImgDummy, BioFormats, RawImgComposite,
%   Metadata, matlab.mixin.Copyable, handle, IRawImg

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
    
    properties (SetAccess = protected)
        
        %filename - The original image filename
        %
        %   See also RawImg.name
        filename
        
        %isDenoised - Has the image been denoised?
        %
        %   See also RawImg.denoise
        isDenoised = false;
        
        %isMotionCorrected - Has the image been motion corrected?
        %
        %   See also RawImg.motion_correct
        isMotionCorrected = false;
        
        %metadata_original - The image metadata in its original format
        %
        %   See also RawImg.metadata
        metadata_original
        
    end
    
    % ------------------------------------------------------------------ %
    
    properties (Dependent)
        
        %name - The object name
        %
        %   The name property of RawImg is a dependent property that
        %   references the raw image name. The name is automatically
        %   extracted from the original image filename.
        %
        %   See also RawImg.filename
        name
        
        %rawdata - The raw image data
        rawdata
        
        %t0 - The image time that should be treated as t=0 [s]
        %
        %   A scalar number corresponding to the time after the image that
        %   should be treated as 0.  This is useful, for example, to set 
        %   the time at which a stimulation occurs to equal 0. 
        %   [default = 0s]
        t0
                
    end
    
    % ------------------------------------------------------------------ %
    
    properties (Access = protected)
        
        % Motion correction properties
        mcCh = [];
        mcRefImg = [];
        mcShiftX = [];
        mcShiftY = [];
        
        % Denoising properties
        dChs = [];
        
        %rawdata_actual - Protected property containing the actual raw
        %   data, since RawImgHelper.rawdata is a dependent property
        rawdata_actual
        
        t0_actual = 0;
        
    end
    
    % ------------------------------------------------------------------ %

    properties (Abstract, Dependent, Access = protected)
        
        %fileFilterSpec - Abstract, protected, constant property to specify
        %   a filter for the RawImg file selection dialogue box
        fileFilterSpec
        
    end
    
    % ------------------------------------------------------------------ %
    
    properties (Constant, Access=protected)
        validPlotNames = {'default', 'motion'};
    end
    
    % ================================================================== %
    
    events
        
        %ToLong - Notifies listeners that the to_long method was called
        ToLong
        
	end
    
    % ================================================================== %
    
    methods
        
        function RawImgObj = RawImg(varargin)
        %RawImg - RawImg class constructor
        %
        %   OBJ = RawImg() prompts for all required information and creates
        %   a RawImg object.
        %
        %   OBJ = RawImg(FILENAME) creates a RawImg object from the file(s)
        %   specified by FILENAME. FILENAME must be a single row character
        %   array, or a cell array containing only single row character
        %   arrays. If FILENAME is empty, the constructor will prompt to
        %   select one or more files.
        %
        %   OBJ = RawImg(..., DOCHOOSEFILE) explicitly specifies whether to
        %   prompt the user to choose a file. This is primarily used to do
        %   some magic with constructing object arrays, and should not be
        %   needed/used under normal circumstances. DOCHOOSEFILE must be a
        %   scalar value convertible to logical.
        %
        %   See also RawImgHelper, RawImgComposite, matlab.mixin.Copyable,
        %   handle, IRawImg
            
            % Parse optional arguments
            [filenameIn, doChooseFile] = utils.parse_opt_args(...
                {'', false}, varargin);
            
            % Check the filename
            isEmptyFN = isempty(filenameIn);
            if doChooseFile && isEmptyFN
                filenameIn = RawImgObj.choose_file();
            end
            
            % Put the filename inside a cell
            if ~iscell(filenameIn)
                filenameIn = {filenameIn};
            end
            
            % Loop through all the filenames
            nFiles = length(filenameIn);
            for iRawImg = nFiles:-1:1
                if ~isempty(filenameIn{iRawImg})
                    
                    % Check the filename is a char array?
                    utils.checks.single_row_char(filenameIn{iRawImg}, ...
                        'filename');
                    
                    % Set the filename.  See next line
                    RawImgObj(iRawImg).filename = filenameIn{iRawImg};
                    
                    % Check that file exists. We have to do this after
                    % setting the filename because otherwise we can't call
                    % the class method
                    RawImgObj(iRawImg).check_filename(filenameIn{iRawImg})
                    
                end
            end
            
        end
        
        % -------------------------------------------------------------- %
        
        ch_calc(self, ff, chNums, varargin)
        
        % -------------------------------------------------------------- %

        ch_calc_ratio(self, chNums, varargin)

        % -------------------------------------------------------------- %

        ch_calc_sum2(self, chNums, varargin)
        
        % -------------------------------------------------------------- %
        
        varargout = denoise(self, varargin)
        
        % -------------------------------------------------------------- %
        
        varargout = downsample(self, dsamp, varargin)
        
        % -------------------------------------------------------------- %
        
        varargout = exclude_frames(self, badFrames, varargin)
        
        % -------------------------------------------------------------- %

        mc = get_mc(self)

        % -------------------------------------------------------------- %
        
        varargout = motion_correct(self, varargin)
        
        % -------------------------------------------------------------- %
        
        varargout = plot(self, varargin)
        
        % -------------------------------------------------------------- %
        
        varargout = split1(self, dim, dimDist)
        
        % -------------------------------------------------------------- %
        
        to_long(self)
        
        % -------------------------------------------------------------- %
        
        varargout = unmix_chs(self, useParallel, varargin)
        
        % -------------------------------------------------------------- %
        
        function name = get.name(self)
            name = [];
            if ~isempty(self.filename)
                [~, name] = fileparts(self.filename);
            end
        end
        
        % -------------------------------------------------------------- %
        
        function rawdata = get.rawdata(self)
            rawdata = self.rawdata_actual;
        end
        
        % -------------------------------------------------------------- %
        
        function t0 = get.t0(self)
            t0 = self.t0_actual;
        end
        
        % -------------------------------------------------------------- %
        
        function set.filename(self, filename)
            
            % Most of the checks are done outside the set method because
            % this makes it easier to avoid checking the filename when
            % loading the RawImg object.
            
            % Assign filename
            self.filename = filename;
            
        end
        
        % -------------------------------------------------------------- %
        
        function set.rawdata(self, rawdata)
            
            % Check rawdata is numeric
            utils.checks.object_class(rawdata, 'numeric', 'rawdata');
            
            % Check the rawdata has the correct number of dimensions
            utils.checks.num_dims(rawdata, [3, 4], 'rawdata');
            
            % Assign the actual rawdata.  This is not assigned directly to
            % the rawdata property, because it is dependent (and must be 
            % so that we can do magic with the RawImgComposite class).
            self.rawdata_actual = rawdata;
            
        end
                
        % -------------------------------------------------------------- %
        
        function set.t0(self, val)
            self.t0_actual = val;
        end
        
        % -------------------------------------------------------------- %
        
        function set.t0_actual(self, val)
            utils.checks.real_num(val, 't0')
            utils.checks.finite(val, 't0')
            utils.checks.scalar(val, 't0')
            self.t0_actual = val;
        end
        
    end
    
    % ================================================================== %
    
    methods (Access = protected)
        
        function fnList = choose_file(self)
        %choose_file - Class method to select a file interactively
            
            % Declare the 'guess' filename as a persistent variable so we
            % can remember where to start from next time.
            persistent fnGuess
            
            % Prompt to select a file to imput
            filterSpec = [self.fileFilterSpec; {'*.*', 'All Files (*.*)'}];
            strTitle = 'Select one or more raw images';
            [fnListRaw, pathname] = uigetfile(filterSpec, strTitle, ...
                fnGuess, 'MultiSelect', 'on');
            
            % Throw an error if user cancelled, otherwise return filename
            hasCancelled = ~(ischar(fnListRaw) || iscell(fnListRaw)) && ...
                (fnListRaw == 0) && (pathname == 0);
            if ~hasCancelled
                fnList = fullfile(pathname, fnListRaw);
                if ~iscell(fnList)
                    fnGuess = fnList;
                else
                    fnGuess = fnList{1};
                end
            else
                error('RawImg:DidNotChooseFile', ['You must select ' ...
                    'one or more raw image files to load.'])
            end
            
        end
        
        % -------------------------------------------------------------- %
        
        function check_filename(~, filename)
        %check_filename - Class method to check a supplied filename
        
            % This implementation doesn't use object itself (i.e. the self
            % argument is unused), but RawImgDummy needs to overload the
            % method, so it cannot be static/defined in the set method.
            
            % Check that the file exists
            utils.checks.file_exists(filename)
            
        end
        
    end

    % ================================================================== %
    
    methods (Abstract, Access = protected)
        
        %import_image - Abstract class method to import/create the RawImg
        varargout = import_image(self, channels, calibration, varargin)
        
    end
    
    % ================================================================== %
    
    methods (Static)
        
        rawImg = cat_data(varargin)
        
        % -------------------------------------------------------------- %
        
        rawImg = from_files(varargin)
        
    end
    
    % ================================================================== %
    
    methods (Static, Access = protected)
        
        [hRaw, strRawImgType] = create_constructor_rawImg(varargin)
        
        % -------------------------------------------------------------- %
        
        [hConstructor, strClass] = choose_rawImg_type()
        
    end
    
    % ================================================================== %
    
end
