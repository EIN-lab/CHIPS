function ch_calc_ratio(self, chNums, varargin)
%ch_calc_ratio - Calculate the ratio of two image channels
%
%   ch_calc_ratio(OBJ, CH_NUMS) calculates a new channel based on the ratio
%   of two existing image channels, and merges it into the existing image
%   data. CH_NUMS must be a length 2 vector specifying the image channels
%   to use when calculating the ratio, and the new channel is calculated
%   based on the formula CH_NUMS(1)./CH_NUMS(2). For example:
%
%       ch_calc_ratio(OBJ, [2 1]) divides channel 2 by channel 1, and
%       ch_calc_ratio(OBJ, [4 2]) divides channel 4 by channel 2.
%
%   The resulting image data is converted to a double precision array to
%   ensure that there is sufficient precision to store the result.
%
%   ch_calc_ratio(OBJ, CH_NUMS, CH_NAME) specifies the name of the new
%   image channel.  CH_NAME must be a single row character array specifying
%   a valid channel name (i.e. one that is known to the Metadata class).
%
%   Please see the <a href="matlab:web(fullfile(utils.CHIPS_rootdir, 'doc', 'html', 'id_pp_utilities.html'))">pre-processing utilities quick start guide</a> for 
%   additional documentation and examples.
%
%   See also RawImg.ch_calc, Metadata.choose_channel

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
narginchk(2, 3);

% Parse optional arguments
[chName] = utils.parse_opt_args({''}, varargin);

% Check that we have exactly 2 channels
utils.checks.equal(numel(chNums), 2, 'number of supplied channel numbers')

% Specify the function for the ratio, and the new class as double to ensure
% we don't lose any precision
ff = @(c1, c2) c1./c2;
newClass = 'double';

% Call the general channel calculator to do the work
self.ch_calc(ff, chNums, chName, newClass)

end