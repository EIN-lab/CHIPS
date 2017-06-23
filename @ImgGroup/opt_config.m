function varargout = opt_config(self)
%opt_config - Optimise the parameters in Config objects using a GUI
%
%   opt_config(OBJ) opens a GUI that allows interactive adjustment of the
%   parameters in each Config object of each child. The GUI can also be
%   used to reprocess the object, and produce various plots, which makes it
%   easier to find optimal parameter values.
%
%   For non-scalar ImgGroup objects, or non-scalar children, one GUI
%   appears at a time, for each scalar ProcessedImg object.  The next GUI
%   appears once the previous one is closed.
%
%   hFig = opt_config(OBJ) returns a handle to the GUI figure object.
%
%   See also ProcessedImg.opt_config, uiwait

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

% Run one after another through the children
for iChild = 1:self.nChildren
    hFig = self.children{iChild}.opt_config();
    uiwait(hFig);
end
if nargout > 0
    varargout{1} = hFig;
end

end