function varargout = numel(val, num, varargin)
%numel - Check that a value has an exact number of elements
%
%   numel(val) checks that val has exactly two elements. If so, nothing
%   else happens; if not, the function throws an exception from the calling
%   function.  val must be a vector or an array.
%
%   numel(val, num) checks that val has exactly num elements. If num is
%   empty or not specified, it is assumed to be 2. num must be a scalar
%   real number.
%
%   numel(val, num, 'VarName') includes VarName in the exception
%   message.
%
%   ME = numel(...) returns the MException object instead of throwing
%   it internally.  If no exception is created, ME will be an empty array.
%   This can be useful for combining multiple checks while still throwing
%   the exception from the original calling function.
%
%   See also numel, error, MException, MException.throwAsCaller

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
narginchk(1, 3)

% Choose whether to use the default or supplied value for num
hasNum = nargin > 1 && ~isempty(num);
if ~hasNum
    num = 2;
end

% Check than num isn't one and give a more specific error if it is
if num == 1
    warning('Utils:Checks:Numel:IsScalar', ['Please use ', ...
        'utils.checks.scalar() instead of using utils.checks.', ...
        'numel() with num = 1.']);
    
end
    
% Check that num is a positive, real, finite, scalar integer
utils.checks.prfsi(num, 'num');

% Work out if we want to return the exception or throw it internally, and
% initialise the output argument if necessary
doReturnME = nargout > 0;
if doReturnME
    varargout{1} = [];
end

%% Check that val has exactly num elements

% Do the comparison
isGood = numel(val) == num;
if ~isGood
    
    % Get the varName, if supplied, or a default string
    varName = utils.checks.varName(varargin{:});
    
    % Create the MException object
    ME = MException('Utils:Checks:Numel', ['%s must have exactly ' ...
        '%.0f elements.'], varName, num);
    
    % Return the MException object, or else throw it as the caller function
    if doReturnME
        varargout{1} = ME;
    else
        throwAsCaller(ME)
    end
    
end

end