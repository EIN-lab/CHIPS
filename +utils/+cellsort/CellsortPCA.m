function [mixedsig, mixedfilters, CovEvals, covtrace, mov, movm, ...
    movtm] = CellsortPCA(imgSeq, fLims, nPCs, dsamp, badFrames)
% CELLSORT
% Read Image rawdata and perform singular-value decomposition (SVD)
% dimensional reduction.
%
% Inputs:
%   ImgSeq - Image stack, must be single-channel, squeezed to 3D.
%   fLims - 2-element vector specifying the endpoints of the range of
%   frames to be analyzed. If empty, default is to analyze all movie
%   frames.
%   nPCs - number of principal components to be returned
%   dsamp - optional downsampling factor. If scalar, specifies temporal
%   downsampling factor. If two-element vector, entries specify temporal
%   and spatial downsampling, respectively.
%   badFrames - optional list of indices of movie frames to be excluded
%   from analysis
%
% Outputs:
%   mixedsig - N x T matrix of N temporal signal mixtures sampled at T
%   points.
%   mixedfilters - N x X x Y array of N spatial signal mixtures sampled at
%   X x Y spatial points.
%   CovEvals - largest eigenvalues of the covariance matrix
%   covtrace - trace of covariance matrix, corresponding to the sum of all
%   eigenvalues (not just the largest few)
%   mov - Movie frames (~imgSeq) with applied downsampling
%   movm - average of all movie time frames at each pixel
%   movtm - average of all movie pixels at each time frame, after
%   normalizing each pixel deltaF/F
%
% Eran Mukamel, Axel Nimmerjahn and Mark Schnitzer, 2009
% Email: eran@post.harvard.edu, mschnitz@stanford.edu
%

%% Check Inputs
narginchk(1, inf)

% Check the format of the image sequence
utils.checks.object_class(imgSeq, 'numeric', 'image sequence');
if ismatrix(imgSeq)
    error('Utils:MotionCorrect:NotEnoughDims', ['The image sequence ' ...
        'must have at least 3 dimensions to perform motion correction'])
end

% Image dimensions
[numLines, nPxlPerLine, numFrames] = size(imgSeq);

if (nargin<2)||(isempty(fLims))
    fLims = [1,numFrames];
end
if nargin<5
    badFrames = [];
end

useframes = setdiff((fLims(1):fLims(2)), badFrames);
nt = length(useframes);

if nargin<3 || isempty(nPCs)
    % Default 100, consistent with default property
    nPCs = min(100, nt);
elseif nPCs > nt
    warning('CellSortPCA:TooManyPCs', ['The number of principal ' ...
        'components was specified as %d, but has been reduced to the ' ...
        'maximum allowable value (%d), which is the number of ' ...
        'image frames.'],  nPCs, nt)
    nPCs = nt; 
end

if nargin<4 || isempty(dsamp)
    dsamp = [1,1];
end

%% Load Data
% Get dimensionality in space
npix = numLines * nPxlPerLine;

% fprintf('   %d pixels x %d time frames;', npix, nt)

%% Do PCA

% Create covariance matrix, decide which problem is smaller and go for it
isT = nt < npix;
[covmat, mov, movm, movtm, numLines, nPxlPerLine] = ... 
    utils.cellsort.create_cov(imgSeq, numLines, nPxlPerLine, useframes, ...
        nt, dsamp, isT);

% Reassign variables after downsampling
npix = numLines*nPxlPerLine;
nt = size(mov,2);

% Compute sum of diag elements to assess explained variance
covtrace = trace(covmat) / npix;

% Matrix of mean pixel values in time
movm = reshape(movm, numLines, nPxlPerLine);

if nt < npix 
    
    % Perform SVD on temporal covariance
    [mixedsig, CovEvals] = utils.cellsort.cellsort_svd(covmat, nPCs, ...
        nt, npix);

    % Load the other set of principal components
    [mixedfilters] = utils.cellsort.reload_moviedata(npix, mov, ...
        mixedsig, CovEvals);
    
else
    
    % Perform SVD on spatial components
    [mixedfilters, CovEvals] = utils.cellsort.cellsort_svd(covmat, ...
        nPCs, nt, npix);
    mixedfilters = mixedfilters' * npix;
    
    % Load the other set of principal components
    [mixedsig] = utils.cellsort.reload_moviedata(nt, mov', ...
        mixedfilters', CovEvals);
    mixedsig = mixedsig' / npix^2;
    
end

nPCs_ds = size(mixedfilters,2); % Number of Components after downsampling
mixedfilters = reshape(mixedfilters, numLines, nPxlPerLine, nPCs_ds);
mov = reshape(mov, numLines, nPxlPerLine, []);

end
