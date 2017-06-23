function self = calc_velocity(self, windowsBig, lineTime, ...
        time, yPosition)

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
    nWinBig = size(windowsBig, 3);
    windowLines = round(self.config.windowTime/lineTime);
    windowsSmallTemp = utils.split_into_windows(...
        windowsBig(:,:,1), self.config.nOverlap, windowLines);
    nWinSmall = size(windowsSmallTemp, 3);
    nWinTotal = nWinBig*nWinSmall;
    pixelShift = zeros(nWinBig, nWinSmall);
    nfft = 2*size(windowsBig, 2) - 1;
    xCorr = zeros(nWinBig, nWinSmall, nfft);
    estSNR = pixelShift;

    % Work out if we're using the parallel features
    [isParallel, numWorkers] = utils.is_parallel();
    doParBig = isParallel && (nWinBig > 2*numWorkers);

    % Setup some anonymous functions and parameters so that the
    % parallelisation doesn't need excessive communcation
    nOverlap = self.config.nOverlap;
    funCalcXCorr = @(winData) CalcVelocityLSPIV.calc_xcorr_img(...
        winData, self.config.shiftAmt);
    funCalcPixelShift = @(winCorr) CalcVelocityLSPIV.calc_pixel_shift(...
        winCorr, self.config.nPixelsToFit);

    % Disable any annoying warnings
    [lastMsgPre, lastIDPre] = lastwarn();
    wngIDOff = 'GetWindow:ExtendWindow';
    wngState = warning('off', wngIDOff);
    if isParallel
        spmd
            warning('off', wngIDOff);
        end
    end

    % Initialise a progress bar
    strMsg = 'Calculating velocity';
    isWorker = utils.is_on_worker();
    if ~isWorker
        if isParallel
            fnPB = utils.progbarpar('msg', strMsg);
        else
            fnPB = '';
            utils.progbar(0, 'msg', strMsg);
        end
    else
        % This is needed for parallel processing, even if it's unused
        fnPB = '';
    end

    % Loop through the through the big windows to do calculate the
    % x-corr image, using parallelisation as available/appropriate
    if doParBig

        parfor iWinBig = 1:nWinBig

            [pixelShift(iWinBig, :), estSNR(iWinBig, :), ...
             xCorr(iWinBig, :, :)] = ...
                CalcVelocityLSPIV.loop_function( ...
                    funCalcXCorr, windowsBig(:, :, iWinBig), ...
                    nOverlap, windowLines, nWinSmall, ...
                    funCalcPixelShift, isParallel, ...
                    nWinBig - iWinBig, nWinTotal, fnPB, strMsg);

        end

    else

        for iWinBig = 1:nWinBig

            [pixelShift(iWinBig, :), estSNR(iWinBig, :), ...
             xCorr(iWinBig, :, :)] = ...
                CalcVelocityLSPIV.loop_function( ...
                    funCalcXCorr, windowsBig(:, :, iWinBig), ...
                    nOverlap, windowLines, nWinSmall, ...
                    funCalcPixelShift, isParallel, ...
                    iWinBig, nWinTotal, fnPB, strMsg);

        end

    end

    % Close the progress bar
    if ~isWorker && isParallel
        utils.progbarpar(fnPB, 0, 'msg', strMsg);
    end

    % Restore the warnings
    warning(wngState)
    utils.clear_unwanted_wngs(wngIDOff, lastMsgPre, lastIDPre)

    % Reshape the data
    pixelShift = pixelShift(:);
    estSNR = estSNR(:);
    xCorr = reshape(permute(xCorr, [3, 2, 1]), ...
        size(xCorr, 3), [])';

    % Assign the data to the correct structure
    self.data = self.data.add_raw_data(time, yPosition, ...
        xCorr, pixelShift, estSNR);

end
