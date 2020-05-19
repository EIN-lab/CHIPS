function peakData = analyse_peak(trace, frameTime, pk, idx, width, ...
    prom, pType, numPeaks)

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

% Extract the portion of the relevant trace
isNaN = all(~isfinite(trace));
if isNaN
    
    peakTrace = NaN;
    idxStart = NaN;
    idxStartHalf = NaN;
    idxEndHalf = NaN;
    idxEnd = NaN;
    
else
    
    [idxStart, idxEnd] = CalcDetectSigsClsfy.peakStartEnd(trace, ...
        idx, pk, prom);
    peakTrace = trace(idxStart:idxEnd);
    
    doHalfProm = true;
    [idxStartHalf, idxEndHalf] = CalcDetectSigsClsfy.peakStartEnd(trace, ...
        idx, pk, prom, doHalfProm);
    
end

% Extract the measurements of the peak
peakData.peakType = pType;
peakData.numPeaks = numPeaks;
peakData.amplitude = pk;
peakData.prominence = prom;
peakData.peakAUC = trapz(peakTrace - min(peakTrace))*frameTime;
peakData.peakTime = idx*frameTime;
peakData.peakStart = idxStart*frameTime;
peakData.peakStartHalf = idxStartHalf*frameTime;
peakData.peakEndHalf = idxEndHalf*frameTime;

if isfinite(width)
    peakData.halfWidth = width;
else
    peakData.halfWidth = (idxEndHalf - idxStartHalf)*frameTime;
end

peakData.fullWidth = (idxEnd - idxStart)*frameTime;
    
end