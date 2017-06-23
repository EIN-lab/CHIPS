function [plotROIs, nROIs] = get_plotROIs(self, plotROIs)
%get_plotROIs - Check and/or return the ROI numbers to plot
%
%   ROIS = get_plotROIs(OBJ) returns a vector containing the ROIS that can
%   be used for plotting.  In most cases, this will be all the ROIs that
%   were detected.
%
%   ROIS = get_plotROIs(OBJ, ROIS) checks the ROIs and returns only those
%   that are valid.
%
%   [ROIS, NROIS] = get_plotROIs(...) also returns the total number of ROIs
%   that exist, which is useful for producing colormaps etc.
%
%   See also CalcMeasureROIs.plot, DataMeasureROIs

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

    % Check that there is ROI data to plot
    if isscalar(self.data.traces)
        nROIs = 0;
    else
        nROIs = size(self.data.traces, 2);
    end
    if ~nROIs
        warning('CalcMeasureROIs:PlotTraces:NoROIsFound', ['Can''t ', ...
            'draw plot, because no ROIs were identified.']);
        return
    end

    % When no ROIs are specified, we just choose all of them
    if isempty(plotROIs)
        plotROIs = 1:size(self.data.traces, 2);
    end
    
    % Check whether the user tried to specify one or more nonexistent ROIs
    badROIs = ~ismember(plotROIs, 1:nROIs);
    hasBadROIs = any(badROIs);
    if hasBadROIs
        
        % Identify the out of bounds ROIs
        outOfBounds = plotROIs(badROIs);
        
        if length(outOfBounds) < length(plotROIs)
            
            % Warn the user and remove any out of bounds ROIs 
            warning('CalcMeasureROIs:PlotTraces:SomeInexistentROIProvided', ...
                ['The ROI(s)', sprintf(' %d ', outOfBounds), ...
                'didn''t exist. Skipped those.']);
            plotROIs = plotROIs(~ismember(plotROIs, outOfBounds));
            
        else
            
            % Give an error if there are no ROIs left
            error('CalcMeasureROIs:PlotTraces:AllInexistentROIProvided', ...
                ['None of the specified ROI(s)', ...
                sprintf(' %d ' , outOfBounds), 'do exist.', ...
                ' The identified number of ROIs for this image is', ...
                sprintf(' %d', nROIs)]);
            
        end
    end

end