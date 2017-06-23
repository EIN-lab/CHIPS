function [theta, estSNR, flux, thetaRangeMid, linearDensity, rbcSpacingT] = ...
    calc_angles_radon(self, windows, isDarkStreaks, pixelSize, ...
        lineTime, pixelTime, isOldToolbox)

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
    
% ---------------------------------------------------------------------- %

% Define the full range of angles
rangeFull = self.config.thetaMin : self.config.incrCoarse : ...
    self.config.thetaMax;

% Preallocate memory
nWindows = size(windows, 3);
theta = zeros(nWindows, 1);
flux = theta;
estSNR = theta;
thetaRangeMid = theta;
linearDensity = theta;
rbcSpacingT = cell(nWindows, 1);

% Make sure the first window does a full scan
doFull = true;

% ---------------------------------------------------------------------- %

% Initialise a progress bar
isWorker = utils.is_on_worker();
strMsg = 'Calculating velocity';
if ~isWorker
    utils.progbar(0, 'msg', strMsg);
end

% Loop through all of the windows
for iWindow = 1:nWindows
    
    % Start each window with a coarse estimate and zeroed counters
    doCoarse = true;
    nFull = 0;
    nCoarse = 0;
    
    % Normalise each window to a mean of 0, standard deviation of 1
    window = windows(:, :, iWindow);
    windowMean = mean(window(:));
    windowStd = std(window(:));
    windowNorm = (window - windowMean)./windowStd;
    
    % Use the previous theta value (if we have one)
    if iWindow > 1
        thetaOld = theta(iWindow-1);
    end
    
    while doCoarse
        
        % -------------------------------------------------------------- %
        
        if ~doFull
            
            % Use the coarse range for most windows
            rangeCoarse = self.makeCoarseRange(thetaOld);
            
        else
            
            % Use the coarse range for the first window, or when lost
            rangeCoarse = rangeFull;
            % Increment the number of full range calculations
            nFull = nFull + 1;
            % Reset the doFull flag.
            doFull = false;
            % Reset the number of coarse calculations
            nCoarse = 0;
            % Reset the thetaOld
            thetaOld = -Inf;
            % Skip the coarse calculation
            skipCoarse = true;
            
        end
        
         % Calculate the coarse range
        thetaCoarse = self.calc_angle_radon(windowNorm, rangeCoarse);
        
        % Check how many full range calculations we've done, issue a
        % warning if we've done too many, and skip further calculations
        % for this window.
        isOverFullLimit = nFull > self.config.maxNFull;
        if isOverFullLimit
            warning('CalcAnglesRadon:TooManyAttempts', ['The current '...
                'window (%d) has exceeded the maximum number of '...
                'attempts to calculate the streak angle.'], iWindow)
            break
        end
        
        % -------------------------------------------------------------- %
        
        % Work out how close we are to the last angle
        isClose = abs(thetaCoarse - thetaOld) < self.config.tolCoarse;
        if isClose || skipCoarse
            
            % Reset skipCoarse
            skipCoarse = false;
            % Exit the coarse range if we're close enough
            break
            
        else
            
            % Increment the number of coarse calculations
            nCoarse = nCoarse + 1;
            
            % Check how many times we've done the coarse calculation
            isOverCoarseLimit = nCoarse > self.config.maxNCoarse;
            if ~isOverCoarseLimit
                
                % Set oldTheta to the last coarse value from this window
                thetaOld = thetaCoarse;
                % Try again if we're outside the range
                continue
                
            else
                
                % Do the full range if we've been trying for too long
                doFull = true;
                continue
                
            end
            
        end
        
        % -------------------------------------------------------------- %
    
    end
	
	% Do the calculation for the fine range, and include flux and SNR
    rangeFine = self.makeFineRange(thetaCoarse);
    [theta(iWindow), estSNR(iWindow), flux(iWindow), ...
     linearDensity(iWindow), rbcSpacingT{iWindow}] = ...
        self.calc_angle_radon(windowNorm, rangeFine, isDarkStreaks, ...
            pixelSize, lineTime, pixelTime, isOldToolbox);
    thetaRangeMid(iWindow) = thetaCoarse;
    
    % Update the progress bar
    if ~isWorker
        utils.progbar(iWindow/nWindows, 'msg', strMsg, ...
            'doBackspace', true);
    end
    
end

end
