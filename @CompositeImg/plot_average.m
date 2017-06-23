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

    % Find a list of children within the CompositeImg
    nGrandchildren = self.children{1}.nChildren;
    hFig = cell(1, nGrandchildren);
    for iGrandchild = 1:nGrandchildren

        % Make a temporary ProcessedImg array
        for jChild = self.nChildren:-1:1
            tempPI(jChild) = ...
                self.children{jChild}.children{iGrandchild};
        end

        hFig{iGrandchild} = tempPI.plot_average(isDebug);

        clear tempPI

    end

    if nargout > 0
        varargout{1} = hFig;
    end

end