function [pixelShift, estSNR, windowCorrAvg] = ...
        calc_pixel_shift(windowCorrImg, nPixelsToFit)

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
    
    % Average the image along the time direction to produce a 1D
    % cross-correlation for this window
    windowCorr = sum(windowCorrImg, 1);
    windowCorrAvg = ((windowCorr - min(windowCorr))./...
        (max(windowCorr) - min(windowCorr)))';

    %% Fit a guassian to the xcorrelation to get a subpixel shift

    % Prepare some variables for the fit
    nPixels = length(windowCorrAvg);
    maxPixelShift = round(nPixels / 2) - 1;
    idxsCorr = maxPixelShift:-1:-maxPixelShift;

    % Fit the peak and return the optimal parameters
    ppOpt = utils.gaussian_peakfit(windowCorrAvg', idxsCorr, nPixelsToFit);

    % Extract the data
    pixelShift = ppOpt(2);

    %% Estimate the Signal to Noise Ratio (SNR) of the shift 
    %  calculation, using the same approach as the radon bootstrap
    pointsSNR = 12;
    pixelRangeSNR = linspace(1, length(windowCorrAvg), pointsSNR+2);
    pixelRangeSNR = round(pixelRangeSNR(2:end-1));
    windowCorrSNR = windowCorrAvg(pixelRangeSNR);
    [~, idxMin] = min(abs(idxsCorr - round(pixelShift)));
    estSNR = windowCorrAvg(idxMin)/mean(windowCorrSNR);


end