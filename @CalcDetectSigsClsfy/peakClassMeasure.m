function varargout = peakClassMeasure(self, traceNorm, frameRate, fBand, ...
    roiName, doPlot, flagVersion)
%peakClassMeasure - Measure and classify peaks
%
%   [PEAKS] = peakClassMeasure(OBJ, TRACE, FRAMERATE) requires
%   passing of a CalcMeasureROIsClsfy object (OBJ), the raw ROI signal
%   trace (TRACE) and the frame rate of the recording (FRAMERATE).
%   peakClassMeasure finds peaks in the trace and classifies found peaks
%   according to their features. The two output structures (PLAT and PEAKS)
%   contain all information about identified plateau signals and peaks,
%   respectively.
%
%   See also CalcMeasureROIsClsfy.measure_ROIs, ConfigMeasureROIsClsfy,
%   DataMeasureROIsClsfy, CalcMeasureROIs

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

% ================================================================== %

% Work out which version of the signal processing toolbox we're using
isVeryOld = flagVersion == -2;
isOld = isVeryOld || (flagVersion == -1);

% Set up data
frameTime = 1/frameRate;
time = frameTime*(0:(numel(traceNorm)-1))';

%% Make different filter designs

% Replace possible NaNs for filtering
nanMask = ~isfinite(traceNorm);
hasNaNs = any(nanMask);
allNaNs = all(nanMask);
if hasNaNs && allNaNs
    % Create a marker in case there's no data
    peakType = 'NoPeak';
    peaks = CalcDetectSigsClsfy.analyse_peak(NaN, NaN, NaN, NaN, NaN, ...
        NaN, peakType, NaN);
    varargout{1} = peaks;
    varargout{2} = [];
    return
end
if hasNaNs
    traceNorm = utils.inpaintn(traceNorm);
end

% A factor to correct for the fact that the width at half prominence (which
% is used as a parameter to filter out unwanted peaks in the findpeaks
% algorithm) is smaller than the "full width" that we use to estimate the
% peak duration/frequency from.
widthFactor = 0.75; 

% Extract out some parameters
minWidth_low = widthFactor*(1/self.config.spPassBandMin)/2;
maFrames = floor(self.config.lpWindowTime*frameRate);

% Calculate the low pass and bandpass filtered traces 
traceLP = utils.moving_average(traceNorm, maFrames);

% Do the band pass filtering
if isVeryOld
    traceBP = filtfilt(fBand.sosMatrix, fBand.ScaleValues, traceNorm);
else
    traceBP = filtfilt(fBand, traceNorm);
end

% Calculate the standard deviations for the filtered traces
dff_BLSD_lp = utils.nansuite.nanstd(traceLP(self.config.baselineFrames));
dff_BLSD_bp = utils.nansuite.nanstd(traceBP(self.config.baselineFrames));

% Do the peak finding
if isOld
    
    % Turn off unneeded warnings for now
    [lastMsgPre, lastIDPre] = lastwarn();
    wngIDOff = 'signal:findpeaks:largeMinPeakHeight';
    wngState = warning('off', wngIDOff);
    
    % Note: the old version of the signal processing toolbox doesn't
    % support the 'time' argument
    fpLow = @() findpeaks(traceLP,  ...
        'MinPeakHeight', self.config.thresholdLP*dff_BLSD_lp);
    fpBand = @() findpeaks(traceBP,  ...
        'MinPeakHeight', self.config.thresholdSP*dff_BLSD_bp);
    
else
    
    fpLow = @() findpeaks(traceLP, time, ...
        'MinPeakProminence', self.config.thresholdLP*dff_BLSD_lp, ...
            'MinPeakWidth', minWidth_low, 'Annotate', 'extents');
    fpBand = @() findpeaks(traceBP, time, ...
        'MinPeakProminence', self.config.thresholdSP*dff_BLSD_bp, ...
        'Annotate', 'extents');
    
end

% Don't plot the values, just find the peaks
if ~doPlot
    
    if isOld
        
        % the old version of findpeaks doesn't output widths/prominences
        [pks_low, idxs_low] = fpLow();
        widths_low = nan(size(pks_low));
        proms_low = widths_low;
        
        [pks_band, idxs_band] = fpBand();
        widths_band = nan(size(pks_band));
        proms_band = widths_band;
        
        % Restore the warnings
        warning(wngState);
        utils.clear_unwanted_wngs(wngIDOff, lastMsgPre, lastIDPre)
        
    else 
        
        [pks_low, locs_low, widths_low, proms_low] = fpLow();
        [pks_band, locs_band, widths_band, proms_band] = fpBand();
        
        % Correct the locations to indices
        idxs_low = round(locs_low/frameTime) + 1;
        idxs_band = round(locs_band/frameTime) + 1;
        
    end
    
