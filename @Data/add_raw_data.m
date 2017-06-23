function self = add_raw_data(self, varargin)
%add_raw_data - Add raw data to the Data object
%
%   OBJ = add_raw_data(OBJ, rawdata1, rawdata2, ...) adds the supplied raw
%   data variables to the Data object OBJ.  The raw data variables must be
%   supplied in the same order as in the protected property listRaw for the
%   appropriate class.  Any properties that are empty will not be added.
%
%   See also Data.listRaw

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
nArgsRaw = length(self.listRaw);
narginchk(1, nArgsRaw + 1)

% Loop through the supplied arguments
for iArg = 1:nargin - 1
    
    % Pull out the current argument name
    iArgName = self.listRaw{iArg};
    
    % Add the argument if it's not empty
    if ~isempty(varargin{iArg})
        self.(iArgName) = varargin{iArg};
    end
    
end

end