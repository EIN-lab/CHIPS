function varargout = stack_slider(varargin)
%stack_slider - Display an image sequence with a slider
%
%   stack_slider(IMG) is a utility function for visual inspection of image
%   stacks. It displays a stack with a slider to scroll through frames.
%
%   stack_slider(..., 'attribute', value, ...) uses the specified
%   attribute/value pairs.  Valid attributes (case insensitive) are:
%
%       'CAxis' ->      An empty, scalar, or length two numeric vector
%                       corresponding to the desired image colour/intensity
%                       axis limits. If empty, the image minimum and
%                       maximum will be used.  If scalar, [0, CAxis] will
%                       be used.  If length two, CAxis should correspond to
%                       [CMin, CMax]. [default = []]
%       'force4D' ->    Boolean flag whether to force the slider to treat
%                       the IMG as 4D, even if it only has 3 dimension.
%                       This is useful when trying to view an image that
%                       only has one frame, but more than one channel.
%                       [default = []]
%       'scaleBarOn'->  Boolean flag whether to add a scale bar.
%                       [default = false] 
%       'pixelSize' ->  Scalar numeric specifying the size of one image 
%                       pixel. Only used when displaying a scale bar. 
%                       [default = []] 
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
%   stack_slider(HFIG, ...) uses the specified figure handle HFIG.  If not
%   supplied, the current figure handle (or a new one, if none exist) will
%   be used.
%
%   HFIG = stack_slider() returns the figure handle.
%
%   This function is based on a significant portion of code (commented '%//')
%   written by stackoverflow user Benoit_11, which was retrieved from:
%   http://stackoverflow.com/questions/28256106/image-stack-display-in-matlab-using-a-slider

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

% ================================================================== %

% Assign/create the figure handle, and make it the current figure
idxStart = 1;
hasFig = (numel(varargin) > 0) && isscalar(varargin{1}) && ...
    ishghandle(varargin{1}) && strcmp(get(varargin{1}, 'type'), 'figure');
if hasFig
    hFig = varargin{1};
    idxStart = idxStart + 1;
else
    hFig = gcf();
end
figure(hFig)

% Check the number of inputs and extract out the image sequence
narginchk(idxStart, inf);
imgSeq = varargin{idxStart};

% Assign the output arguments
if nargout > 0
    varargout{1} = hFig;
end

% Define allowed optional arguments and default values
pNames = {...
    'CAxis'; ...
    'force4D'; ...
    'scaleBarOn'; ...
    'pixelSize'; ...
    'barlength'; ...
    'location'; ...
    'color'};
pValues  = {...
    []; ...
    []; ...
    false; ...
    []; ...
    []; ...
    'southeast'; ...
    []};
dflts = cell2struct(pValues, pNames);

% Parse any remaining input arguments
params = utils.parsepropval(dflts, varargin{idxStart+1:end});

% Check input is numeric or logical
utils.checks.object_class(imgSeq, {'numeric', 'logical'}, 'image sequence')

% Check input is a stack of the appropriate dimensions
if params.force4D
    nDimsImg = 4;
else
    imgSeq = squeeze(imgSeq);
    nDimsImg = ndims(imgSeq);
end
allowEq = true;
utils.checks.less_than(nDimsImg, 4, allowEq, 'number of image dimensions')
utils.checks.greater_than(nDimsImg, 3, allowEq, 'number of image dimensions')

