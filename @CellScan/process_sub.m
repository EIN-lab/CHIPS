function process_sub(self, varargin)

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
  
% Parse arguments
defFlag = {'calcFindROIs', 'calcMeasureROIs', 'calcDetectSigs'};
flag = utils.parse_opt_args({defFlag}, varargin);
if ischar(flag)
    flag = {flag};
end

% Find the ROIs, except when the user only wants to measure them (e.g. ROIs
% were found before) or detect signals
doFind = ismember('calcFindROIs', flag);
if doFind
    self.find_ROIs()
end

% Measure the ROIs, except when the user only wants to find them or detect
% signals
doMeasure = ismember('calcMeasureROIs', flag);
if doMeasure
    hasFound = strcmp(self.calcFindROIs.data.state, 'processed');
    if ~hasFound
        error('CellScan:ProcessSub:NotFound', ['The CellScan object ' ...
            'must have a processed calcFindROIs object before the '...
            'calcMeasureROIs can be processed'])
    end
    self.measure_ROIs()
end

% Detect the signals, except when the user only wants to find or measure
% ROIs
doDetect = ismember('calcDetectSigs', flag);
if doDetect
    hasMeasured = strcmp(self.calcMeasureROIs.data.state, 'processed');
    if ~hasMeasured
        error('CellScan:ProcessSub:NotMeasured', ['The CellScan object ' ...
            'must have a processed calcMeasureROIs object before the '...
            'calcDetectSigs can be processed'])
    end
    self.detect_sigs()
end

end