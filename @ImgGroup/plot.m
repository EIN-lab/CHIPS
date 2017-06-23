function varargout = plot(self, varargin)
%plot - Plot a figure for each child object
%
%   plot(OBJ) sequentially loops through the elements of the ImgGroup
%   object and calls the plot_fig method for each of the ImgGroup children.
%
%   plot(OBJ, ...) passes any additional arguments to the child method.
%
%   H = plot(...) returns a handle to the figure(s).  If OBJ is non-scalar,
%   the figure handles are returned as a cell array.
%
%   See also ProcessedImg.plot, Data.plot, Data.plot_graphs

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
        if nargout > 0
            varargout{1} = hFig;
        end
        return
    end

    % Loop through each of the children
    hFig = cell(1, self.nChildren);
    for iChild = 1:self.nChildren

        % Do the actual processing
        hFig{iChild} = self.children{iChild}.plot(varargin{:});
        
    end
    
    % Return the figure handle if asked for
    hFig = [hFig{:}];
    if nargout > 0
        varargout{1} = hFig;
    end

end
