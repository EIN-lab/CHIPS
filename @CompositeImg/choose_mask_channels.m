function mask = choose_mask_channels(self, imgType, varargin)
%choose_mask_channels - Protected class method to choose an individual mask
%   based on the image channels

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

% Parse the input arguments
[chToUse] = utils.parse_opt_args({[], ''}, varargin);

if isempty(chToUse)

    % Make a list of the available channels that are valid for this imgType
    chsAvailable = fieldnames(self.rawImg.metadata.channels);
    fChsAll = str2func(sprintf('%s.reqChannelAll', imgType));
    fChsAny = str2func(sprintf('%s.reqChannelAny', imgType));
    chsValid = [fChsAll(), fChsAny()];
    chChoices = intersect(chsAvailable, chsValid);

    % Ask the user what channel to use
    strMenu = sprintf('What channel would you like to use?');
    chNumChoice = utils.txtmenu({strMenu, 'Answer:'}, ...
        '<Finished>', chChoices{:});
    if chNumChoice > 0
        chNumToUse = ...
            self.rawImg.metadata.channels.(chChoices{chNumChoice});
    else
        chNumToUse = 0;
    end
    
else
    
    if isnumeric(chToUse)
        utils.checks.prfsi(chToUse, 'Channel Number');
        utils.checks.less_than(chToUse, ...
            self.rawImg.metadata.nChannels, true, 'Channel Number');
        chNumToUse = chToUse;
    elseif ischar(chToUse)
        utils.checks.single_row_char(chToUse, 'Channel Name');
        utils.checks.has_field(self.rawImg.metadata.channels, chToUse, ...
            'Metadata')
        chNumToUse = self.rawImg.metadata.channels.(chToUse);
    else
        error('CompositeImg:ChooseMaskChs:UnknownChToUseFmt', ...
            'The chToUse must be a valid channel number or name.')
    end

end

mask = [];
if chNumToUse > 0
    
    % Create the empty mask
    mask = false(size(self.rawImg.rawdata(:,:, :, 1)));

    % Fill in the correct channel on the mask
    mask(:,:,chNumToUse) = true;
    
end

end