classdef SCIM_Tif < RawImg
%SCIM_Tif - Class implementing ScanImage Tif raw image objects
%
%   The SCIM_Tif class implements functionality related to ScanImage Tif
%   objects and simplifies the process of importing the image data and
%   metadata.
%
%   This class relies on and includes existing code provided with the
%   ScanImage microscope software.  For more information on ScanImage,
%   please visit http://www.scanimage.org, or refer to 
%   <a href="matlab:web('http://dx.doi.org/10.1186/1475-925X-2-13', '-browser')">Pologruto et al. (2010)</a>, BioMed Eng OnLine 2(1):1-9.
%
%   Please see the <a href="matlab:web(fullfile(utils.CHIPS_rootdir, 'doc', 'html', 'id_ri_SCIM_Tif.html'))">SCIM_Tif quick start guide</a> for additional documentation
%   and examples.
%
% SCIM_Tif public properties:
%   filename        - The original image filename
%   isDenoised      - Has the image been denoised?
%   isMotionCorrected - Has the image been motion corrected?
%   metadata        - The image metadata
%   metadata_original - The image metadata in its original format
%   name            - The object name
%   rawdata         - The raw image data
%   t0              - The image time that should be treated as t=0 [s]
% 
% SCIM_Tif public methods:
%   SCIM_Tif        - SCIM_Tif class constructor
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
% SCIM_Tif static methods:
%   cat_data        - Concatenate the data from SCIM_Tif objects
%   from_files      - Create a SCIM_Tif object from a list of files
%
% SCIM_Tif public events:
%   ToLong          - Notifies listeners that the to_long method was called
%
%   See also SCIM_Tif.SCIM_Tif, RawImg, RawImgHelper, RawImgDummy,
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
        %   for the RawImg file selection dialogue box
        fileFilterSpec
    end
    
    % ================================================================== %
    
    methods
        
        function SCIM_TifObj = SCIM_Tif(varargin)
        %SCIM_Tif - SCIM_Tif class constructor
        %
        %   OBJ = SCIM_Tif() prompts for all required information and
        %   creates a SCIM_Tif object.
        %
        %   OBJ = SCIM_Tif(FILENAME, CHS, CAL) uses the specified channels
        %   and calibration to construct the SCIM_Tif object. FILENAME must
        %   be a single row character array, or a cell array containing
        %   only single row character arrays. If FILENAME is empty, the
        %   constructor will prompt to select one or more files.  CHS and
        %   CAL must be scalar and in the format expected by the Metadata
        %   constructor (see link below).  If either of these arguments are
        %   empty, the constructor will prompt for the required
        %   information.
        %
        %   Please see the <a href="matlab:web(fullfile(utils.CHIPS_rootdir, 'doc', 'html', 'id_ri_SCIM_Tif.html'))">SCIM_Tif quick start guide</a> for additional
        %   documentation and examples.
        %
        %   See also RawImg, RawImgHelper, RawImgDummy, RawImgComposite,
        %   Metadata, matlab.mixin.Copyable, handle,
        %   utils.scim.scim_openTif

            % Parse optional arguments
            [filename, channels, calibration, skipImport] = ...
                utils.parse_opt_args({'', [], [], false}, varargin);
            
            % Work out the current recursion depth
            doChooseFile = ~utils.is_deeper_than('SCIM_Tif.SCIM_Tif');
            
            % Call RawImg (i.e. parent class) constructor
            SCIM_TifObj = SCIM_TifObj@RawImg(filename, doChooseFile);

            % Do the actual import
            doImport = (nargin < 2) || ~skipImport;
            if doImport
                nImgs = length(SCIM_TifObj);
                for iImg = 1:nImgs
                    [channels, calibration] = ...
                        SCIM_TifObj(iImg).import_image(...
                        channels, calibration);
                end
            end
            
        end
        
        % -------------------------------------------------------------- %
        
        function fileFilterSpec = get.fileFilterSpec(~)
            fileFilterSpec = {'*.tif*', 'Recognised images (*.tif*)'};
        end
        
    end
    
    % ================================================================== %
    
    methods (Access = protected)
        
        function varargout = import_image(self, channels, calibration, ~)
        %import_image - Class method to import/create the SCIM_Tif
            
            % Don't do anything if the filename is empty
            if nargout > 0
                varargout{1} = channels;
            end
            if nargout > 1
                varargout{2} = calibration;
            end
            if isempty(self.filename)
                return
            end
            
            % Import the image using the scim package
            wng_state = warning('off', ...
                'MATLAB:imagesci:tiffmexutils:libtiffWarning');
            [header, self.rawdata] = utils.scim.scim_openTif(self.filename);
            warning(wng_state);
            
            % Map the original metadata
            self.metadata_original = header;
            
            % Map the metadata in more detail
            
            acq.lineTime = header.acq.msPerLine;
            acq.pixelTime = header.acq.pixelTime/1E-6;
            acq.zoom = header.acq.zoomFactor;
            acq.isBiDi = logical(header.acq.bidirectionalScan);
            acq.discardFlybackLine = logical(...
                header.acq.slowDimDiscardFlybackLine);
            hasFlybackLine = logical(header.acq.slowDimFlybackFinalLine);
            acq.nLinesPerFrameOrig = header.acq.linesPerFrame;
            acq.nPixelsPerLineOrig = header.acq.pixelsPerLine;
            
            % Remove the flyback line, if it's not already done
            if hasFlybackLine && ~acq.discardFlybackLine
                self.rawdata = self.rawdata(1:end-1,:,:,:);
            end
            
            imgSize = size(self.rawdata);
            
            % Map the pulse wave parameters
            try 
                acq.pulseDuration = header.acq.pockelsPulseDuration;
                if acq.pulseDuration < 1
                    acq.pulseDuration = acq.pulseDuration/1E-6;
                end
            catch
            end
            try 
                acq.pulsePeriod = header.acq.pockelsPeriod;
                if acq.pulsePeriod < 1
                    acq.pulsePeriod = acq.pulsePeriod/1E-6;
                end
            catch
            end
            
            % Map the fastpoints data
            try 
                acq.nFastPoints = header.acq.nFastPoints;
            catch
            end
            
            % Map the linepoints data.  This is only useful for a few
            % images when nLinePoints existed as well as nFastPoints.
            hasFP = isfield(acq, 'nFastPoints') && (acq.nFastPoints > 0);
            hasLP = isfield(header.acq, 'nLinePoints') && ...
                (header.acq.nLinePoints > 0);
            hasBoth = hasFP && hasLP;
            if hasLP && ~hasBoth
                try 
                    acq.nFastPoints = header.acq.nLinePoints;
                catch
                end
            elseif hasBoth
                warning('SCIM_Tif:ImportImage:BadFP', ['Both ' ...
                    'nFastPoints and nLinePoints are > 0. nLinePoints ' ...
                    'will be ignored.'])
            end
            
            % Create the metadata
            self.metadata = Metadata(imgSize, acq, channels, calibration);
            
            % Pass out these arguments if requested
            if nargout > 0
                varargout{1} = self.metadata.channels;
            end
            if nargout > 1
                varargout{2} = self.metadata.calibration;
            end
            
        end
        
    end
    
    % ================================================================== %
    
    methods (Static)
        
        rawImg = from_files(varargin)
        
    end
    
    % ================================================================== %
    
end
