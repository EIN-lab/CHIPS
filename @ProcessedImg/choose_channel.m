function channelToUse = choose_channel(self)
%CHOOSE_CHANNEL - Compares image channels to a set of processable channels
%and in case there is more than one appropriate channel, asks the user
%which channel to use. Can deal with a single RawImg object or an array of
%RawImg objects.

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

    % Assumes all rawImg objects in array have the same channels
    if ~isscalar(self)
        warning('ProcessedImg:ChooseChannel:Array', ['All of the ' ...
            'RawImg objects are assumed to have the same channel ' ...
            'structure. If this is not true, the processing will not ' ...
            'work as expected; in this case you will need to create ' ...
            'the objects seperately.'])
    end
    
    % Extract channel information from first rawImg object and compare to
    % required channels
    chsAvail = self(1).rawImg.metadata.channels;
    channelToUse = utils.choose_channel(chsAvail, ...
        self(1).reqChannelAny, class(self));

end