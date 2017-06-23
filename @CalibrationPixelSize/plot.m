function varargout = plot(self, varargin)
%plot - Plot CalibrationPixelSize objects
%
%   plot(OBJ) produces a plot of the CalibrationPixelSize object OBJ.
%
%   plot(OBJ, DOSAVE) specifies whether to save the plot to a file.  DOSAVE
%   must be a scalar value convertible to a logical.  The function will 
%
%   plot(OBJ, DOSAVE, FILENAME) also specifies the filename for the figure.
%   At this time, only pdf files are supported.

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
%   along with this program.  If not, see <http://www.gnu.org/licenses/>

    % Call the function one by one if we have an array
    if ~isscalar(self)
        arrayfun(@(xx) plot(xx, varargin{:}), self);
        return
    end

    % Parse arguments
    [doSavePlot, fnFig] = utils.parse_opt_args({false, ''}, ...
        varargin);
    
    % Check the input arguments
    utils.checks.scalar_logical_able(doSavePlot);
    if ~isempty(fnFig), utils.checks.single_row_char(fnFig); end
    
    % Extract the string of the calibration function
    if ~isempty(self.funFitted)
        [~, calFunction] = self.funFitted(1);
    else
        calFunction = [];
    end

    % Setup the figure
    hFig = gcf;
    if nargout > 0
        varargout{1} = hFig;
    end
    imgWidth = 900;
    imgHeight = 350;
    oldUnits = get(hFig, 'Units');
    set(hFig, 'Units', 'Points', 'PaperUnits', 'Points')
    set(hFig, 'PaperSize', [imgWidth, imgHeight], ...
        'PaperPosition', [0, 0, imgWidth, imgHeight])
    set(hFig, 'Position', [50, 50, imgWidth, imgHeight])
    set(hFig, 'Units', oldUnits)

    % Setup the subfigures
    nRows = 1;
    nCols = 3;
    propsAxes = {'FontSize', 12, 'Box', 'On'};

    % Prep some data for the first plot
    nPoints = 100;
    zoomPlot = linspace(min(self.zoom), max(self.zoom), nPoints);
    pixelSizePlot = self.funFitted(zoomPlot);
    xText = 0.9*max(self.zoom);
    yText = 0.5*max(self.pixelSize);
    strText = sprintf('%s', ['$' calFunction '$']);

    % Plot the pixelSize vs zoom graph
    subplot(nRows, nCols, 1, propsAxes{:})
    hold on
    xlim([0 1.1*max(self.zoom)])
    plot(self.zoom, self.pixelSize, 'bx', 'MarkerSize', 7)
    plot(zoomPlot, pixelSizePlot,'r-')
    hText = text(xText, yText, strText);
    set(hText, 'FontSize', 12, 'HorizontalAlignment', 'right', ...
        'Interpreter', 'LaTeX')
    xlabel('Zoom')
    ylabel('Pixel Size [microns]')
    legend('Measured Values', 'Fitted Curve')
    legend('boxoff')
    hold off

    % Prep some data for the second plot
    pixelSizeFit = self.funFitted(self.zoom);
    xlimsPS = [min(self.pixelSize)*0.9 max(self.pixelSize)*1.1];
    ylimsPS = [min(pixelSizeFit)*0.9 max(pixelSizeFit)*1.1];
    strTitle = sprintf(['Pixel Size Calibration of the %s ' ...
        'Objective for an Image with %d Pixels per Line'], ...
        self.objective, self.imgSize);

    % Plot the measured vs fitted pixelSize graph
    subplot(nRows, nCols, 2, propsAxes{:}, 'XScale', 'log', ...
        'YScale', 'log')
    hold on
    plot(xlimsPS, ylimsPS, 'k:')
    plot(self.pixelSize, pixelSizeFit, 'b+')
    title(strTitle, 'FontSize', 14, 'FontWeight', 'bold')
    xlabel('Measured Pixel Size [microns]')
    ylabel('Fitted Pixel Size [microns]')
    hold off


    % Prep some data for the third plot
    pixelSizeResiduals = (pixelSizeFit - self.pixelSize)*10^3;
    maxVal = 1.1*max(abs(pixelSizeResiduals));
    if ~(maxVal == 0)
        ylimsResiduals = [-maxVal maxVal];
    else
        ylimsResiduals = [-inf, +inf];
    end

    % Plot the residuals graph
    subplot(nRows, nCols, 3, propsAxes{:}, 'XScale', 'log')
    hold on
    ylim(ylimsResiduals)
    xlim(xlimsPS)
    plot(xlimsPS, zeros(size(xlimsPS)), 'k-')
    plot(self.pixelSize, pixelSizeResiduals, 'bx', 'MarkerSize', 7)
    xlabel('Measured Pixel Size [microns]')
    ylabel('Residuals [nm]')
    hold off

    % Prepare the filename
    if doSavePlot && isempty(fnFig)
        
        % Prompt the user to select a filename
        filterspec = {'*.pdf', 'Portable Document Format (*.pdf)'};
        strSaveTitle = 'Save the calibration figure as...';
        [fnFig, pathFig, ~] = uiputfile(filterspec, ...
            strSaveTitle);
        
        % Throw an error if user cancelled, otherwise return filename
        hasCancelled = ~ischar(fnFig) && (fnFig == 0) && (pathFig == 0);
        if hasCancelled
            error('CalibrationPixelSize:Plot:DidNotChooseFile', ...
                'You must choose where to save the data file.')
        end

    end

    % Print/save the figure
    if doSavePlot
        print(hFig, '-dpdf', '-r300', fullfile(pathFig, fnFig))
    end

end