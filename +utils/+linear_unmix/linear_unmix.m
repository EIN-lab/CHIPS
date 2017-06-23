function [img_u, MM] = linear_unmix(img, varargin)
%linear_unmix - Perform linear unmixing of image channels
%
%   IMG = linear_unmix(IMG) prompts for all required information, and
%   performs linear spectral unmixing on IMG, an MxNxCxP image array, where
%   MxN are the dimensions of the image(s), C is the number of channels,
%   and P the number of frames.
%
%   IMG = linear_unmix(IMG, N_FP) specifies the number of unique
%   fluorophores contained in the image.  N_FP must be a positive integer
%   not larger than C.  If empty or not specified, and not implied via
%   other arguments, the function will prompt for the value of N_FP.
%
%   IMG = linear_unmix(IMG, N_FP, MASKS) specifies regions containing
%   exclusively a single fluorophore, and a mutual background region. MASKS
%   must be a 3D logical array, and will be resized so the number of rows
%   and columns match IMG.  If N_FP is specified, size(MASKS, 3) must equal
%   (N_FP + 1). MASKS(:,:,end) corresponds to the mutual background region.
%
%   IMG = linear_unmix(IMG, N_FP, MM) specifies the mixing matrix, MM,
%   which must be of size [C, N_FP]. MM(i,j) corresponds to the fractional
%   contribution of the jth fluorophore to the ith image channel.
%
%   IMG = linear_unmix(IMG, N_FP, MM, BG) specifies the background value
%   for each image channel.  BG must be a numeric vector of length C.  If
%   unspecified, the all background values are assumed to be 0.
%
%   [IMG, MM] = linear_unmix(...) returns the mixing matrix, which can be
%   reused for other images containing the same fluorophores.
%
%   See also RawImg.unmix_chs, utils.unmix_chs,
%   utils.linear_unmix.assemble_mixmat

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

% Check number of inputs.
narginchk(1, 4);

% Parse the optional arguments
[nFPs, maskORmixMat, bgCh] = utils.parse_opt_args({[], [], []}, varargin);

% Check input image
utils.checks.object_class(img, {'numeric'}, 'image sequence')
utils.checks.greater_than(ndims(img), 2, 1, 'Number of image dimensions')
utils.checks.less_than(ndims(img), 4, 1, 'Number of image dimensions')

% Get some image dimensions
[nRows, nCols, nChs, nFrames] = size(img);
img = double(img);

%% Choose/check the number of fluorophores

hasMaskORmatFP = ~isempty(maskORmixMat);
doChooseNFPs = isempty(nFPs) && ~hasMaskORmatFP;
if doChooseNFPs
    
    % If we don't have enough channels, assume the same number of channels
    % and fluorophores, otherwise prompt the user to choose
    if nChs <= 2
        nFPs = nChs;
    else
        strTitle = ...
            'How many unique fluorophores are present in the image?';
        listOptions = [{''}, {''}, num2cell(2:nChs)];
        defOption = nChs;
        nFPs = utils.txtmenu({strTitle, 'Number of fluorophores: '}, ...
            defOption, listOptions);
    end
    
elseif ~isempty(nFPs)
    utils.checks.prfsi(nFPs, 'number of fluorophores');
end

%% Work out what to do with the second optional argument (i.e. what it is)

% Use a utility function to get the masks if nothing's supplied
if ~hasMaskORmatFP
    maskORmixMat = utils.linear_unmix.select_fp_masks(img, nFPs);
end

% Check if the input is a mask to define the fluorophore regions, or a
% matrix of mixing values
hasMask = ndims(maskORmixMat) == 3;
hasMixMat = isnumeric(maskORmixMat) && ismatrix(maskORmixMat);
if hasMask
    
    % Check the mask, and convert it to a logical
    maskFPBG = maskORmixMat;
    utils.checks.logical_able(maskFPBG, 'mask')
    maskFPBG = logical(utils.resize_img(maskFPBG, [nRows, nCols]));
    
    % Work out how many fluorophores are implied, and check it matches up
    nFPs_implied = size(maskFPBG, 3) - 1;
    if isempty(nFPs)
        nFPs = nFPs_implied;
    else
        utils.checks.prfsi(nFPs, 'number of fluorophores');
        utils.checks.equal(nFPs, nFPs_implied, ...
            'specified number of fluorophores', ...
            'number of fluorophores implied by the mask')
    end
    
    % Assemble the mixing matrix using a utility function
    [MM, bgCh] = utils.linear_unmix.assemble_mixmat(img, maskFPBG);

elseif hasMixMat

    % Extract and check the mixing matrix
    MM = maskORmixMat;
    utils.checks.object_class(MM, 'numeric', 'mixing matrix')
    utils.checks.num_dims(MM, 2, 'mixing matrix')
    utils.checks.greater_than(MM, 0, 1, 'mixing matrix')
    utils.checks.less_than(MM, 1, 1, 'mixing matrix')
    
    % Sort out the channel background values
    if isempty(bgCh)
        bgCh = zeros(1, nChs);
    else
        utils.checks.object_class(bgCh, 'numeric', ...
            'channel background values')
        utils.checks.greater_than(bgCh, 0, 1, 'channel background values')
        utils.checks.vector(bgCh, 'channel background values')
        utils.checks.numel(bgCh, nChs, 'channel background values')
    end

    % Work out how many channels and fluorophores are implied
    nFPs_implied = size(MM, 2);
    nChs_implied = size(MM, 1);

    % Check everything matches up
    if isempty(nFPs)
        nFPs = nFPs_implied;
    else
        utils.checks.equal(nFPs, nFPs_implied, ...
            'specified number of fluorophores', ...
            'number of fluorophores implied by the mixing matrix')
    end
    utils.checks.equal(nChs, nChs_implied, ...
        'actual number of image channels', ...
        'number of image channels implied by the mixing matrix')

else

    % Throw an error is something weird is happening
    error('SpecUnmix:UnrecognisedArgument', ['The argument is not ' ...
        'recognised as either a mask of the fluorophore regions ' ...
        'or a mixing matrix.'])

end

% Check we have a right number of channels
utils.checks.greater_than(nChs, nFPs, 1, 'Number of channels')

%% Do the actual unmixing

% Reshape the image into a 2D matrix, and subtract the background
for iCh = nChs:-1:1
    chTemp = img(:,:,iCh,:);
    IIr(iCh, :) = chTemp(:) - bgCh(iCh);
end
isBG = repmat(any(IIr < 0, 1), [nFPs, 1]);

% Solve for the fluorophore contributions, either by linear algebra (if
% there the same number of as fluorophores) or linear least squares (if
% there are more channels than fluorophores)
FF = MM \ IIr;
FF(isBG) = 0;

% Work out which pixels to redo
isNeg = any(FF < 0, 1);
listNegPixels = find(isNeg);

% Loop through and redo the negative pixels using the slower constrained
% algorithm (lsqnonneg)
IIr_neg = IIr(:, listNegPixels);
FF_neg = utils.lsqnonnegvect(MM, IIr_neg);
FF(:, listNegPixels) = FF_neg;

% Reshape the 2D matrix of fluorophores back into an image
for iFP = nFPs:-1:1
    img_u(:,:,iFP,:) = reshape(FF(iFP,:), nRows, nCols, 1, nFrames);
end

end
