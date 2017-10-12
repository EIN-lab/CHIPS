function varargout = plot_graphs(self, varargin)
%plot_graphs - Plot multiple graphs from the data object
%
%   plot_graphs(OBJ, X) plots graphs of X vs the default variables for the
%   appropriate Data subclass Y onto the current figure.  X must be either
%   a numeric array, or a character array corresponding to a valid property
%   name in the data object OBJ.
%
%   plot_graphs(OBJ, X, Y) plots graphs of X vs Y instead of the default
%   variables.  Y must be either a numeric array, a character array
%   corresponding to a valid property name in the data object OBJ, or a
%   cell array where the elements are one of these formats.
%
%   plot_graphs(..., 'attribute', value, ...) specifies one or more
%   attribute/value pairs.  In addition to those attributes supported by
%   the plot method of the Data class (see link below), other valid
%   attributes (case insensitive) are:
%
%       yLabels ->  A list of y axis labels.  yLabels must be either a
%                   single row character array, or a cell array containing
%                   single row character arrays.
%
%   plot_graphs(OBJ, AX, ...) plots the graphs onto axes AX.
%
%   AX = plot_graphs(...) returns handles to the axes plotted on.
%
%   See also Data.plot, plot

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
pnames = {'average', 'blArgs', 'debug', 'interp', 'inverse', 'yLabels', ...
    'plotArgs', 'plotFun'};
dflts  = {false, {'alpha'}, true, [], false, [], {}, @plot};
params = cell2struct(dflts, pnames, 2);

% Check we have enough arguments
narginchk(2, inf)

% Parse arguments (ignoring warning about any extra ones)
wngState = warning('off', 'ParseOptArgs:TooManyInputs');

% Check axis handle is the correct class, create one if it doesn't exist,
% and work out where the rest of the arguments are
hAxes = [];
hasAxes = (nargin > 1) && all(ishghandle(varargin{1})) && ...
    all(strcmp(get(varargin{1}, 'type'), 'axes'));
if hasAxes
    
    % Check we have enough arguments in this case
    narginchk(3, inf)
    
    % Pull out the axis
    hAxes = varargin{1};
    
    % Extract the rest of the arguments
    [xDataIn, yVarListIn] = utils.parse_opt_args({[], []}, ...
        varargin(2:end));
    params = utils.parsepropval(params, varargin{4:end});
    
else
    
    % Extract the rest of the arguments
    [xDataIn, yVarListIn] = utils.parse_opt_args({[], []}, ...
        varargin(:));
    params = utils.parsepropval(params, varargin{3:end});
    
end

% Restore the warning state
warning(wngState)

%% Check the easy arguments

% Check average - should be scalar and convertible to boolean
utils.checks.scalar_logical_able(params.average, 'average flag');

% Check blArgs - should be a cell array
utils.checks.cell_array(params.blArgs, 'blArgs');

% Check isDebug - should be scalar and convertible to boolean
utils.checks.scalar_logical_able(params.debug, 'debug flag');

% Check inverse - should be scalar and convertible to boolean
utils.checks.scalar_logical_able(params.inverse, 'inverse flag');

% Check interp = should be empty or a scalar boolean
if isempty(params.interp)
    params.interp = ~params.debug && ~params.inverse;
end
utils.checks.scalar_logical_able(params.interp);

% Check plotFun - should be a scalar function handle
utils.checks.scalar(params.plotFun, 'plotFun');
utils.checks.object_class(params.plotFun, 'function_handle', 'plotFun');

% Check plotArgs - should be a cell array
utils.checks.cell_array(params.plotArgs, 'plotArgs');

%% Check/generate the y variables and labels

% Work out which variables to plot
if isempty(yVarListIn)
    
    % Extract the default list of variables
    if params.debug
        yVarList = self.listPlotDebug;
        yLabelList = self.labelPlotDebug;
    else
        yVarList = self.listPlotGood;
        yLabelList = self.labelPlotGood;
    end
    
