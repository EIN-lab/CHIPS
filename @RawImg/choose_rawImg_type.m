function [hConstructor, strClass] = choose_rawImg_type()
%choose_rawImg_type - Class method to choose a RawImg type interactively.

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
   
    % Create a list of all the non-abstract subclasses of RawImg,
    % excluding RawImgDummy
    subclasses = utils.find_subclasses('RawImg');
    maskRID = strcmp('RawImgDummy', subclasses);
    imgOptions = [{''}, subclasses(~maskRID)];
    defOption = 1;

    % Ask the user to choose which image type to use
    imgType = utils.txtmenu({['What type of RawImg would you ' ...
        'like to load?'], 'Select a format:'}, defOption, ...
        imgOptions);
    fprintf('\n')

    % Call the RawImg subclass constructor
    strClass = imgOptions{imgType+1};
    hConstructor = str2func(strClass);

end