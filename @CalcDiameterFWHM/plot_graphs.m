function varargout = plot_graphs(self, ~, hAx, varargin)

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

% Check handle, making a new one if necessary
if isempty(hAx)
    hAx = gca();
else
    % Otherwise check that it's an axes
    utils.checks.hghandle(hAx, 'axes', 'hAx');
    utils.checks.scalar(hAx, 'axes')
end

% Plot the time series graphs
self.data.plot_graphs(hAx, 'time', [], 'debug', params.isDebug)
xlabel(hAx(end), 'Time [s]')

% Return the axes handle if asked for
if nargout > 0
    varargout{1} = hAx;
end

end