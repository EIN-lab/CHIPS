function [sigOut, rangeOut] = normalise_sig(sigIn)
%normalise_sig - Normalise a signal to its max and min values
%
%   X_NORM = normalise_sig(X) normalises X to it's maximum and minimum
%   value, such that X_NORM = (X - min(X(:)))/(max(X(:)) - min(X(:))).  NaN
%   values are ignored in the maximum and minimum calculations.
%
%   [X_NORM, RANGE_X] = normalise_sig(X) also returns RANGE_X, where
%   RANGE_X = [min(X(:)), max(X(:)].
%
%   See also utils.nansuite.nanmin, utils.nansuite.nanmax, utils.zscore

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
narginchk(1, 1);

% Check the signal
utils.checks.real_num(sigIn, 'X')

% Normalise the signal
maxVal = utils.nansuite.nanmax(sigIn(:));
minVal = utils.nansuite.nanmin(sigIn(:));
sigOut = (sigIn - minVal)/(maxVal - minVal);
rangeOut = [minVal, maxVal];

end
