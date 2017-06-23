function varargout = equal(val1, val2, varargin)
%equal - Check that two variables are equal
%
%   equal(val1, val2) checks that val1 and val2 are equal. If they are,
%   nothing else happens; if they are not, the function throws an exception
%   from the calling function.
%
%   equal(val1, val2, 'VarName1', 'VarName2') includes VarName1 and/or
%   VarName2 in the exception message.
%
%   ME = equal(...) returns the MException object instead of
%   throwing it internally.  If no exception is created, ME will be an
%   empty array. This can be useful for combining multiple checks while
%   still throwing the exception from the original calling function.
%
%   See also isequal, error, MException, MException.throwAsCaller

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
narginchk(2, 4)

% Work out if we want to return the exception or throw it internally, and
% initialise the output argument if necessary
doReturnME = nargout > 0;
if doReturnME
    varargout{1} = [];
end

%% Check the elements of val are less than num

isGood = isequal(val1, val2);
if ~isGood
    
    % Parse optional arguments
    [varName1, varName2] = utils.parse_opt_args(...
        {'Var1', 'Var2'}, varargin);
    
    % Create the MException object
    ME = MException('Utils:Checks:Equal', '%s must be equal to %s', ...
        varName1, varName2);
    
    % Return the MException object, or else throw it as the caller function
    if doReturnME
        varargout{1} = ME;
    else
        throwAsCaller(ME)
    end
    
end

end
