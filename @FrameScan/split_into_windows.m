function [windows, time, yPos] = split_into_windows(self, windowTime, ...
    nOverlap)
%split_into_windows  - Split the raw image data into windows
%
%   [WINDOWS, TT, YY] = split_into_windows(OBJ, T_WINDOW, N_OVERLAP) splits
%   the raw image data into a matrix WINDOWS, and also returns the time
%   value (TT) and vertical position (YY) associated with each window.
%
%   See also FrameScan.channelStreak, FrameScan.colsToUseVel,
%   ICalcVelocityStreaks, CalcVelocityStreaks

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

    % Check the number of input arguments
    narginchk(3, 3);

    % Extract data from the metadata
    lineTime = self.rawImg.metadata.lineTime;
    nFrames = self.rawImg.metadata.nFrames;
    pixelSize = self.rawImg.metadata.pixelSize;

    % Calculate the number of lines per window, based on the input,
    % and recalculate the actual windowTime
    windowLines = round(windowTime/lineTime);

    % Work out the columns and rows to use
    colsToUse = self.colsToUseVel(1) : self.colsToUseVel(2);
    rowsToUse = self.rowsToUseVel(1) : self.rowsToUseVel(2);
    
    % Loop through each frame and create the windows
    for iFrame = 1:nFrames
        
        % Extract only the relevant part of this frame
        imgTemp = self.rawImg.rawdata(rowsToUse, colsToUse, ...
            self.channelStreak, iFrame);
        
        if iFrame == 1
            
            % Create the first windows so we can preallocate memory
            [windowsTemp, yPosRaw] = utils.split_into_windows(imgTemp, ...
                nOverlap, windowLines);
            [winRows, winCols, winPerFrame] = size(windowsTemp);
            nWindows = nFrames*winPerFrame;
            windows = zeros(winRows, winCols, nWindows);
            windows(:,:,1:winPerFrame) = windowsTemp;
            
            % Calculate the y position at the centre of each window
            yPos = repmat(yPosRaw, [nFrames, 1])';
            yPos = (rowsToUse(1) + yPos(:)) .* pixelSize;
            
            % Calculate the time at the centre of each window
            timeWindow = 1E-3*lineTime*yPosRaw;
            timeFrame = (1/self.rawImg.metadata.frameRate)* ...
                repmat(0:nFrames-1, winPerFrame, 1);
            time = bsxfun(@plus, timeWindow, timeFrame);
            time = time(:);
            
            % Supress these warnings after the first window since they'll
            % all be the same anyway.
            % Turn off unneeded warnings for now
            [lastMsgPre, lastIDPre] = lastwarn();
            wngIDOff = {'GetWindow:ExtendWindow', ...
                'GetWindow:TooBigWindow'};
            wngState = warning('off', wngIDOff{1});
            warning('off', wngIDOff{2})
            
        else
            
            % Finish extracting the rest of the windows
            winIdxs = (iFrame-1)*winPerFrame + 1 : winPerFrame*iFrame;
            windows(:,:,winIdxs) = utils.split_into_windows(imgTemp, ...
                nOverlap, windowLines);
            
        end

    end
    
    % Restore the warning state
    warning(wngState);
    utils.clear_unwanted_wngs(wngIDOff, lastMsgPre, lastIDPre)

end