function [objID, objZoom, pxSize, experimenter, channels] = parseOME(self)

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

objID = char;
objIDs = {};
objCount = 0;
err = false;
omeMeta = self.metadata_original;

% Retreive current objective
try
    objKey = omeMeta.getObjectiveSettingsID(0);
    objID = objKey.toCharArray';
catch
end
if isempty(objID)
    objID = 'unknown';
end

% Retreive other objectives in system
while ~err
    try
        objIDs{objCount+1} = ...
            omeMeta.getObjectiveID(0,objCount).toCharArray()'; %#ok<AGROW>
    catch
        err = true;
    end
    objCount = objCount + 1;
end

% Find current objective's index, and the zoom
objZoom = [];
try
    objIdx = cellfun(@strcmp, objIDs, repmat({objID},1,numel(objIDs)), ...
        'uniformoutput', false);
    objIdx = find(cell2mat(objIdx));
    objZoom = omeMeta.getObjectiveCalibratedMagnification(0, objIdx-1).doubleValue();
catch
    try
        objZoom = omeMeta.getDetectorZoom(0, 0).doubleValue();
    catch
    end
end
if isempty(objZoom)
    objZoom = 1;
end
objZoom = repmat(objZoom, 1, 2);

% Retreive pixel size and check for square pixels
try
    pxSizeX = omeMeta.getPixelsPhysicalSizeX(0).value(...
        ome.units.UNITS.MICROMETER).doubleValue();
catch ME_pxSizeX
    warning('BioFormats:ParseOME:BadPxSizeX', ['The following error ' ...
        'occurred when attempting to get the pixel size in X:' ...
        '\n\n\t%s\n\nA value of 1 will be used.'], ME_pxSizeX.message)
    pxSizeX = 1;
end
try
    pxSizeY = omeMeta.getPixelsPhysicalSizeY(0).value(...
        ome.units.UNITS.MICROMETER).doubleValue();
catch ME_pxSizeY
    warning('BioFormats:ParseOME:BadPxSizeY', ['The following error ' ...
        'occurred when attempting to get the pixel size in Y:' ...
        '\n\n\t%s\n\nA value of 1 will be used.'], ME_pxSizeY.message)
    pxSizeY = 1;
end
isNotSquare = abs(pxSizeX/pxSizeY - 1) > 0.01;
if isNotSquare
    warning('BioFormats:ImportImage:NonSquare', ['The image appears to ' ...
            'have a pixel aspect ratio other than 1 (i.e. the pixels '...
            'may be rectangular, rather than square).  This software ' ...
            'currently does not account for pixel aspect ratios other ' ...
            'than 1, so certain algorithms may produce incorrect ' ...
            'results.  Please check the output carefully.']);
end
pxSize = [pxSizeX, pxSizeX];

% Retrieve experimenter information
try
    experimenter = omeMeta.getExperimenterUserName(0).toCharArray()';
catch
    experimenter = 'unknown';
end

% Retrieve channel information
nChans = omeMeta.getPixelsSizeC(0).getValue();
try
    for i = 1:nChans
        currFluor = omeMeta.getChannelFluor(0, i-1).toCharArray()';
        currFluor = matlab.lang.makeValidName(currFluor);
        channels.(currFluor) = i;
    end
catch
    channels = [];
end

end