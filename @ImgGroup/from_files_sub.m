function childrenOut = from_files_sub(varargin)
%from_files_sub - Protected helper function to create children for an
%   ImgGroup object from a list of files

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
[rawImgType, configIn, procImgType] = utils.parse_opt_args(...
    {[], [], []}, varargin);

% Check RawImg

% Work out which class of ProcessedImg we want to create
hProcessable = ImgGroup.create_constructor_processable(procImgType);

% Create the RawImg Object Array
fileNameList = [];
channels = [];
calibration = [];
rawImgArray = RawImg.from_files(rawImgType, fileNameList, ...
    channels, calibration);

% Create the ProcessedImg Objects
childrenOut = ImgGroup.from_rawImgs(rawImgArray, configIn, hProcessable);
    
end
