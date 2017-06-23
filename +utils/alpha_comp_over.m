function [imgAB, alphaAB] = alpha_comp_over(imgA, imgB, alphaA, alphaB)
%alpha_comp_over - Alpha composite one image over another
%
%   [IMG_AB, ALPHA_AB] = alpha_comp_over(IMG_A, IMG_B, ALPHA_A, ALPHA_B)
%   alpha composites IMG_B on top of IMG_A, using the alpha masks ALPHA_A
%   and ALPHA_B.
%
%   This function is not intended to be called directly.

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

% Check the number of input arguments
narginchk(4, 4);

imgAa = bsxfun(@times, imgA, alphaA);
imgBa = bsxfun(@times, imgB, alphaB);

maskA = alphaA > 0;
maskB = alphaB > 0;
maskAB = maskA & maskB;
idxs = find(maskAB);

imgABa = imgAa + imgBa;
for kCol = 1:3
    kOffset = (kCol-1)*numel(maskA);
    imgABa(idxs + kOffset) = imgAa(idxs + kOffset) + ...
        imgBa(idxs + kOffset).*(1 - alphaA(idxs));
end

alphaAB = alphaA + alphaB - alphaA .* alphaB;
imgAB = bsxfun(@rdivide, imgABa, alphaAB);
maskNaN = isnan(imgAB);
imgAB(maskNaN) = 0;

end