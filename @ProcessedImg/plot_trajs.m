function varargout = plot_trajs(self, varargin)

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

    % Choose the reference image
    if isscalar(self)
        refImg = self(1).refImg;
    else
        % Check that all the raw images are equal
        allEqual = isequal(self(:).refImg);
        if allEqual
            refImg = self(1).refImg;
        else
            error('something has gone wrong');
        end
    end

    % Choose the traj images
    trajImgs = self;

    % Create a new figure
    hFig = figure('Name', refImg.name);

    % Call the utility function to do the plotting
    utils.plot_trajs(refImg, trajImgs, varargin{:})

    if nargout > 0
        varargout{1} = hFig;
    end

end