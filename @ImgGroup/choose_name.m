function nameOut = choose_name()
% choose_name - Choose a name for the ImgGroup object

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
    
    % Create a default name based on the current time
    defName = datestr(now, 'yyyy-mm-dd_HH:MM:SS');

    % Get the name from the user
    inputStr = sprintf(['\nEnter a name for this image group,' ...
        '\nor press enter to accept the default:\n\t"%s"'], ...
        defName);
    disp(inputStr)
    nameOut = input('Name: ', 's');

    % Assign the default name if the user pressed enter
    pressedEnter = isempty(nameOut);
    if pressedEnter
        nameOut = defName;
    end
    
    % Package the name into a cell array
    nameOut = {nameOut};

end