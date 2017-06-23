function varargout = opt_config(self, objPI, calcName, varargin)
%opt_config - Optimise parameters using a GUI
%
%   opt_config(OBJ, OBJ_PI, 'calc') opens a GUI that allows interactive
%   adjustment of the parameters in a Config object, using the ProcessedImg
%   object OBJ_PI and the property name of the relevant Calc object in
%   OBJ_PI. The GUI can also be used to produce various plots, which makes
%   it easier to find optimal parameter values.
%
%   [OBJ, H] = opt_config(...) returns a the Config object and a handle to
%   the uipanel.
%
%   See also Config.opt_config, ImgGroup.opt_config, uiwait

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
narginchk(3, 5);

% Check the ProcessedImg
utils.checks.object_class(objPI, 'ProcessedImg', 'ProcessedImg object');
utils.checks.scalar(objPI, 'ProcessedImg object');

% Check the calcName
utils.checks.single_row_char(calcName, 'Calc name');
utils.checks.has_prop(objPI, calcName, 'ProcessedImg object')

% Parse arguments
[hPan0, initConfig] = utils.parse_opt_args({[], copy(self)}, varargin);

% Create a new panel, if one is not supplied
hasNoParent = isempty(hPan0);
if hasNoParent
    hPan0 = uipanel();
end

% Get some details
set(hPan0, 'Units', 'pixels')
panelPos = get(hPan0, 'Position');

% Setup the output arguments
if nargout > 0
    varargout{1} = self;
end
if nargout > 1
    varargout{2} = hPan0;
end

% Get some dimensions
dims = self.get_dims();

% Add a title 
bTitle = panelPos(4) - dims.edgePanel - dims.hText;
lTitle = dims.edgePanel;
uicontrol('Style', 'text', 'Parent', hPan0', ...
    'String', class(self), 'FontWeight', 'bold', ...
    'Position', [lTitle, bTitle, dims.wPanel, dims.hText]);

% Add some useful text if there are no parameters to optimise
if ~self.isOptimisable
    strNotOpt = sprintf(...
        ['This Config object contains\n', ...
         ' no optimisable parameters ']);
    hNonOpt = 40;
    bNonOpt = 0.5*(bTitle - dims.edgePanel + dims.hText) + ...
        dims.edgePanel - 0.5*hNonOpt;
    posStr = [0 bNonOpt panelPos(3) hNonOpt];
    uicontrol('Style', 'text', 'Parent', hPan0, 'Units', 'pixels', ...
        'String', strNotOpt, 'Position', posStr);
end

% Create update button
hBtnUpdate = uicontrol('Style', 'pushbutton', 'Parent', hPan0', ...
    'String', 'Process', 'FontWeight', 'normal', ...
    'Position', [dims.edgePanel, dims.edgePanel, dims.wButton dims.hText], ...
    'Callback', {@process_btn, self, objPI, calcName}, ...
    'TooltipString', 'Process the Calc corresponding to this Config');

% We don't need anything below here if there's nothing to optimise
if ~self.isOptimisable
    return
end

% Create default button
hBtnDefault = uicontrol('Style', 'pushbutton', 'Parent', hPan0', ...
    'String', 'Default', 'FontWeight', 'normal', ...
    'Position', [dims.edgePanel+5 dims.edgePanel dims.wButton dims.hText], ...
    'Callback', {@default_btn, self, initConfig, objPI, calcName, hPan0}, ...
    'TooltipString', 'Apply the default parameter values for this Config');

% Create reset button
hBtnReset = uicontrol('Style', 'pushbutton', 'Parent', hPan0', ...
    'String', 'Reset', 'FontWeight', 'normal', ...
    'Position', [dims.wPanel+dims.edgePanel-dims.wButton, ...
        dims.edgePanel dims.wButton dims.hText], ...
    'Callback', {@reset_btn, self, initConfig, objPI, calcName, hPan0}, ...
    'TooltipString', ['Reset this Config to the initial parameter ', ...
        'values (i.e. those that existed when the GUI opened)']);

% Align the three buttons
align([hBtnReset, hBtnDefault, hBtnUpdate], 'Distribute', 'none')

%% Layout the actual properties, in their groups

