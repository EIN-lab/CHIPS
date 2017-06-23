function strOut = varName(varargin)
%varName - Supply a default or user-specified variable name for error msgs
%
%   str = varName() supplies a default variable name ('value') for use in
%   error messages.
%
%   str = varName('VarName') returns VarName as the variable name.  If
%   VarName is empty, the default variable name will be returned.  VarName
%   must be a single row character array.
%
%   str = varName('VarName', 'NewDefault') replaces the hard-coded default
%   variable name with NewDefault, so that the function will return
%   NewDefault when VarName is empty.  NewDefault must be a single row
%   character array.
%
%   This function is primarily a helper function for use in other checks.

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

% Check the number of arguments in
narginchk(0, 2)

% Specify the default default value
strOut = 'value';

% Override the default default value with a new default value, if specified
hasOverride = (nargin > 1) && ~isempty(varargin{2});
if hasOverride
    utils.checks.single_row_char(varargin{2});
    strOut = varargin{2};
end

% Replace whichever default value with the user-specified value
hasVarName = (nargin > 0) && ~isempty(varargin{1});
if hasVarName
    if ~utils.is_deeper_than('varName')
        utils.checks.single_row_char(varargin{1});
    end
    strOut = varargin{1};
end

end
