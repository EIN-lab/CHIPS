function lims = get_limits(xx)
%get_limits - Helper function for getting axis limits
%
%   This function is not intended to be called directly.

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

isSameLims = (utils.nansuite.nanmin(xx(:)) == ...
    utils.nansuite.nanmax(xx(:)));
if ~isSameLims
    lims = [min(xx(:)), max(xx(:))];
else
    lims = [-inf inf];
end

if isnan(lims(1))
    lims(1) = -inf;
end

if isnan(lims(2))
    lims(2) = inf;
end

end
