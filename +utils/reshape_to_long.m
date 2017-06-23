function imgLong = reshape_to_long(imgDeep, varargin)
%reshape_to_long - Convert the image to long format
%
%   imgLong = reshape_to_long(imgDeep) converts imgDeep to long format.
%   That is, the image lines are rearranged into a single, long image
%   frame.  This is useful when working with image types that are
%   line-based instead of frame-based (e.g. line scans).
%
%   See also RawImg.to_long, RawImgComposite.to_long.

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
narginchk(1, 3);

% Parse optional arguments
[chs, colsToUse] = utils.parse_opt_args({[], []}, varargin);

% Work out which columns to use
if isempty(colsToUse)
    colsToUse = 1:size(imgDeep, 2);
end
nColsToUse = length(colsToUse);

% Work out how many channels
if isempty(chs)
    chs = 1:size(imgDeep, 3);
end
nChannels = length(chs);

% Do the actual reshaping
nFrames = size(imgDeep, 4);
if nFrames > 1
    imgLong = permute(reshape(permute(imgDeep(:, colsToUse, chs, :), ...
        [2 1 4 3]), nColsToUse, [], nChannels), [2 1 3]);
else
    imgLong = imgDeep(:, colsToUse, chs);
end

end