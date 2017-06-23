function varargout = hghandle(hh, validTypes, varargin)
%hghandle - Check that the input is handles to existing graphics objects
%
%   hghandle(h) checks that all elements of h are handles to existing
%   graphics objects.  If they are, nothing else happens; if it is not, the
%   function throws an exception from the calling function.
%
%   hghandle(h, 'ValidType') checks that all elements of h are handles of
%   the type specified by ValidType. ValidType can be either a character
%   array or a cell object containing character arrays.
%
%   hghandle(h, type, 'VarName') includes VarName in the exception message.
%
%   ME = hghandle(...) returns the MException object instead of throwing it
%   internally.  If no exception is created, ME will be an empty array.
%   This can be useful for combining multiple checks while still throwing
%   the exception from the original calling function.
%
%   See also ishghandle, error, MException, MException.throwAsCaller

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

% Check the valid types
defValidTypes = {'figure', 'axes'};
hasValidTypes = nargin > 1 && ~isempty(validTypes);
if hasValidTypes
    
    % Check that it's a cell or char array
    utils.checks.object_class(validTypes, {'cell', 'char'}, 'validTypes');
    
    % Put any char arrays inside a cell
    if ~iscell(validTypes);
        validTypes = {validTypes};
    end
    
    % Check the individual cells
    for iType = 1:numel(validTypes)
        
        % Check they're all char arrays
        ME_char = utils.checks.object_class(validTypes{iType}, 'char', ...
            'validTypes');
        if ~isempty(ME_char)
            error('Utils:Checks:HGHandle_char', ['If the validTypes ' ...
                'is a cell array, it must contain only valid strings'])
        end
        
        % Check they're valid types
        badType = ~any(strcmpi(validTypes{iType}, defValidTypes));
        if badType
            listTypes = sprintf('%s, ', defValidTypes{:});
            error('Utils:Checks:HGHandle_type', ['ValidTypes must ' ...
                'must contain only values from the list: %s'], ...
                listTypes(1:end-2))
        end

    end
    
else
    % Use the default validTypes
    validTypes = defValidTypes;
end

% Work out if we want to return the exception or throw it internally, and
% initialise the output argument if necessary
doReturnME = nargout > 0;
if doReturnME
    varargout{1} = [];
end

%% Check the value is handles to existing graphics objects

for iElem = 1:numel(hh)
    
    % Check the value is handles to existing graphics objects of the
    % appropriate type
    try
        isGood = ishghandle(hh(iElem)) && ...
            any(strcmpi(get(hh(iElem), 'type'), validTypes));
    catch
        isGood = false;
    end
    
    if ~isGood

        % Get the varName, if supplied, or a default string
        varName = utils.checks.varName(varargin{:});

        % Create the MException object
        listTypes = sprintf('%s, ', validTypes{:});
        ME = MException('Utils:Checks:HGHandle', ['The %s must contain ' ...
            'only handles to existing graphics objects of type: %s.'], ...
            varName, listTypes(1:end-2));

        % Return the MException object, or else throw it as the caller function
        if doReturnME
            varargout{1} = ME;
        else
            throwAsCaller(ME)
        end

    end
    
end

end
