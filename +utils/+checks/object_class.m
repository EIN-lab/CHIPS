function varargout = object_class(obj, className, varargin)
%object_class - Check that an object is an instance of a particular class
%
%   object_class(obj, 'ClassName') checks that obj is an instance of the
%   class specified by ClassName.  If it is, nothing else happens; if it is
%   not, the function throws an exception from the calling function.
%   ClassName can be either a character array or a cell object containing
%   character arrays.  ClassName can also be 'object', to check if obj is
%   an object of any class.
%
%   object_class(obj, 'ClassName', 'VarName') includes VarName in the
%   exception message.
%
%   ME = object_class(...) returns the MException object instead of
%   throwing it internally.  If no exception is created, ME will be an
%   empty array. This can be useful for combining multiple checks while
%   still throwing the exception from the original calling function.
%
%   See also isa, isobject, error, MException, MException.throwAsCaller

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

% Check whether or not we're dealing with a cell array of strings
isCell = iscell(className);

% Check that the className is a string
% Work out the current recursion depth, and if we're not too deep
if ~utils.is_deeper_than('object_class')
    
    % Check that we have either a char or cell array
    utils.checks.object_class(className, {'char', 'cell'}, 'class name');
    
    % If we have a cell, check that the cell contains only char arrays
    if isCell
        ME = cellfun(...
            @(xx) utils.checks.object_class(xx, 'char', 'class name'), ...
            className, 'UniformOutput', false);
        hasErrors = any(~cellfun(@isempty, ME));
        if hasErrors
            error('Utils:Checks:ObjectClass', ['If the className is ' ...
                'a cell array, it must contain only strings'])
        end
    end
    
end

% Check the argument is not empty
utils.checks.not_empty(className, 'class name');

% Work out if we want to return the exception or throw it internally, and
% initialise the output argument if necessary
doReturnME = nargout > 0;
if doReturnME
    varargout{1} = [];
end

%% Check the value is a of the correct class

% Check that we have the correct class
if isCell
    className = className(:);
    isGood = any(cellfun(@(xx) isa(obj, xx), className));
    if ismember('object', className)
        isGood = isGood || isobject(obj);
    end
else
    if strcmpi(className, 'object')
        isGood = isobject(obj);
    else
        isGood = isa(obj, className);
    end
    className = {className};
end

if ~isGood
    
    % Get the varName, if supplied, or a default string
    varName = utils.checks.varName(varargin{:});
    
    % Format a string nicely for the error message
    nClasses = numel(className);
    if nClasses == 1
        strClass = className{1};
    elseif nClasses == 2
        strClass = sprintf('"%s" or "%s"', className{:});
    else
        strClass = [sprintf('"%s", ', className{1:end-1}), ...
            sprintf('or "%s"', className{end})];
    end
    
    % Create the MException object
    ME = MException('Utils:Checks:IsClass', ['The %s must be of class ' ...
        '%s, but the one supplied is of class "%s".'], ...
        varName, strClass, class(obj));
    
    % Return the MException object, or else throw it as the caller function
    if doReturnME
        varargout{1} = ME;
    else
        throwAsCaller(ME)
    end
    
end

end
