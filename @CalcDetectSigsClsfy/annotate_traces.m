function annotate_traces(self, objPI, hAxTraces, varargin)

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
    params = utils.parse_params(dflts, varargin{:});
    
    % Get/check the axes
    if isempty(hAxTraces)
        hAxTraces = gca();
    else
        % Otherwise check that it's a scalar axes
        utils.checks.hghandle(hAxTraces, 'axes', 'hAxTraces');
        utils.checks.scalar(hAxTraces, 'hAxTraces')
    end
    
    % Check/get the plotROIs and number of ROIs
    params.plotROIs = objPI.calcMeasureROIs.get_plotROIs(params.plotROIs);
    nROIs = numel(params.plotROIs);
    params.doHeatmap = objPI.calcMeasureROIs.get_doHeatmap(...
        params.doHeatmap, nROIs);
    
    % Extract out the data and adjust the traces appropriately
    time = objPI.calcMeasureROIs.data.time;
    roiNames = objPI.calcFindROIs.data.roiNames;
    if params.normTraces
        traces = objPI.calcMeasureROIs.data.tracesNorm;
    else
        traces = objPI.calcMeasureROIs.data.traces;
    end
    tracesAdj = utils.adjust_traces(traces(:, params.plotROIs), ...
        params.spacingFactor);

    % Plot the traces
    for iROI = nROIs:-1:1
        
        % Extract the current ROI and trace
        currROI = params.plotROIs(iROI);
        trace = tracesAdj(:,iROI);

        % Extract the peaks for this ROI
        peakIdxAll = strcmp(self.data.roiName, roiNames{currROI});
        peakTimesAll = [self.data.peakTime{peakIdxAll}];
        peakTypesAll = self.data.peakType(peakIdxAll);
        peakTypesUnique = unique(peakTypesAll);

        % Plot bars under the peaks to show their extents
        if ~params.doHeatmap
            peakStarts = [self.data.peakStart{peakIdxAll}];
            peakWidths = [self.data.fullWidth{peakIdxAll}];
            nPeaks = numel(peakStarts);
            minVal = utils.nansuite.nanmin(trace);
            barVal = minVal + 0.02*(utils.nansuite.nanmax(trace) - minVal);
            hold(hAxTraces, 'on')
            for iPeak = 1:nPeaks
                xPeak = peakStarts(iPeak) + [0, peakWidths(iPeak)];
                yPeak = barVal*ones(1, 2);
                utils.patchline(xPeak, yPeak, ...
                    'EdgeColor', [0.5, 0.5, 0.5], 'LineWidth', 2, ...
                    'EdgeAlpha', 0.5, 'Parent', hAxTraces);
            end
            hold(hAxTraces, 'off')
        end
        
        % Plot letters to show the types of the peaks
        nPeakTypes = numel(peakTypesUnique);
        for iPeakType = 1:nPeakTypes
            
            % Work out where to plot the peaks
            peakType = peakTypesUnique{iPeakType};
            peakIdx = ~cellfun(@isempty, strfind(peakTypesAll, ...
                peakType));
            peakTimes = peakTimesAll(peakIdx);
            if params.doHeatmap
                vAlign = 'Middle';
                peakVals = iROI*ones(size(peakTimes));
                colTxt = 'r';
            else
                vAlign = 'Bottom';
                peakVals = interp1(time, trace, peakTimes);
                colTxt = 'k';
            end
            
            % Work out what to plot
            switch peakType
                case 'SinglePeak'
                    mkr = 'S';
                case 'MultiPeak'
                    mkr = 'M'; 
                case 'Plateau'
                    mkr = 'P';
                case 'Unclassified'
                    mkr = 'U';
                otherwise
                    continue
            end
            
            % Plot the labels
            text(peakTimes, peakVals, mkr, ...
                'Parent', hAxTraces, 'FontName', 'Arial', ...
                'HorizontalAlign', 'Center', ...
                'VerticalAlign', vAlign, 'Color', colTxt)
            
        end

    end

end