function annotate_signals(self, objPI, hFig, currROI, params)
%annotate_signals - Add annotations to 'signals' plot
%
%   The function 'annotate_signals' calls function 'annotate_traces' with
%   adjusted parameters to produce annotations for ROI responses
%   one-by-one.
%
%   See also CalcDetectSigs, CalcDetectSigsClsfy,
%   CalcDetectSigsClsfy/plot_signals, CalcDetectSigsClsfy/annotate_traces,
%   CellScan/plot_traces
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

% Check that we annotate only when requested
utils.checks.equal(params.annotateSigs, true, 'annotateSigs')

% Pick a current ROI for annotation
params.plotROIs = currROI;

% Extract axes from figure and pick the one without filtering
axHandles = findall(hFig, 'type', 'axes');
hAxAnnotate = axHandles(3);

% Annotate signals using function 'annotate_traces'
wngState = warning('off', 'CalcDetectSigsDummy:AnnotateTraces:NoClsfy');
self.plot(objPI, hAxAnnotate, 'annotations', params);
warning(wngState)

end
