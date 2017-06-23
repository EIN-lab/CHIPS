function varargout = split1(self, dim, dimDist)
%split1 - Split the image data along a given dimension
%
%   [OBJA, OBJB, ...] = split1(OBJ, DIM, DIMDIST) splits a raw image object
%   into smaller RawImgDummy objects along the dimension DIM, based on the
%   distance vector DIMDIST.  The number of output arguments is determined
%   by numel(DIMDIST), and the size of the rawdata of the output objects is
%   determined by the DIMDIST vector.  The elements of the DIMDIST vector
%   must sum to the total number of image pixels along the dimension dim.
%   The documentation of the built-in function mat2cell (link below) gives
%   more details on how this process works, but the following examples may
%   be useful:
%
%       [OBJ12, OBJ3] = split1(OBJ123, 3, [2 1]) splits OBJ123 along the
%       third dimension (i.e. channels) into OBJ12 (which contains the
%       original channels 1 and 2) and OBJ3 (which contains the original
%       channel 3).
%
%       [OBJ1, OBJ23] = split1(OBJ123, 3, [1 2]) behaves similarly, but
%       OBJ1 contains only the original channel 1, while OBJ23 contains the
%       original channels 2 and 3.
%
%       [OBJ1TO50, OBJ51TO100] = split1(OBJ1TO100, 4, [50 50]) splits
%       OBJ1TO100 along the 4th dimension (i.e. frames) into two objects,
%       each containing 50 frames from the original image; OBJ1TO50
%       contains the original frames 1:50, while OBJ51TO100 contains the
%       original frames 51:100.
%
%   Please see the <a href="matlab:web(fullfile(utils.CHIPS_rootdir, 'doc', 'html', 'id_pp_utilities.html'))">pre-processing utilities quick start guide</a> for 
%   additional documentation and examples.
%
% See also mat2cell, RawImgDummy, RawImg.cat_data

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

% Check the number of arguments in
narginchk(3, 3)

% The dim must be a scalar integer
utils.checks.scalar(dim, 'dimension')
utils.checks.integer(dim, 'dimension')

%  The dimDist must be a vector of integers
utils.checks.integer(dimDist, 'distance vector');
utils.checks.vector(dimDist, 'distance vector');

% If we have an array of RawImgs, call the split1 function recursively
if ~isscalar(self)
    
    % Prepare some temporary output arguments
    nElems = numel(self);
    nOutputs = numel(dimDist);
    tempOutputs = cell(nElems, nOutputs);
    
    % Call the split1 function recursively
    for iElem = 1:nElems
        [tempOutputs{iElem, :}] = self(iElem).split1(dim, dimDist);
    end
    
    % Package up the output arguments
    for iOutput = nOutputs:-1:1
        varargout{iOutput} = [tempOutputs{:, iOutput}];
    end
    
    % Return out of the function now
    return
    
end

% That dim must be less than or equal to the number of dimensions available
sz = size(self.rawdata);
nDims = numel(sz);
utils.checks.less_than(dim, nDims, true, 'dimension');

% Check that the dimDist vector matches the actual dimensions of the image
nImgs = numel(dimDist);
isGoodDist = sum(dimDist) == sz(dim);
if ~isGoodDist
    error('RawImg:Split1:BadDimDistSum', ['The distance vector ' ...
        'elements must add up to the total number of pixels in this ' ...
        'image dimension']);
end

% ---------------------------------------------------------------------- %

% Create a cell containing the actual image data
szCell = num2cell(sz);
szCell{dim} = dimDist;
rawdata = mat2cell(self.rawdata, szCell{:});
rawdata = rawdata(:);

% Extract the other required information
nameBase = self.name;
acq = self.metadata.get_acq();
cal = self.metadata.calibration;

% Create the dummy rawImg by combining the input arguments
varargout = cell(1, nImgs);

for iImg = 1:nImgs
    
    % Organise the channels information if we're splitting channels
    if dim == 3
        
        % Re-initialise the channels and jCh counter for each new image
        % The jCh counter is designed to track the channel number in the
        % current (i.e. new) RawImgDummy object
        channels = struct([]);
        jCh = 1;
        
        % Initialise the kCh counter only once.  This counter is designed
        % to keep track of the channel number in the original RawImg object
        if iImg == 1
            kCh = 1;
        end
        
        % Create a new channels structure for the current image
        while jCh <= dimDist(iImg)
            iChName = self.get_ch_name(kCh);
            iChName = iChName{:};
            if ~isempty(iChName)
                channels(1).(iChName) = jCh;
            end
            jCh = jCh + 1;
            kCh = kCh + 1;
        end
        
    else
        
        % We don't need to change the channels for different dimensions
        channels = self.metadata.channels;
        
    end
    
    % Create a new name for the RawImgDummy
    nameIn = sprintf('%s-split-%03d', nameBase, iImg);
    
    % Create the actual RawImgDummy objects
    varargout{iImg} = RawImgDummy(nameIn, rawdata{iImg}, ...
        channels, cal, acq);
    
end

end
