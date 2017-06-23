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

    % Create a new figure
    hFig = figure;

    % Find a list of calcs
    calcList0 = self.calcList();

    % Loop through the different calc types
    dataArray = cell(size(calcList0));
    for iCalc = 1:length(calcList0)
        for jChild = 1:numel(self)

            % Extract the data into a single array, 
            dataArray{iCalc}(jChild) = ...
                self(jChild).(calcList0{iCalc}).data;

        end

        % Use the plot_average function from the data class 
        % to do the work
        dataArray{iCalc}.plot_average(isDebug);

    end

    if nargout > 0
        varargout{1} = hFig;
    end

end