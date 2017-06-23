function varargout = denoise(imgSeq, varargin)
%denoise - Denoising of an image sequence
%
%   This function implements a block matching 3D (BM3D) algorithm for
%   improving signal-to-noise ratio in two-photon imaging data. For further
%   information about BM3D, please refer to <a href="matlab:web('http://doi.org/10.1016/j.ymeth.2014.03.010', '-browser')">Danielyan et al. (2014)</a>, 
%   Methods 68(2):308-316.
%
%   CORRSEQ = denoise(IMGSEQ) denoises imgSeq using default parameters.
%   IMGSEQ must be a numeric array with at least 3 dimensions.  If IMGSEQ
%   is an integer data type, it will be converted into a single precision
%   floating point array.
% 
%   CORRSEQ = denoise(..., 'attribute', value) specifies one or more 
%   attribute/value pairs.  Valid attributes (case insensitive) are:
%
%       'force4D' ->        Boolean flag whether to force the slider to
%                           treat the IMG as 4D, even if it only has 3
%                           dimension. This is useful when trying to view
%                           an image that only has one frame, but more than
%                           one channel. [default = []]
%       'skipChs' ->        Image channel(s) that the denoising is not
%                           applied to. [default = []]
%       'profile' ->        Quality / complexity trade-off. Options are:
%                               'np' (Normal Profile, balanced quality),
%                               'lc' (Low Complexity profile, faster but 
%                                   lower quality), and
%                               'hi' (High profile).
%                           [default ='np']
%
%   [CORRSEQ, CORR_CHS] = denoise(IMGSEQ) additionally outputs an array of
%   channel indices that have been processed.
%
%   See also RawImg.denoise, utils.invansc.denoise_VBM3D,
%   utils.invansc.VBM3D

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

%% Check parameter assignments

% Check the number of input arguments
narginchk(1, inf)

% Define allowed optional arguments and default values
pNames = {...
    'force4D'; ...
    'skipChs'; ...
    'profile'; ...
    };
pValues  = {...
    []; ...
    []; ...
    'np'; ...
    };
dflts = cell2struct(pValues, pNames);

% Parse function input arguments
params = utils.parsepropval(dflts, varargin{:});
paramsIn = rmfield(params, {'force4D', 'skipChs'});

% Check the format of the image sequence
utils.checks.object_class(imgSeq, 'numeric', 'image sequence');

% Check input is a stack of the appropriate dimensions
if params.force4D
    nDimsImg = 4;
else
    nDimsImg = ndims(imgSeq);
    is3D = nDimsImg == 3;
    if is3D
        imgSeq = permute(imgSeq, [1, 2, 4, 3]);
    end
end
allowEq = true;
utils.checks.less_than(nDimsImg, 4, allowEq, 'number of image dimensions')
utils.checks.greater_than(nDimsImg, 3, allowEq, 'number of image dimensions')

% Save input dimensions for later use
[~, ~, nChs, ~] = size(imgSeq);

% Check the skipChannels
if ~isempty(params.skipChs)
    utils.checks.integer(params.skipChs, 'channel');
    utils.checks.less_than(params.skipChs, nChs, true, 'channel');
end

% ---------------------------------------------------------------------- %
%% Perform Denoising

% Initialise a progress bar
isParallel = utils.is_parallel();
isWorker = utils.is_on_worker();
if ~isWorker
    strMsg = 'Denoising sequence';
    if isParallel
        fnPB = utils.progbarpar('msg', strMsg);
    else
        fnPB = '';
        utils.progbar(0, 'msg', strMsg);
    end
else
    strMsg = '';
end

% Loop through the relevant channels and do the denoising
chsUse = setdiff(1:nChs, params.skipChs);
nChsUse = numel(chsUse);

for iChUse = 1:nChsUse
    
    % Pull out the appropriate channel and denoise it
    iCh = chsUse(iChUse);
    imgSeq(:, :, iCh, :) = utils.denoise_VBM3D(...
        imgSeq(:, :, iCh, :), paramsIn);
    
    % Update the progress bar
    if ~isWorker
        if isParallel
            utils.progbarpar(fnPB, nChsUse, 'msg', strMsg);
        else
            utils.progbar(iChUse / nChsUse, ...
                'msg', strMsg, 'doBackspace', true);
        end
    end

end

% Close the progress bar
if ~isWorker && isParallel
    utils.progbarpar(fnPB, 0, 'msg', strMsg);
end

% ---------------------------------------------------------------------- %
%% Assign output arguments

% Restore the image sequence to 3d, if necessary
if is3D
    imgSeq = squeeze(imgSeq);
end

varargout{1} = imgSeq;
varargout{2} = chsUse;

end
