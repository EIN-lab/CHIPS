function channelToUse = choose_channel(chsAvail, chsReqNames, procImgType)
%choose_channel - Helper function for choosing channels
%
%   This function is not intended to be called directly.

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

    % Check the number of input arguments
    narginchk(3, 3);
    
    % Compare the available channels to the required ones for this class
    chsAvailNames = fieldnames(chsAvail);
    chGood = intersect(chsAvailNames, chsReqNames);

    if isempty(chGood)
        
        % Throw an error if there's no good channels
        chListAvail = sprintf(' %s,', chsAvailNames);
        chListReq = sprintf(' %s,', chsReqNames);
        error('ChooseChannel:NoChannels', ['None of the supplied ', ...
            'channels (%s) can be used for %s images. Permitted ', ...
            'channels are: %s'], chListAvail(2:end-1), procImgType, ...
            chListReq(2:end-1));
        
    elseif numel(chGood) == 1
        
        % Return the channel if there's only one option
        defChannel = chsAvail.(chGood{:});
        channelToUse = defChannel;
        return
        
    end

    % Prompt the user to choose a channel
    strTitle = 'Which channel would you like to use?';
    listChannels = chGood(:, 1)';
    listOptions = [{''}, listChannels];
    defOption = 1;
    channelNum = utils.txtmenu({strTitle, ...
        'Select a channel, please:'}, ...
        defOption, listOptions);
    
    % Select corresponding channel
    channelToUse = chsAvail.(chGood{channelNum});

end
