function hAx = plot_windows(self, ~, hAx, varargin)

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
        'nWindowsSQRT'
        };
    pValues = {
        4
        };
    dflts = cell2struct(pValues, pNames);
    params = utils.parse_params(dflts, varargin{:});
    
    % Check for the optimization toolbox
    feature = 'Optimization_Toolbox';
    className = 'CalcVelocityLSPIV:PlotWindows';
    utils.verify_license(feature, className);

    % Work out which windows to use
    nWindows = numel(self.data.time);
    nWindowsPlot = params.nWindowsSQRT^2;
    windowNums = round(linspace(1, nWindows, nWindowsPlot + 2));
    windowNums = windowNums(2:end-1);

    % Check handle, making a new one if necessary
    if isempty(hAx)
        gap = [0.05, 0.05];
        for iGraph = nWindowsPlot:-1:1
            hAx(iGraph) = utils.subplot_tight(...
                params.nWindowsSQRT, params.nWindowsSQRT, ...
                iGraph, gap);
        end
    else
        % Otherwise check that it's a scalar axes
        utils.checks.hghandle(hAx, 'axes', 'hAx');
        utils.checks.numel(hAx, nWindowsPlot, 'hAx');
    end

    % Prepare some variables for the fit
    nPixels = size(self.data.xCorr, 2);
    maxPixelShift = round(nPixels / 2) - 1;
    idxsCorr = maxPixelShift:-1:-maxPixelShift;
    doPlot = true;
    for iWindow = 1:nWindowsPlot;

        % Extract the current window number
        iWindowNum = windowNums(iWindow);

        % Create a new subplot axes
        axes(hAx(iWindow)) %#ok<LAXES>

        % Plot the gaussian peak fitting for each window
        utils.gaussian_peakfit(self.data.xCorr(iWindowNum,:), ...
            idxsCorr, self.config.nPixelsToFit, doPlot);

    end

    % Rearrange hAx to make it easier to work with
    hAx = reshape(hAx, params.nWindowsSQRT, params.nWindowsSQRT)';

    % Add some annotations
    arrayfun(@(hh) box(hh, 'on'), hAx)
    arrayfun(@(hh) grid(hh, 'on'), hAx)
    set(hAx(1:params.nWindowsSQRT-1, :), 'XTickLabel', [])
    set(hAx(:, 2:params.nWindowsSQRT), 'YTickLabel', [])
    set(hAx, 'Color', 'none')
    hFig = get(hAx(1), 'Parent');
    utils.mtit(hFig, 'Cross Correlation (Y) vs Pixel Shift (X)')

end