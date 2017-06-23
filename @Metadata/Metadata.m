classdef Metadata
%Metadata - Class containing metadata about a raw image
%
%   The Metadata class is a data class that is designed to contain all the
%   extra information (i.e. metadata) about a given raw image.  It also
%   implements related helper/convenience functions.
%
%   Please see the <a href="matlab:web(fullfile(utils.CHIPS_rootdir, 'doc', 'html', 'id_md_Metadata.html'))">Metadata quick start guide</a> for additional documentation
%   and examples.
%
% Metadata public properties
%   calibration     - The calibration to convert from zoom to pixel size
%   channels        - The meaning of the image channels
%   discardFlybackLine - Was the flyback line discarded?
%   frameRate       - The image frame rate [Hz]
%   isBiDi          - Is the image bidirectional?
%   knownChannels   - A list of valid channel names.
%   lineTime        - The image line time [ms]
%   nChannels       - The number of channels in the image (dim = 3)
%   nFrames         - The number of frames in the image (dim = 4)
%   nLinesPerFrame  - The number of lines per image frame (dim = 1)
%   nLinesPerFrameOrig - The original number of lines per image frame
%   nPixelsPerLine  - The number of pixels per image line (dim = 2)
%   nPixelsPerLineOrig - The original number of pixels per image line
%   pixelSize       - The pixel size [um]
%   pixelTime       - The pixel time [us]
%   zoom            - The microscope zoom factor
%
% Metadata public methods:
%   Metadata        - Metadata class constructor
%   check_ch        - Check that the appropriate channels are present
%   get_acq         - Get the image acquisition data
%   get_ch_name     - Get channel names from channel numbers
%   has_ch          - Determine if particular channels are present
%
% Metadata static methods:
%   choose_channel  - Choose an image channel
%
%   See also Metadata.Metadata, RawImgHelper, CalibrationPixelSize

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
        
        %calibration - The calibration to convert from zoom to pixel size
        %
        %   The calibration object is used to calculate a physical pixel
        %   size based on the microscope zoom factor.
        %
        %   See also Metadata.pixelSize, Metadata.zoom,
        %   CalibrationPixelSize
        calibration
        
    end
    
    % ------------------------------------------------------------------ %
    
    properties (SetAccess = protected)
        
        %channels - The meaning of the image channels
        %
        %   The channels structure contains information about the meaning
        %   of the image channels.  Each field of the channels structure
        %   represents the 'real life meaning' of one image channel, and
        %   the number contained in the field points to the corresponding
        %   channel in the raw image.
        channels
        
        %discardFlybackLine - Was the flyback line discarded?
        %
        %   discardFlybackLine is a scalar boolean flag that represents
        %   whether or not the image flyback line (i.e. last line in an
        %   image frame) was discarded.
        discardFlybackLine
        
    end
    
    % ------------------------------------------------------------------ %
    
    properties (Dependent)
        
        %frameRate - The image frame rate [Hz]
        %
        %   frameRate is a dependent property that calculates the image
        %   frame rate from the line time and number of lines per frame
        %   according to the following formula:
        %
        %       frameRate = (1e-3 * lineTime * nLinesPerFrame)^-1,
        %
        %   where frameRate is in Hz and lineTime is in ms.
        %
        %   See also Metadata.lineTime, Metadata.nLinesPerFrame
        frameRate
        
    end
    
    % ------------------------------------------------------------------ %
    
    properties (SetAccess = protected)
        
        %isBiDi - Is the image bidirectional?
        %
        %   isBiDi is a scalar boolean flag that represents whether or not
        %   the image was acquired in bidirectional mode.
        isBiDi
        
        % lineTime - The image line time [ms]
        %
        %   lineTime is the time it takes to acquire one line of an image
        %   frame.  In some cases this is more useful than the frameRate.
        %
        %   See also Metadata.frameRate
        lineTime
        
        %nChannels - The number of channels in the image (dim = 3)
        %
        %   nChannels represents the number of channels contained in the
        %   raw image.  This corresponds to the size of the image's 3rd
        %   dimension, i.e. size(img, 3).
        %   
        %   See also size, Metadata.nFrames, Metadata.nLinesPerFrame,
        %   Metadata.nPixelsPerLine
        nChannels
        
    end
    
    % ------------------------------------------------------------------ %
    
    properties (SetAccess = protected, Hidden)
        
        %nFastPoints - The number of points used for a fastpoint image
        %
        %   nFastPoints represents the number of individual image points
        %   that were specified and combined into a fastpoints acquisition
        %   in ScanImage.  Only relevant in this case.
        nFastPoints
        
    end
    
    % ------------------------------------------------------------------ %
    
    properties (SetAccess = protected)
        
        %nFrames - The number of frames in the image (dim = 4)
        %
        %   nFrames represents the number of frames contained in the
        %   raw image.  This corresponds to the size of the image's 4th
        %   dimension, i.e. size(img, 4).
        %   
        %   See also size, Metadata.nChannels, Metadata.nLinesPerFrame,
        %   Metadata.nPixelsPerLine
        nFrames
        
        %nLinesPerFrame - The number of lines per image frame (dim = 1)
        %
        %   nLinesPerFrame represents the number of lines contained in each
        %   frame of the raw image.  This corresponds to the size of the
        %   image's 1st dimension, i.e. size(img, 1).
        %   
        %   See also size, Metadata.nChannels, Metadata.nFrames,
        %   Metadata.nPixelsPerLine
        nLinesPerFrame
        
        %nLinesPerFrameOrig - The original number of lines per image frame
        %
        %   nLinesPerFrameOrig represents the original number of lines
        %   contained in each frame of the raw image, before any resizing
        %   that may have occured after aquisition (e.g. using the to_long
        %   method of the RawImgHelper class).
        %   
        %   See also Metadata.nPixelsPerLineOrig, Metadata.nLinesPerFrame
        nLinesPerFrameOrig;
        
        %nPixelsPerLine - The number of pixels per image line (dim = 2)
        %
        %   nPixelsPerLine represents the number of pixels contained in
        %   each line of the raw image.  This corresponds to the size of
        %   the image's 2nd dimension, i.e. size(img, 2).
        %   
        %   See also size, Metadata.nChannels, Metadata.nFrames,
        %   Metadata.nLinesPerFrame
        nPixelsPerLine
        
        %nPixelsPerLineOrig - The original number of pixels per image line
        %
        %   nPixelsPerLineOrig represents the original number of pixels
        %   contained in each line of the raw image, before any resizing
        %   that may have occured after aquisition (e.g. using only part of
        %   the image in RawImgComposite class).  This is important to
        %   ensure that the pixelSize calculation is correct
        %   
        %   See also Metadata.nLinesPerFrameOrig, Metadata.nPixelsPerLine
        nPixelsPerLineOrig
        
    end
    
    % ------------------------------------------------------------------ %
    
    properties (Dependent)
        
        %pixelSize - The pixel size [um]
        %
        %   pixelSize represents the size of one image pixel.  pixelSize is
        %   a dependent property calculated using the calibration object,
        %   the microscope zoom factor, and the number of pixels per line.
        %   In the case of RawImgComposite images, the number of pixels
        %   per line from the original/parent RawImg is used to ensure that
        %   the resulting pixel size is correct.
        %
        %   See also Metadata.zoom, Metadata.calibration,
        %   CalibrationPixelSize, Metadata.nPixelsPerLine
        pixelSize
        
    end
    
    % ------------------------------------------------------------------ %
    
    properties (SetAccess = protected)
        
        %pixelTime - The pixel time [us]
        %
        %   pixelTime is the time it takes to acquire one pixel of an
        %   image.  In most cases this cannot be calculated directly from
        %   the lineTime because there may be a variable amount of time
        %   where the microscope was not acquiring pixels (e.g. for the
        %   galvo mirrors to return to the correct location).
        %
        %   See also Metadata.lineTime, Metadata.frameRate
        pixelTime
        
    end
    
    % ------------------------------------------------------------------ %
    
    properties (SetAccess = protected, Hidden)
        
        %pulseDuration - The laser pulse duration [us]
        %
        %   pulseDuration is the duration of the laser pulse on each line.
        %   This property is often blank and is only used in special cases.
        %
        %   See also Metadata.pulsePeriod, Metadata.lineTime
        pulseDuration
        
        %pulsePeriod - The laser pulse period [us]
        %
        %   pulsePeriod is the period (i.e. 1/f) of the laser pulse on each
        %   line.  This property is often blank and is only used in special
        %   cases.
        %
        %   See also Metadata.pulseDuration, Metadata.lineTime
        pulsePeriod
        
    end
    
    % ------------------------------------------------------------------ %
    
    properties (SetAccess = protected)
        
        %zoom - The microscope zoom factor
        %
        %   zoom represents the microscope zoom factor.  Along with the
        %   calibration, this value is used to calculate the size of a
        %   pixel in physical units.
        %
        %   See also Metadata.pixelSize, Metadata.calibration,
        %   CalibrationPixelSize
        zoom
        
    end
    
    % ------------------------------------------------------------------ %
    
    properties (Constant)
        
        %knownChannels - A list of valid channel names
        knownChannels = {
            'blood_plasma', ...
            'blood_rbcs', ...
            'Ca_Cyto_Astro', ...
            'Ca_Memb_Astro', ...
            'Ca_Neuron', ...
            'cellular_signal', ...
            'FRET_ratio'};
        
    end
    
    % ------------------------------------------------------------------ %
        
    properties (Constant, Access = protected)
        
        %acqFields - Constant, protected property containing a list of
        %   the aquisition properties 
        acqFields = {'discardFlybackLine', 'isBiDi', 'lineTime', ...
            'nFastPoints', 'nLinesPerFrameOrig', 'nPixelsPerLineOrig', ...
            'pixelTime', 'pulseDuration', 'pulsePeriod', 'zoom'};
        
        %acqFieldsReq - Constant, protected property containing a list of
        %   the aquisition properties that are required to create a
        %   metadata object
        acqFieldsReq = {'isBiDi', 'lineTime', 'zoom'};
        
        %acqFieldsReqStr - Constant, protected property containing a list
        %   of helper strings corresponding to the aquisition properties
        %   that are required to create a metadata object.  These are used
        %   to prompt the user to input values.
        acqFieldsReqStr = {'if the image is bidirectional [1/0]', ...
            'the line time [ms]', 'the zoom factor'};
        
    end
    
    % ================================================================== %
    
    methods
        
        function MetadataObj = Metadata(varargin)
        %Metadata - Metadata class constructor
        %
        %   OBJ = Metadata() prompts for all required information and
        %   creates a Metadata object.
        %
        %   OBJ = Metadata(IMGSIZE, ACQ, CHS, CAL) uses the specified image
        %   size (IMGSIZE), acquisition structure (ACQ), channels structure
        %   (CHS) and calibration (CAL) to construct the Metadata object.
        %   If any of the input arguments are empty, the constructor will
        %   prompt for any required information.  See below for more
        %   information on each of the arguments.
        %
        %   IMGSIZE is specified as the array resulting from size(IMGDATA),
        %   provided that the dimensions of IMGDATA correspond, in the
        %   correct order, to: lines per image frame, pixels per line,
        %   image channels, and image frames.
        %
        %   ACQ is a structure containing information about the image
        %   acquisition (e.g. line time, zoom factor etc).  This is
        %   normally packaged up by the relevant concrete subclass of
        %   RawImg, but can also be specified manually.  A list of fields
        %   for ACQ can be found in the (protected) property acqFields, and
        %   further information on each of the fields can be found in the
        %   documentation of the Metadata class properties.
        %
        %   CHS is a structure containing information about the image
        %   channels.  See the documentation of the channels property for
        %   more information (link below).
        %
        %   CAL is a scalar CalibrationPixelSize object. See the
        %   documentation of the calibration property or the
        %   CalibrationPixelSize class for more information (links below).
        %
        %   Please see the <a href="matlab:web(fullfile(utils.CHIPS_rootdir, 'doc', 'html', 'id_md_Metadata.html'))">Metadata quick start guide</a> for additional
        %   documentation and examples.
        %
        %   See also Metadata.channels, Metadata.calibration,
        %   CalibrationPixelSize, RawImgHelper, RawImg
            
            % Parse optional arguments
            [imgSize, acq, channelsIn, calibrationIn] = ...
                utils.parse_opt_args({[], [], [], []}, varargin);
            
            % Set the basic size data
            if ~isempty(imgSize)
                MetadataObj = MetadataObj.set_sizes(imgSize);
            end
            
            % Acquisition details
            if ~isempty(acq)
                MetadataObj = MetadataObj.set_acq(acq);
            end
            MetadataObj = MetadataObj.choose_acq();
            
            % Calibration
            if isempty(calibrationIn)
                MetadataObj.calibration = CalibrationPixelSize.load();
            else
                MetadataObj.calibration = calibrationIn;
            end
            
            % Channel details
            doChoose = isempty(channelsIn) || iscell(channelsIn);
            if doChoose
                MetadataObj = MetadataObj.choose_channels(channelsIn);
            else
                MetadataObj.channels = channelsIn;
            end
            
        end
        
        % -------------------------------------------------------------- %
        
        varargout = check_ch(self, channels, checkType, varargin)
        
        % -------------------------------------------------------------- %
        
        acq = get_acq(self)
        
        % -------------------------------------------------------------- %
        
        chName = get_ch_name(self, chNums)
        
        % -------------------------------------------------------------- %
        
        tf = has_ch(self, chNames)
        
        % -------------------------------------------------------------- %
        
        function frameRate = get.frameRate(self)
            
            hasOrig = ~isempty(self.nLinesPerFrameOrig);
            if hasOrig
                
                % Use the original nLinesPerFrame
                frameRate = 1/((1e-3) * self.lineTime * ...
                    self.nLinesPerFrameOrig);
                
            else
                
                % Use the nLinesPerFrame
                warning('Metadata:GetFrameRate:NoOrigNLines', ['The '...
                    'original number of lines per frame is not defined ' ...
                    'for this image.  This may be because the metadata ' ...
                    'was created in an unexpected way.  Please check ' ...
                    'carefully any results that depend on the frame ' ...
                    'rate.'])
                hasCurrent = ~isempty(self.nLinesPerFrame);
                if hasCurrent
                    frameRate = 1/((1e-3) * self.lineTime * ...
                        self.nLinesPerFrame);
                else
                    warning('Metadata:GetFrameRate:NoNLines', ['The ' ...
                        'image dimensions are not defined, so the ' ...
                        'frame rate could not be determined.'])
                    frameRate = NaN;
                end
                
            end
            
        end
        
        % -------------------------------------------------------------- %
        
        function pixelSize = get.pixelSize(self)
            
            hasOrig = ~isempty(self.nPixelsPerLineOrig);
            if hasOrig
                
                % Use the original nPixelsPerLine
                pixelSize = self.calibration.calc_pixel_size(self.zoom, ...
                    self.nPixelsPerLineOrig);
                
            else
                
                % Use the nPixelsPerLine
                warning('Metadata:GetPixelSize:NoOrigNPixels', ['The '...
                    'original number of pixels per line is not defined ' ...
                    'for this image.  This may be because the metadata ' ...
                    'was created in an unexpected way.  Please check ' ...
                    'carefully any results that depend on the pixel ' ...
                    'size.'])
                hasCurrent = ~isempty(self.nPixelsPerLine);
                if hasCurrent
                    pixelSize = self.calibration.calc_pixel_size(...
                        self.zoom, self.nPixelsPerLine);
                else
                    warning('Metadata:GetPixelSize:NoNPixels', ['The ' ...
                        'image dimensions are not defined, so the ' ...
                        'pixel size could not be determined.'])
                    pixelSize = NaN;
                end
                
            end
            
        end
        
        % -------------------------------------------------------------- %
        
        function self = set.calibration(self, calibration)
            
            % Check it's scalar
            utils.checks.scalar(calibration);
            
            % Check it's the correct class
            varName = 'calibration';
            className = 'CalibrationPixelSize';
            utils.checks.object_class(calibration, className, varName);
            
            % Set the property
            self.calibration = calibration;
            
        end
        
        % -------------------------------------------------------------- %
        
        function self = set.channels(self, channels)
            
            % Check that channels is a scalar structure
            utils.checks.object_class(channels, 'struct', 'channels');
            utils.checks.scalar(channels, 'channels structure');

            % Order the fields for nice-ness
            channels = orderfields(channels);

            % Extract the channel names from the structure
            names = fieldnames(channels);
            nFields = length(names);

            % For each field name...
            for iField = 1:nFields

                % Check the channel name is known
                iName = names{iField};
                isKnown = ismember(iName, self.knownChannels);
                
                if ~isKnown
                    error('Metadata:SetChannels:UnknownChannel', ...
                        '"%s" is not a recognised channel name', iName)
                end

                % Check the channel number is a positive integer scalar
                iNumber = channels.(iName);
                utils.checks.prfs(channels.(iName), 'lineTime');

                % Check the channel number exists
                if ~isempty(self.nChannels)
                    
                    isBadChannel = (iNumber > self.nChannels);
                    if isBadChannel
                            
                        error('Metadata:SetChannels:BadChannel', ['You ' ...
                            'are trying to set the channel %d as %s, ' ...
                            'but the image contains only %d channels.'], ...
                            iNumber, iName, self.nChannels)
                        
                    end
                    
                end

            end

            % Assign the property
            self.channels = channels;
    
        end
        
        % -------------------------------------------------------------- %
        
        function self = set.discardFlybackLine(self, discardFlybackLine)
            utils.checks.scalar_logical_able(discardFlybackLine, ...
                'discardFlybackLine');
            self.discardFlybackLine = logical(discardFlybackLine);
        end
        
        % -------------------------------------------------------------- %
        
        function self = set.isBiDi(self, isBiDi)
            utils.checks.scalar_logical_able(isBiDi, 'isBiDi');
            self.isBiDi = logical(isBiDi);
        end
        
        % -------------------------------------------------------------- %
        
        function self = set.lineTime(self, lineTime)
            utils.checks.prfs(lineTime, 'lineTime');
            self.lineTime = lineTime;
        end
        
        % -------------------------------------------------------------- %
        
        function self = set.nChannels(self, nChannels)
            utils.checks.integer(nChannels, 'nChannels');
            utils.checks.positive(nChannels, 'nChannels');
            self.nChannels = nChannels;
        end
        
        % -------------------------------------------------------------- %
        
        function self = set.nFrames(self, nFrames)
            utils.checks.integer(nFrames, 'nFrames');
            utils.checks.positive(nFrames, 'nFrames');
            self.nFrames = nFrames;
        end
        
        % -------------------------------------------------------------- %
        
        function self = set.nLinesPerFrame(self, nLinesPerFrame)
            utils.checks.integer(nLinesPerFrame, 'nLinesPerFrame');
            utils.checks.positive(nLinesPerFrame, 'nLinesPerFrame');
            self.nLinesPerFrame = nLinesPerFrame;
        end
        
        % -------------------------------------------------------------- %
        
        function self = set.nPixelsPerLine(self, nPixelsPerLine)
            utils.checks.integer(nPixelsPerLine, 'nPixelsPerLine');
            utils.checks.positive(nPixelsPerLine, 'nPixelsPerLine');
            self.nPixelsPerLine = nPixelsPerLine;
        end
        
        % -------------------------------------------------------------- %
        
        function self = set.pixelTime(self, pixelTime)
            utils.checks.prfs(pixelTime, 'pixelTime');
            self.pixelTime = pixelTime;
        end
        
        % -------------------------------------------------------------- %
        
        function self = set.pulseDuration(self, pulseDuration)
            utils.checks.prfs(pulseDuration, 'pulseDuration');
            self.pulseDuration = pulseDuration;
        end
        
        % -------------------------------------------------------------- %
        
        function self = set.pulsePeriod(self, pulsePeriod)
            utils.checks.prfs(pulsePeriod, 'pulsePeriod');
            self.pulsePeriod = pulsePeriod;
        end
        
        % -------------------------------------------------------------- %
        
        function self = set.zoom(self, zoom)
            utils.checks.prfs(zoom, 'zoom');
            self.zoom = zoom;
        end
        
    end
    
    % ================================================================== %
    
    methods (Access = protected)
        
        self = choose_acq(self)
        
        % -------------------------------------------------------------- %
        
        self = choose_channels(self, varargin)
        
        % -------------------------------------------------------------- %
        
        self = set_acq(self, acq)
        
        % -------------------------------------------------------------- %
        
        self = set_sizes(self, imgSize)
        
    end
    
    % ================================================================== %
    
    methods (Static)
        
        chName = choose_channel(varargin)
        
    end
    
    % ================================================================== %
    
end
