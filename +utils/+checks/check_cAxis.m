function CAxis = check_cAxis(CAxis, img)
%check_cAxis - Check that the colour axis is appropriate
%
%   CAXIS = check_cAxis(CAXIS, IMG) checks that the supplied values of
%   CAXIS, the colour/intensity axis limits, are appropriate for the image
%   IMG.  CAXIS  must be an empty, scalar, or length two numeric vector
%   corresponding to the desired image colour/intensity axis limits. If
%   empty, the minimum and maximum values of IMG will be returned.  If
%   scalar, [0, CAxis] will be returned.  If length two, CAxis should
%   correspond to [CMin, CMax].

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

% Check the number of arguments in
narginchk(2, 2)

% Deal with the case where CAxis is empty
if isempty(CAxis)
    CAxis = [utils.nansuite.nanmin(img(:)), ...
        utils.nansuite.nanmax(img(:))];
    return
end

% Check the CAxis
utils.checks.finite(CAxis, 'CAxis');
utils.checks.real_num(CAxis, 'CAxis');
utils.checks.less_than(numel(CAxis), 2, true, 'CAxis');
if isscalar(CAxis)
    CAxis = [0, CAxis];
end
CAxis = sort(CAxis);

end
