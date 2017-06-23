function clear_persistent()
%clear_persistent - Helper function for clearing persistent variables
%
%   Clears persistent variables by clearing the class/function that they
%   belong to.  This seems to be the cleanest way, although it means
%   updating the list below for every new persistent variable.

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
narginchk(0, 0);

persObjs = {...
    'RawImg', ...
    'CalibrationPixelSize/load'};

clear(persObjs{:})

end