switch nDimsImg
    case 4
        
        % Work out if it's really a grayscale image, and if so recursively 
        % call the function to do some magic!
        nChsImg = size(imgSeq, 3);
        if nChsImg == 1  
            hFig = utils.stack_slider(hFig, squeeze(imgSeq), ...
                varargin{idxStart+1:end}, 'force4D', false);
            return
        end
            
        % RGB stack or multichannel img
        mode = 'rgb';
        frameDim = 4;
        
        % If it's already an RGB truecolour image, don't do anything.
        % Otherwise cast the image data to a double precision array, then
        % scale the image channels to their maximum and minimum values
        isTC = isa(imgSeq, 'double') && (size(imgSeq, 3) == 3) && ...
            (min(imgSeq(:)) >= 0) && (max(imgSeq(:)) <= 1);
        if ~isTC
            imgSeq = utils.combine_img_chs(imgSeq);
        end
        nChsImg = size(imgSeq, 3);
        if isempty(params.CAxis)
            params.CAxis = [0, 1];
        end
        
    case 3
        
        % Gray scale or logical stack
        mode = 'grayscale';
        frameDim = 3;
        nChsImg = 1;
        if isempty(params.CAxis)
            params.CAxis = utils.checks.check_cAxis(params.CAxis, imgSeq);
        end

end
utils.checks.less_than(nChsImg, 4, allowEq, 'number of image channels')

% Prepare the scale bar, if necessary
barLabel = [];
if params.scaleBarOn
    
    % Change the scale bar colour, if necessary
    updateSBCol = ~isempty(params.CAxis) && isempty(params.color);
    if updateSBCol
        params.color = params.CAxis(end);
    end
    
    % Add the scale bar to the image stack
    [imgSeq, barLabel] = utils.scaleBar(imgSeq, params.pixelSize, ...
        'barlength', params.barlength, 'location', params.location, ...
        'color', params.color);
    nChsImg = size(imgSeq, 3);
    
end

%// Function SliderDemo by stackoverflow user 'Benoit_11'
NumFrames = size(imgSeq, frameDim);
set(hFig, 'Position', [100 100 500 500], ...
    'Units', 'normalized', ...
    'WindowScrollWheelFcn', @figScroll);
handles.axes1 = axes('Parent', hFig, 'Units', 'normalized', ...
    'Position', [0.05 0.05 0.9 0.9]);
handles.image = image(zeros(size(imgSeq(:,:,1,1))));

%// Display 1st frame
switch mode
    case 'rgb'
        szImg = size(imgSeq(:,:,1,1));
        MyMatrix = zeros([szImg, 3, NumFrames], class(imgSeq));
        MyMatrix(:, :, 1:nChsImg, :) = imgSeq;
    case 'grayscale'
        MyMatrix = imgSeq;
end
update_img(mode, handles, MyMatrix, 1, params.CAxis)
setappdata(hFig, 'MyMatrix', MyMatrix);

% Tidy up the axes
axis(handles.axes1, 'off')
axis(handles.axes1, 'equal')
hold(handles.axes1, 'on')

% If there's only one frame, we don't need to do anything else!
if NumFrames == 1
    return
end

%// Create slider and listener object for smooth visualization
handles.SliderFrame = uicontrol('Style', 'slider', 'Units', 'normalized', ...
    'Position', [0.05, 0.005, 0.725, 0.04], 'Min', 1, 'Max', NumFrames, ...
    'Value', 1, 'SliderStep', [1/(NumFrames-1) 2/NumFrames], ...
    'Callback', @XSliderCallback);
handles.SliderxListener = addlistener(handles.SliderFrame, 'Value',...
    'PostSet', @(s,e) XListenerCallBack);
handles.title = title(gen_title(1, barLabel));

%// Use setappdata to store the image stack and in callbacks, use 
%   getappdata to retrieve it and use it. Check the docs for the calling
%   syntax.

% Create save button
handles.hBtnSave = uicontrol('Style', 'pushbutton', 'Units', 'normalized', ...
    'String', 'Save', 'FontWeight', 'normal', ...
    'Position', [0.8, 0.005, 0.15, 0.04], ...
    'Callback', {@save_btn, imgSeq, mode}, ...
    'TooltipString', 'Save the image for later use');

%// IMPORTANT. Update handles structure.
guidata(hFig, handles);

