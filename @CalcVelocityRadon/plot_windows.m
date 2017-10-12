function hAx = plot_windows(self, objPI, hAx, varargin)

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

    % Extract some data from the ProcessedImg object
    fWindows = @(windowTime, nOverlap) ...
        split_into_windows(objPI, windowTime, nOverlap);
    isDarkStreaks = objPI.isDarkStreaks;
    pixelSize = objPI.rawImg.metadata.pixelSize;
    lineTime = objPI.rawImg.metadata.lineTime;
    pixelTime = CalcVelocityRadon.get_pixelTime(objPI, lineTime);

    % Split the long data format into windows
    windows = fWindows(self.config.windowTime, ...
        self.config.nOverlap);
    nWindows = size(windows, 3);

    % Work out which windows to use
    nWindowsPlot = params.nWindowsSQRT^2;
    windowNums = round(linspace(1, nWindows, nWindowsPlot + 2));
    windowNums = windowNums(2:end-1);

    % Check handle, making a new one if necessary
    if isempty(hAx)
        gap = [0.02, 0.02];
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

    % Check that we have the appropriate toolboxes
    className = 'CalcVelocityRadon';
    featureSig = 'Signal_Toolbox';
    toolboxdirSig = 'signal';
    verSig = '6.22';
    isOldToolbox = utils.verify_license(featureSig, className, ...
        toolboxdirSig, verSig) < 1;

    % Loop through the windows
    doPlotRadon = false;
    doPlotWindow = true;
    doPlotScale = true;
    for iWindow = 1:nWindowsPlot;

        axes(hAx(iWindow)) %#ok<LAXES>

        % Extract the current window number
        iWindowNum = windowNums(iWindow);

        % Calculate the theta range that was supplied to the
        % calc_angle_radon function
        rangeTheta = self.makeFineRange(...
            self.data.thetaRangeMid(iWindowNum));

        % Plot the window
        [~, ~, ~] = self.calc_angle_radon(...
            windows(:,:,iWindowNum), rangeTheta, isDarkStreaks, ...
            pixelSize, lineTime, pixelTime, isOldToolbox, doPlotRadon, ...
            doPlotWindow, doPlotScale);

        doPlotScale = false;

    end

end