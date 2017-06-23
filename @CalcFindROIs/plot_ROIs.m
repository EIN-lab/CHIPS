function varargout = plot_ROIs(self, objPI, hAxes, varargin)

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

    % Check the axes
    if isempty(hAxes)
        % Create them if necessary
        hAxes = axes();
    else
        % Otherwise check that it's a scalar axes
        utils.checks.hghandle(hAxes, 'axes', 'hAxes');
        utils.checks.scalar(hAxes, 'hAxes')
    end
    
    % Setup the default parameter names and values
    pNames = {
        'CAxis'; ...
        'Group'; ...
        };
    pValues = {
        []; ...
        false; ...
        };
    dflts = cell2struct(pValues, pNames);
    params = utils.parse_params(dflts, varargin{:});
    
    % Call a sub function to magically prepare and combine the reference
    % image and the ROI overlay
    [combinedImg, nROIs, barLabel] = self.plot_ROI_img(objPI, varargin{:});
    
    % Plot the combined images
    imagesc(combinedImg, 'Parent', hAxes)
    hold(hAxes, 'on')
    colormap(hAxes, 'gray')
    hasCAxisLim = ~isempty(params.CAxis);
    if hasCAxisLim
        caxis([0, params.CAxis])
    end
    title(hAxes, ['ROIs - Scale bar = ', barLabel]);
    axis(hAxes, 'image')
    axis(hAxes, 'off')
    
    % Give a warning if no ROIs were found
    if nROIs == 0
        warning('CalcFindROIs:plotROIs:NoROIFound', ...
            'No ROIs were identified in this image sequence.');
    end

    % Pass the output argument, if requested
    if nargout > 0
        varargout{1} = hAxes;
    end

end