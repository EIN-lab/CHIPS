function chName = get_ch_name(self, chNum)
%get_ch_name - Get channel names from channel numbers
%
%   CHNAMES = get_ch_name(OBJ, CHNUMS) returns a cell array of
%   channel names from OBJ corresponding to the supplied channel
%   numbers CHNUMS.
%
%   CHNUMS must be a numeric array containing only positive integers, and
%   values greater than the total number of channels in the raw image will
%   be ignored. Any channel numbers that have not been assigned a channel
%   name will be returned with an empty character array as the name.

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

if ~isempty(self.metadata)
    chName = self.metadata.get_ch_name(chNum);
else
    error('RawImgHelper:GetChName:NoMetadata', ['Cannot get ' ...
        'the channel name as the metadata property is empty.'])
end

end