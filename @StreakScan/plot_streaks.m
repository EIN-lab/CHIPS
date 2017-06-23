function plot_streaks(self, varargin)

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
   
% Parse arguments
[hdlStreakImg, isDebug] = utils.parse_opt_args({[], true}, varargin);

% %%%%%%%%%%%%%%%%% Check handle, and make a new figure + axes handle if
if isempty(hdlStreakImg)
    figure
    hdlStreakImg = axes();
end

% Check isDebug format
utils.checks.scalar_logical_able(isDebug, 'isDebug');

% Work out how much of the image to show
if isDebug
    % Whole image
    colsToUse = 1 : self.rawImg.metadata.nPixelsPerLine;
    nColsToUse = self.rawImg.metadata.nPixelsPerLine;
else
    % Only the part we used
    colsToUse = self.colsToUseVel(1) : self.colsToUseVel(2);
    nColsToUse = self.colsToUseVel(2) - self.colsToUseVel(1) + 1;
end

% Extract the image data     
imgData = utils.reshape_to_long(self.rawImg.rawdata, ...
    self.channelStreak, colsToUse)';

% Setup the distance axis 
distanceAxis = self.rawImg.metadata.pixelSize*(1:nColsToUse-1);

% Plot the image
axes(hdlStreakImg)
imagesc(self.calcVelocity.data.time, distanceAxis, imgData)
colormap('gray')
hold on

ylabel('Distance [um]')

% Show the colsToUseVel on the image
if isDebug
    xLims = [min(self.calcVelocity.data.time) ...
        max(self.calcVelocity.data.time)];
    for iEdge = 1:2
        plot(xLims, self.rawImg.metadata.pixelSize* ...
            self.colsToUseVel(iEdge)*ones(1, 2), 'b--', 'LineWidth', 1)
    end
end

axis tight
hold off

end