function varargout = check_ch(self, channels, checkType, varargin)
%check_ch - Check that the appropriate channels are present
%
%   check_ch(OBJ, CHS, 'any') checks that at least one of the channels are
%   present in the Metadata obj. CHS must be a single row char array or a
%   cell array containing single row char arrays.  If this is true, nothing
%   else happens; if it is not, the function throws an exception from the
%   calling function.
%
%   check_ch(OBJ, CHS, 'all') is the same, but all the channels specified
%   in CHS must be present in the Metadata obj.
%
%   check_ch(..., 'ObjName') includes ObjName in the exception message.
%
%   ME = check_ch(...) returns the MException object instead of throwing it
%   internally.  If no exception is created, ME will be an empty array.
%   This can be useful for combining multiple checks while still throwing
%   the exception from the original calling function.
%
%   See also RawImgHelper.check_ch, error, MException,
%   MException.throwAsCaller

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
narginchk(3, 4)

% checkType must be a single row character array
utils.checks.single_row_char(checkType, 'checkType');

% Initialise the output argument
ME = [];

% Work out if we want to return the exception or throw it internally
doReturnME = nargout > 0;

% Get the varName, if supplied, or a default string
objName = utils.checks.varName(varargin{:}, 'object');

%% Work out if the channels we have meet the requirements

% Find out which channels are present
tf = self.has_ch(channels);

switch lower(checkType)
    
    % Check that we have all of the channels
    case 'all'
        
        hasAll = all(tf);
        if ~hasAll
            
            % Create some helper strings for the error message
            chNeedsAll = sprintf('"%s", ', channels{:});
            if any(hasAll)
                chHasAll = sprintf('"%s", ', channels{hasAll});
                chHasAll = ['only: ' chHasAll(1:end-2)];
            else
                chHasAll = 'none of them';
            end
            
            % Create the MException object
            ME = MException('Metadata:CheckChannels:NotAllChannels', ...
                ['The %s requires all of the following channels: %s; ' ...
                'however, the metadata supplied contains %s.'], ...
                objName, chNeedsAll(1:end-2), chHasAll);
            
        end
        
    % Check that we have at least one of the channels
    case 'any'
        
        hasAny = ~isempty(tf) && any(tf);
        if ~hasAny
            
            % Create some helper strings for the error message
            chNeedsAny = sprintf('"%s", ', channels{:});
            
            % Create the MException object
            ME = MException('Metadata:CheckChannels:NoAnyChannels', ...
                ['The %s requires one of the following channels: %s; ' ...
                'however, the RawImg supplied contains none of them'], ...
                objName, chNeedsAny(1:end-2));
            
        end
        
    otherwise
        
        error('Metadata:CheckChannels:BadCheckType', ['The checkType ' ...
            'must be either ''any'' or ''all'''])
        
end

% Assign the output argument or throw the exception 
if doReturnME
    varargout{1} = ME;
else
    if ~isempty(ME);
        throwAsCaller(ME)
    end
end

end