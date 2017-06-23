function varargout = plot(self, varargin)
%plot - Plot a single graph from the data object
%
%   plot(OBJ, X, Y) plots a graph of X vs Y onto the current axis using
%   default values for all other options.  X and Y can be either numeric
%   arrays, or character arrays corresponding to a valid property name in
%   the data object OBJ.  The types and dimensions of X and Y must meet the
%   requirements for the plotting function.
%
%   plot(..., 'attribute', value, ...) specifies one or more
%   attribute/value pairs.  Valid attributes (case insensitive) are:
%
%       debug ->    A flag indicating whether to plot in debug mode.  In
%                   debug mode, the masked points are illustrated with
%                   different colour points. The value must be a scalar
%                   that can be converted to a logical. [default = true]
%
%       average ->  A flag indicating whether to plot the mean and upper
%                   and lower bounds based on the data s.e.m. The value
%                   must be a scalar that can be converted to a logical.
%                   [default = false]
%
%       interp ->   A flag indicating whether to interpolate masked data
%                   points.  The value must be either empty or a scalar
%                   that can be converted to a logical. If empty, the value
%                   for interp is the inverse of debug. [default = []]
%
%       inverse ->  A flag indicating whether to invert the graphs (i.e.
%                   plot Y vs X instead of X vs Y. The value must be a
%                   scalar that can be converted to a logical. 
%                   [default = false]
%
%       plotFun ->  The function to be used for plotting X and Y.  plotFun
%                   must be a scalar function handle. [default = @plot]
%                   The function will be called with the following syntax:
%
%                       plotFun(AX, X, Y)
%
%       plotArgs -> A list of additional arguments to be passed to plotFun.
%                   plotArgs must be a cell array. [default = {}] The 
%                   arguments will be passed with the following syntax:
%
%                       plotFun(AX, X, Y, plotArgs{:})
%
%       blArgs ->   A list of additional arguments to be passed to the
%                   function that produces the bounded line when averaging.
%                   blArgs must be a cell array. [default = {'alpha'}] 
%
%   plot(OBJ, AX, ...) plots onto axis AX instead of the current axis.
%
%   hP =  plot(...) returns handles as ouput by the plotFun.
%
%   [hP, hM] =  plot(...) also returns the handles generated when plotting
%   the masks.
%
%   [hP, hM, hB] =  plot(...) also returns handles to the patch objects
%   generated when plotting the bounds.
%
%   See also utils.boundedline.boundedline, Data.plot_graphs, plot

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
    
%% Parse arguments

% Define the allowed optional arguments and default values, and create a
% default parameters structure
pnames = {'average', 'blArgs', 'debug', 'interp', 'inverse', ...
    'plotArgs', 'plotFun'};
dflts  = {false, {'alpha'}, true, [], false, {}, @plot};
params = cell2struct(dflts, pnames, 2);

% Parse arguments (ignoring warning about any extra ones)
wngState = warning('off', 'ParseOptArgs:TooManyInputs');
warning('off', 'ParsePropVal:UnknownAttr');

% Check we have enough arguments (initial check)
narginchk(2, inf)

% Check axis handle is the correct class, create one if it doesn't exist,
% and work out where the rest of the arguments are
hasAxis = isscalar(varargin{1}) && ishghandle(varargin{1});
if hasAxis
    
    % Check we have enough arguments
    narginchk(4, inf)
    
    % Pull out the axis
    hAxis = varargin{1};
    
    % Extract the rest of the arguments
    [xDataIn, yDataIn] = utils.parse_opt_args({[], []}, varargin(2:end));
    params = utils.parsepropval(params, varargin{4:end});
    
else
    
    % Check we have enough arguments
    narginchk(3, inf)
    
    % Get the current axis (or create one)
    hAxis = gca;
    
    % Extract the rest of the arguments
    [xDataIn, yDataIn] = utils.parse_opt_args({[], []}, varargin(1:end));
    params = utils.parsepropval(params, varargin{3:end});
    
end

% Restore the warning state
warning(wngState)

%% Check arguments

% Check average - should be scalar and convertible to boolean
utils.checks.scalar_logical_able(params.average, 'average flag');

% Check blArgs - should be a cell array
utils.checks.cell_array(params.blArgs, 'blArgs');

% Check isDebug - should be scalar and convertible to boolean
utils.checks.scalar_logical_able(params.debug, 'debug flag');

% Check interp = should be empty or a scalar boolean
if isempty(params.interp)
    params.interp = ~params.debug;
end
utils.checks.scalar_logical_able(params.interp);

% Check plotFun - should be a scalar function handle
utils.checks.scalar(params.plotFun, 'plotFun');
utils.checks.object_class(params.plotFun, 'function_handle', 'plotFun');

% Check plotArgs - should be a cell array
utils.checks.cell_array(params.plotArgs, 'plotArgs');

% Check the data - should be char or numeric array
xData = self.check_data(xDataIn, params.average, 'X');
[yData, yDataSEM] = self.check_data(yDataIn, params.average, 'Y');

%% Main part of the function

% Linearly interpolate the points
if params.interp
    yData = self.interp_masked(yData);
end

% Do the actual plotting
hBounds = [];
axes(hAxis), hold on
if params.average
    [hLine, hBounds] = utils.boundedline.boundedline(xData, yData, ...
        yDataSEM, hAxis, params.blArgs{:});
    delete(hLine)
end
hPlot = params.plotFun(hAxis, xData, yData, params.plotArgs{:});

% Display the masked points
hMask = [];
if params.debug
    
    pointType = {'x','+','o','s','d','v','^','<','>','p','h'};
    maskFields = self.listMask;
    nMasks = length(maskFields);
    hMask = zeros(nMasks, 1);
    
    nPointTypes = numel(pointType);
    for iMask = 1:nMasks
        maskTmp = any([self.(maskFields{iMask})], 2);
        if sum(maskTmp) > 0
            iPointType = rem(iMask, nPointTypes);
            if iPointType == 0;
                iPointType = nPointTypes;
            end
            hMask(iMask) = plot(xData(maskTmp), yData(maskTmp), ...
                ['r' pointType{iPointType}]);
        end
    end
    
end

%% Sort out the axis limits

maskAll = [self.mask];
doAverage = params.average;
[xLims, yLims] = get_all_lims(xData, yData, yDataSEM, ...
    maskAll, doAverage);
if params.inverse
    semUse = std(xData, [], 2)/sqrt(length(self));
    [~, xLims] = get_all_lims(yData, xData, semUse, ...
        maskAll, doAverage);
end


% % X axis
% xLims = utils.get_limits(xDataUse);
%     
% % Y axis - Check that we actually have some good (non-masked data)
% yLimMultiple = 0.1;
% maskAll = [self.mask];
% if params.average
%     maskAll = any(maskAll, 2);
% end
% hasSomeData = ~isempty(yDataUse(~maskAll)) && ...
%     length(unique(yDataUse(~maskAll))) > 1;
% if hasSomeData
% 
%     yMaxData = bsxfun(@plus, yDataUse, params.average*semUse);
%     yMinData = bsxfun(@minus, yDataUse, params.average*semUse);
%     yMax = max(yMaxData(~maskAll));
%     yMin = min(yMinData(~maskAll));
%     yRange = yMax - yMin;
%     yLims = [yMin - yLimMultiple*yRange, ...
%         yMax + yLimMultiple*yRange];
%     if isnan(yLims(1))
%         yLims(1) = -inf;
%     end
%     if isnan(yLims(2))
%         yLims(2) = inf;
%     end
% 
% else
%     yLims = [-inf inf];
% end

xlim(hAxis, xLims)
ylim(hAxis, yLims)
set(hAxis, 'Color', 'none')
hold off

% Assign the output argument, if necessary
if nargout > 0
    varargout{1} = hPlot;
    varargout{2} = hMask;
    varargout{3} = hBounds;
end

end

function [xLims, yLims] = get_all_lims(xDataUse, yDataUse, yDataSEMUse, ...
    maskAll, doAverage)

% X axis
xLims = utils.get_limits(xDataUse);
    
% Y axis - Check that we actually have some good (non-masked data)
yLimMultiple = 0.1;
if doAverage
    maskAll = any(maskAll, 2);
end
hasSomeData = ~isempty(yDataUse(~maskAll)) && ...
    length(unique(yDataUse(~maskAll))) > 1;
if hasSomeData

    yMaxData = bsxfun(@plus, yDataUse, doAverage*yDataSEMUse);
    yMinData = bsxfun(@minus, yDataUse, doAverage*yDataSEMUse);
    yMax = max(yMaxData(~maskAll));
    yMin = min(yMinData(~maskAll));
    yRange = yMax - yMin;
    yLims = [yMin - yLimMultiple*yRange, ...
        yMax + yLimMultiple*yRange];
    if isnan(yLims(1))
        yLims(1) = -inf;
    end
    if isnan(yLims(2))
        yLims(2) = inf;
    end

else
    yLims = [-inf inf];
end

end
