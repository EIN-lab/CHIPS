function varargout = flip(self, varargin)
%flip - Flip the image data along a given dimension
%
%   [OBJfl] = flip(OBJ, DIM) flips a raw image object along the dimension
%   DIM. The documentation of the built-in function flip (link below) gives
%   more details on how this process works, but the following examples may
%   be useful:
%
%       [OBJrl] = flip(OBJlr, 2) flips OBJlr along the second dimension
%       (i.e. left to right) resulting in OBJrl.
%
%   Please see the <a href="matlab:web(fullfile(utils.CHIPS_rootdir, 'doc', 'html', 'id_pp_utilities.html'))">pre-processing utilities quick start guide</a> for 
%   additional documentation and examples.
%
% See also flip, RawImgDummy

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
narginchk(1, 2)

% Flip along first dimension, if not specified
if nargin == 2
    dim = varargin{1};
elseif nargin < 2
    dim = 1;
end

% The dim must be a scalar integer
utils.checks.scalar(dim, 'dimension')
utils.checks.integer(dim, 'dimension')

% If we have an array of RawImgs, call the flip function recursively
if ~isscalar(self)    
        
    % Call the flip function recursively
    nElems = numel(self);
    for iElem = 1:nElems
        [tempOutput(:, iElem)] = self(iElem).flip(dim);
    end
    varargout{1} = tempOutput;
    
    % Return out of the function now
    return
    
end

% That dim must be less than or equal to the number of dimensions available
sz = size(self.rawdata);
nDims = numel(sz);
utils.checks.less_than(dim, nDims, true, 'dimension');

% That dim must be non-singleton
if sz(dim) == 1
    warning('RawImg:Flip:SingletonDim', ...
        'Flipping along singleton dimensions won''t have any effect.');
end

% ---------------------------------------------------------------------- %

% Extract the other required information
nameBase = self.name;
acq = self.metadata.get_acq();
cal = self.metadata.calibration;
channels = self.metadata.channels; 

% Flip order of elements
rawdata = flip(self.rawdata, dim);

% Reorder channels structure, if necessary
if dim == 3 && sz(dim) > 1
    chNames = fieldnames(channels);
    chNos = struct2cell(channels);
    chNos = flip(chNos);
    
    %Assign ordered channels
    channels = cell2struct(chNos, chNames);   
end

% Create a new name for the RawImgDummy
nameIn = sprintf('%s-flip', nameBase);

% Create the actual RawImgDummy object
varargout{1} = RawImgDummy(nameIn, rawdata, channels, cal, acq);
    
end
