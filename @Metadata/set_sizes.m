function self = set_sizes(self, imgSize)
%set_sizes - Protected class method to set the image size properties

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
%   along with this program.  If not, see <http://www.gnu.org/licenses/>

    % Check it's a correctly sized array (at least 2 dims to make 
    % it an image, no more than 4 dims at the moment)
    imgSize = imgSize(:);
    nDims = length(imgSize);
    isCorrectSize = (nDims >= 2) && (nDims <= 4);
    if ~isCorrectSize
        error('Metadata:SetSizes:BadNumberOfDims', ['The image' ...
            'should have 2-4 dimensions, and you have supplied ' ...
            'data for %d dimension(s)'], nDims)
    end

    % Assign the values
    self.nLinesPerFrame = imgSize(1);
    self.nPixelsPerLine = imgSize(2);
    if nDims > 2
        self.nChannels = imgSize(3);
        if nDims > 3
            self.nFrames = imgSize(4);
        else
            self.nFrames = 1;
        end
    else
        self.nChannels = 1;
    end
    
    % Check if it looks like the aspect ratio is different.  Note, this
    % only uses the number of pixels, since I can't see any metadata from
    % ScanImage that records the pixel aspect ratio.  So, images could be
    % rectangular but have the same number of rows and columns, and we
    % wouldn't know.
    apparentAR = self.nPixelsPerLine / self.nLinesPerFrame;
    isNonSquare = (apparentAR < 0.99) || (apparentAR > 1.01);
    if isNonSquare
        warning('Metadata:SetSizes:NonSquare', ['The image appears to ' ...
            'have a pixel aspect ratio other than 1 (i.e. the pixels '...
            'may be rectangular, rather than square).  This software ' ...
            'currently does not account for pixel aspect ratios other ' ...
            'than 1, so certain algorithms may produce incorrect ' ...
            'results.  Please check the output carefully.'])
    end

end