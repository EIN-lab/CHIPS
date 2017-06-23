function chNames = get_ch_name(self, chNums)
%get_ch_name - Get channel names from channel numbers
%
%   CHNAMES = get_ch_name(OBJ, CHNUMS) returns a cell array of
%   channel names from the Metadata object corresponding to the supplied
%   channel numbers.
%
%   CHNUMS must be a numeric array containing only positive integers, and
%   values greater than the total number of channels in the metadata will
%   be ignored. Any channel numbers that have not been assigned a channel
%   name will be returned with an empty character array as the name.
%
%   See also RawImgHelper.get_ch_name, Metadata.has_ch

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

% Check the input argument format
utils.checks.integer(chNums);
utils.checks.positive(chNums);
utils.checks.vector(chNums);

% Exclude channel numbers greater than the total number of channels
maskTooBig = chNums > self.nChannels;
if any(maskTooBig)
    warning('Metadata:GetChName:ExcludingBigChs', ['Excluding channel ' ...
        'numbers larger than the total number of image channels (%d).'], ...
        self.nChannels);
    chNums = chNums(~maskTooBig);
end

% Prepare a list of channel names and numbers
chNamesAvail = fieldnames(self.channels);
cc = struct2cell(self.channels);
chNumsAvail = [cc{:}];

% Find the index of the channel number we want, and get the
% corresponding channel name
chNames = repmat({''}, size(chNums));
for iCh = numel(chNums):-1:1
    idxName = find(ismember(chNumsAvail, chNums(iCh)));
    hasName = ~isempty(idxName);
    if hasName
        chNames{iCh} = chNamesAvail{idxName};
    end
end

end