iYPan = panelPos(4) - dims.edgePanel - dims.hText;
for iPanel = 1:self.nOptPanels
    
    % Create the panel for this group
    nProps = numel(self.optList{iPanel, 2});
    iHPan = nProps*dims.yIncProp + dims.yStartProp*2 + dims.yOffPanTitle;
    iYPan = iYPan - iHPan - (iPanel > 1)*dims.yIncPanel;
    hPanGroups(iPanel) = uipanel('Parent', hPan0, 'Units', 'pixels', ...
        'Title', self.optList{iPanel, 1}, 'FontWeight', 'bold', ...
        'Position', [dims.edgePanel, iYPan, dims.wPanel, iHPan]);
    
    % Loop through the properties for this group, adding a text box and
    % edit control for each of them
    for jProp = nProps:-1:1
        
        jPropR = nProps - jProp + 1;
        jPropName = self.optList{iPanel, 2}{jProp};
        jYProp = (jPropR-1)*dims.yIncProp + dims.yStartProp;
        uicontrol('Style', 'text', 'Parent', hPanGroups(iPanel), ...
            'Units', 'pixels', 'String', jPropName, ...
            'Position', [dims.wEdgeProp jYProp dims.wStr dims.hText]);
        
        if islogical(self.(jPropName))
            uiStyle = 'checkbox';
            uiStr = 'Value';
            uiVal = self.(jPropName);
        elseif ischar(self.(jPropName))
            uiStyle = 'edit';
            uiStr = 'String';
            uiVal = self.(jPropName);
        else
            uiStyle = 'edit';
            uiStr = 'String';
            propDims = size(self.(jPropName));
            
            % Check for any vector properties and convert them to colon
            % notation
            if any(propDims > 1)
                uiVal = utils.vect2colon(self.(jPropName));
            else
                uiVal = num2str(self.(jPropName));
            end
        end
        
        uicontrol('Style', uiStyle, 'Parent', hPanGroups(iPanel), ...
            'Units', 'pixels', uiStr, uiVal, ...
            'Position', [dims.wEdgeProp+dims.wStr, jYProp, ...
                dims.wEdit, dims.hText], ...
            'TooltipString', help([class(self) '.' jPropName]), ...
            'Callback', {@update_val, self, jPropName});
        
    end
    
end

end

% ---------------------------------------------------------------------- %

function update_val(hObject, ~, confObj, jPropName)
% hObject    handle to edit1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB

switch get(hObject, 'Style')
    
    case 'checkbox'
        
        input = get(hObject,'Value');
        
    case 'edit'
        
        input = str2double(get(hObject,'string'));
        if isnan(input)
            input = str2num(get(hObject,'string')); %#ok<ST2NM>
            if isempty(input)
                input = get(hObject,'string');
            end
        end
        
end

confObj.(jPropName) = input;

end

% ---------------------------------------------------------------------- %

function reset_btn(~, ~, confObj, initConfig, objPI, calcName, hPan)
% hObject    handle to edit1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB

% Replace all the properties with the originals
propsList = properties(initConfig);
for iProp = 1:numel(propsList)
    iPropName = propsList{iProp};
    confObj.(iPropName) = initConfig.(iPropName);
end

% Redraw the GUI so that it updates
confObj.opt_config(objPI, calcName, hPan, initConfig);

end

% ---------------------------------------------------------------------- %

function default_btn(~, ~, confObj, initConfig, objPI, calcName, hPan)
% hObject    handle to edit1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB

% Replace all the properties with the defaults
hCon = str2func(class(confObj));
defConfig = hCon();
propsList = properties(defConfig);
for iProp = 1:numel(propsList)
    iPropName = propsList{iProp};
    confObj.(iPropName) = defConfig.(iPropName);
end

% Redraw the GUI so that it updates
confObj.opt_config(objPI, calcName, hPan, initConfig);

end

% ---------------------------------------------------------------------- %

function process_btn(~, ~, confObj, objPI, calcName)
% hObject    handle to edit1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB

% Notify listeners to process an object
eventDataObj = ED_ProcessNow(objPI, calcName);
notify(confObj, 'ProcessNow', eventDataObj);

end
