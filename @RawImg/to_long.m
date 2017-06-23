function to_long(self)
%to_long - Convert the images to long format
%
%   to_long(OBJ) converts the rawdata of the RawImg object to long format.
%   That is, the image lines are rearranged into a single, long image
%   frame.  This is useful when working with image types that are
%   line-based instead of frame-based (e.g. line scans).
%
%   See also utils.reshape_to_long, RawImgComposite.to_long.

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

    % Call the function one by one if we have an array
    if ~isscalar(self)
        arrayfun(@to_long, self);
        return
    end

    % Reshape the image to long (i.e. making it one long image)
    self.rawdata_actual = utils.reshape_to_long(self.rawdata_actual);
    
    % Turn off unneeded warnings for now
    [lastMsgPre, lastIDPre] = lastwarn();
    wngIDOff = 'Metadata:SetSizes:NonSquare';
    wngState = warning('off', wngIDOff);

    % Update the metadata to reflect the new image size
    imgSizeNew = size(self.rawdata_actual);
    acqIn = self.metadata.get_acq();
    channelsIn = self.metadata.channels;
    calibrationIn = self.metadata.calibration;
    metadataNew = Metadata(imgSizeNew, acqIn, channelsIn, calibrationIn);
    self.metadata = metadataNew;
    
    % Restore the warnings
    warning(wngState)
    utils.clear_unwanted_wngs(wngIDOff, lastMsgPre, lastIDPre)
    
    % Notify listeners that the method was called
    notify(self, 'ToLong')

end
