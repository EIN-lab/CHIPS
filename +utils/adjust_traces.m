function tracesAdj = adjust_traces(traces, spacingFactor)
%adjust_traces - Adjust traces to plot on a single axes
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

% Work out the median range of the traces, to help with spacing
ranges = utils.nansuite.nanmax(traces, 1) - ...
    utils.nansuite.nanmin(traces, 1);
medRange = median(ranges);

% Adjust the trace
nTraces = size(traces, 2);
tracesAdj = [];
for iTrace = nTraces:-1:1
    tracesAdj(:, iTrace) = traces(:, iTrace) - ...
        median(traces(:, iTrace)) - ...
        spacingFactor*medRange*iTrace;
end

end