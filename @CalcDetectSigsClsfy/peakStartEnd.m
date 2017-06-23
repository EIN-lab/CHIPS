function [idxStart, idxEnd] = peakStartEnd(trace, peakLoc, peakHeight, ...
    peakProm, varargin)
%peakStartEnd - Find the indices of the peak (half) extents

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

doHalfProm = false;
hasFlag = (nargin > 4) && ~isempty(varargin{1});
if hasFlag
    utils.checks.scalar_logical_able(varargin{1}, 'doHalfProm flag')
    doHalfProm = varargin{1};
end

% Calculate the threshold that we need to drop below
if doHalfProm
    heightRef = (peakHeight - 0.5*peakProm);
else
    heightRef = (peakHeight - 0.9*peakProm);
end

% Calculate the outer indices of the peak
idxStart = find(trace(1:peakLoc) < heightRef, 1, 'last');
idxEnd = find(trace(peakLoc:end) < heightRef, 1, 'first') + peakLoc - 1;

% Correct for edge cases
if isempty(idxStart)
    idxStart = 1;
end
if isempty(idxEnd)
    idxEnd = numel(trace);
end

end