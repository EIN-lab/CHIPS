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
%   plot(..., 'attribute', value, ...) uses the specified attribute/value
%   pairs.  Valid attributes (case insensitive) are:
%
%       'frameNum' ->   Integer scalar indicating which frame number to
%                       show in the plots. [default = 1]
%
%       'isDebug' ->    Logical scalar indicating whether to show debugging
%                       information and/or plots on the figure. 
%                       [default = true]
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

        case {'default'}

            self.calcDiameter.plot(self, 'default', ...
                varargin{idxStart:end});

        otherwise

            error('XSectScan:Plot:UnknownPlot', ['Unknown ' ...
                'plot type "%s"'], nameIn)

    end

    % Return the figure handle if asked for
    if nargout > 0
        varargout{1} = hFig;
    end

end
