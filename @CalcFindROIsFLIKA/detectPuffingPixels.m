function [self, puffBoolean] = detectPuffingPixels(self, normFiltSeq, ...
    frameRate)

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

% Create an empty array to count the number of times a pixel is puffing
puffCount = zeros(size(normFiltSeq), 'uint8');

% Define the range of the boxcar windows
minRiseTime = max([1, round(self.config.minRiseTime*frameRate)]);
maxRiseTime = ceil(self.config.maxRiseTime*frameRate);
dt = minRiseTime:maxRiseTime;

isWorker = utils.is_on_worker();
nT = numel(dt);
for iIter = 1:nT
    
    iStep = dt(iIter);
    
    % Calculate the boxcar window differences
    diffSeq = normFiltSeq(:,:,iStep+1:end) - normFiltSeq(:,:,1:end-iStep);
    
    % Add this to the cumulative pixel puffCount
    puffCount(:,:,iStep+1:end) = puffCount(:,:,iStep+1:end) + ...
        uint8(diffSeq > self.config.thresholdPuff);
    
    % Update the progress bar
    if ~isWorker
        utils.progbar(self.fracDetect*iIter/nT, 'msg', self.strMsg, ...
            'doBackspace', true);
    end
    
end

% Find pixels that had a signal for more than one frame and create a
% logical matrix for these "puffing pixels"
puffBoolean = puffCount > 1;

end