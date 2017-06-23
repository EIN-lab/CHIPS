function varargout = plot_default(self, objPI, ~, varargin)
%plot - Plot a figure

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
    
% Setup the default parameter names and values
pNames = {
    'isDebug'; ...
    'FrameNum'
    };
pValues = {
    true; ...
    2
    };
dflts = cell2struct(pValues, pNames);
params = utils.parse_params(dflts, varargin{:});

% Check the optional arguments
utils.checks.prfsi(params.FrameNum, 'Frame Number');
utils.checks.scalar_logical_able(params.isDebug, 'isDebug');

% Extract some data from the ProcessedImg object
pixelSize = objPI.rawImg.metadata.pixelSize;
isDarkPlasma = objPI.isDarkPlasma;
chPlasma = objPI.rawImg.metadata.channels.blood_plasma;
imgChData = squeeze(objPI.rawImg.rawdata(:,:,chPlasma,:));

if params.isDebug
    nRows = 4;
else
    nRows = 3;
end
nCols = 6;

% Work out which image to plot (depending on if we need to
% invert the frame
strTitleRaw = sprintf('Raw Image (Frame %d)', params.FrameNum);
if ~isDarkPlasma
    imgToPlot = imgChData(:,:,params.FrameNum);
else
    imgToPlot = imgChData(:,:,params.FrameNum);
    imgToPlot = max(imgToPlot(:)) - imgToPlot;
    strTitleRaw = ['Inverted ' strTitleRaw];
end

% Add the scale bar
[imgWithBar, strScale] = utils.scaleBar(imgToPlot, pixelSize);
strTitleRaw = [strTitleRaw '. Scale Bar = ' strScale];

% Plot the original image frame
hAxOrig = subplot(nRows, nCols, [1:nCols/2, nCols+1:1.5*nCols]);
imagesc(imgWithBar);
colormap('gray')
title(strTitleRaw)
axis image, axis off

% Plot the vessel mask
hAxMask = subplot(nRows, nCols, [nCols/2+1:nCols, 1.5*nCols+1:nCols*2]);
imagesc(self.data.vesselMask(:,:,params.FrameNum))
title(sprintf('Final Mask'))
axis image, axis off

% Link the streak scan axes to the graphs
hAxLink = [hAxOrig, hAxMask];

if params.isDebug

    % Plot the radon transform image
    hAxRadon = subplot(nRows, nCols, 2*nCols+1:2*nCols+nCols*2/3);
    imagesc(self.data.imgRadon(:,:,params.FrameNum))
    hold on
    plot(self.data.idxEdgesFWHM(1,:,params.FrameNum), 'r-')
    plot(self.data.idxEdgesFWHM(2,:,params.FrameNum), 'r-')
    title(sprintf('Radon Transformed'))
    axis off

    % Plot the inverse radon transform image
    hAxInv = subplot(nRows, nCols, 2*nCols+1+nCols*2/3:3*nCols);
    imagesc(self.data.imgInvRadon(:,:,params.FrameNum))
    title(sprintf('Back-Transformed'))
    axis image, axis off
    
    % Link the streak scan axes to the graphs
    hAxLink = [hAxLink, hAxInv];

end

hAxDiam = subplot(nRows, nCols, ...
    nRows*nCols-nCols+1:nRows*nCols);
self.data.plot_graphs(hAxDiam, 'time')

% Link the image axes
linkaxes(hAxLink, 'xy')

% Pass the output argument, if required
if nargout > 0
    if params.isDebug
        hAx = [hAxOrig, hAxMask, hAxRadon, hAxInv, hAxDiam];
    else
        hAx = [hAxOrig, hAxMask, hAxDiam];
    end
    varargout{1} = hAx;
end

end