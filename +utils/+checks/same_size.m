function varargout = same_size(x1, x2, varargin)
%same_size - Check that two variables are the same size
%
%   same_size(x1, x2) checks that x1 and x2 are the same size.  If they
%   are, nothing else happens; if they are not, the function throws an
%   exception from the calling function.
%
%   same_size(x1, x2, 'VarName') includes VarName in the exception message.
%   The VarName string can include the names of both variables for a more
%   useful error message
%
%   ME = same_size(...) returns the MException object instead of throwing
%   it internally.  If no exception is created, ME will be an empty array.
%   This can be useful for combining multiple checks while still throwing
%   the exception from the original calling function.
%
%   See also size, isequal, error, MException, MException.throwAsCaller

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
narginchk(2, 3)

% Work out if we want to return the exception or throw it internally, and
% initialise the output argument if necessary
doReturnME = nargout > 0;
if doReturnME
    varargout{1} = [];
end

%% Check the value is a of the correct class

isGood = isequal(size(x1), size(x2));
if ~isGood
    
    % Get the varName, if supplied, or a default string
    varName = utils.checks.varName(varargin{:}, 'values');
    
    % Create the MException object
    ME = MException('Utils:Checks:SameSize', ['The %s must be the ' ...
        'same size.'], varName);
    
    % Return the MException object, or else throw it as the caller function
    if doReturnME
        varargout{1} = ME;
    else
        throwAsCaller(ME)
    end
    
end

end
