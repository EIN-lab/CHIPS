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
%       'windows' ->    A figure showing a more detailed view of the
%                       individual windows.
%
%   plot(..., 'attribute', value, ...) uses the specified attribute/value
%   pairs.  Valid attributes (case insensitive) are:
%
%       'doPics' ->     Logical scalar indicating whether to include image
%                       panels in the figure. [default = true]
%
%       'doYPos' ->     Logical scalar indicating whether to include the Y
%                       position images in the figure.  This attribute is
%                       only relevant for FrameScan objects. 
%                       [default = true]
%
%       'isDebug' ->    Logical scalar indicating whether to show debugging
%                       information and/or plots on the figure. 
%                       [default = true]
%
%       'nWindowsSQRT' ->  Scalar integer specifying the square root of the
%                       number of windows to include on the figure.  E.g.,
%                       when nPlotSQRT = 4, there will be 4 * 4 (i.e. 16)
%                       windows shown on the plot.  This attribute is only
%                       relevant for the 'windows' plot. [default = 4]
%
%   AX = plot(...) returns a handle to the axes created/used in the figure.
%
%   See also StreakScan.plot, Data.plot, Data.plot_graphs, StreakScan,
%   LineScanVel, FrameScan

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
[hAx, plotName, idxStart] = self.check_plot_args(...
    objPI, varargin);

% Call the appropriate plotting function
if flag > 0
    switch plotName

        case {'graphs'}

            hAx = self.plot_graphs(objPI, hAx, ...
                varargin{idxStart:end});

        case {'windows'}

            hAx = self.plot_windows(objPI, hAx, ...
                varargin{idxStart:end});

        otherwise

            error('CalcVelocityStreaks:Plot:UnknownPlot', ...
                'Unknown plot type "%s"', plotName)

    end
end

% Return the axes handle if asked for
if nargout > 0
    varargout{1} = hAx;
end

end
