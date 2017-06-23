function self = add_processed_data(self, varargin)
%add_processed_data - Add processed data to the Data object
%
%   OBJ = add_processed_data(OBJ, procdata1, procdata2, ...) adds the
%   supplied processed data variables to the Data object OBJ.  The
%   processed data variables must be supplied in the same order as in the
%   protected property listProcessed for the appropriate class.  Any
%   properties that are empty will not be added.
%
%   See also Data.listProcessed

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
nArgsProcessed = length(self.listProcessed);
narginchk(1, nArgsProcessed + 1)

% Loop through the supplied arguments
for iArg = 1:nargin - 1
    
    % Pull out the current argument name
    iArgName = self.listProcessed{iArg};
    
    % Add the argument if it's not empty
    if ~isempty(varargin{iArg})
        self.(iArgName) = varargin{iArg};
    end
    
end

end