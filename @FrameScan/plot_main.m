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
    };
pValues = {
    true;
    true;
    true;
    };
dflts = cell2struct(pValues, pNames);
params = utils.parse_params(dflts, varargin{:});

% Work out the number of rows and graphs
if params.isDebug
    nRows = self.calcVelocity.data.nPlotsDebug + 1;
else
    nRows = self.calcVelocity.data.nPlotsGood + 1;
end
nGraphs = nRows - 1;
hAxLinkTime = [];

% Create a new figure
if nargout > 0
    varargout{1} = hFig;
end

if params.doPics
    
    % Work out which column the graphs go in
    colGraphs = 2;
    
    if params.doYPos
        
        % Work out the number of cols
        nCols = 3;
        
        % Generate the handle for the frame and diameter image
        hdlFrameImg = subplot(nRows, nCols, ...
            1 : nCols : 1 + (nRows - 2)*nCols);
        hdlDiamImg = subplot(nRows, nCols, nCols);
        
    else
        
        % Work out the number of cols
        nCols = 2;
        
        % Generate the handle for the frame and diameter image
        hdlFrameImg = subplot(nRows, nCols, ...
            1 : nCols : 1 + (nRows - 3)*nCols);
        hdlDiamImg = subplot(nRows, nCols, 1 + (nRows - 2)*nCols);
        
    end
    
    % Plot the frame image
    self.plot_frame(hdlFrameImg, params.isDebug)
    
    % Plot the streak image
    hdlStreakImg = subplot(nRows, nCols, 1 + (nRows - 1)*nCols);
    self.plot_streaks(hdlStreakImg, params.isDebug)
    
    % Link the diameter and streak scan axes to the graphs
    hAxLinkTime = [hAxLinkTime, hdlDiamImg, hdlStreakImg];
    
else
    
    % Work out which column the graphs go in
    colGraphs = 1;
    
    if params.doYPos
        
        % Work out the number of cols and prepare for the diameter image
        nCols = 2;
        hdlDiamImg = subplot(nRows, nCols, nCols);
        
    else
        
        % Work out the number of cols
        nCols = 1;
        
    end
    
    % Link the diameter axis to the graphs
    hAxLinkTime = [hAxLinkTime, hdlDiamImg];
    
end

% Plot the diameter image
self.calcDiameter.plot(self, hdlDiamImg, 'diam_profile', varargin{:});

% Generate the handle for and plot the diameter time series graph
hdlDiamGraph = subplot(nRows, nCols, colGraphs);
self.calcDiameter.plot(self, hdlDiamGraph, 'graphs', varargin{:})

% Generate the handles for the time series and y position graphs
% hdlGraphsTime = zeros(nGraphs, 1);
if params.doYPos
    
%     hdlGraphsYPos = hdlGraphsTime;
    for iGraph = nGraphs:-1:1
        hdlGraphsTime(iGraph) = subplot(nRows, nCols, ...
            colGraphs + nCols*(iGraph));
        hdlGraphsYPos(iGraph) = subplot(nRows, nCols, ...
            nCols*(iGraph + 1));
    end
    
    % Plot the yPosition series graphs
    doInverse = true;
    doAverage = false;
    yLabels = repmat({'Y Position [um]'}, [1, nGraphs]);
    self.calcVelocity.data.plot_graphs(hdlGraphsYPos, 'yPosition', [], ...
        'debug', params.isDebug, 'inverse', doInverse, ...
        'average', doAverage, 'plotArgs', {'.'}, 'yLabels', yLabels)
    xlabel(hdlGraphsYPos(end), 'Metric - See Y Axis on Left')
    
    % Link the y position axes
    linkaxes(hdlGraphsYPos, 'y')
    
else
    
    % Generate the handles for the rest of the time series graphs
    hdlGraphsYPos = [];
    for iGraph = nGraphs:-1:1
        hdlGraphsTime(iGraph) = subplot(nRows, nCols, ...
            nCols*(iGraph + 1));
    end
    
end

% Plot the time series graphs
self.calcVelocity.plot(self, hdlGraphsTime, 'graphs', varargin{:})

% Link the time series axis to the graphs
hAxLinkTime = [hAxLinkTime, hdlDiamGraph, hdlGraphsTime];
linkaxes(hAxLinkTime, 'x')

% Return the axes handle if asked for
if nargout > 0
    varargout{1} = [hAxLinkTime, hdlGraphsYPos, hdlDiamGraph];
end

end

% Check:
%   - isDebug format
%   - hdl format
%   - hdl numels matches expectations (incl for isDebug if relevant)