function chName = choose_channel(varargin)
%choose_channel - Choose an image channel
%
%   CH_NAME = choose_channel() prompts the user to specify what is shown on
%   a given image channel from a list of all the known channel types.
%
%   CH_NAME = choose_channel(CH_OPTS) provides the user only those options
%   listed in CH_OPTS. CH_OPTs must be a single row character array or a
%   cell array containing only single row character arrays, and the
%   character arrays 
%
%   CH_NAME = choose_channel(CH_OPTS, STR_MENU) prompts the user with the
%   question specified by STR_MENU.  STR_MENU must be a single row
%   character array.

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
[chOptions, strMenu] = utils.parse_opt_args(...
    {[], 'What is shown on the channel?'}, varargin);

% Specify the default options or check the supplied options
if isempty(chOptions)
    
    % Pull out the full list
    chOptions = Metadata.knownChannels;
    
else
    
    % Encase the options inside a cell
    if ~iscell(chOptions)
        chOptions = {chOptions};
    end
    
    % Check that the cell contains only single row character arrays
    ME = cellfun(@(xx) utils.checks.single_row_char(xx, 'CH_OPTS'), ...
        chOptions, 'UniformOutput', false);
    hasErrors = any(~cellfun(@isempty, ME));
    if hasErrors
        error('Metadata:ChooseChannel:BadCell', ['If CH_OPTS is a ' ...
            'cell array, it must contain only strings'])
    end
    
    % Remove any unrecognised channels
    chOptionsOld = chOptions;
    chOptions = intersect(chOptionsOld, Metadata.knownChannels, 'stable');
    hasChanged = ~isequal(chOptionsOld, chOptions);
    if hasChanged
        warning('Metadata:ChooseChannel:RemovedChs', ['Unrecognised ' ...
            'channels were removed from the options'])
    end
        
end

% Choose a 'role' for from the list of known channels
defOption = 0;
options = [{'<blank>'}, chOptions];

% Ask the user to choose the role for this channel
iRole = utils.txtmenu({strMenu, 'Answer:'}, defOption, options{:});

% Apply the channel
if iRole > 0
    chName = chOptions{iRole};
else
    chName = '';
end

end