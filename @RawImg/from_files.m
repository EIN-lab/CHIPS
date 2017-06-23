function rawImg = from_files(varargin)
%from_files - Create a RawImg object from a list of files
%
%   OBJ = RawImg.from_files() prompts for all required information and
%   creates a concrete RawImg subclass object.
%
%   OBJ = RawImg.from_files(RAWIMGTYPE) creates an object of the class
%   specified by RAWIMGTYPE. RAWIMGTYPE must be a single row character
%   array representing one of the concrete subclasses of RawImg.  If
%   RAWIMGTYPE is empty, the function prompts for RAWIMGTYPE.
%
%   OBJ = RawImg.from_files(RAWIMGTYPE, FILENAME) creates an object from
%   the specified filename(s).  FILENAME must be a single row character
%   array, or a cell array containing only single row character arrays. If
%   FILENAME is empty, the constructor will prompt to select one or more
%   files.
%
%   OBJ = RawImg.from_files(RAWIMGTYPE, FILENAME, CHS) specifies the
%   metadata channels contained in the image.  CHS must be a structure of
%   the type expected by Metadata.  If CHS is empty, the constructor will
%   prompt for all required information.
%
%   OBJ = RawImg.from_files(RAWIMGTYPE, FILENAME, CHS, CAL) specifies the
%   pixel size calibration for the image.  CAL must be a scalar
%   CalibrationPixelSize object.  If calibration is empty, the constructor
%   will prompt to select one.
%
%   See also RawImg.RawImg, Metadata, CalibrationPixelSize

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

    % Parse arguments
    wngState = warning('off', 'ParseOptArgs:TooManyInputs');
    [strRawImgType, fileNameList, chsIn, calIn] = utils.parse_opt_args(...
        {'', [], [], []}, varargin);
    warning(wngState)
    
    % Create a constructor for the desired type of RawImg object
    hRawImg = RawImg.create_constructor_rawImg(strRawImgType);
    
    % Create the RawImg Object Array
    rawImg = hRawImg(fileNameList, chsIn, calIn);

end
