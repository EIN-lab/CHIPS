function check_plotList(self)

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

% Skip the rest of the checks if it's empty
if isempty(self.plotList)
    return
end

% Check it's a structure
if ~isstruct(self.plotList);
    error('ProcessedImg:CheckPlotList:NotStruct', ['The plotList ' ...
        'must be a structure.  Please contact a developer.'])
end

% Check it's a scalar
if ~isscalar(self.plotList)
    error('ProcessedImg:CheckPlotList:NotScalar', ['The plotList ' ...
        'must be a scalar.  Please contact a developer.'])
end

% Check each field is a property
fields = fieldnames(self.plotList);
props = properties(self);
for iField = 1:numel(fields)
    iFieldName = fields{iField};
    if ~ismember(iFieldName, props)
        error('ProcessedImg:CheckPlotList:NotProperty', ['The field ' ...
            '"%s" is not a property of %s objects. Please contact a ' ...
            'developer.'], iFieldName, class(self))
    end
end
            
end