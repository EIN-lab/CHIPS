function varargout = opt_config(self)
%opt_config - Optimise the parameters in Config objects using a GUI
%
%   opt_config(OBJ) opens a GUI that allows interactive adjustment of the
%   parameters in each Config object. The GUI can also be used to reprocess
%   the object, and produce various plots, which makes it easier to find
%   optimal parameter values.
%
%   For non-scalar ProcessedImg objects, one GUI appears at a time, for
%   each element of the ProcessedImg object.  The next GUI appears once the
%   previous one is closed.
%
%   hFig = opt_config(OBJ) returns a handle to the GUI figure object.
%
%   See also ImgGroup.opt_config, uiwait

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

% Run one after another for non-scalar objects
varargout = {};
if ~isscalar(self)
    for iElem = 1:numel(self)
        hFig = self(iElem).opt_config();
        uiwait(hFig);
    end
    if nargout > 0
        varargout{1} = hFig;
    end
    return
end

% Create the figure and tab group
hFig = figure('name', self.name, 'NumberTitle', 'off');
hTG = uitabgroup('Parent', hFig);

% Setup some dimensions
hOffsetTab = 30;
figWidth = 320;

% Find out the maximum dimensions
calcList0 = self.calcList;
nCalcs = numel(calcList0);
for iCalc = nCalcs:-1:1
    tempDims(iCalc) = self.(calcList0{iCalc}).config.get_dims();
end
maxWidth = max([tempDims(:).panelWidth]);
maxHeight = max([tempDims(:).panelHeight]);
xPanel = (figWidth - maxWidth)/2;

% Loop through each of the Calcs
for iCalc = 1:nCalcs
    
    % Create one tab for each calc
    iCalcName = calcList0{iCalc};
    hTab(iCalc) = uitab('Parent', hTG, 'Title', iCalcName, ...
        'Units', 'pixels');
    
    % Create a panel for the config
    dims = self.(iCalcName).config.get_dims();
    
    % Create the dropdown box for the plot selection
    iWDropdown = 1.5*dims.wButton;
    iXPlotDD = dims.edgePanel;
    iYPlotDD = dims.edgePanel;
    hPopPlot(iCalc) = uicontrol('Style', 'popup', 'Parent', hTab(iCalc), ...
        'String', self.plotList.(iCalcName),...
        'Position', [iXPlotDD, iYPlotDD, iWDropdown, dims.hText]);

	% Create the plot button
    iXPlot = iXPlotDD+iWDropdown+dims.edgePanel;
	hPlot(iCalc) = uicontrol('Style', 'pushbutton', 'Parent', hTab(iCalc), ...
        'String', 'Plot', 'Units', 'pixels', ...
        'Position', [iXPlot iYPlotDD dims.wButton dims.hText], ...
        'CallBack', {@update_plot, self, hPopPlot(iCalc)}, ...
        'TooltipString', 'Display the selected plot');
    
    % Create the close button
    iXClose = iXPlot + dims.wButton + dims.edgePanel;
    hClose(iCalc) = uicontrol('Style', 'pushbutton', 'Parent', hTab(iCalc), ...
        'String', 'Close', 'Units', 'pixels', ...
        'Position', [iXClose iYPlotDD dims.wButton dims.hText], ...
        'CallBack', {@close_plots, hFig}, ...
        'TooltipString', 'Closes all open figures, except this GUI');
    
    % Create save button
    iXSave = figWidth - dims.wButton - dims.edgePanel;
    hSave(iCalc) = uicontrol('Style', 'pushbutton', 'Parent', hTab(iCalc), ...
        'String', 'Save', 'Units', 'pixels', ...
        'Position', [iXSave, iYPlotDD, dims.wButton dims.hText], ...
        'Callback', {@save_btn, self}, ...
        'TooltipString', 'Save the Config to a file for later use');

    
	% Call the config to do most of the work
    yPanel = dims.edgePanel + dims.hText + dims.yIncPanel + dims.yStartProp;
    hPanel(iCalc) = uipanel('Parent', hTab(iCalc), ...
        'Units', 'pixels', ...
        'Position', [xPanel, yPanel, maxWidth, maxHeight]);
    self.(iCalcName).config = ...
        self.(iCalcName).config.opt_config(self, iCalcName, hPanel(iCalc));
    
end

% Adjust/fix the figure size and properties
if ismac
    buffer = 0.5*dims.hText;
else
    buffer = 0;
end
figHeight = maxHeight + dims.yIncPanel + dims.yStartProp + ...
    dims.hText + dims.edgePanel + hOffsetTab + buffer;
currPos = get(hFig, 'OuterPosition');
newPos = [currPos(1)-figWidth-20, currPos(2) - (figHeight - currPos(4)), ...
    figWidth, figHeight];
set(hFig, 'Position', newPos, 'MenuBar', 'none', 'ToolBar', 'none', ...
    'Resize', 'off')

if nargout > 0
    varargout{1} = hFig;
end

end

% ---------------------------------------------------------------------- %

function update_plot(~, ~, objPI, hPopPlot)
% hObject    handle to edit1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB

% Plot the desired figure
options = get(hPopPlot, 'string');
selected = get(hPopPlot, 'Value');
plotName = options{selected};
objPI.plot(plotName)

end

% ---------------------------------------------------------------------- %

function close_plots(~, ~, hFig)
% hObject    handle to edit1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB

% Close all other figures (except the optimise one, and hidden handles)
hFigAll = findobj('Type', 'figure');
maskOther = hFigAll ~= hFig;
close(hFigAll(maskOther))

end

% ---------------------------------------------------------------------- %

function save_btn(~, ~, objPI)
% hObject    handle to edit1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB

% Save Config object to file
confObj = objPI.get_config();
defaultName = class(confObj);
dialog = ['Save ', defaultName, ' object'];
filtSpec = '*.mat';
[fileName, pathName] = uiputfile(filtSpec, dialog, defaultName);

hasCancelled = ~ischar(fileName) || ~ischar(pathName);
if hasCancelled
    % User has cancelled
    return
end

filePath = fullfile(pathName, fileName);
save(filePath, 'confObj')

end
