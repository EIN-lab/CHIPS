classdef RawImgDummy < RawImg
%RawImgDummy - Class implementing dummy raw image objects
%
%   The RawImgDummy class implements functionality related to 'dummy'
%   RawImg objects; i.e. RawImg objects that don't have a specific class
%   designed to work with their format.  This makes it possible to create
%   functional RawImg objects from any data without requiring the overhead
%   of creating a class (but also without the benefits of a streamlined
%   creation/import process).  In addition, RawImgDummy objects are created
%   when other RawImg objects are modified in such a way that the modified
%   objects no longer represent the original raw image file.
%
%   Please see the <a href="matlab:web(fullfile(utils.CHIPS_rootdir, 'doc', 'html', 'id_ri_RawImgDummy.html'))">RawImgDummy quick start guide</a> for additional
%   documentation and examples.
%
% RawImgDummy public properties:
%   filename        - The original image filename
%   isDenoised      - Has the image been denoised?
%   isMotionCorrected - Has the image been motion corrected?
%   metadata        - The image metadata
%   metadata_original - The image metadata in its original format
%   name            - The object name
%   rawdata         - The raw image data
%   t0              - The image time that should be treated as t=0 [s]
% 
% RawImgDummy public methods:
%   RawImgDummy     - RawImgDummy class constructor
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
% RawImgDummy static methods:
%   cat_data        - Concatenate the data from RawImgDummy objects
%   from_files      - Create a RawImgDummy object from a list of files
%
% RawImgDummy public events:
%   ToLong          - Notifies listeners that the to_long method was called
%
%   See also RawImgDummy.RawImgDummy, RawImg, RawImgHelper, SCIM_Tif,
%   BioFormats, RawImgComposite, Metadata, matlab.mixin.Copyable, handle,
%   IRawImg

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
        %   for the RawImg file selection dialogue box. Empty in this case.
        fileFilterSpec
    end
    
    % ================================================================== %
    
    methods
        
        function ridObj = RawImgDummy(varargin)
        %RawImgDummy - RawImgDummy class constructor
        %
        %   OBJ = RawImgDummy() prompts for all required information and
        %   creates a RawImgDummy object from an image file.
        %
        %   OBJ = RawImgDummy(FILENAME) uses the filename to construct the
        %   RawImgDummy object. FILENAME must be a single row character
        %   array, or a cell array containing only single row character
        %   arrays. If FILENAME is empty, the constructor will prompt to
        %   select one or more files.
        %
        %   Note: When creating a RawImgDummy object from an image file,
        %   the image is assumed to contain only one channel.
        %
        %   OBJ = RawImgDummy('name', RAWDATA) prompts for all additional
        %   information required and creates a RawImgDummy object with the
        %   specified name and rawdata.  The name must be a single row
        %   character array, and RAWDATA must be a numeric array.
        %
        %   OBJ = RawImgDummy(..., CHS, CAL, ACQ) uses the specified
        %   channels, calibration and acquisition to construct the
        %   RawImgDummy object. The CHS, CAL and ACQ arguments must be in
        %   the format expected by the Metadata constructor (see link
        %   below). If any of these arguments are empty, the constructor
        %   will prompt for the required information.
        %
        %   Please see the <a href="matlab:web(fullfile(utils.CHIPS_rootdir, 'doc', 'html', 'id_ri_RawImgDummy.html'))">RawImgDummy quick start guide</a> for additional
        %   documentation and examples.
        %
        %   See also RawImg, Metadata, RawImgHelper, RawImgComposite,
        %   matlab.mixin.Copyable, handle, IRawImg
            
            % Pull out the name.  It can be either a name or filename
            nameIn = '';
            hasName = nargin > 0;
            if hasName
                nameIn = varargin{1};
            end
            
            % Check if we have rawdata
            idxStart = 2;
            rawdataIn = [];
            hasRawData = (nargin > 1) && ~isempty(varargin{2}) && ...
                isnumeric(varargin{2}) && (ndims(varargin{2}) >= 2);
            if hasRawData
                rawdataIn = varargin{2};
                idxStart = idxStart + 1;
            end
            
            % Call RawImg (i.e. parent class) constructor
            doChooseFile = ...
                ~utils.is_deeper_than('RawImgDummy.RawImgDummy') && ...
                ~hasRawData;
            ridObj = ridObj@RawImg(nameIn, doChooseFile);
            
            % Parse remaining optional arguments
            [chsIn, calIn, acqIn] = utils.parse_opt_args({[], [], []}, ...
                varargin(idxStart:end));
            
            % Don't need to check rawdataIn because import_image and
            % set.rawdata does this
            
            % Don't need to check chsIn, calIn or acqIn because the
            % Metadata class does this
            
            % Add the stuff
            nImgs = length(ridObj);
            for iImg = 1:nImgs
                [chsIn, calIn, acqIn] = ridObj(iImg).import_image(...
                    rawdataIn, chsIn, calIn, acqIn);
            end
            
        end
        
        % -------------------------------------------------------------- %
        
        function fileFilterSpec = get.fileFilterSpec(~)
            fileFilterSpec = {'*.tif*', 'Recognised images (*.tif*)'};
        end
        
    end
    
    % ================================================================== %
    
    methods (Access = protected)
        
        function varargout = import_image(self, rawdata, chs, cal, acq)
        %import_image - Class method to import/create the RawImgDummy
        
            % Don't do anything if the filename is empty
            if nargout > 0
                varargout{1} = chs;
            end
            if nargout > 1
                varargout{2} = cal;
            end
            if nargout > 2
                varargout{3} = acq;
            end
            if isempty(self.filename) && isempty(rawdata)
                return
            end
        
            % Check if we have raw data
            hasRawData = ~isempty(rawdata);
            if ~hasRawData
                
                % Check we have a valid filename
                ME = utils.checks.file_exists(self.filename);
                if ~isempty(ME)
                    error('RawImgDummy:ImportImage:NoFN', ['You ' ...
                        'must supply or choose a valid filename if you ' ...
                        'do not supply any image data'])
                end
                
                % If we do, load the data
                
                info = imfinfo(self.filename);
                nFrames = numel(info);
                
                % Initialise a progress bar
                [~, fnTemp, ext] = fileparts(self.filename);
                strMsg = ['Opening ' fnTemp, ext];
                isWorker = utils.is_on_worker();
                if ~isWorker
                    utils.progbar(0, 'msg', strMsg);
                end
                
                % Load the frames sequentially
                for iFrame = 1:nFrames
                    
                    % Get the correct image class and preallocate
                    if iFrame == 1
                        rawdataTemp = imread(self.filename, ...
                            iFrame, 'Info', info);
                        szImg = [size(rawdataTemp), 1, numel(info)];
                        rawdata = zeros(szImg, class(rawdataTemp)); %#ok<ZEROLIKE>
                    end
                    
                    % Load the data
                    rawdata(:,:,1,iFrame) = imread(self.filename, ...
                        iFrame, 'Info', info);
                    if ~isWorker
                        utils.progbar(iFrame/nFrames, ...
                            'msg', strMsg, 'doBackspace', true);
                    end
                    
                end
                
            end
            
            % Set the rawdata.  More checks happen in here
            self.rawdata = rawdata;
            
            % Pull out the imgSize
            imgSize = size(self.rawdata);
            
            % Add some acq data, if necessary
            if isempty(acq)
                acq.nLinesPerFrameOrig = imgSize(3);
                acq.nPixelsPerLineOrig = imgSize(2);
            end
            
            % Create a metadata object
            self.metadata = Metadata(imgSize, acq, chs, cal);
            
            % Pass out these arguments if requested
            if nargout > 0
                varargout{1} = self.metadata.channels;
            end
            if nargout > 1
                varargout{2} = self.metadata.calibration;
            end
            if nargout > 2
                varargout{3} = self.metadata.get_acq();
            end
            
        end
        
        % -------------------------------------------------------------- %
        
        function check_filename(~, ~)
        %check_filename - Overloaded class method to check a supplied
        %   filename, which in this case does nothing.
        end
        
    end
    
    % ================================================================== %
    
    methods (Static)
        
        rawImg = from_files(varargin)
        
    end
    
    % ================================================================== %
    
end
