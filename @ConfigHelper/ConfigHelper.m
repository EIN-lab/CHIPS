classdef (Abstract) ConfigHelper < matlab.mixin.Copyable
%Config - Superclass for ConfigHelper classes
%
%   ConfigHelper is an abstract superclass that implements (or requires
%   implementation in its subclasses via abstract methods or properties)
%   most functionality related to ConfigHelper objects.
%
%   ConfigHelper is a subclass of matlab.mixin.Copyable, which is itself a
%   subclass of handle, meaning that ConfigHelper objects are actually
%   references to the data contained in the object.  This allows certain
%   features that are only possible with handle objects, such as events and
%   certain GUI operations.  However, it is important to use the copy
%   method of matlab.mixin.Copyable to create a new, independent object;
%   otherwise changes to a ConfigHelper object used in one place will also
%   lead to changes in another (perhaps undesired) place.
%   
% ConfigHelper public methods
%   copy            - Copy MATLAB array of handle objects
%
%   See also matlab.mixin.Copyable, handle

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
    
end
