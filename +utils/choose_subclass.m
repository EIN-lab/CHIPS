function subclassOut = choose_subclass(classParent, strType, varargin)
%choose_subclass - Helper function for choosing a subclass
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
narginchk(2, 3);

% Parse arguments
inclParent = utils.parse_opt_args({false}, varargin);

% Find a list of (non abstract etc) subclasses 
exclAbstract = true;
exclMock = true;
exclTest = true;
subclasses = utils.find_subclasses(classParent, exclAbstract, exclMock, ...
    exclTest, inclParent);
classOptions = [{''}, subclasses];
defOption = 1;
            
% Ask the user to choose which image type to use
strInstructions = sprintf(['What type of %s would you like ' ...
    'to use?'], strType);
imgType = utils.txtmenu({strInstructions, 'Select a format:'}, defOption, ...
    classOptions);

% Call the RawImg subclass constructor
hConstructor = str2func(classOptions{imgType+1});
subclassOut = hConstructor();

end
