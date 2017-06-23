function varargout = plot_diam_profile(self, objPI, hAx, varargin)

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
    % Otherwise check that it's a scalar axes
    utils.checks.hghandle(hAx, 'axes', 'hAx');
    utils.checks.scalar(hAx, 'hAx')
end

% Setup the distance axis
pixelSize = objPI.rawImg.metadata.pixelSize;
distanceAxis = pixelSize*(1:size(self.data.diamProfile, 2) - 1);

% Plot stuff
axes(hAx)
imagesc(self.data.time, distanceAxis, self.data.diamProfile')
hold on
axis tight
colormap('gray')

ylabel('Y Position [um]')

if params.isDebug
    % Plot the actual edges
    for iEdge = 1:2
        plot(self.data.time, ...
            pixelSize*(self.data.idxEdges(:,iEdge) - 1), ...
            'b-', 'LineWidth', 2)
    end
end

hold off

% Return the axes handle if asked for
if nargout > 0
    varargout{1} = hAx;
end

end