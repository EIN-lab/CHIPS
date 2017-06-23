function varargout = plot_default(self, objPI, hdlGraphsTime, varargin)

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
    'isDebug'
    };
pValues = {
    true
    };
dflts = cell2struct(pValues, pNames);
params = utils.parse_params(dflts, varargin{:});

% Check the arguments
utils.checks.scalar_logical_able(params.isDebug);

% Work out the number of rows, graphs, and cols
if params.isDebug
    nRows = self.data.nPlotsDebug + 1;
else
    nRows = self.data.nPlotsGood + 1;
end
nGraphs = nRows - 1;
nCols = 1;

% Plot the diameter image
hdlDiamImg = subplot(nRows, nCols, 1);
self.plot_diam_profile(objPI, hdlDiamImg, varargin{:})

% Generate the handles for the time series graphs
if isempty(hdlGraphsTime)
    for iGraph = nGraphs:-1:1
        hdlGraphsTime(iGraph) = subplot(nRows, nCols, ...
            nCols*(iGraph + 1));
    end
end

% Plot the time series graphs
self.plot(objPI, hdlGraphsTime, 'graphs', varargin{:})

% Link the axes
hAx = [hdlDiamImg, hdlGraphsTime];
linkaxes(hAx, 'x')

% Return the axes handle if asked for
if nargout > 0
    varargout{1} = hAx;
end

end