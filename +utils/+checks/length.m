function varargout = length(val, num, varargin)
%length - Check that the value is of a specific length
%
%   length(val, num) checks that val has length num.  If it does, nothing
%   else happens; if it does not, the function throws an exception from the
%   calling function.
%
%   length(val, num, 'VarName') includes VarName in the exception message.
%
%   length(val, num, 'VarName', 'mode') specifies whether val must be an
%   'exact' match for num (the default), otherwise 'less' than or 'greater'
%   than num.
%
%   ME = length(...) returns the MException object instead of throwing it
%   internally.  If no exception is created, ME will be an empty array.
%   This can be useful for combining multiple checks while still throwing
%   the exception from the original calling function.
%
%   See also islength, error, MException, MException.throwAsCaller

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

% Check that num is a numeric scalar
utils.checks.real_num(num, 'num');
utils.checks.scalar(num, 'num');

% Choose whether to use the default or supplied mode
hasMode = nargin > 2 & numel(varargin) > 1;
if ~hasMode
    mode = 'exact';
else
    mode = varargin{2};
    varargin(2) = [];
end

%% Check the value is a vector
utils.checks.vector(val, 'val');

switch lower(mode)
    case 'exact'
        isGood = length(val) == num;
        str = 'exactly';
    case 'less'
        isGood = length(val) < num;
        str = 'less than';
    case 'greater'
        isGood = length(val) > num;
        str = 'greater than';
    otherwise
        error('Utils:Checks:Length:BadMode', ['The mode must be either ' ...
            '''exact'', ''less'', or ''greater''.'])
end

if ~isGood
    
    % Get the varName, if supplied, or a default string
    varName = utils.checks.varName(varargin{:});
    
    % Create the MException object
    ME = MException('Utils:Checks:Vector', ['The length of %s must be %s'...
        ' %i but the data provided was of length %i.'], ...
        varName, str, num, length(val));
    
    % Return the MException object, or else throw it as the caller function
    if doReturnME
        varargout{1} = ME;
    else
        throwAsCaller(ME)
    end
    
end

end
