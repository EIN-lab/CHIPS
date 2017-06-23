function imgTypes = choose_imgtypes(varargin)
%choose_imgtypes - Protected class method to choose image types

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
  
% Parse the remaining arguments
[doChooseMany] = utils.parse_opt_args({true}, varargin);

% Initialise this
imgTypes = {};

if doChooseMany
    fprintf(['\n----- Choose as many ProcessedImg classes as '...
        'you would like -----'])
end

% Don't exit the loop until
while true

    % Choose the image types
    doAllowCancel = doChooseMany;
    doProcessedImg = true;
    [~, isCancelled, strType] = ...
        Processable.choose_Processable(doAllowCancel, doProcessedImg);

    if isCancelled
        
        % Break if the user doesn't want any more imgTypes
        break
        
    else

        % Check if the type already exists
        doesExist = any(strcmp(strType, imgTypes));
        if doesExist
            warning('The imgType "%s" already exists.  Ignoring.', ...
                strType)
            continue
        end

        % Add the new type to the list of existing ones
        imgTypes{end+1} = strType; %#ok<AGROW>

    end
    
    % Break if we're only allowing the user to choose one type
    if ~doChooseMany
        break
    end

end

end