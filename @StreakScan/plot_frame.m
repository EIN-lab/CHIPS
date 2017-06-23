function plot_frame(self, varargin)

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
[hdlFrameImg, isDebug] = utils.parse_opt_args({[], true}, varargin);

% %%%%%%%%%%%%%%%%% Check handle, and make a new figure + axes handle if
if isempty(hdlFrameImg)
    figure
    hdlFrameImg = axes();
end

% Check isDebug format
utils.checks.scalar_logical_able(isDebug, 'isDebug');

plasmaChannel = self.rawImg.metadata.channels.blood_plasma;
imgData = self.rawImg.rawdata(:,:,plasmaChannel,1);

% Add the scale bar
[imgWithBar, strScale] = utils.scaleBar(imgData, ...
    self.rawImg.metadata.pixelSize);
strTitle = ['Scale Bar = ' strScale];

% Plot stuff
axes(hdlFrameImg)  
imagesc(imgWithBar);
hold on
axis tight, axis image, axis off
colormap('gray')
title(strTitle)
hold off

end

