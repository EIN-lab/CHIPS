function maskOut = dilate_erode(self, maskIn, pixelSize, frameRate)
%dilate_erode - Dilate and erode ROI mask

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

    % Create the temporary mask
    maskOut = maskIn;

    % Work out if we need to continue further
    dilateXY = round(0.5*self.config.dilateXY/pixelSize);
    dilateT = round(0.5*self.config.dilateT*frameRate);
    erodeXY = round(0.5*self.config.erodeXY/pixelSize);
    erodeT = round(0.5*self.config.erodeT*frameRate);
    doDilate = (dilateXY > 0) || (dilateT > 0);
    doErode = (erodeXY > 0) || (erodeT > 0);
    if ~doErode && ~doDilate
        return
    end
    
    % Do the dilation, if necessary
    if doDilate
        seDilate = strel('disk', dilateXY);
        seDilate = seDilate.getnhood();
        if dilateT > 0 % only if temporal dilation is set
            seDilate = repmat(seDilate, [1, 1, dilateT]);
            maskOut = imdilate(maskOut, seDilate);
        end
    end
    
    % Do the erosion, if necessary
    if doErode
        seErode = strel('disk', erodeXY);
        seErode = seErode.getnhood();
        if erodeT > 0 % only if temporal dilation is set
            seErode = repmat(seErode, [1, 1, erodeT]);
            maskOut = imerode(maskOut, seErode);
        end
    end
    
end