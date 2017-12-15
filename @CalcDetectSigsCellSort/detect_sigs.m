function self = detect_sigs(self, objPI, tracesNorm, frameRate, roiNames)
%detect_sigs - Detect the signals
%
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
flagVersion = CalcDetectSigsCellSort.check_version();

% Work out how many ROIs there are
if isscalar(tracesNorm)
    nROIs = 0;
else
    nROIs = size(tracesNorm, 2);
end

% Check that there are actually ROIs to process
if nROIs < 1
    warning('CalcDetectSigsCellSort:DetectSigs:NoROIs', ['No signals ' ...
        'could be detected, because no ROIs were identified.'])
    dummyData = {[1,0], [1,2], [1,2], {[]}, {[]}};
    self.data = self.data.add_processed_data(dummyData{:});
    return
end

% --------------------------------------------------------- %
%Check for valid find/detect combination
is_invalid_combination = 0;
if  isa(self, 'CalcDetectSigsCellSort') && ...
    ~isa(objPI.calcFindROIs, 'CalcFindROIsCellSort')
    is_invalid_combination = 1;
end

if is_invalid_combination
    warning('CellScan:WrongClassCalc', ['The valid calcFind '...
        'for "DetectSigsCellSort", is "FindROIsCellSort", whereas ' ...
        'the supplied calc is of class "%s".' ...
        'The signals will not be detected.'], ...
        class(objPI.calcFindROIs))
    dummyData = {[1,0], [1,2], [1,2], {[]}, {[]}};
    self.data = self.data.add_processed_data(dummyData{:});
    return
end
% --------------------------------------------------------- %

% Initialise a progress bar
isWorker = utils.is_on_worker();
if ~isWorker
    strMsg = 'Detecting signals';
    utils.progbar(0, 'msg', strMsg);
    lastwarn('')
end
        
% Extract vars
ica_sig = objPI.calcFindROIs.data.icTraces;
%roi_sig = objPI.calcMeasureROIs.data.traces;
spike_thresh = self.config.spike_thresh;
dt = 1/frameRate;
deconvtau = self.config.deconvtau;
normalization = self.config.normalization;
% MH - 10/11/2017 - May eventually want to move this function from utils?        
[spmat, spt, spc] = utils.cellsort.CellsortFindspikes(ica_sig, spike_thresh,...
                                            dt, deconvtau,...
                                            normalization);

% Get possible rois of origin
segmentlabels = objPI.calcFindROIs.data.segmentlabel;
spc_rois = cell(length(spc), 1);
for j = 1:length(spc)
    ic_label = spc(j);
    names = roiNames(segmentlabels == ic_label);
    spc_rois{j} = names;
end                                        
                                        
% Update the progress bar
if ~isWorker
    utils.progbar(1, 'msg', strMsg, 'doBackspace', true);
end

% Add the processed data
self.data = self.data.add_processed_data(spmat, spt, spc, roiNames, spc_rois);



end
