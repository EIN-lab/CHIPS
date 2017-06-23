function varargout = plot_average(self, varargin)

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
    
    % Parse arguments
    isDebug = utils.parse_opt_args({true}, varargin);

    % Call the function one by one if we have an array
    if ~isscalar(self)
        arrayfun(@plot_average, self);
        return
    end

    % Loop through each of the children
    hFig = cell(1, self.nChildren);
    for iChild = 1:self.nChildren

        % Do the actual processing
        hFig{iChild} = self.children{iChild}.plot_average(varargin{:});

    end
    
    if nargout > 0
        varargout{1} = hFig;
    end

end