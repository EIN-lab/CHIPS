function [trajs, otherChs] = calc_trajs(self, varargin)

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
    trajs = arrayfun(@(xx) calc_trajs(xx, varargin{:}), self);
    return
end

[trajs, otherChs] = ITraj.calc_traj(self.refImg, self, varargin{:});
trajs = {trajs};
otherChs = {otherChs};

end