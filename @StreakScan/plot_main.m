function varargout = plot_main(self, varargin)

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
    'doPics';
    'doYPos';
    'isDebug';
    'nPlotSQRT'
    };
pValues = {
    true;
    true;
    true;
    4
    };
dflts = cell2struct(pValues, pNames);
params = utils.parse_params(dflts, varargin{:});

% Check arguments
utils.checks.scalar_logical_able(params.isDebug);
utils.checks.scalar_logical_able(params.doPics);

% Work out if there is a reference image
hasFrame = false;

% Work out the initial number of rows 
if params.isDebug
	nRows = self.calcVelocity.data.nPlotsDebug;
else
	nRows = self.calcVelocity.data.nPlotsGood;
end

% Work out some more initial values
nCols = 1;
nGraphs = nRows;
rowGraphStart = 1;
hAxLink = [];

% Generate the handles and plot the images
if params.doPics
    
    if hasFrame
        
        % Add a column for the images
        nCols = 2;
        
        % Plot the frame image
        hdlFrameImg = subplot(nRows, nCols, 1 : 2 : nRows*nCols-3);
        self.plot_frame(hdlFrameImg, params.isDebug)
        
        % Generate the handle for the streak image
        hdlStreakImg = subplot(nRows, nCols, nRows*nCols-1);
        
    else
        
        % Add an extra row (at the top) for the streak scan
        nRows = nRows + 1;
        rowGraphStart = rowGraphStart + 1;
        
        % Generate the handle for the streak image
        hdlStreakImg = subplot(nRows, nCols, 1);
        
    end
    
    % Plot the streak image
    self.plot_streaks(hdlStreakImg, params.isDebug)
    
    % Link the streak scan axes to the graphs
    hAxLink = [hAxLink, hdlStreakImg];
    
end

% Generate the handles for the time series graphs
for iGraph = nGraphs:-1:1
    hdlGraphs(iGraph) = subplot(nRows, nCols, ...
        nCols*(rowGraphStart +  iGraph - 1));
end
hAxLink = [hAxLink, hdlGraphs];

% Plot the time series graphs
self.calcVelocity.plot(self, hdlGraphs, 'graphs', varargin{:});
xlabel(hdlGraphs(end), 'Time [s]')
if params.isDebug
    axes(hdlGraphs(end)), hold on
    plot(get(hdlGraphs(end), 'xlim'), ...
        ones(1,2)*self.calcVelocity.config.thresholdSNR, 'k-')
    hold off
    ylim(hdlGraphs(end), [0 inf])
end

% Link the axes
linkaxes(hAxLink, 'x')

% Return the axes handle if asked for
if nargout > 0
    varargout{1} = hAxLink;
end

end