function varargout = plot_imgs(self, objPI, hAxes, varargin)

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

    % Check the number of arguments
    narginchk(3, inf);

    % Check the axes
    nAxes = 3;
    if isempty(hAxes)

        % Create them if necessary
        mImgs = [0.03 0.02];
        for iAx = 1:nAxes
            hAxes(iAx) = utils.subplot_tight(1, nAxes, iAx, mImgs);
        end

    else

        % Otherwise check that they're axes and there are 3 of them
        utils.checks.hghandle(hAxes, 'axes', 'hAxes');
        utils.checks.numel(hAxes, nAxes, 'hAxes')

    end

    % Check for the image processing toolboxes
    featureImg = 'Image_Toolbox';
    className = 'CalcFindROIsDummy:PlotFig';
    utils.verify_license(featureImg, className);

    % Call the sub function to do most of the work
    self.plot_imgs_sub(objPI, hAxes, varargin{:});
    
    % Pass the output argument, if requested
    if nargout > 0
        varargout{1} = hAxes;
    end

end
