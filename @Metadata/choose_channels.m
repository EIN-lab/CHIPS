function self = choose_channels(self, varargin)
%choose_channels - Protected class method allowing the user to manually
%   specify/create the channels structure

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
%   along with this program.  If not, see <http://www.gnu.org/licenses/>

    % Parse optional arguments
    chOptions = utils.parse_opt_args({[]}, varargin);
    
    % Specify the default options
    if isempty(chOptions)
        chOptions = Metadata.knownChannels;
    end

    % Preallocate variable name
    channelsIn = struct();

    % Check if there are any channels specified
    if ~isempty(self.nChannels)

        % Loop through all channels
        for iChannel = 1:self.nChannels

            % Ask the user to choose the role for this channel
            strMenu = sprintf('What is shown on channel %d?', iChannel);
            
            % Choose a channel using the static function
            iChannelName = Metadata.choose_channel(chOptions, strMenu);

            % Apply the channel name
            hasCh = ~isempty(iChannelName);
            if hasCh
                channelsIn.(iChannelName) = iChannel;
            end

        end
    else
        return
    end

    % Assign the channels to the object
    self.channels = channelsIn;

end