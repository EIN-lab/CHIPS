function varargout = plot_traces(self, ~, hAxTraces, varargin)

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
    narginchk(3, inf);
    varargout = {};
    
    % Setup the default parameter names and values
    pNames = {
        'doHeatmap';...
        'doWholeFrame'; ...
        'normTraces'; ...
        'plotROIs'; ...
        'spacingFactor' ...
        };
    pValues = {
        [];
        true; ...
        true; ...
        []; ...
        1 ...
        };
    dflts = cell2struct(pValues, pNames);
    params = utils.parse_params(dflts, varargin{:});
    
    % Check/get the plotROIs and number of ROIs
    params.plotROIs = self.get_plotROIs(params.plotROIs);
    nROIs = numel(params.plotROIs);
    params.doHeatmap = self.get_doHeatmap(params.doHeatmap, nROIs);

    % Check the axes
    if params.doWholeFrame
        nAxes = nROIs+1;
        hAx = 2;
    else
        nAxes = nROIs;
        hAx = 1;
    end
    hAxTraces = CalcMeasureROIs.get_hAxTraces(hAxTraces, nAxes, ...
        params.doWholeFrame);

    % Setup the x axis limits
    xLims = utils.get_limits(self.data.time);
    
    % Plot the average trace
    if params.doWholeFrame
        plot(hAxTraces(1), self.data.time, self.data.rawTrace, 'k-', ...
            'DisplayName', 'Whole Frame', 'LineWidth', 1.5)
        xlim(hAxTraces(1), xLims)
        hLeg = legend(hAxTraces(1), 'Location', 'Best');
        box(hLeg, 'off')
        set(hLeg, 'Color', 'none')
    end
    
    traces = [];
    if nROIs > 0
    
        % Extract out the traces temporarily
        if params.normTraces
            traces = self.data.tracesNorm;
        else
            traces = self.data.traces;
        end
        
        % Do the plotting
        if params.doHeatmap
            self.plot_traces_heatmap(traces, ...
                hAxTraces(hAx), params);
        else
            self.plot_traces_lines(traces, ...
                hAxTraces(hAx), params);
        end
    
    end
    
    % Format the axes
    axis(hAxTraces, 'tight')
    set(hAxTraces, 'xlim', xLims)
    axis(hAxTraces(1:end-1), 'off')
    
    % Format the last axes differently
    set(hAxTraces(end), 'Color', 'none')
    try 
        set(hAxTraces(end), 'YColor', 'none')
    catch
        set(hAxTraces(end), 'YColor', [0, 0, 0])
    end
    box(hAxTraces(end), 'off')
    xlabel(hAxTraces(end), 'Time [s]')
    
    % Link the axes
    linkaxes(hAxTraces, 'x')
    
    % Draw a scrollable, vertical line over all traces
    % Get units and convert to pixel
    u = get(hAxTraces(1), 'Units');
    set(hAxTraces, 'Units', 'Pixel');
    
    % Get position of first and last axes
    pos1 = get(hAxTraces(1), 'Position');
    pos2 = get(hAxTraces(end), 'Position');
    
    % Set units back to original value
    set(hAxTraces, 'Units', u);
    
    % Find minimal and maximal x values
    minx = pos1(1);
    maxx = pos2(1)+pos2(3);
    
    % Find minimal and maximal Y values
    miny = pos2(4);
    maxy = pos1(2)+pos1(4);
    
    % Create invisible axes over all traces
    coveraxes = axes('Units', 'Pixel', ...
        'Position', [minx miny maxx-minx maxy-miny], ...
        'Visible', 'off', ...
        'Xlim', [0,1]);
    
    % Draw an invisible vertical line
    LineHandle = line([0, 0], [miny, maxy], ...
        'color', 'r', ...
        'Parent', coveraxes, ...
        'Visible', 'off');
    
    % Remove the label for the vertical line
    set(get(get(LineHandle, 'Annotation'), 'LegendInformation'), ...
        'IconDisplayStyle', 'off');
    
    % Set a custom scroll function
    set(gcf, 'WindowScrollWheelFcn', @scrollfun, ...
        'buttondownfcn', @clickline)
    
    % Define the scroll function
    function scrollfun(~,callbackdata)
                
        % Calculate increment
        currInc = 0.01*callbackdata.VerticalScrollCount;
        
        % Find the new X value for the line
        currX = LineHandle.XData;
        newX = currX(1) + currInc;
        newX = max([0, newX(1)]);
        newX = min([newX(1), 1]);
        
        % Update the line position and visibility
        set(LineHandle, 'XData', [newX, newX], 'Visible', 'on');
        
    end
    
    % Define click and drag functions function
    function clickline(~,~)
        
        % Find the position on mouse click
        clicked = get(coveraxes,'currentpoint');
        xcoord = clicked(1,1,1);
        
        % Move vertical line to that position
        set(LineHandle, 'XData', [xcoord xcoord], 'Visible', 'on');
        
        % Set functions for dragging and relase
        set(gcf, 'windowbuttonmotionfcn', @dragline)
        set(gcf, 'windowbuttonupfcn', @dragdone)
        
        function dragline(~,~)
            % Find current curser position
            clicked = get(coveraxes, 'currentpoint');
            xcoord = clicked(1, 1, 1);
            
            % Move vertical line to that position
            set(LineHandle, 'XData', [xcoord xcoord], 'Visible', 'on');
            
        end
        
        function dragdone(~,~)
                
            % Clear the functions
                set(gcf, 'windowbuttonmotionfcn', '');
                set(gcf, 'windowbuttonupfcn', '');
            
        end
        
    end

    if nargout > 0
        varargout{1} = hAxTraces;
        varargout{2} = traces;
    end
    
end