function self = add_mask_data(self, varargin)
%add_mask_data - Add mask data to the Data object
%
%   OBJ = add_mask_data(OBJ, maskdata1, maskdata2, ...) adds the supplied
%   mask data variables to the Data object OBJ.  The mask data
%   variables must be supplied in the same order as in the protected
%   property listMask for the appropriate class.  Any properties that
%   are empty will not be added.
%
%   See also Data.listMask

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
    
% Check we have the right number of arguments
nArgsMask = length(self.listMask);
narginchk(1, nArgsMask + 1)

% Loop through the supplied arguments
for iArg = 1:nargin - 1
    
    % Pull out the current argument name
    iArgName = self.listMask{iArg};
    
    % Add the argument if it's not empty
    if ~isempty(varargin{iArg})
        self.(iArgName) = varargin{iArg};
    end
    
end

end