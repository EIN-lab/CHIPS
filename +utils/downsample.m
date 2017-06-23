function corrSeq = downsample(imgSeq, dsamp, varargin)
%downsample - Downsample image sequence in space and/or time
%
%   CORRSEQ = downsample(IMG, DSAMP) downsamples IMGSEQ in space and/or
%   time.  IMGSEQ must be a numeric array with either 3 or 4 dimensions.
%   For 4D IMGSEQ, the fourth dimension is assumed to represent time.
%   DSAMP, the downsampling factor, can be a numeric scalar or 2 element
%   vector.  For DSAMP = 2, CORRSEQ will have half as many pixels in both
%   spatial dimensions compared to IMGSEQ, and half as many frames. DSAMP
%   corresponds to [DSAMP_XY, DSAMP_T] when it has two elements.
%
%   CORRSEQ = downsample(..., 'attribute', value, ...) uses the specified
%   attribute/value pairs.  Valid attributes (case insensitive) are:
%
%       'force4D' ->    Boolean flag whether to force the function to treat
%                       the IMG as 4D, even if it only has 3 dimension.
%                       This is useful when trying to downsample an image
%                       that only has one frame, but more than one channel.
%                       [default = false]
%
%       'method' ->     A method in the format expected by the function
%                       imresize.  See the link to the function below for
%                       more details. [default = 'bilinear']
%
%   See also utils.resize_img, imresize, RawImg.downsample

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

%% Assign Parameters, do checks

% Check the number of input arguments
narginchk(2, inf);

% Define allowed optional arguments and default values
pNames = {...
    'force4D'; ...
    'method'};
pValues  = {...
    false; ...
    'bilinear';};
dflts = cell2struct(pValues, pNames);

% Parse any input arguments
params = utils.parsepropval(dflts, varargin{:});

% Check image stack
utils.checks.object_class(imgSeq, 'numeric', 'image');
if params.force4D
    nDimsImg = 4;
else
    nDimsImg = ndims(imgSeq);
end
allowEq = true;
strDims = 'Number of dimensions of the image';
utils.checks.greater_than(nDimsImg, 3, allowEq, strDims);
utils.checks.less_than(nDimsImg, 4, allowEq, strDims);

% Check dsamp
utils.checks.integer(dsamp, 'dsamp');
utils.checks.positive(dsamp, 'dsamp');
if isscalar(dsamp)
    dsamp = repmat(dsamp, 1, 2);
end
utils.checks.length(dsamp, 3, 'dsamp', 'less')

% Work out what we're doing
dsamp_xy = dsamp(1);
dsamp_t = dsamp(2);
doXY = dsamp_xy > 1;
doT = dsamp_t > 1;
doNothing = ~doXY && ~doT;
if doNothing
    corrSeq = imgSeq;
    warning('Downsample:NoChange', ['Neither downsampling factor ', ...
        'was > 1 so the image did not change.'])
    return
end

% Extract the dimensions
if nDimsImg == 4
    [nY, nX, ~, nT] = size(imgSeq);
elseif nDimsImg == 3
    [nY, nX, nT] = size(imgSeq);
end

% Turn off unneeded warnings for now
[lastMsgPre, lastIDPre] = lastwarn();
wngIDOff = {'ResizeImg:Resizing', 'ResizeImg:NonUniform'};
wngState = warning('off', wngIDOff{1});
warning('off', wngIDOff{2});

%% Main part of the function

% Spatial Downsampling
if doXY
    newYX = ceil([nY, nX] .* (1/dsamp_xy));
    corrSeq = utils.resize_img(imgSeq, newYX, params.method);
end

% Temporal Downsampling
if doT
    permOrder = [nDimsImg, 1:(nDimsImg-1)];
    corrSeq = permute(corrSeq, permOrder);
    newTY = [ceil(nT/dsamp_t), newYX(1)];
    corrSeq = utils.resize_img(corrSeq, newTY, params.method);
    corrSeq = ipermute(corrSeq, permOrder);
end

% Restore the warnings
warning(wngState);
utils.clear_unwanted_wngs(wngIDOff, lastMsgPre, lastIDPre)

end
