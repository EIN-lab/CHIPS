function varargout = plot_signals(self, objPI, varargin)
%
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
    'plotROIs'; ...
    };
pValues = {
    []; ...
    };
dflts = cell2struct(pValues, pNames);
params = utils.parse_params(dflts, varargin{:});

% Check for the signal processing toolboxes
flagVersion = CalcDetectSigsCellSort.check_version();

% Check that there is ROI data to plot
% Check/get the plotROIs and number of ROIs
nROIs_req = numel(params.plotROIs);
if ~nROIs_req
    warning('CalcDetectSigs:PlotSignals:NoROIsFound', ...
        'Can''t draw plot, because no ROIs were identified.');
    varargout{1} = [];
    return
end

% --------------------------------------------------------- %
%Check for valid find/detect combination
is_invalid_combination = 0;
if  isa(self, 'CalcDetectSigsCellSort') && ...
    ~isa(objPI.calcFindROIs, 'CalcFindROIsCellSort')
    is_invalid_combination = 1;
end

if is_invalid_combination
    warning('CellScan:PlotSignals:WrongClassCalc', ['The valid calcFind '...
        'for "DetectSigsCellSort", is "FindROIsCellSort", whereas ' ...
        'the supplied calc is of class "%s".' ...
        'The signals will not be detected.'], ...
        class(objPI.calcFindROIs))
    varargout{1} = [];
    return
end
% --------------------------------------------------------- %
% MH - 10/11/2017 - Plotting w/ opt_config broken
hFig = figure('Name', objPI.name);
hAx = self.plot_ICAsigs(objPI, [], params);

% Setup the output arguments
if nargout > 0
    varargout{1} = get(hAx, 'parent');% [hAx]
end

end
