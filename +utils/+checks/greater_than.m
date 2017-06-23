function varargout = greater_than(val, num, allowEq, varargin)
%greater_than - Check that a value is greater than a number
%
%   greater_than(val) checks that all elements of val are greater than 1.
%   If they are, nothing else happens; if it is not, the function throws an
%   exception from the calling function.  val must be numeric, real and
%   finite.
%
%   greater_than(val, num) checks that all elements of val are greater than
%   num. If num is empty or not specified, it is assumed to be 1. num must
%   be a scalar real number.
%
%   greater_than(val, num, allowEq) specifies whether to allow cases where
%   val is equal to num.  If allowEq is empty or not specified, it is
%   assumed to be false.  allowEq must be a scalar value that can be
%   converted to a logical.
%
%   greater_than(val, num, allowEq, 'VarName') includes VarName in the
%   exception message.
%
%   ME = greater_than(...) returns the MException object instead of
%   throwing it internally.  If no exception is created, ME will be an
%   empty array. This can be useful for combining multiple checks while
%   still throwing the exception from the original calling function.
%
%   See also gt, ge, error, MException, MException.throwAsCaller

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
narginchk(1, 4)

% Check that val is numeric, real and finite
utils.checks.real_num(val, 'val');
utils.checks.finite(val, 'val');

% Choose whether to use the default or supplied value for num
hasNum = nargin > 1 && ~isempty(num);
if ~hasNum
    num = 1;
end

% Check that num is a numeric scalar
utils.checks.real_num(num, 'num');
utils.checks.scalar(num, 'num');

% Choose whether to use the default or supplied value for allowEq
hasAllowEq = nargin > 2 && ~isempty(allowEq);
if ~hasAllowEq
    allowEq = false;
end

% Check that allowEq is scalar convertible to a logical
utils.checks.logical_able(allowEq, 'allowEq');
utils.checks.scalar(allowEq, 'allowEq');
allowEq = logical(allowEq);

% Work out if we want to return the exception or throw it internally, and
% initialise the output argument if necessary
doReturnME = nargout > 0;
if doReturnME
    varargout{1} = [];
end

%% Check the elements of val are less than num

% Create the comparison array
if allowEq
    comparisonArray = val >= num;
else
    comparisonArray = val > num;
end

isGood = all(comparisonArray(:));
if ~isGood
    
    % Get the varName, if supplied, or a default string
    varName = utils.checks.varName(varargin{:});
    
    % Create a convenient helper string for the error message
    if allowEq
        strComp = 'greater than or equal to';
    else
        strComp = 'greater than';
    end
    
    % Create the MException object
    ME = MException('Utils:Checks:GreaterThan', ['All elements of %s ' ...
        'must be %s %.3f.'], varName, strComp, num);
    
    % Return the MException object, or else throw it as the caller function
    if doReturnME
        varargout{1} = ME;
    else
        throwAsCaller(ME)
    end
    
end

end
