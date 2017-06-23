function varargout = calc_angle_radon(self, window, rangeTheta, ...
    isDarkStreaks, pixelSize, lineTime, pixelTime, isOldToolbox, varargin)

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
    
% Parse optional arguments
[doPlotRadon, doPlotWindow, doPlotScale] = utils.parse_opt_args(...
    {false, false, true}, varargin);

% ----------------------------------------------------------------------- %

% Perform the radon transform
[radonTrans, xp] = radon(window, rangeTheta);

% Calculate variance for each angle
varTheta = sum(radonTrans.^2,1)./size(radonTrans,1);

% find where highest variance occurs
[maxVarTheta, idxMaxVarTheta] = max(varTheta);

% calculate best theta (occurs where variance is maximum)
theta = rangeTheta(idxMaxVarTheta);
varargout{1} = theta;

% A figure for debugging
if doPlotRadon
    plot_radon(rangeTheta, xp, radonTrans, varTheta, maxVarTheta)
end

% ----------------------------------------------------------------------- %

doSNR = nargout > 1;
if doSNR
    
    % Estimate the Signal to Noise Ratio (SNR) of the angle calculation
    thetaRangeSNR = linspace(-90, 90, self.config.pointsSNR+2);
    thetaRangeSNR = thetaRangeSNR(2:end-1);
    radonSNR = radon(window, thetaRangeSNR);
    varSNR = var(radonSNR, 0, 1);
    estSNR = maxVarTheta/mean(varSNR);
    varargout{2} = estSNR;
    
end

% ----------------------------------------------------------------------- %

doFlux = nargout > 2;
if doFlux
    % Turn off unneeded warnings for now
    [lastMsgPre, lastIDPre] = lastwarn();
    wngIDOff = 'signal:findpeaks:largeMinPeakHeight';
    wngState = warning('off', wngIDOff);
    
    % calculate the RBC flux
    nLines = size(window, 1);
    windowTime = lineTime*nLines;
    [flux, peakLocs, imgSum, linearDensity, rbcSpacingT, maskRBC] = ...
        self.calc_flux(radonTrans, theta, idxMaxVarTheta, ...
            isDarkStreaks, pixelSize, pixelTime, lineTime, nLines, ...
            isOldToolbox, doPlotWindow);
    varargout{3} = flux;
    varargout{4} = linearDensity;
    varargout{5} = rbcSpacingT;
    
    % A figure for debugging
    if doPlotWindow
        CalcVelocityRadon.plot_window(imgSum, peakLocs, xp, window, ...
            theta, maskRBC, pixelSize, windowTime, doPlotScale);
    end    
    
    % Restore the warnings
    warning(wngState);
    utils.clear_unwanted_wngs(wngIDOff, lastMsgPre, lastIDPre)
    
end

end

% ======================================================================= %

function plot_radon(rangeTheta, xp, radonTrans, varTheta, maxVarTheta)

cmap = utils.cubehelix(256, 0.3, 0.4, 2, 1, [0, 0.95], [0, 0.95]);
figure, 
subplot(2,1,1), hold on
    imagesc(rangeTheta, xp, radonTrans);
    title('Radon Transform'); ylabel('r (pixels)');
    axis([rangeTheta(1) rangeTheta(end),xp(1) xp(end)]);
    colormap(cmap); hold off
subplot(2,1,2), hold on
    plot(rangeTheta,varTheta/maxVarTheta);
    xlabel('\theta (degrees)'); ylabel('Normalised Variance');
    axis([rangeTheta(1) rangeTheta(end) 0 1]); hold off
        
end