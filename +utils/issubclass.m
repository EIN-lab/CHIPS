function tf = issubclass(subClassStr, superClassStr)
%issubclass - Check if a class is a subclass
%
%   TF = issubclass('subclass', 'superclass') returns a binary flag
%   specifying whether 'subclass' is a subclass of 'superclass'.
%
%   See also subclasses, metaclass

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
narginchk(2, 2);

% Check the input arguments
utils.checks.single_row_char(subClassStr, 'subclass')
utils.checks.single_row_char(superClassStr, 'superclass')

try
    listSuperclasses = superclasses(subClassStr);
    tf = ismember(superClassStr, listSuperclasses);
catch
    tf = false;
end

end