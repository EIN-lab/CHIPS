function cpObj = copyElement(obj)
%copyElement - Customised copyElement class method to ensure that the
%   rawImg property and the children (which are both handle objects) are
%   recursively copied.
    
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
    
    % Make a shallow copy of the object
    cpObj = copyElement@matlab.mixin.Copyable(obj);

    % Make a deep copy of the rawImg object
    cpObj.rawImg = copy(obj.rawImg);

    % Attach a listener to update the properties when a new rawImg
    % is added to this object
    addlistener(cpObj, 'NewRawImg', @IRawImg.new_rawImg);

    % Deal with the children
    for iChild = 1:obj.nChildren

        % Copy the whole child ProcessedImg
        cpObj.children{iChild} = copy(obj.children{iChild});

        % Replace the ProcessedImg's rawImg object (i.e. the one inside
        % the RawImgComposite) with a handle that points to the parent
        % CompositeImg rawImg object
        cpObj.children{iChild}.rawImg.rawImg = cpObj.rawImg;

    end

end