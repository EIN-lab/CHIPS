function varargout = plot(self, varargin)
%plot - Plot a figure
%
%   plot(OBJ) plots the default figure for each element of OBJ.
%
%   plot(OBJ, H_FIG, FIG_NAME) plots the figure on the specified figure
%   handle(s) H_FIG, and the particular figure specified by FIG_NAME.
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
%   H = plot(...) returns handles to the figure created/used.
%
%   See also Data.plot, Data.plot_graphs

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

    % Call the function one by one if we have an array
    if ~isscalar(self)
        hFig = arrayfun(@(xx) plot(xx, varargin{:}), self, ...
            'UniformOutput', false);
        hFig = [hFig{:}];
        if nargout > 0
            varargout{1} = hFig;
        end
        return
    end
    
    % Check the state of the object, and the arguments
    self.check_state_plot();
    [hFig, plotName, idxStart] = self.check_plot_args(varargin);

    % Call the appropriate plotting function
    switch plotName

        case 'default'

            self.plot_main(varargin{idxStart:end});
            
        case 'graphs'

            self.calcVelocity.plot(self, 'graphs', ...
                varargin{idxStart:end});

        case 'windows'
            
            self.calcVelocity.plot(self, 'windows', ...
                varargin{idxStart:end});

        otherwise

            error('StreakScan:Plot:UnknownPlot', ['Unknown ' ...
                'plot type "%s"'], nameIn)

    end

    % Return the figure handle if asked for
    if nargout > 0
        varargout{1} = hFig;
    end

end