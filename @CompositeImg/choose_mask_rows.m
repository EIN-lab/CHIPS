function mask = choose_mask_rows(self, strBoundary)
%choose_mask_rows - Protected class method to choose an individual mask
%   based on the image rows

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

% Call the function to choose the columns
isLR = false;
rowsToUse = utils.crop_rows_cols(@(strFigTitle) ...
    self.plot_imgData([], strFigTitle), ...
    isLR, strBoundary);

% Convert the columns into a mask
mask = false(size(self.rawImg.rawdata(:,:, 1, 1)));
tempRows = rowsToUse(1) : rowsToUse(2);
mask(tempRows, :) = true;

end