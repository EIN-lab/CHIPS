function varargout = plot_trajs(varargin)
%plot_trajs - Helper function to plot trajectories
%
%   This function is not intended to be called directly.

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

%% Parse input arguments

% Check the first argument to see if it's an axes
idxOffset = 0;
% hasAxes = nargin > 2 && ishghandle(varargin{1}) && ...
%     isgraphics(varargin{1}, 'axes');
% if hasAxes
%     hAxes = varargin{1};
%     idxOffset = 1;
% else
%     hAxes = axes;
% end

nReqArgs = 2;
nOptArgs = 3;

refImg = varargin{1 + idxOffset};
trajImgs = varargin{2 + idxOffset};

areas = 40;
hasAreas = (nargin > (idxOffset + nReqArgs)) && ...
    ~isempty(varargin{idxOffset + nReqArgs + 1});
if hasAreas
    areas = varargin{idxOffset + nReqArgs + 1};
end

colours = 'r';
hasColours = (nargin > (idxOffset + nReqArgs + 1)) && ...
    ~isempty(varargin{idxOffset + nReqArgs + 2});
if hasColours
    colours = varargin{idxOffset + nReqArgs + 2};
end

names = '';
hasNames = (nargin > (idxOffset + nReqArgs + 2)) && ...
    ~isempty(varargin{idxOffset + nReqArgs + 3});
if hasNames
    names = varargin{idxOffset + nReqArgs + 3};
end

% Set up some other default arguments
properties.chToPlot = 1;
properties.cRangeRef = NaN;
properties.LineMode = 'horizontal';
properties.marker = 'o';
properties.parent = [];
properties.pixelSize = [];
properties.zFun = @(img) mean(img, 4);
filledMarkers = {'o','s','d','^','v','>','<','p','h'};

% Override the default arguments with any user-specified arguments
if nargin > (idxOffset + nReqArgs + nOptArgs)
    properties = utils.parsepropval(properties, ...
        varargin{(idxOffset + nReqArgs + nOptArgs + 1):end});
end

if isempty(properties.parent)
    properties.parent = gca();
end

%%

% Plot the reference image
imgData = properties.zFun(refImg.rawdata(:,:,properties.chToPlot,:));
if isnan(properties.cRangeRef)
    properties.cRangeRef = [min(imgData(:)), max(imgData(:))];
end
hasPixelSize = ~isempty(properties.pixelSize);
barLabel = '';
if hasPixelSize
    [imgData, barLabel] = utils.scaleBar(imgData, properties.pixelSize);
end
axes(properties.parent)
utils.sc_pkg.imsc(imgData, properties.cRangeRef)
axis(properties.parent, 'image', 'off');

% Calculate the trajectories using the object's built in method
trajs = trajImgs.calc_trajs('LineMode', properties.LineMode);
nTrajs = numel(trajs);

% Set up the axes for additional plotting
hold(properties.parent, 'on')

% Plot the trajs
for iTraj = 1:nTrajs
    
    xx = trajs{iTraj}(:,1);
    yy = trajs{iTraj}(:,2);
    nPoints = size(trajs{iTraj}, 1);
    
    if isscalar(areas)
        areaToPlot = areas;
    else
        areaToPlot = areas(iTraj);
    end
    
    if iscell(colours)
        colourToPlot = colours{iTraj};
    elseif ischar(colours)
        colourToPlot = colours;
    else
        if isscalar(colours)
            colourToPlot = repmat(colours, [nPoints, 1]);
        elseif isvector(colours)
            colourToPlot = colours;
        elseif ismatrix(colours)
            colourToPlot = colours(iTraj, :);
        end
    end
    
    if iscell(names)
        nameToPlot = names{iTraj};
    else
        nameToPlot = names;
    end
    
    % Choose whether to fill the marker or not.  If a non-filled marker is
    % called with 'filled', then it doesn't seem to plot
    if ismember(properties.marker, filledMarkers)
        extraArgs = {properties.marker, 'filled', ...
            'DisplayName', nameToPlot};
    else
        extraArgs = {properties.marker, 'DisplayName', nameToPlot};
    end
        
    scatter(properties.parent, xx, yy, areaToPlot, colourToPlot, extraArgs{:});
    
end

% Switch hold back to off
hold(properties.parent, 'off')

% Show the legend by default if there are names
if ~isempty(names)
    legend(properties.parent, 'show')
end

if nargout > 0
    varargout{1} = barLabel;
end

end