function [data, bgLevel] = subtract_bg(data, bgPct)
%subtract_bg - Helper function to subtract the image background
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
narginchk(2, 2);

% Calculate the baseline level, avoiding the need for the stats toolbox
bgLevel = get_bgLevel(data(:), bgPct);

% Subtract the background from each frame
data = data - bgLevel;

end

% ---------------------------------------------------------------------- %

function bgLevel = get_bgLevel(vv, pp)

% Check how many points we need to calculate the background effectively 
nVV = length(vv);
nReq = ceil(100/pp);
if nVV > nReq
    
    % Create the percentiles, if we have enough points
    pctiles = linspace(0.5/nVV, 1-0.5/nVV, nVV)';
    vv_sorted = sort(vv);
    bgLevel = interp1(pctiles, vv_sorted, pp*0.01, 'linear');
    
else
    
    % Otherwise assume no background
    bgLevel = 0;
    
end

end
