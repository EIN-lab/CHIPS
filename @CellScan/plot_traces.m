function plot_traces(self, varargin)

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
  
% Work out if we have the axes
idxStart = 1;
hAxTraces = [];
hasAxes = (nargin > 1) && all(ishghandle(varargin{1}));
if hasAxes
    idxStart = 2;
    hAxTraces = varargin{1};
end

% Setup the default parameter names and values
pNames = {
        'doHeatmap';...
        'doWholeFrame'; ...
        'normTraces'; ...
        'plotROIs'; ...
        'spacingFactor' ...
        };
    pValues = {
        [];
        true; ...
        true; ...
        []; ...
        1 ...
        };
dflts = cell2struct(pValues, pNames);
params = utils.parse_params(dflts, varargin{idxStart:end});

% Check/get the plotROIs, doHeatmap and number of ROIs
params.plotROIs = self.calcMeasureROIs.get_plotROIs(params.plotROIs);
params.doHeatmap = self.calcMeasureROIs.get_doHeatmap(params.doHeatmap, ...
    numel(params.plotROIs));

% Do the main plotting
hAxTraces = self.calcMeasureROIs.plot(self, hAxTraces, 'traces', params);
if isempty(hAxTraces)
    hAxAnnotate = hAxTraces;
else
    if params.doWholeFrame
        hAxAnnotate = hAxTraces(end);
    else
        hAxAnnotate = hAxTraces(1);
    end
end


% Annotate the traces with any signals
wngState = warning('off', 'CalcDetectSigsDummy:AnnotateTraces:NoClsfy');
self.calcDetectSigs.plot(self, hAxAnnotate, 'annotations', params);
warning(wngState)

end
