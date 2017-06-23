function ch_calc_sum2(self, chNums, varargin)
%ch_calc_sum2 - Calculate the sum of two image channels
%
%   ch_calc_sum2(OBJ, CH_NUMS) calculates a new channel based on the sum
%   of two existing image channels, and merges it into the existing image
%   data. CH_NUMS must be a length 2 vector specifying the image channels
%   to use when calculating the sum.
%
%   ch_calc_sum2(OBJ, CH_NUMS, CH_NAME) specifies the name of the new
%   image channel.  CH_NAME must be a single row character array specifying
%   a valid channel name (i.e. one that is known to the Metadata class).
%
%   ch_calc_sum2(OBJ, CH_NUMS, CH_NAME, NEW_CLASS) casts the image raw data
%   to class NEW_CLASS before evaluating the function.
%
%   IMPORTANT NOTE: Specifying an appropriate numerical class can be
%   critical to avoid numerical overflow if the raw data is stored in an
%   integer format.
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
narginchk(2, 4);

% Parse optional arguments
[chName, newClass] = utils.parse_opt_args({'', class(self.rawdata)}, ...
    varargin);

% Check that we have exactly 2 channels
utils.checks.equal(numel(chNums), 2, 'number of supplied channel numbers')

% Check if we're going to cause numerical overflow
isInteger = isa(newClass, 'integer');
if isInteger
    ch1 = self.rawdata(:,:,chNums(1),:);
    ch2 = self.rawdata(:,:,chNums(2),:);
    maxVal = double(max(ch1(:))) + double(max(ch2(:)));
    hasOverflow = maxVal > intmax(newClass);
    if hasOverflow
        warning('RawImg:ChCalcSum2:Overflow', ['This operation caused ' ...
            'integer overflow.'])
    end
end

% Specify the function for the ratio, and the new class as double to ensure
% we don't lose any precision
ff = @(c1, c2) c1 + c2;

% Call the general channel calculator to do the work
self.ch_calc(ff, chNums, chName, newClass)

end