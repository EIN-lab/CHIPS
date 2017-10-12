function varargout = plot_signals(self, objPI, varargin)

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
    'annotateSigs' ...
    };
pValues = {
    []; ...
    true ...
    };
dflts = cell2struct(pValues, pNames);
params = utils.parse_params(dflts, varargin{:});

% Check for the signal processing toolboxes
flagVersion = CalcDetectSigsClsfy.check_version();

% Check that there is ROI data to plot
% Check/get the plotROIs and number of ROIs
nROIs_req = numel(params.plotROIs);
if ~nROIs_req
    warning('CalcDetectSigs:PlotSignals:NoROIsFound', ...
        'Can''t draw plot, because no ROIs were identified.');
    varargout{1} = [];
    return
end

% Extract some data from the ProcessedImg
tracesNorm = objPI.calcMeasureROIs.data.tracesNorm;
frameRate = objPI.rawImg.metadata.frameRate;
roiNames = objPI.calcFindROIs.data.roiNames;
doPlot = true;
fBand = self.get_fBand(frameRate);

% Loop through and plot the ROIs
for iROI = 1:nROIs_req

    currROI = params.plotROIs(iROI);

    % Retrieve or create ROI name
    if isempty(roiNames) || isempty(roiNames{currROI})
        roiName{1} = sprintf('ROI %03d', currROI);
    else
        roiName = roiNames(currROI);
    end

    % Call this function to do the plotting
    [~, hFig{currROI}] = self.peakClassMeasure(...
        tracesNorm(:, currROI), frameRate, fBand, ...
        roiName, doPlot, flagVersion);
    
    % Annotate signals
    if params.annotateSigs
        self.annotate_signals(objPI, hFig{currROI}, currROI, params)
    end
    
end

% Setup the output arguments
if nargout > 0
    varargout{1} = [hFig{:}];
end

end
