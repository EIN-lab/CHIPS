function varargout = check_ch(self, channels, checkType, varargin)
%check_ch - Check that the appropriate channels are present 
%
%   check_ch(OBJ, CHS, 'any') checks that at least one of the channels
%   specified by CHS are present in OBJ. CHS must be a single row char
%   array or a cell array containing single row char arrays.  If this is
%   true, nothing else happens; if it is not, the function throws an
%   exception from the calling function.
%
%   check_ch(OBJ, CHS, 'all') is the same, but all the channels specified
%   in CHS must be present in the OBJ.
%
%   check_ch(..., 'ObjName') includes ObjName in the exception message.
%
%   ME = check_ch(...) returns the MException object instead of throwing it
%   internally.  If no exception is created, ME will be an empty array.
%   This can be useful for combining multiple checks while still throwing
%   the exception from the original calling function.
%
%   See also Metadata.check_ch, error, MException, MException.throwAsCaller

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

if ~isempty(self.metadata)
    varargout{1} = self.metadata.check_ch(channels, ...
        checkType, varargin{:});
else
    error('RawImgHelper:CheckCh:NoMetadata', ['Cannot check ' ...
        'the channels as the metadata property is empty.'])
end

end