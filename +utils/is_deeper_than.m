function tf = is_deeper_than(strFun, varargin)
%is_deeper_than - Check if the level of recursion is deeper than a limit
%
%   This function is not intended to be called directly.

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
narginchk(1, 2);

% Parse arguments
depthLim = utils.parse_opt_args({1}, varargin);

% Check if the current recursion depth is deeper than the limit
stackInfo = dbstack();
depthRecursion = sum(strcmp(strFun, {stackInfo(:).name}));
tf =  depthRecursion > depthLim;

end