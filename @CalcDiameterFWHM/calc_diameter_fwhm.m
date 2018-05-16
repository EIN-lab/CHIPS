function [self, pixelWidth] = calc_diameter_fwhm(self, diamProfile, ...
    lineRate, t0, doInvert)

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
    
% Preallocate memory
nFrames = size(diamProfile, 1);
pixelWidth = zeros(nFrames, 1);
idxEdges = zeros(nFrames, 2);

% Calculate the time for each frame
frameTime = 1/lineRate;
time = ((0.5*frameTime):frameTime:(nFrames*frameTime))' - t0;

% Initialise a progress bar
isWorker = utils.is_on_worker();
if ~isWorker
    strMsg = 'Calculating diameter';
    utils.progbar(0, 'msg', strMsg);
end

% Loop through the image frames
for iFrame = 1:nFrames
    
    % Calculate the width using the FWHM function
    [pixelWidth(iFrame), idxEdges(iFrame, :)] = utils.fwhm(...
        diamProfile(iFrame,:), 'lev50', self.config.lev50);
    
    % Update the progress bar
    if ~isWorker
        utils.progbar(iFrame/nFrames, 'msg', strMsg, 'doBackspace', true);
    end

end

% Work out if there were any problems with NaNs
mask1 = isnan(idxEdges(:, 1));
mask2 = isnan(idxEdges(:, 2));
maskNaN = mask1 | mask2;
hasNans = any(mask1) || any(mask2);

% Give a warning if we have NaNs
if hasNans
    warning('CalcDiameterFWHM:NoFWHM', ['The algorithm could not ' ...
        'detect one or more vessel edges for %d of %d time points.  ' ...
        'This may be due to selecting a subset of the image that is ' ...
        'too narrow or because the maxRate is too high.'], ...
        sum(maskNaN), numel(maskNaN))
end

% Figure out if we need back-inversion and if so, do it
if doInvert
    diamProfile = utils.nansuite.nanmax(diamProfile(:)) - diamProfile;
end

% Add the raw data to the data object
self.data = self.data.add_raw_data(time, diamProfile, idxEdges);

end
