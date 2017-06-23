function [img_u, MM] = unmix_chs(img, varargin)
%unmix_chs - Perform unmixing of image channels
%
%   IMG = unmix_chs(IMG) interactively unmixes image channels.
%
%   IMG = unmix_chs(IMG, ...) passes all additional arguments to the
%   linear_unmix function.  See the linear_unmix function documentation
%   (link below) for more information.
%
%   [IMG, ...] = unmix_chs(...) returns all additional output arguments.
%
%   Note: For now this function is simply a wrapper for linear_unmix, but
%   more unmixing methods may be added in the future.
%
%   See also RawImg.unmix_chs, utils.linear_unmix.linear_unmix

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
narginchk(1, inf);

[img_u, MM] = utils.linear_unmix.linear_unmix(img, varargin{:});

end