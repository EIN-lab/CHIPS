function zz = zscore(xx)
%zscore - Replacement for MATLAB function zscore without Statistics Toolbox
%
%   Z = zscore(X) calculates the zscore of a vector or matrix (i.e. the
%   values centered by the mean and normalised by the standard deviation).
%   If X is a matrix, skewness calculates the value for each column of X.
%
%   Z = zscore(X, DIM) operates along the dimension DIM.

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

% Compute X's mean and sd, and standardize it
% look for first non-singleton dimension
dim = find(size(xx) ~= 1, 1, 'first');
if isempty(dim), dim = 1; end

mu = mean(xx, dim);
sigma = std(xx,0,dim);
sigma(sigma==0) = 1;
zz = bsxfun(@minus,xx, mu);
zz = bsxfun(@rdivide, zz, sigma);

end