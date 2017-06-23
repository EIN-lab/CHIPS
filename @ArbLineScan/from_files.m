function ArbLineScanObj = from_files(varargin)
%from_files - Create an ArbLineScan object from a list of files
%
%   OBJ = ArbLineScan.from_files() prompts for all required information
%   and creates an ArbLineScan object from existing files.
%
%   OBJ = ArbLineScan.from_files(RAWIMGTYPE) loads the files into object
%   of the class specified by RAWIMGTYPE. RAWIMGTYPE must be a single row
%   character array representing one of the concrete subclasses of RawImg.
%   If RAWIMGTYPE is empty, the function prompts for RAWIMGTYPE.
%
%   OBJ = ArbLineScan.from_files(RAWIMGTYPE, CONFIG) uses the specified
%   CONFIG object to create the children.  The CONFIG must be a scalar
%   concrete object with the superclass Config. If CONFIG is empty, the
%   function prompts for CONFIG if necessary.
%
%   OBJ = ArbLineScan.from_files(RAWIMGTYPE, CONFIG, PROCTYPE) creates
%   children of the type specified by PROCTYPE.  PROCTYPE must be a single
%   row character array representing one of the concrete subclasses of
%   Processable. If PROCTYPE is empty, the function prompts for PROCTYPE.
%
%   OBJ = ArbLineScan.from_files(RAWIMGTYPE, CONFIG, PROCTYPE, MASK)
%   creates children using the specified MASK to create the
%   RawImgComposite object. MASK must be convertible to a logical array
%   and meet the other requirements to act as a RawImgComposite mask.
%
%   OBJ = ArbLineScan.from_files(NAME, ...) specifies a name for the
%   ArbLineScan object. NAME must be a single row character array, or a
%   cell array containging a single row character array.
%
%   See also ArbLineScan.add, RawImg.from_files, RawImgComposite

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
    hasName = nargin > 0 && ischar(varargin{1});
    if hasName
        nameIn = varargin{1};
        idxStart = 2;
    end
    
    % Parse the remaining arguments
    [rawImgType, config, procType, masks] = utils.parse_opt_args(...
        {[], [], [], []}, varargin(idxStart:end));
    
    % Create the RawImg Object Array
    fileNameList = [];
    channels = [];
    calibration = [];
    rawImgArray = RawImg.from_files(rawImgType, fileNameList, ...
        channels, calibration);

    % Create the ArbLineScan object
    ArbLineScanObj = ArbLineScan(nameIn, rawImgArray, config, ...
        procType, masks);

end