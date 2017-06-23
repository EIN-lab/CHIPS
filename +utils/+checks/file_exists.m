function varargout = file_exists(val)
%file_exists - Check that the file exists
%
%   file_exists('fn') checks that fn is a path to a file that exists.  If
%   it is, nothing else happens; if it is not, the function throws an
%   exception from the calling function.
%
%   ME = file_exists(...) returns the MException object instead of throwing
%   it internally.  If no exception is created, ME will be an empty array.
%   This can be useful for combining multiple checks while still throwing
%   the exception from the original calling function.
%
%   See also exist, error, MException, MException.throwAsCaller

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
narginchk(1, 1)

% Check the filename looks appropriate
utils.checks.single_row_char(val)

% Work out if we want to return the exception or throw it internally, and
% initialise the output argument if necessary
doReturnME = nargout > 0;
if doReturnME
    varargout{1} = [];
end

%% Check the value is a scalar

isGood = exist(val, 'file') > 0;
if ~isGood
    
    % Create the MException object
    ME = MException('Utils:Checks:FileExists', ['The file "%s" does ' ...
        'not exist, or cannot be found on the MATLAB search path.'], ...
        val);
    
    % Return the MException object, or else throw it as the caller function
    if doReturnME
        varargout{1} = ME;
    else
        throwAsCaller(ME)
    end
    
end

end
