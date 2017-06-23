function tf = has_ch(self, chNames)
%has_ch - Determine if particular channels are present
%
%   TF = has_ch(OBJ, CHNAMES) returns a logical array that is true
%   where the elements of CHNAMES are channels in the MetadataObj and false
%   where they are not.  CHNAMES must be either a single row character
%   array or a cell array containing only single row character arrays.
%
%   See also RawImgHelper.has_ch, Metadata.get_ch_name

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
narginchk(2, 2)

% Channels must be a char array or a cell array of chars
if ischar(chNames)
    chNames = {chNames};
end
utils.checks.cell_array(chNames, 'channel names')

nChannelsReq = length(chNames);
tf = false(size(chNames));
for iChReq = 1:nChannelsReq

    % Pull out the current channel name
    iChName = chNames{iChReq};

    % checkType must be a single row character array
    utils.checks.single_row_char(iChName, 'channel name');

    % Work out if this channel is present in the metadata
    tf(iChReq) = isfield(self.channels, iChName) && ...
        ~isempty(self.channels.(iChName));

end

end