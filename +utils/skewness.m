function ss = skewness(xx, varargin)
%skewness - Replacement for MATLAB function skewness w/out Stats Toolbox
%
%   S = skewness(X) calculates the skewness of a distribution.  If X is a
%   matrix, skewness calculates the value for each column of X.
%
%   S = skewness(X, DIM) operates along the dimension DIM.
%
%   The function skewness ignores NaN values.
%
%   See also utils.nansuite.nanmean, utils.nansuite.nanvar

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
narginchk(1, 2);

% Parse optional arguments
dim = utils.parse_opt_args({[]}, varargin);

% Work out which dimension to use
if isempty(dim)
    dim = find(size(xx)~=1, 1, 'first');
    if isempty(dim), dim = 1; end
end

% Calculate the skewness
x0 = bsxfun(@minus, xx, mean(xx, dim));
m3 = utils.nansuite.nanmean(x0.^3, dim);
sd3 = utils.nansuite.nanvar(x0, dim).^1.5;
ss = m3 ./ sd3;

end