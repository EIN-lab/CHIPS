function check_optList(self)

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
    
    % Check it's a cell
    if ~iscell(self.optList);
        error('Config:CheckOptList:NotCell', ['The optList ' ...
            'must be a cell array.  Please contact a developer.'])
    end

    % Skip the rest of the checks if it's empty
    if isempty(self.optList)
        return
    end

    % Check it has 2 columns
    [nRows, nCols] = size(self.optList);
    if nCols ~= 2
        error('Config:CheckOptList:WrongSize', ['The optList ' ...
            'must be N x 2.  Please contact a developer.'])
    end

    % Check the first column are all strings
    if ~all(cellfun(@ischar, self.optList(:, 1)))
        error('Config:CheckOptList:WrongSize', ['The first ' ...
            'column of optList must contain only strings.  ' ...
            'Please contact a developer.'])
    end

    % Check the second column are all cells
    if ~all(cellfun(@iscell, self.optList(:, 2)))
        error('Config:CheckOptList:WrongSize', ['The second ' ...
            'column of optList must contain only cell arrays.  ' ...
            'Please contact a developer.'])
    end

    % Check each row
    propList = properties(self);
    for iGroup = 1:nRows

        % Check the cell contains only strings
        if ~all(cellfun(@ischar, self.optList{iGroup, 2}))
            error('Config:CheckOptList:WrongSize', ['The second ' ...
                'column of optList must contain only cell arrays ' ...
                'of strings. Please contact a developer.'])
        end

        % Check each property is valid
        for jProp = 1:numel(self.optList{iGroup, 2})
            if ~ismember(self.optList{iGroup, 2}{jProp}, propList)
                error('Config:CheckOptList:NotProperty', ...
                    ['%s is not a valid property of %s. ' ...
                    'Please contact a developer.'], ...
                    self.optList{iGroup, 2}{jProp}, class(self))
            end
        end

    end

end