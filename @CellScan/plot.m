function varargout = plot(self, varargin)
%plot - Plot a figure
%
%   plot(OBJ) plots the default figure for each element of OBJ.
%
%   plot(OBJ, H_FIG, FIG_NAME) plots the figure on the specified figure
%   handle(s) H_FIG, and the particular figure specified by FIG_NAME.
%   FIG_NAME must be one of the following:
%
%       'default' ->    The default figure.
%
%       'classification' -> A figure showing detail on the classification 
%                       of the ROIs. This figure is only relevant when the 
%                       CalcDetectSigsClsfy approach is used.
%
%       'ica_traces' ->	A figure showing the traces extracted from the
%                       independent components.  This figure is only
%                       relevant for the CalcFindROIsCellSort approach.
%
%       'images' ->     A figure showing images used to identify the active
%                       ROIs.  This figure is only relevant when the 
%                       CalcFindROIsFLIKA approach is used.
%
%       'pc_filters' -> A figure showing the principle component filters,
%                       which can be useful for identifying which contain
%                       structures useful for independent component
%                       analysis. This figure is only relevant for the
%                       CalcFindROIsCellSort approach.
%
%       'pc_spectrum' -> A figure showing the principle component spectrum
%                       and comparing it with the corresponding 
%                       random-matrix noise floor
%
%       'signals' ->    A series of figures showing detail on the signals 
%                       detection and classification process. One figure is
%                       produced for every ROI. These figures are only
%                       relevant when using CalcDetectSigsClsfy.
%
%       'rois' ->       A figure showing the image ROIs.
%
%       'traces' ->     A figure showing the traces measured from the ROIs.
%
%       'video' ->      A figure showing the original image stack with the
%                       ROIs overlaid. This method also saves a tiff image
%                       stack to the current working directory.
%
%   plot(..., 'attribute', value, ...) uses the specified attribute/value
%   pairs.  Valid attributes (case insensitive) are:
%
%       'AlphaSpec' ->	A scalar number between 0 and 1 representing how
%                       transparent the ROI overlays should appear.  
%                       [default = 0.6]
%
%       'annotateSigs'  -> A boolean flag indiciating whether to add
%                       annotations to plots of individual ROI's responses.
%                       Applicable for plot type 'signals' only. 
%                       [default = true]
%
%       'CAxis' ->      An empty, scalar, or length two numeric vector
%                       corresponding to the desired image colour/intensity
%                       axis limits. If empty, the image minimum and
%                       maximum will be used.  If scalar, [0, CAxis] will
%                       be used.  If length two, CAxis should correspond to
%                       [CMin, CMax]. [default = []]
%
%       'doHeatmap' ->  Logical scalar indicating whether to display the
%                       traces as a heatmap or regular 2d lines. 
%                       [default = true if > 15 ROIs, otherwise false]
%
%       'doWholeFrame' -> Logical scalar indicating whether to display the
%                       whole frame trace(s). [default = true]
%
%       'FilledROIs' ->	Logical scalar indicating whether the ROIs should
%                       be displayed filled or only as an outline. 
%                       [default = true]
%
%       'FrameNum' ->   The (scalar, integer) frame number of the raw image
%                       to display as a reference image.  If empty, the
%                       average of all frames is used. [default = []]
%
%       'isDebug' ->    Logical scalar indicating whether to show debugging
%                       information and/or plots on the figure. 
%                       [default = true]
%
%       'normTraces' -> Logical scalar indicating whether to plot the
%                       normalised traces (instead of the raw traces).
%                       [default = true]
%
%       'plotROIs' ->   A vector of integers corresponding to the ROI
%                       numbers that should be displayed as the traces.  If
%                       empty, all ROIs are selected. 
%                       [default = []]
%
%       'spacingFactor' -> A scalar number reperesenting how far apart the
%                       individual ROI traces should be spaced.  Larger
%                       numbers represent more spaced ROIs and thus smaller
%                       amplitudes for the traces.  [default = 1]
%
%   H = plot(...) returns handles to the figure created/used.
%
%   See also Data.plot, Data.plot_graphs

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

    % Call the function one by one if we have an array
    if ~isscalar(self)
        hFig = arrayfun(@(xx) plot(xx, varargin{:}), self, ...
            'UniformOutput', false);
        hFig = [hFig{:}];
        if nargout > 0
            varargout{1} = hFig;
        end
        return
    end

    % Check the state of the object, and the arguments
    self.check_state_plot();
    [hFig, plotName, idxStart] = self.check_plot_args(varargin);

    % Call the appropriate plotting function
    switch plotName

        case {'default'}

            self.plot_main(hFig, varargin{idxStart:end});
            
        case {'classification'}
            
            self.calcDetectSigs.plot(self, 'classification');
            
        case {'images'}
            
            self.calcFindROIs.plot(self, 'images', varargin{idxStart:end});
            
        case {'signals'}
            
            close(hFig);
            hFig = self.plot_signals(varargin{idxStart:end});
            
        case {'rois'}
            
            self.calcFindROIs.plot(self, 'rois', varargin{idxStart:end});
        
        case {'traces'}
            
            self.plot_traces(varargin{idxStart:end})
            
        case {'video'}
            
            self.calcFindROIs.plot(self, 'video', varargin{idxStart:end});
            
        case {'pc_filters'}
            
            close(hFig);
            hFig = self.calcFindROIs.plot(self, 'pc_filters', ...
                varargin{idxStart:end});
            
        case {'pc_spectrum'}
                
            self.calcFindROIs.plot(self, ...
                'pc_spectrum', varargin{idxStart:end});
            
        case{'ica_traces'}
            
            self.calcFindROIs.plot(self, 'ica_traces', ...
                varargin{idxStart:end});
            
        otherwise

            error('CellScan:Plot:UnknownPlot', ['Unknown ' ...
                'plot type "%s"'], plotName)

    end

    % Return the figure handle if asked for
    if nargout > 0
        varargout{1} = hFig;
    end

end
