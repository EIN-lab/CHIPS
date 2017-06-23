function clear_unwanted_wngs(IDsOff, lastMsgPre, lastIDPre)
%clear_unwanted_wngs - Helper function to clear unwanted warnings
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
narginchk(3, 3);

% Put this inside a cell array for easier use
if ~iscell(IDsOff)
    IDsOff = {IDsOff};
end

% Work out if an unwanted warning was triggered, and if so remove it.
[lastMsgPost, lastIDPost] = lastwarn();
isSameWarn = strcmpi(lastMsgPre, lastMsgPost);
doReset = ~isSameWarn && ismember(lastIDPost, IDsOff);
if doReset
    lastwarn(lastMsgPre, lastIDPre);
end

end
