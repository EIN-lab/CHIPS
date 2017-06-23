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
    
    argsout{:} = arrayfun(@(xx) plot_trajs(xx, varargin{:}), self, ...
        'UniformOutput', false);
    if nargout > 0
        varargout = argsout;
    end
    
    return
    
%     % Check that all the raw images are equal
%     allEqual = isequal(self(:).refImg);
%     if allEqual
%         refImg = self(1).refImg;
%     else
%         error();
%     end
    
end

% Choose the traj images
trajImgs = self;

% Call the utility function to do the plotting
nVarArgs = numel(varargin);
argsIn = cell(1, 3);
argsIn(1:nVarArgs) = varargin(1:nVarArgs);
barLabel = utils.plot_trajs(refImg, trajImgs, argsIn{:}, ...
    'pixelSize', self.refImg.metadata.pixelSize);

% Add some annotations
if ~isempty(barLabel)
    strTitle = sprintf('%s (scale = %s)', refImg.name, barLabel);
else
    strTitle = refImg.name;
end
hFig = gcf();
set(hFig, 'Name', strTitle)

if nargout > 0
%     varargout{1} = hFig;
    varargout{1} = [];
end

end