classdef BioFormats < RawImg
%BioFormats - Class implementing BioFormats raw image objects
%
%   The BioFormats class implements functionality related to the
%   Bio-Formats Java library and simplifies the process of importing the
%   image data and metadata. This class requires prior installation of the
%   Bio-Formats Java library, downloadable from the Open Microscopy
%   Environment website: 
%   
%       <a href="matlab:web('http://www.openmicroscopy.org/site/products/bio-formats','-browser')">http://www.openmicroscopy.org/site/products/bio-formats</a>
%
%   This can be done either manually or by using the utility function
%   utils.install_bfmatlab (see the link at the bottom of this help text).
%
%   Please see the <a href="matlab:web(fullfile(utils.CHIPS_rootdir, 'doc', 'html', 'id_ri_BioFormats.html'))">BioFormats quick start guide</a> for additional
%   documentation and examples.
%
% BioFormats public properties:
%   filename        - The original image filename
%   isDenoised      - Has the image been denoised?
%   isMotionCorrected - Has the image been motion corrected?
%   metadata        - The image metadata
%   metadata_original - The image metadata in its original format
%   name            - The object name
%   rawdata         - The raw image data
%   t0              - The image time that should be treated as t=0 [s]
% 
% BioFormats public methods:
%   BioFormats      - BioFormats class constructor
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
% BioFormats static methods:
%   cat_data        - Concatenate the data from BioFormats objects
%   from_files      - Create a BioFormats object from a list of files
%   upgrade         - Check for new version of Bio-Formats and update it
%
% BioFormats public events:
%   ToLong          - Notifies listeners that the to_long method was called
%
%   See also BioFormats.BioFormats, RawImg, RawImgHelper, RawImgDummy,
%   SCIM_Tif, RawImgComposite, Metadata, matlab.mixin.Copyable, handle,
%   IRawImg, utils.install_bfmatlab

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
    
    properties (Dependent, Access = protected)
        %fileFilterSpec - Protected, dependent property specifying a filter 
        %   for the RawImg file selection dialogue box
        fileFilterSpec
    end
    
    % ================================================================== %
    
    methods
        
        function BioFormatsObj = BioFormats(varargin)
        %BioFormats - BioFormats class constructor
        %
        %   OBJ = BioFormats() prompts for all required information and
        %   creates a BioFormats object.
        %
        %   OBJ = BioFormats(FILENAME, CHS, CAL) uses the specified
        %   channels and calibration to construct the BioFormats object.
        %   FILENAME must be a single row character array, or a cell array
        %   containing only single row character arrays. If FILENAME is
        %   empty, the constructor will prompt to select one or more files.
        %   CHS and CAL must be scalar and in the format expected by the
        %   Metadata constructor (see link below).  If either of these
        %   arguments are empty, the constructor will prompt for the
        %   required information.
        %
        %   Please see the <a href="matlab:web(fullfile(utils.CHIPS_rootdir, 'doc', 'html', 'id_ri_BioFormats.html'))">BioFormats quick start guide</a> for additional
        %   documentation and examples.
        %
        %   See also RawImg, RawImgHelper, RawImgDummy, RawImgComposite,
        %   Metadata, matlab.mixin.Copyable, handle
        
            % Check that the library exists
            BioFormats.check_library()
            
            % Parse optional arguments
            [filename, channels, calibration, skipImport, downsamp] = ...
                utils.parse_opt_args({'', [], [], false, 1}, varargin);
            
            % Work out the current recursion depth
            doChooseFile = ~utils.is_deeper_than('BioFormats.BioFormats');
            
            % Call RawImg (i.e. parent class) constructor
            BioFormatsObj = BioFormatsObj@RawImg(filename, doChooseFile);
                        
            % Do the actual import
            doImport = (nargin < 2) || ~skipImport;
            if doImport
                nImgs = length(BioFormatsObj);
                for iImg = 1:nImgs
                    [channels, calibration] = ...
                        BioFormatsObj(iImg).import_image(...
                        channels, calibration, downsamp);
                end
            end
            
        end
        
        % -------------------------------------------------------------- %
        
        function fileFilterSpec = get.fileFilterSpec(~)
            fileFilterSpec = BioFormats.getFileExtensions();
        end
        
    end
    
    % ================================================================== %
    
    methods (Access = protected)
        
        varargout = import_image(self, channels, calibration, downsamp)
        
        % -------------------------------------------------------------- %
        
        [objID, objZoom, pxSize, experimenter, channels] = parseOME(self);
        
    end
    
    % ================================================================== %
    
    methods (Static)
        
        rawImg = from_files(varargin)
        
        % -------------------------------------------------------------- %
        
        function upgrade(varargin)
        %upgrade - Check for new version of Bio-Formats and update it
        %
        %   BioFormats.upgrade(...) checks for newer versions of the
        %   Bio-Formats library and updates it if necessary/specified.
        %   Refer to the documentation of the function bfUpgradeCheck (link
        %   below) for more details on the input arguments/options.
        %
        %   See also bfUpgradeCheck
                        
            % Run upgrade check
            bfUpgradeCheck(varargin{:});
            
        end
                
    end
    
    % ================================================================== %
    
    methods (Static, Access = protected)
        
        function check_library()
            
            % Check the path for these directories, and add if necessary
            utils.checkaddpath('bfmatlab')
            
            % Setup a list of known errors/warnings
            strErrors = {'MATLAB:UndefinedFunction', ...
                'MATLAB:Java:ClassLoad'};
            strWarnings = {'MATLAB:GENERAL:JAVARMPATH:NotFoundInPath'};
            lastwarn('')
            
            % Check if any errors occur when trying the java path
            wngState = warning('off', ...
                'MATLAB:javaclasspath:jarAlreadySpecified');
            try
                bfCheckJavaPath();
            catch ME
                if ismember(ME.identifier, strErrors)
                    BioFormats.throw_bf_error();
                else
                    rethrow(ME)
                end
            end
            warning(wngState);
            
            % Also check for any warnings
            [~, id] = lastwarn();
            if ismember(id, strWarnings)
                BioFormats.throw_bf_error();
            end 
            
        end
        
        % -------------------------------------------------------------- %
        
        function throw_bf_error()
            error('BioFormats:LibNotFound', ['The BioFormats library ', ...
                'wasn''t found on the path. Please download it from ', ...
                'https://www.openmicroscopy.org/site/products/bio-formats, ', ...
                'install it and properly add it to your MATLAB (and ', ...
                'in some cases java) path before creating BioFormats'...
                'objects.  Alternatively, you may use the utility ' ...
                'function "utils.install_bfmatlab()" to do this ' ...
                'automatically.']);
        end
        
        % -------------------------------------------------------------- %
        
        function fileFilterSpec = getFileExtensions()
            
            % Check for the BioFormats library to prevent errors
            try
                BioFormats.check_library();
            catch ME
                if strcmp(ME.identifier, 'BioFormats:LibNotFound')
                    return
                else
                    rethrow(ME)
                end
            end
            
            % Get file extensions
            try
                fileFilterSpec = bfGetFileExtensions();
            catch
                fileFilterSpec = '';
            end
            
        end
        
    end
    
    % ================================================================== %
    
end
