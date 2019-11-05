function newCh = sparse_ratio(c1, c2, varargin)
%sparse_ratio - Calculate ratio of channels using "sparse" method
%
%   sparse_ratio(CH1, CH2) applies a threshold before calculating a new
%   channel based on the ratio of two existing image channels. Pixels from
%   either channel that are below the threshold are replaced with NaN.
%
%   ch_calc_ratio(CH1, CH2, THRESH) specifies the threshold to apply in
%   percentiles. The percentile is applied to each channel individually.
%
%   See also RawImg.ch_calc, RawImg.ch_calc_ratio

%   Copyright (C) 2019  Matthew J.P. Barrett, Kim David Ferrari et al.
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
narginchk(2, 3);

% Parse optional arguments
[thresh] = utils.parse_opt_args({30}, varargin);

% Check that thresh is a positive, real, finite, scalar integer
utils.checks.prfsi(thresh, 'thresh');

% Threshold
c1_thresh = prctile(c1(:), thresh);
c2_thresh = prctile(c2(:), thresh);

c1_bgIdx = c1 <= c1_thresh;
c2_bgIdx = c2 <= c2_thresh;

% Combine indices from both channels
bgIdx = c1_bgIdx | c2_bgIdx;

% Calculate ratio
newCh = c1./c2;

% Replace background pixels with NaN
newCh(bgIdx) = NaN;

end