else
    
    nRows = 3;
    nCols = 1;
    
    tracesAll = [traceNorm; traceLP; traceBP];
    maxVal = max(tracesAll);
    minVal = min(tracesAll);
    rangeTraces = maxVal - minVal;
    yLims = [minVal - 0.05*rangeTraces, maxVal + 0.05*rangeTraces];
    xLims = [0, time(end)];
    
    hFig = figure('Name', roiName{1});
    hAx(1) = subplot(nRows, nCols, 1); hold on
        plot(time, traceNorm)
        ylim(hAx(1), yLims)
        xlim(hAx(1), xLims)
        ylabel('Normalised Trace')
        box(hAx(1), 'on')
        grid(hAx(1), 'on')
        hold off
    hAx(2) = subplot(nRows, nCols, 2); hold on
        fpLow();
        ylim(hAx(2), yLims)
        xlim(hAx(2), xLims)
        ylabel('Low-Pass Filtered')
        box(hAx(2), 'on')
        legend('boxoff')
        hold off
    hAx(3) = subplot(nRows, nCols, 3); hold on
        fpBand();
        ylim(hAx(3), yLims)
        xlim(hAx(3), xLims)
        ylabel('Band-Pass Filtered')
        xlabel('Time [s]')
        box(hAx(3), 'on')
        legend('boxoff')
        hold off
        
    set(hAx(1:end-1), 'XTickLabel', [])
    linkaxes(hAx, 'xy')
    
    % Restore the warnings
    if isOld
        warning(wngState);
        utils.clear_unwanted_wngs(wngIDOff, lastMsgPre, lastIDPre)
    end
    
    varargout{2} = hFig;
    return
        
end

%% Compare found peaks and determine overlay

nLP = length(idxs_low);
if nLP > 0
    isLP_plateau = false(1, nLP);
else
    longpeaks = [];
end

nBP = length(idxs_band);
isBP_multi = false(nBP, 1);

% Loop through and analyse the long peaks
for iLP = nLP:-1:1
    
    % Calculate the outer indices of this low pass peak
    [idx1, idx2] = CalcDetectSigsClsfy.peakStartEnd(traceLP, ...
        idxs_low(iLP), pks_low(iLP), proms_low(iLP));
    
    % Check if there are any peaks from the band pass filter inside the
    % range of the current peak from the low pass filter
    isBP_inside = (idxs_band > idx1) & (idxs_band < idx2);
    isLP_plateau(iLP) = ~any(isBP_inside);
    
    % Label the peaks from the band pass filter as part of the multipeak
    if nBP > 0
        isBP_multi = isBP_multi | isBP_inside;
    end
    
    % Work out what type of peak this is
    if isLP_plateau(iLP)
        numPeaks = 1;
        peakType = 'Plateau';
    else
        numPeaks = sum(isBP_inside) + 1;
        peakType = 'MultiPeak';
    end
    
    % Analyse this peak
    longpeaks(iLP) = CalcDetectSigsClsfy.analyse_peak(traceLP, ...
        frameTime, pks_low(iLP), idxs_low(iLP), widths_low(iLP), ...
        proms_low(iLP), peakType, numPeaks);
    
end

% Work out how many actual single peaks we have, excluding those that are
% counted as a multipeak
nSingles = sum(~isBP_multi);
hasNoPeaks = (nSingles == 0) && (nLP == 0);
if hasNoPeaks
    
    % Create a marker in case there's no peak
    peakType = 'NoPeak';
    singlepeaks = CalcDetectSigsClsfy.analyse_peak(NaN, NaN, NaN, ...
        NaN, NaN, NaN, peakType, NaN);
    
elseif nSingles == 0
    
    singlepeaks = [];
    
end

% Loop through and analyse the single peaks
listBP_single = find(~isBP_multi);
for iSP = nSingles:-1:1
    
    % Analyse this peak
    iBP = listBP_single(iSP);
    numPeaks = 1;
    peakType = 'SinglePeak';
    singlepeaks(iSP) = CalcDetectSigsClsfy.analyse_peak(traceBP, ...
        frameTime, pks_band(iBP), idxs_band(iBP), widths_band(iBP), ...
        proms_band(iBP), peakType, numPeaks);

end

% Join the peaks together
peaks = [singlepeaks, longpeaks];
varargout{1} = peaks;

end
