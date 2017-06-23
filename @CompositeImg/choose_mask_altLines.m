function mask = choose_mask_altLines(self, isEven)
%choose_mask_altLines - Protected class method to choose an individual mask
%   based on alternating lines in the image

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

% Create the empty mask
mask = false(size(self.rawImg.rawdata(:,:, 1, 1)));

% Fill in the alternate lines
nLines = size(mask, 1);
if isEven
    mask(1:2:nLines, :) = true;
else
    mask(2:2:nLines, :) = true;
end

end