function plot_traces_lines(self, traces, hAxTraces, params)

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

% Count the number of ROIs and set up the colorscheme
nROIs = numel(params.plotROIs);
nROIsTotal = size(self.data.traces, 2);
cmap = utils.get_ROI_cmap(nROIsTotal);
cGray = [0.5, 0.5, 0.5];

% Adjust the traces appropriately
tracesAdj = utils.adjust_traces(traces(:, params.plotROIs), ...
    params.spacingFactor);

% Plot the traces
hasExistData = ~isscalar(self.data.tracesExist);
for iROI = 1:nROIs

    isFirst = iROI == 1;
    if isFirst
        hold(hAxTraces, 'on')
    end

    % Plot the trace
    currROI = params.plotROIs(iROI);
    if ~hasExistData
        plot(hAxTraces, self.data.time, tracesAdj(:, iROI), ...
            'Color', cmap(currROI, :))
    else
        maskExist = self.data.tracesExist(:,currROI);
        plot(hAxTraces, self.data.time, tracesAdj(:, iROI), ...
            'Color', cGray)
        plot(hAxTraces, self.data.time(maskExist), ...
            tracesAdj(maskExist, iROI), 'Color', cmap(currROI, :))
    end

end

hold(hAxTraces, 'off')

end