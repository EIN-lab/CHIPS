function varargout = plot(self, objPI, varargin)
%plot - Plot a figure
%
%   plot(OBJ, OBJ_PI) plots the default figure for the CalcDetectSigs
%   object OBJ using the ProcessedImg object OBJ_PI.
%
%   plot(OBJ, OBJ_PI, AX, FIG_NAME) plots the figure on the specified axes
%   handles AX, and the particular figure specified by FIG_NAME. The number
%   of axes present is AX varies depending on the particular figure.
%   FIG_NAME must be one of the following:
%
%       'default' ->    The default figure.
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
%       'rois' ->       A figure showing the image ROIs.
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
%       'plotROIs' ->   A vector of integers corresponding to the ROI
%                       numbers that should be displayed as the traces.  If
%                       empty, all ROIs are selected. 
%                       [default = []]
%
%   AX = plot(...) returns a handle to the axes created/used in the figure.
%
%   See also CellScan.plot, Data.plot, Data.plot_graphs, CellScan

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

    % Check the number of input arguments
    narginchk(2, inf);

    % Check the state of the image, and the arguments
    flag = self.check_state_plot();
    [hAx, plotName, idxStart] = self.check_plot_args(objPI, varargin);
    
    % Call the appropriate plotting function
    if flag > 0
        switch plotName

            case {'images', 'default'}

                hAx = self.plot_imgs(objPI, hAx, varargin{idxStart:end});

            case {'rois'}

                hAx = self.plot_ROIs(objPI, hAx, varargin{idxStart:end});

            case {'video'}

                self.plot_video(objPI, varargin{idxStart:end})
                hAx = gca();

            case {'ica_traces'}

                hAx = self.plot_ICAsigs(objPI, hAx, ...
                    varargin{idxStart:end});

            case {'pc_filters'}

                hAx = self.plot_pcs(objPI, hAx, varargin{idxStart:end});

            case {'pc_spectrum'}

                hAx = self.plot_PCspectrum(objPI, hAx, ...
                    varargin{idxStart:end});

            otherwise

                error('CalcFindROIs:Plot:UnknownPlot', ['Unknown ' ...
                    'plot type "%s"'], plotName)

        end
    end
    
    % Return the axes handle if asked for
    if nargout > 0
        varargout{1} = hAx;
    end
    
end
