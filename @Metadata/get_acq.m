function acq = get_acq(self)
%get_acq - Get the image acquisition data
%
%   ACQ = get_acq(OBJ) returns an acquisition structure ACQ that can be
%   used as an argument to the Metadata constructor to create a new
%   Metadata object.
%
%   See also Metadata.Metadata

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

% Export the acq for use elsewhere
nFields = length(self.acqFields);
for iField = 1:nFields
    acq.(self.acqFields{iField}) = self.(self.acqFields{iField});
end

end
