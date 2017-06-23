function plot_frame(self, varargin)

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

% Parse arguments
[hdlFrameImg, isDebug] = utils.parse_opt_args({[], true}, varargin);

self.plot_frame@StreakScan(hdlFrameImg, isDebug);

lineWidth = 2;

rowsToUse = [0 self.rawImg.metadata.nLinesPerFrame];

axes(hdlFrameImg) 
hold on
if isDebug
    
    plot(self.colsToUseVel(1)*[1, 1], self.rowsToUseVel, 'b--', ...
        'LineWidth', lineWidth)
    plot(self.colsToUseVel(2)*[1, 1], self.rowsToUseVel, 'b--', ...
        'LineWidth', lineWidth)
    plot(self.colsToUseVel, self.rowsToUseVel(1)*[1, 1], 'b--', ...
        'LineWidth', lineWidth)
    plot(self.colsToUseVel, self.rowsToUseVel(2)*[1, 1], 'b--', ...
        'LineWidth', lineWidth)
    
    plot(self.colsToUseDiam(1)*[1, 1], rowsToUse, 'b--', ...
        'LineWidth', lineWidth)
    plot(self.colsToUseDiam(2)*[1, 1], rowsToUse, 'b--', ...
        'LineWidth', lineWidth)
    
end
hold off


end