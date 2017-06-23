function ImgGroupObj = from_files(varargin)
%from_files - Create an ImgGroup object from a list of files
%
%   OBJ = ImgGroup.from_files() prompts for all required information and
%   creates an ImgGroup object from existing files.  The resulting children
%   will be of the same type and have the same config.
%
%   OBJ = ImgGroup.from_files(RAWIMGTYPE) loads the files into object of
%   the class specified by RAWIMGTYPE. RAWIMGTYPE must be a single row
%   character array representing one of the concrete subclasses of RawImg.
%   If RAWIMGTYPE is empty, the function prompts for RAWIMGTYPE.
%
%   OBJ = ImgGroup.from_files(RAWIMGTYPE, CONFIG) uses the specified CONFIG
%   object to create the children.  CONFIG must be a scalar concrete
%   object with the superclass Config. If CONFIG is empty, the function
%   prompts for CONFIG if necessary.
%
%   OBJ = ImgGroup.from_files(RAWIMGTYPE, CONFIG, PROCTYPE) creates
%   children of the type specified by PROCTYPE.  PROCTYPE must be a single
%   row character array representing one of the concrete subclasses of
%   Processable. If PROCTYPE is empty, the function prompts for PROCTYPE.
%
%   OBJ = ImgGroup.from_files(NAME, ...) specifies a name for the ImgGroup
%   object. NAME must be a single row character array, or a cell array
%   containging a single row character array; however, NAME must not be a
%   valid RAWIMGTYPE.
%
%   See also ImgGroup.add, RawImg.from_files

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

    % Check the first argument to see if it's the name
    nameIn = '';
    idxStart = 1;
    hasName = nargin > 0 && ischar(varargin{1}) && ...
        ~utils.issubclass(varargin{1}, 'RawImg');
    if hasName
        nameIn = varargin{1};
        idxStart = 2;
    end

    % Create an empty image group object
    ImgGroupObj = ImgGroup(nameIn);
    
    childrenOut = ImgGroupObj.from_files_sub(varargin{idxStart:end});
    
    % Add the ProcessedImg Objects to the ImgGroup
    ImgGroupObj.add(childrenOut{:})

end