function varargout = plot(self, varargin)
%plot - Plot a figure
%
%   plot(OBJ) plots the default figure for each element of OBJ.
%
%   plot(OBJ, FIG_NAME) plots the figure specified by FIG_NAME for each
%   element of OBJ. FIG_NAME must be one of the following:
%
%       'default' ->    The default figure.
%       'motion' ->     A figure showing detail on the motion correction.
%
%   plot(..., 'attribute', value, ...) uses the specified attribute/value
%   pairs.  Valid attributes (case insensitive) are:
%
%       'scaleBarOn'->  Boolean flag whether to add a scale bar.
%                       [default = true] 
%       'barlength' ->  Scalar numeric specifying the desired length of the
%                       scale bar in micrometers. Only used when displaying 
%                       a scale bar.[default = []] 
%       'location'  ->  String describing the desired location of the scale 
%                       bar in the image. Possible options are 'northeast',
%                       'northwest', southeast, 'southwest'. Only used when 
%                       displaying a scale bar. [default = 'southeast']
%       'color'     ->  A numeric vector of length=3 that specifies the
%                       desired scale bar color in RGB images. In grayscale
%                       images, the bar will always be white. Only used 
%                       when displaying a scale bar. [default = [1,1,1]]
%
%   H = plot(...) returns a handle to the figure.  If OBJ is non-scalar,
%   the figure handles are returned as an array.
%
%   See also utils.stack_slider, utils.scaleBar, utils.motion_correct_plot

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

% Get the plot names etc
[hFig, plotName, idxStart] = utils.check_plot_args(self.validPlotNames, ...
    varargin, 'figure');
figure(hFig);

% Call the appropriate plotting function
switch plotName

    case {'default'}

        % Plot the figure using the utility function
        hFig = utils.stack_slider(hFig, self.rawdata, ...
            'pixelSize', self.metadata.pixelSize, ...
            'force4D', true, varargin{idxStart:end});

    case {'motion'}
        
        % Check if the RawImg has already been motion corrected
        if ~self.isMotionCorrected
            error('RawImg:NotMotionCorrected', ['The object must ' ...
                'be motion corrected before plotting.'])
        end
        
        % Call the utility function to do the plotting
        utils.motion_correct_plot(self.mcShiftX, self.mcShiftY, ...
            size(squeeze(self.rawdata(:,:,self.mcCh,:))), self.mcRefImg);
   
    otherwise

        error('RawImg:Plot:UnknownPlot', 'Unknown plot type "%s"', nameIn)

end

% Pass the output argument
if nargout > 0
    varargout{1} = hFig;
end

end