else
    
    % Put a char array inside a cell
    if ischar(yVarListIn)
        yVarListIn = {yVarListIn};
    end
    
    % Check the contents of each element of the cell array
    if iscell(yVarListIn)
        
        nVarsIn = length(yVarListIn);
        for iVarIn = 1:length(nVarsIn)
            
            % Check that the contents of the cell array is as expected
            utils.checks.single_row_char(yVarListIn{iVarIn}, ...
                'elements of the Y variable list')
            
            % Check that the variable is actually present in this class
            isProperty = ismember(yVarListIn{iVarIn}, properties(self));
            if ~isProperty
                error('Data:PlotGraphs:UnknownYVarIn', ['"%s" is not ' ...
                    'recognised as a property of the data class "%s".'], ...
                    yVarListIn{iVarIn}, class(self))
            end
            
        end
        
    else
        
        % Bad data type
        error('Data:PlotGraphs:BadYVarIn', ['The yVarList must be a ' ...
            'cell or character array, and you have supplied data of ' ...
            'class "%s"'], class(yVarListIn))
        
    end
    
    % Assign the variables
    yVarList = yVarListIn;
    yLabelList = yVarList;
    
end

% Work out how many plots we're going to do
nVars = length(yVarList);

% Assign the input labels, if necessary
if ~isempty(params.yLabels)

    % Put a char array inside a cell
    if ischar(params.yLabels)
        params.yLabels = {params.yLabels};
    end

    % Check the cell and the contents of each element
    if iscell(params.yLabels)

        yLabTooShort = numel(params.yLabels) < nVars;
        yLabTooLong = numel(params.yLabels) > nVars;
        if yLabTooShort
            error('Data:PlotGraphs:ShortYLabelsIn', ['There are ' ...
                'fewer y labels supplied than variables to plot.'])
        elseif yLabTooLong
            warning('Data:PlotGraphs:LongYLabelsIn', ['Ignoring ' ...
                'extra y labels.'])
        end
        
        % Check that the contents of the cell array is as expected
        nLabelsIn = length(params.yLabels);
        for iVarIn = 1:nLabelsIn
            utils.checks.single_row_char(params.yLabels{iVarIn}, ...
                'elements of the Y labels list')
        end

    else
        
        % Bad data type
        error('Data:PlotGraphs:BadYLabelsIn', ['The yVarList must ' ...
            'be a cell or character array, and you have supplied ' ...
            'data of class "%s"'], class(params.yLabels))

    end
    
    % Assign the labels
    yLabelList = params.yLabels;

end

%% Main part of the function

% Check hAxes is the correct size.
if ~isempty(hAxes)
    axTooShort = numel(hAxes) < nVars;
    axTooLong = numel(hAxes) > nVars;
    if axTooShort
        error('Data:PlotGraphs:ShortHAxes', ['There are fewer axes ' ...
            'supplied than variables to plot.'])
    elseif axTooLong
        warning('Data:PlotGraphs:LongHAxes', 'Ignoring extra axes.')
    end
end

% Plot all of the variables
for iVar = nVars:-1:1
    
    % Create new axes, if necessary
    doCreate = isempty(hAxes) || ~strcmp(get(hAxes(iVar), 'type'), 'axes');
    if doCreate
        hAxes(iVar) = subplot(nVars, 1, iVar);
    end
    
    % Check if we're plotting normally or with x and y reversed
    if ~params.inverse
        
        % Keep the x and y axes data on the correct axes
        xDataPlot = xDataIn;
        yDataPlot = yVarList{iVar};
        ylabel(hAxes(iVar), yLabelList{iVar})
        
    else
        
        % Switch the x and y axes around
        yDataPlot = xDataIn;
        xDataPlot = yVarList{iVar};
        ylabel(hAxes(iVar), yLabelList{iVar})
        
    end
    
    % Do the actual plotting
    self.plot(hAxes(iVar), xDataPlot, yDataPlot, params)
    
end

% Assign the output argument, if necessary
if nargout > 0
    varargout{1} = hAxes;
end

end