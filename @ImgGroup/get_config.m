function configOut = get_config(self)
%get_config - Return the Configs from this object
%
%   CONFIGS = get_config(OBJ) returns a list of the config objects
%   associated with each child. CONFIGS is a cell array of size 
%   [1, nChildren].  If the ImgGroup object is non-scalar, CONFIGS will 
%   be a cell array of length numel(OBJ), where each cell corresponds to
%   the output from one ImgGroup object.
%
%   See also ImgGroup.children, ImgGroup.nChildren,
%   ProcessedImg.get_config, Config

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
    
    % Call the function one by one if we have an array
    if ~isscalar(self)
        configOut = arrayfun(@(xx) get_config(xx), self, ...
            'UniformOutput', false);
        return
    end

    configOut = cell(1, self.nChildren);
    for iChild = 1:self.nChildren
        configOut{iChild} = self.children{iChild}.get_config();
    end

end