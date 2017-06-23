function varargout = has_field(structIn, fieldName, varargin)
%has_field - Check that the value is a field in a structure
%
%   has_field(struct, 'FieldName') checks that the structure struct
%   contains the field FieldName. If it does, nothing else happens; if it
%   does not, the function throws an exception from the calling function.
%
%   has_field(struct, 'FieldName', 'VarName') includes VarName in the
%   exception message.
%
%   ME = has_field(...) returns the MException object instead of throwing
%   it internally.  If no exception is created, ME will be an empty array.
%   This can be useful for combining multiple checks while still throwing
%   the exception from the original calling function.
%
%   See also isfield, error, MException, MException.throwAsCaller

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

% Check that structIn is a struct
utils.checks.object_class(structIn, 'struct', 'structure');

% Check that fieldName is a single row char array
utils.checks.single_row_char(fieldName, 'field name');

% Work out if we want to return the exception or throw it internally, and
% initialise the output argument if necessary
doReturnME = nargout > 0;
if doReturnME
    varargout{1} = [];
end

%% Check the structure has the appropriate field

isGood = isfield(structIn, fieldName);
if ~isGood
    
    % Get the varName, if supplied, or a default string
    varName = utils.checks.varName(varargin{:}, 'structure');
    
    % Create the MException object
    ME = MException('Utils:Checks:HasField', ['The %s must ' ...
        'contain the field "%s".'], varName, fieldName);
    
    % Return the MException object, or else throw it as the caller function
    if doReturnME
        varargout{1} = ME;
    else
        throwAsCaller(ME)
    end
    
end

end
