function [pixelShift, estSNR, xCorr] = loop_function(...
    funCalcXCorr, windowsBig, nOverlap, windowLines, ...
    nWindowsSmall, funCalcPixelShift, isParallel, ...
    iWinBig, nWinTotal, fnPB, strMsg)

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
    
    % Do the FFT-convolution / cross correllation
    windowCorrImg = funCalcXCorr(windowsBig);

    % Split the big windows into little windows, as necessary
    windowsSmall = utils.split_into_windows(windowCorrImg, ...
        nOverlap, windowLines);
    [~, lastID] = lastwarn();
    isSuppressedWarning = strcmp(lastID, 'GetWindow:ExtendWindow');
    if isSuppressedWarning
        lastwarn('');
    end

    pixelShift = zeros(1, nWindowsSmall);
    estSNR = pixelShift;
    xCorr = zeros(1, nWindowsSmall, size(windowCorrImg, 2));

    % Loop through the small windows to calculate the more
    % detailed parameters
    isWorker = utils.is_on_worker();
    parfor jWindowSmall = 1:nWindowsSmall

        % Calculate the pixelShift and estimated SNR
        [pixelShift(1, jWindowSmall), estSNR(1, jWindowSmall), ...
         xCorr(1, jWindowSmall, :)] = funCalcPixelShift(...
                windowsSmall(:, :, jWindowSmall)); %#ok<PFBNS>

        % Update the progress bar
        if ~isWorker
            if isParallel
                utils.progbarpar(fnPB, nWinTotal, 'msg', strMsg);
            else
                kWindow = (iWinBig-1)*nWindowsSmall + ...
                    nWindowsSmall - jWindowSmall + 1;
                utils.progbar(kWindow/nWinTotal, 'msg', strMsg, ...
                    'doBackspace', true);
            end
        end

    end

end