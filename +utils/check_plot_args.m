function [hHG, plotName, idxStart] = check_plot_args(validPlotNames, ...
    args, hgType)
%check_plot_args - Helper function to check and return plot arguments
%
%   This function is not intended to be called directly.

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

% Check the number of input arguments
narginchk(3, 3);

% Setup the defaults
hHG = [];
plotName = 'default';
idxStart = 1;

% Assign/create the figure handle, and make it the current figure
hasHG = (numel(args) > 0) && ((all(ishghandle(args{1})) && ...
    all(strcmp(get(args{1}, 'type'), hgType))) || isempty(args{1}));
if hasHG
    hHG = args{1};
    idxStart = idxStart + 1;
end

% Some extra tests for figures
if strcmpi(hgType, 'figure')
    % Create the figure, if one doesn't exist, and make it current
    if isempty(hHG)
        hHG = figure();
    elseif ~isscalar(hHG)
        error('CheckPlotArgs:NonScalarHFig', ...
            'The figure handle must be scalar')
    end

    % Only display figure, if it hasn't been set invisible before
    isDefaultInvisible = strcmpi(get(groot,'defaultFigureVisible'),'off');
    isFigureInvisible = strcmpi(hHG.Visible, 'off');
    if ~isDefaultInvisible && ~isFigureInvisible
        figure(hHG);
    end    
end

% Work out the plotName
hasPlotName = (numel(args) > (idxStart - 1)) && ischar(args{idxStart}) && ...
    ismember(lower(args{idxStart}), validPlotNames);
if hasPlotName
    plotName = lower(args{idxStart});
    idxStart = idxStart + 1;
end

end