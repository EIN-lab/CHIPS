function plot_traces_heatmap(self, traces, hAxTraces, params)

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

% Create the images to plot
cmap = utils.cubehelix(256, 0.25, -0.9, 1.25, 1, [0, 0.99]);
imgToUse = utils.sc_pkg.sc(traces', cmap);
hasExistData = ~isscalar(self.data.tracesExist);
if hasExistData
    imgToUse = imgToUse .* repmat(self.data.tracesExist', [1, 1, 3]) + ...
    utils.sc_pkg.sc(traces', 'gray') .* ...
        repmat(~self.data.tracesExist', [1, 1, 3]);
end

% Plot the images
nROIs = numel(params.plotROIs);
imagesc(self.data.time, 1:nROIs, imgToUse, 'Parent', hAxTraces)

end