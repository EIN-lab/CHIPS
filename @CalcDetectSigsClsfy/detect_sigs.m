function self = detect_sigs(self, objPI, tracesNorm, frameRate, roiNames)
%detect_sigs - Detect the signals

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

% Check for the signal processing toolboxes
flagVersion = CalcDetectSigsClsfy.check_version();

% Work out how many ROIs there are
if isscalar(tracesNorm)
    nROIs = 0;
else
    nROIs = size(tracesNorm, 2);
end

% Check that there are actually ROIs to process
if nROIs < 1
    warning('CalcDetectSigsClsfy:DetectSigs:NoROIs', ['No signals ' ...
        'could be detected, because no ROIs were identified.'])
    dummyData = repmat({{[]}}, [1, 12]);
    self.data = self.data.add_processed_data(dummyData{:});
    return
end

% Initialise a progress bar
isWorker = utils.is_on_worker();
if ~isWorker
    strMsg = 'Detecting signals';
    utils.progbar(0, 'msg', strMsg);
    lastwarn('')
end

% Preallocate Memory
peakData = cell(1, nROIs);

% Create variables to make sure we only warn once
idNaN = 'CalcDetectSigsClsfy:DetectSigs:NaNROI';
stateNaN = warning('query', idNaN);
idEmpty = 'CalcDetectSigsClsfy:DetectSigs:NaNROI';
stateEmpty = warning('query', idEmpty);
hasWarnedNaN = strcmpi(stateNaN.state, 'off');
hasWarnedEmpty = strcmpi(stateEmpty.state, 'off');
wngState = warning();

% Prepare the filters
fBand = self.get_fBand(frameRate);

% Loop through each of the ROIs
for iROI = 1:nROIs
      
    % Retrieve or create ROI name
    if isempty(roiNames{iROI}) || isempty(roiNames)
        roiName = sprintf('ROI %03d', iROI);
    else
        roiName = roiNames(iROI);
    end
    
    % Make sure that the ROI contains actual data (and not just NaNs from
    % motion correction)
    signalTrace = tracesNorm(:, iROI);
    hasNaN = any(~isfinite(signalTrace));
    
    if hasNaN && self.config.excludeNaNs 
        
        if ~hasWarnedEmpty
            warning('CalcDetectSigsClsfy:DetectSigs:EmptyROI', ['Some ' ...
                'ROI(s) contain NaNs and will be skipped. A likely cause ' ...
                'is motion correction.'])
            
            % Update flag and disable warning
            hasWarnedEmpty = true;
            warning('Off', 'CalcDetectSigsClsfy:DetectSigs:EmptyROI');
        end
        
        % Delete information for these ROIs
        peakType = 'MotionCorrectionArtifact';
        peaks = CalcDetectSigsClsfy.analyse_peak(NaN, NaN, NaN, NaN, ...
            NaN, NaN, peakType, NaN);
        
    else
        
        % Give a warning if there are NaNs
        if hasNaN && ~hasWarnedNaN
            warning('CalcDetectSigsClsfy:DetectSigs:NaNROI', ['Some ' ...
                'ROI(s) contain NaNs. A likely cause is motion.'])
            
            % Update flag and disable warning
            hasWarnedNaN = true;
            warning('Off', 'CalcDetectSigsClsfy:DetectSigs:NaNROI');
        end
        
        % Run peak detection and sorting
        doPlot = false;
        peaks = self.peakClassMeasure(signalTrace, frameRate, fBand, ...
            roiName, doPlot, flagVersion);
        
    end
    
    if ~isempty(peaks)
        
        % Add the current ROI name to the data
        [peaks(:).roiName] = deal(roiName);
    
    end
    
    % Store data in cell array
    peakData{iROI} = peaks;
    
    % Update the progress bar
    if ~isWorker
        utils.progbar(iROI/nROIs, 'msg', strMsg, 'doBackspace', true);
    end
    
end

% Create table
peakStruct = [peakData{:}];

% This is sort of an ugly workaround of which I'm sure it could be done
% much easier
if ~isempty(peakStruct)
    fields = fieldnames(peakStruct);
    for iField = numel(fields):-1:1;
        isCellField = iscell(peakStruct(1).(fields{iField}));
        if isCellField
            tableColumns{iField} = [peakStruct(:).(fields{iField})]';
        else
            tableColumns{iField} = {peakStruct(:).(fields{iField})}';
        end
    end
else
    warning('CalcDetectSigsClsfy:DetectSigs:NoPeaks', ['No peaks ' ...
        'were detected.'])
    tableColumns = {};
end

% Add the processed data
self.data = self.data.add_processed_data(tableColumns{:});

% Recover warning state, if neccessary
if hasWarnedEmpty || hasWarnedNaN
    warning(wngState);
end

end
