function mask = choose_mask_imroi(self, imgType, roiFun, roiType)
%choose_mask_imroi - Protected class method to choose an individual mask
%   based on the built in imroi functions

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

% Setup the title
strInstructions = 'Double click inside to complete the ROI.';
strFigTitle = sprintf('Select a %s ROI for the %s image.\n%s', ...
    roiType, imgType, strInstructions);

% Plot the basic data
hFig = figure();
[~, hImgData] = self.plot_imgData([], strFigTitle);
axis image, axis tight, axis off

% Create the ROI and mask
hImPoly = roiFun();
wait(hImPoly);
mask = hImPoly.createMask(hImgData);

% Close the figure
close(hFig)

end