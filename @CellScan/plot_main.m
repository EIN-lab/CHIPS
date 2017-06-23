function plot_main(self, hFig, varargin)
%PLOT_MAIN - Create the main plot for CellScan objects

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

% ======================================================================= %
    
    % Setup the default parameter names and values
    pNames = {
        'doWholeFrame'; ...
        'FrameNum';
        'plotROIs' ...
        };
    pValues = {
        true; ...
        []; ...
        [] ...
        };
    dflts = cell2struct(pValues, pNames);
    
    % Parse any remaining input arguments
    params = utils.parse_params(dflts, varargin{:});

    % Check/get the plotROIs
    params.plotROIs = self.calcMeasureROIs.get_plotROIs(params.plotROIs);
    nROIs = numel(params.plotROIs);
    if params.doWholeFrame
        nLinesMod = nROIs + 2;
    else
        nLines = nROIs;
        nLinesMod = nLines;
    end
    % Make sure we don't have a ridiculous number of axes, which could be
    % problematic
    nLinesMod = min([nLinesMod, 22]);

    % Set up rows and columns
    nRows = nLinesMod*3;
    nRowsMod = nRows + 1;
    nCols = self.calcDetectSigs.nColsDetect;

    % Set up the figure
    set(hFig, 'units', 'normalized', 'outerposition', [0 0 1 1]);
    
    % Plot the FindROIs images
    mImgs = [0.03 0.02];
    for iImg = 3:-1:1
        hAxFindROIsImgs(iImg) = utils.subplot_tight(nRowsMod, nCols, ...
            iImg : nCols : (nLinesMod-1)*nCols+iImg, mImgs);
    end
    self.calcFindROIs.plot(self, hAxFindROIsImgs, 'images', varargin{:})
    
    % Setup the axes for the traces
    mTraces = [0.03, 0.03];
    idxAxMatrix = repmat(1:3, [nLinesMod*2, 1]) + ...
        repmat(nCols*(0:nLinesMod*2-1)', 1, 3) + nLinesMod*nCols;
    if params.doWholeFrame
        idxAxWF = idxAxMatrix(1:4, :);
        hAxTraces(1) = utils.subplot_tight(nRowsMod, nCols, ...
            idxAxWF(:), mTraces);
        if nROIs > 0
            idxAxTraces = idxAxMatrix(5:end, :);
            hAxTraces(2) = utils.subplot_tight(nRowsMod, nCols, ...
                idxAxTraces(:), mTraces);
        end
    else
        hAxTraces(2) = utils.subplot_tight(nRowsMod, nCols, ...
            idxAxMatrix(:), mTraces);
    end
    
    % Plot the traces
    wngState = warning('off', 'CalcMeasureROIs:PlotTraces:NoROIsFound');
    self.plot_traces(hAxTraces, varargin{:});
    warning(wngState)
    
    % Setup the axes for the classification figures
    if nCols > 3
        
        % Setup an axes diagram for helping
        axAll = reshape(1:nRows*nCols, nCols, [])';
        
        % Setup the pie graph axis
        axPie = axAll(1:nRows/3, 4:nCols);
        mPie = 0.01;     
        hAxClsfy(1) = utils.subplot_tight(nRowsMod, nCols, axPie(:), mPie);
        
        % Setup the boxplot axes
        axBoxes = [axAll((1:nRows/3) + nRows/3, 4:nCols), ...
            axAll((1:nRows/3) + 2*(nRows/3), 4:nCols)];
        nBoxes = 6;
        mBoxes = [0.02 0.04];
        for iBox = nBoxes:-1:1
            hAxClsfy(1+iBox) = utils.subplot_tight(nRowsMod, nCols, ...
                axBoxes(:, iBox), mBoxes);
        end
        
    else
        hAxClsfy = [];
    end
    
    % Plot the Classification Images
    wngState = warning('off', 'CalcDetectSigsDummy:PlotClsfy:NoClsfy');
    self.calcDetectSigs.plot(self, hAxClsfy, 'classification');
    warning(wngState)

end