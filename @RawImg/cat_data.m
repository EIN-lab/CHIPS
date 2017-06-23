function rawImg = cat_data(varargin)
%cat_data - Concatenate the data from RawImg objects
%
%   OBJ = RawImg.cat_data(RAWIMG1, RAWIMG2, RAWIMG3, ...) concatenates the
%   data from the RawImg objects into a new RawImgDummy object. By default,
%   the images frames are appended; see below for more options.  The RawImg
%   objects must be able to be concatenated; i.e., they must have the same
%   acquisition settings, channels, and calibration, and the image sizes
%   must match.  Any non-scalar RawImg objects are recursively
%   concatenated.
%
%   OBJ = RawImg.cat_data(DIM, ...) concatenates the data along the
%   dimension specified by DIM.  DIM must be a number from 1 to 4,
%   corresponding to the 4 known image dimensions (rows, columns, channels,
%   frames).
%
%   OBJ = RawImg.cat_data(DIM, NAME, ...) sets NAME as the name of the
%   newly-constructed RawImgDummy object. NAME must be a single row
%   character array.
%
%   Please see the <a href="matlab:web(fullfile(utils.CHIPS_rootdir, 'doc', 'html', 'id_pp_utilities.html'))">pre-processing utilities quick start guide</a> for 
%   additional documentation and examples.
%
%   See also cat, RawImgDummy, RawImg.split1, Metadata,
%   CalibrationPixelSize

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

    % Check the first argument to see if it's the dim
    dimIn = 4;
    idxStart = 1;
    hasDim = nargin > 1 && ...
        (isnumeric(varargin{1}) && isscalar(varargin{idxStart}));
    if hasDim
        utils.checks.integer(varargin{idxStart}, 'dim')
        utils.checks.less_than(varargin{idxStart}, 4, true, 'dim')
        dimIn = varargin{idxStart};
        idxStart = idxStart + 1;
    end

    % Check the next argument to see if it's the name
    nameIn = '';
    hasName = nargin > idxStart && (ischar(varargin{idxStart}));
    if hasName
        utils.checks.single_row_char(varargin{idxStart}, 'name')
        nameIn = varargin{idxStart};
        if ischar(nameIn)
            nameIn = {nameIn};
        end
        idxStart = idxStart + 1;
    end

    % Check inputs are RawImgs
    isAllRawImg = all(cellfun(@(xx) isa(xx, 'RawImg'), ...
        varargin(idxStart:end)));
    if ~isAllRawImg
        error('RawImg:Join:NotRawImgs', ['The inputs must be ' ...
            'objects with the superclass "RawImg"'])
    end
    
    % Work out how many images we have
    nVarArgs = numel(varargin);
    idxsVarArgs = idxStart:nVarArgs;
    nImgArgs = numel(idxsVarArgs);
    if nImgArgs < 1
        error('RawImg:Cat_Data:NotEnoughInput', ['At least one RawImg ' ...
            'object is required'])
    end

    % Check inputs are scalar, and recursively call cat if not
    for iArgRI = 1:nImgArgs
        iIdxRI = idxsVarArgs(iArgRI);
        if ~isscalar(varargin{iIdxRI})
            tempCell = num2cell(varargin{iIdxRI});
            varargin{iIdxRI} = RawImg.cat_data(tempCell{:});
            clear tempCell
        end
    end

    % Check acq is combineable (i.e. equal)
    acqList = cell(1, nImgArgs);
    for iArgAcq = 1:nImgArgs
        acqList{iArgAcq} = ...
            varargin{idxsVarArgs(iArgAcq)}.metadata.get_acq();
    end
    isAcqOK = (nImgArgs == 1) || isequal(acqList{:});
    if ~isAcqOK
        error('RawImg:Join:BadAcq', ['The "acq" structures must '...
            'all be identical'])
    end

    % Check channels are combineable (i.e. equal)
    chList = cell(1, nImgArgs);
    for iArgCh = 1:nImgArgs
        chList{iArgCh} = varargin{idxsVarArgs(iArgCh)}.metadata.channels;
    end
    isChannelOK = (nImgArgs == 1) || isequal(chList{:});
    if ~isChannelOK
        error('RawImg:Join:BadChannel', ['The "channel" ' ...
            'structures must all be identical'])
    end

    % Check calibrations are combineable (i.e. equal)
    calList = cell(1, nImgArgs);
    for iArgCal = 1:nImgArgs
        calList{iArgCal} = ...
            varargin{idxsVarArgs(iArgCal)}.metadata.calibration;
    end
    isCalOK = (nImgArgs == 1) || isequal(calList{:});
    if ~isCalOK
        error('RawImg:Join:BadCalibration', ['The calibrations ' ...
            'must all be identical'])
    end

    % Check rawdata sizes are combineable, (i.e. rows, columns and
    % channels are all equal)
    dimsToCheck = (1:4) ~= dimIn;
    imgSize = cell(1, nImgArgs);
    for iArgRD1 = 1:nImgArgs
        nDimsRD1 = ndims(varargin{idxsVarArgs(iArgRD1)}.rawdata);
        imgSizeTemp = ones(1, 4);
        imgSizeTemp(1:nDimsRD1) = ...
            size(varargin{idxsVarArgs(iArgRD1)}.rawdata);
        imgSize{iArgRD1} = imgSizeTemp(dimsToCheck);
    end
    isOKSize = (nImgArgs == 1) || isequal(imgSize{:});
    if ~isOKSize
        error('RawImg:Join:BadRawdata', ['The rawdata must ' ...
            'have the same number of rows, columns and channels'])
    end
    rawdata = [];
    for iArgRD2 = 1:nImgArgs
        rawdata = cat(dimIn, rawdata, ...
            varargin{idxsVarArgs(iArgRD2)}.rawdata);
    end

    % Create the dummy rawImg by combining the input arguments
    rawImg = RawImgDummy(nameIn, rawdata, chList{1}, ...
        calList{1}, acqList{1});

end