%// Listener callback, executed when you drag the slider.

    function XListenerCallBack
        
        %// Retrieve handles structure. Used to let MATLAB recognize the
        %// edit box, slider and all UI components.
        handles = guidata(gcf);
        
        %// Here retrieve MyMatrix using getappdata.
        MyMatrix = getappdata(hFig, 'MyMatrix');
        
        %// Get current frame
        CurrentFrame = round((get(handles.SliderFrame, 'Value')));
        set(handles.title, 'String', gen_title(CurrentFrame, barLabel));
        
        %// Display appropriate frame.
        update_img(mode, handles, MyMatrix, CurrentFrame, params.CAxis)
        
        guidata(hFig, handles);
    end

    % ------------------------------------------------------------------- %

%// Slider callback; executed when the slider is release or you press
%// the arrows.
    function XSliderCallback(~,~)
        
        handles = guidata(gcf);
        
        %// Here retrieve MyMatrix using getappdata.
        MyMatrix = getappdata(hFig,'MyMatrix');
        
        CurrentFrame = round((get(handles.SliderFrame, 'Value')));
        set(handles.title, 'String', gen_title(CurrentFrame, barLabel));
        
        update_img(mode, handles, MyMatrix, CurrentFrame, params.CAxis)
        
        guidata(hFig, handles);
    end

    % ------------------------------------------------------------------- %
    
    %// Figure scroll function. Executed when you use the scroll wheel
    function figScroll(~,callbackdata)
        
        handles = guidata(gcf);
        
        % Get total number of frames
        [~,~,nFrames] = size(MyMatrix);
        
        % Find current position
        CurrentFrame = round((get(handles.SliderFrame, 'Value')));
        
        % Calculate increment
        inc = round(nFrames/100);
        
        % Find the new frame to display
        newFrame = CurrentFrame + inc*callbackdata.VerticalScrollCount;
        newFrame = max([1, newFrame]);
        newFrame = min([newFrame, nFrames]);
        
        % Update the title, slider and displayed frame
        set(handles.title, 'String', gen_title(newFrame, barLabel));
        set(handles.SliderFrame, 'Value', newFrame);
        
        update_img(mode, handles, MyMatrix, newFrame, params.CAxis)
        
        guidata(hFig, handles);
    end

end

% ----------------------------------------------------------------------- %

function save_btn(~, ~, imgSeq, mode)
    % Save image data to file
    dialog = 'Save image';
    filtSpec = '*.tif';
    [fileName, pathName] = uiputfile(filtSpec, dialog);

    hasCancelled = ~ischar(fileName) || ~ischar(pathName);
    if hasCancelled
        % User has cancelled
        return
    end

    filePath = fullfile(pathName, fileName);

    switch mode
        case 'grayscale'
            % Export the image stack to a grayscale TIFF
            optsTif = struct('color', false, 'compression', 'lzw', ...
                'overwrite', true, 'message', false);

        case 'rgb'
            % Export the image stack to a color TIFF
            optsTif = struct('color', true, 'compression', 'lzw', ...
                'overwrite', true, 'message', false);
            imgSeq = cast(imgSeq*(2^16), 'uint16');
    end

    % Save stack using utility function
    utils.saveastiff(imgSeq, filePath, optsTif);

end

% ----------------------------------------------------------------------- %

function update_img(mode, handles, img, numFrame, cAxis)

    switch mode
        case 'rgb'
            set(handles.image, ...
                'CData', utils.sc_pkg.sc(img(:,:,:,numFrame), cAxis));
        case 'grayscale'
            set(handles.image, ...
                'CData', utils.sc_pkg.sc(img(:,:,numFrame), cAxis));
    end
        
end

% ----------------------------------------------------------------------- %

function strTitle = gen_title(iFrame, barLabel)

if isempty(barLabel)
    strTitle = sprintf('Frame: %d', iFrame);
else
    strTitle = sprintf('Frame: %d (Scale Bar = %s)', iFrame, barLabel);
end

end
