function trace = measure_ROI(imgSeq, xIdx, yIdx, propagateNaNs)

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

% Overlay the mask/pixels with the image
nPixels = numel(yIdx);
traceArray = zeros(length(yIdx), size(imgSeq,3));
for jPixel = 1:nPixels
    traceArray(jPixel, :) = imgSeq(yIdx(jPixel), xIdx(jPixel), :);
end

% Remove the Infs and NaNs from the array
if ~propagateNaNs
    traceInf = ~isfinite(traceArray);
    traceArray(traceInf) = 0;
end

% Measure the average trace of the ROI
trace = sum(traceArray,1)./nPixels;

end