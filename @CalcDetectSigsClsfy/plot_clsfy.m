function varargout = plot_clsfy(self, hAxes, varargin)

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

    % Check the number of arguments
    narginchk(2, inf);

    % Check the axes
    nRows = 3;
    nCols = 3;
    nBoxes = 6;
    nAxes = nBoxes + 1;
    if isempty(hAxes)

        % Create them if necessary
        mPie = 0.01;
        mBoxes = [0.02 0.07];
        hAxes(1) = utils.subplot_tight(nRows, nCols, ...
            1:nCols, mPie);
        for iBox = 1:nBoxes
            hAxes(iBox+1) = utils.subplot_tight(nRows, nCols, ...
                iBox+3, mBoxes);
        end

    else

        % Otherwise check that they're axes and there are 3 of them
        utils.checks.hghandle(hAxes, 'axes', 'hAxes');
        utils.checks.numel(hAxes, nAxes, 'hAxes')

    end

    % Setup the output arguments
    if nargout > 0
        varargout{1} = [];
    end

    hasNoPeaks = (numel(self.data.peakType) == 1) && ...
        (isempty(self.data.peakType{1}));
    if ~hasNoPeaks

        % Plot pie chart
        [pLabels, ~, idxs] = unique(self.data.peakType);
        nTypes = numel(pLabels);
        pNum = accumarray(idxs(:),1,[],@sum); 
        pLabelsBlank = repmat({''}, [1, nTypes]);
        pie(hAxes(1), pNum, pLabelsBlank);
        colormap(hAxes(1), 'gray')

        % Add a legend
        pNumCell = cellfun(@(xx) num2str(xx), num2cell(pNum), ...
            'UniformOutput', false);
        pLabels = strcat(pLabels(:), ' (', pNumCell(:), ')');
        hLeg = legend(hAxes(1), pLabels, 'Location', 'EastOutside');
        box(hLeg, 'off')
        set(hLeg, 'Color', 'none')

    else

        % Plot something so the user knows there's no peaks
        text(0.5, 0.5, 'No Peaks!', 'FontSize', 16, ...
            'Parent', hAxes(1), 'FontName', 'Arial', ...
            'HorizontalAlign', 'Center', ...
            'VerticalAlign', 'Middle')
        set(hAxes(1), 'Color', 'none')
        axis(hAxes(1), 'off')

    end

    % Plot the boxplots
    self.data.plot_graphs(hAxes(2:7));
    set(hAxes(2:7), 'Color', 'none')

end