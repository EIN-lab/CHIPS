function varargout = plot(self, objPI, varargin)
%plot - Plot a figure
%
%   plot(OBJ, OBJ_PI) plots the default figure for the CalcDetectSigs
%   object OBJ using the ProcessedImg object OBJ_PI.
%
%   plot(OBJ, OBJ_PI, AX, FIG_NAME) plots the figure on the specified axes
%   handles AX, and the particular figure specified by FIG_NAME. The number
%   of axes present is AX varies depending on the particular figure.
%   FIG_NAME must be one of the following:
%
%       'default' ->    The default figure.
%
%       'annotations' -> A figure annotating the traces with the detected
%                       signals and/or classifications These figures are
%                       only relevant when using CalcDetectSigsClsfy.
%
%       'classification' -> A figure showing detail on the classification 
%                       of the ROIs. These figures are only relevant when
%                       using CalcDetectSigsClsfy.
%
%       'signals' ->    A series of figures showing detail on the signals 
%                       detection and classification process. One figure is
%                       produced for every ROI. These figures are only
%                       relevant when using CalcDetectSigsClsfy.
%
%   plot(..., 'attribute', value, ...) uses the specified attribute/value
%   pairs.  Valid attributes (case insensitive) are:
%
%       'annotateSigs'  -> A boolean flag indiciating whether to add
%                       annotations to plots of individual ROI's responses.
%                       Applicable for plot type 'signals' only. 
%                       [default = true]
%
%       'doHeatmap' ->  Logical scalar indicating whether to display the
%                       traces as a heatmap or regular 2d lines. 
%                       [default = true if > 15 ROIs, otherwise false]
%
%       'doWholeFrame' -> Logical scalar indicating whether to display the
%                       whole frame trace(s). [default = true]
%
%       'isDebug' ->    Logical scalar indicating whether to show debugging
%                       information and/or plots on the figure. 
%                       [default = true]
%
%       'normTraces' -> Logical scalar indicating whether to plot the
%                       normalised traces (instead of the raw traces).
%                       [default = true]
%
%       'plotROIs' ->   A vector of integers corresponding to the ROI
%                       numbers that should be displayed as the traces.  If
%                       empty, all ROIs are selected. 
%                       [default = []]
%
%       'spacingFactor' -> A scalar number reperesenting how far apart the
%                       individual ROI traces should be spaced.  Larger
%                       numbers represent more spaced ROIs and thus smaller
%                       amplitudes for the traces.  [default = 1]
%
%   AX = plot(...) returns a handle to the axes created/used in the figure.
%
%   See also CellScan.plot, Data.plot, Data.plot_graphs, CellScan

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
narginchk(2, inf);

% Check the state of the image, and the arguments
flag = self.check_state_plot();
[hAx, plotName, idxStart] = self.check_plot_args(objPI, varargin);

% Call the appropriate plotting function
if flag > 0
    switch plotName

        case {'annotations'}

            self.annotate_traces(objPI, hAx, ...
                varargin{idxStart:end});

        case {'default', 'classification'}

            self.plot_clsfy(hAx, varargin{idxStart:end});

        case {'signals'}

            hFig = self.plot_signals(objPI, ...
                varargin{idxStart:end});
            hAx = hFig;

        otherwise

            error('CalcDetectSigs:Plot:UnknownPlot', ...
                'Unknown plot type "%s"', plotName)

    end
end

% Return the axes handle if asked for
if nargout > 0
    varargout{1} = hAx;
end

end