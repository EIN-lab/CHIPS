function varargout = import_image(self, channels, calibration, downsamp)
%import_image - Class method to import/create the BioFormats

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

% Check if the user specified channels
if ~isempty(channels)
    forceUserChannels = true;
end

% Get the full file path. Required for some of the Java classes
[path, ~, ~] = fileparts(self.filename);
if isempty(path)
    fnLoad = which(self.filename);
else
    fnLoad = self.filename;
end

% Import the image using the BioFormats package
[imgData] = bfopen(fnLoad);

% Map the original metadata
hasOMEMeta = ~isempty(imgData{1,4}.dumpXML().toCharArray());

if ~hasOMEMeta
    error('BioFormats:import_image:NoMetadata', ...
        'No metadata available.')
end

% Check for image series
omeMeta = imgData{1,4};
imLoad = 1;
imCount = omeMeta.getImageCount;
hasMultipleImages = imCount > 1;

if hasMultipleImages

    dispStr = sprintf(['The file you''re loading contains ', ...
        '%i images. Please indicate, which one to load.\n'], ...
        imCount);
    imLoad = input(dispStr);

    hasCancelled = ~isnumeric(imLoad) && ...
        ~ismember(imLoad, 1:imCount);

    if hasCancelled
        error('BioFormats:DidNotChooseImage', ['You must ' ...
            'select an image to load.'])
    end

end

% Retrieve correct OME metadata
omeMeta = imgData{imLoad,4};
self.metadata_original = omeMeta;

% Map the metadata in more detail
stackSizeX = omeMeta.getPixelsSizeX(0).getValue(); % image width, pixels
stackSizeY = omeMeta.getPixelsSizeY(0).getValue(); % image height, pixels
stackSizeT = omeMeta.getPixelsSizeT(0).getValue();
stackSizeZ = omeMeta.getPixelsSizeZ(0).getValue();
nChannels = omeMeta.getPixelsSizeC(0).getValue();

% For now, combine T and Z if both are non scalar
hasBoth = (stackSizeT > 1) && (stackSizeZ > 1);
if hasBoth
    warning('BioFormats:ImportImage:BothTAndZ', ['The image contains ' ...
        'both T and Z dimensions.  This is not currently supported, ' ...
        'so both T and Z data will be combined into a single dimension.'])
end
stackSizeT = stackSizeT*stackSizeZ;

imgSize = [stackSizeY, stackSizeX, nChannels, stackSizeT];

% Try to find the frame interval/time increment
frameInterval = [];
try
    frameInterval = omeMeta.getPlaneDeltaT(0,0).value(...
        ome.units.UNITS.MILLISECOND).doubleValue();
catch
    try
        frameInterval = omeMeta.getPixelsTimeIncrement(0).value(...
            ome.units.UNITS.MILLISECOND).doubleValue();
    catch
    end
end

iFrame = 1;
isBadFrame = @(xx) isempty(xx) || (xx == 0);
while isBadFrame(frameInterval)
    frameInterval = omeMeta.getPlaneDeltaT(0,iFrame).value(...
        ome.units.UNITS.MILLISECOND).doubleValue();
    iFrame = iFrame + 1;
    if iFrame == stackSizeT
        warning('BioFormats:ImportImage:NoFrame', ['Frame interval ' ...
            'couldn''t be found. Set to 1.'])
        break
    end
end

acq.lineTime = frameInterval/stackSizeY;
acq.pixelTime = acq.lineTime/stackSizeX;
acq.zoom = 1;
acq.isBiDi = 0;
acq.discardFlybackLine = 0;
acq.nLinesPerFrameOrig = stackSizeY;
acq.nPixelsPerLineOrig = stackSizeX;

% Map calibration data from metadata
hasCalibIn = ~isempty(calibration);

if ~hasCalibIn

    % Parse OME metadata
    [objID, objZoom, pxSize, experimenter, channelsOME] = ...
        self.parseOME();
    acq.zoom = objZoom(1);

    % Check necessary information
    hasZoom = ~isempty(objZoom);
    hasPxSize = ~isempty(pxSize);
    hasObjective = ~isempty(objID);
    hasExperimenter = ~isempty(experimenter);
    hasChannels = ~isempty(channelsOME);

    hasCalibMeta = hasObjective && hasZoom && hasPxSize;
    if ~hasExperimenter
        experimenter = 'auto';
    end

    % Create calibration
    if hasCalibMeta

        name = [date, '_auto_', objID];

        calibration = CalibrationPixelSize(objZoom, pxSize, ...
            stackSizeX, objID, date, name, experimenter, ...
            @CalibrationPixelSize.funRawDummy);
    end

    if hasChannels && ~forceUserChannels
        channels = channelsOME;
    end

end

% Create the metadata
wngState = warning('off', 'Metadata:SetSizes:NonSquare');
self.metadata = Metadata(imgSize, acq, channels, calibration);
warning(wngState)

data = cell2mat(imgData{imLoad,1}(:,1));
data = reshape(data, stackSizeY, nChannels, stackSizeT, stackSizeX);
self.rawdata = permute(data, [1, 4, 2, 3]);

% Perform downsampling
if downsamp < 1
    self.rawdata = utils.resize_img(self.rawdata, ...
        round(downsamp.*size(self.rawdata(:,:,1,1))));
end

% Pass out these arguments if requested
if nargout > 0
    varargout{1} = self.metadata.channels;
end
if nargout > 1
    varargout{2} = self.metadata.calibration;
end

end
