function varargout = single_row(val, varargin)
%single_row - Check that the value has a single row
%
%   single_row(val) checks that val has a single row.  If it does, nothing
%   else happens; if it is not, the function throws an exception from the
%   calling function.
%
%   single_row(val, 'VarName') includes VarName in the exception message.
%
%   ME = single_row(...) returns the MException object instead of throwing
%   it internally.  If no exception is created, ME will be an empty array.
%   This can be useful for combining multiple checks while still throwing
%   the exception from the original calling function.
%
%   See also size, error, MException, MException.throwAsCaller

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
narginchk(1, 2)

% Work out if we want to return the exception or throw it internally, and
% initialise the output argument if necessary
doReturnME = nargout > 0;
if doReturnME
    varargout{1} = [];
end

%% Check the value has a single row

isSingleRow = size(val, 1) == 1;
if ~isSingleRow
    
    % Get the varName, if supplied, or a default string
    varName = utils.checks.varName(varargin{:});
    
    % Create the MException object
    ME = MException('Utils:Checks:SingleRowChar', ['The %s must be ' ...
        'a single row, but the data provided contains %d.'], ...
        varName, size(val, 1));
    
    % Return the MException object, or else throw it as the caller function
    if doReturnME
        varargout{1} = ME;
    else
        throwAsCaller(ME)
    end
    
end

end
