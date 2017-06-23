function [MM, bgCh] = assemble_mixmat(img, maskFPBG)
%assemble_mixmat - Assemble the mixing matrix based on masked regions
%
%   MM = assemble_mixmat(IMG, MASKS) assembles a mixing matrix MM for the
%   image IMG using the exclusive fluorophore regions identified using
%   MASKS.
%   IMG must be an MxNxCxP image array, where MxN are the dimensions of the
%   image(s), C is the number of channels, and P the number of frames.
%   MASKS must be a 3D logical array, and will be resized so the number of
%   rows and columns match IMG. size(MASKS, 3) = (N_FP + 1), where N_FP is
%   the number of fluorophores found in IMG. MASKS(:,:,end) corresponds to
%   the mutual background region.
%   The mixing matrix, MM, is of size [C, N_FP], and can be used for
%   subsequent spectral unmixing. MM(i,j) corresponds to the fractional
%   contribution of the jth fluorophore to the ith image channel.
%
%   [MM, BG] = assemble_mixmat(...) also returns the background value for
%   each image channel
%
%   See also utils.linear_unmix.linear_unmix,
%   utils.linear_unmix.select_fp_masks

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
narginchk(2, 2);

% Check the input image
utils.checks.object_class(img, {'numeric'}, 'image sequence')
utils.checks.greater_than(ndims(img), 2, 1, 'Number of image dimensions')
utils.checks.less_than(ndims(img), 4, 1, 'Number of image dimensions')
img = double(img);
[nRows, nCols, nChs, ~] = size(img);

% Check the masks, convert them to a logical, and split into the
% fluorophores and background
utils.checks.logical_able(maskFPBG, 'mask')
utils.checks.equal(ndims(maskFPBG), 3, 'Number of dimensions of the mask')
maskFPBG = logical(utils.resize_img(maskFPBG, [nRows, nCols]));
maskFP = maskFPBG(:,:,1:end-1);
maskBG = maskFPBG(:,:,end);
nFPs = size(maskFP, 3);

%% Main part of the function

% Assemble the mixing matrix
isFirst = true;
idxBG = find(maskBG);
II_mean = squeeze(mean(img, 4));
for iFP = nFPs:-1:1

    % Extract the appropriate pixels on each channel
    idxFP = find(maskFP(:,:,iFP));
    for jCh = nChs:-1:1
        idxOffset = nRows*nCols*(jCh-1);
        if isFirst
            bgCh(jCh) = median(II_mean(idxBG + idxOffset));
        end
        tempPix(:,jCh) = II_mean(idxFP + idxOffset) - bgCh(jCh);
    end

    % Normalise the components, including dealing with any tiny or negative
    % components, and add into the mixing matrix
    tempPix = bsxfun(@rdivide, tempPix, sum(tempPix, 2));
    tempMM = median(tempPix, 1);
    tempMM(tempMM < 0.001) = 0;
    tempMM = tempMM./sum(tempMM);
    MM(:, iFP) = tempMM;

    % Tidy some things up
    if isFirst
        isFirst = false;
    end
    clear tempPix

end
    
end