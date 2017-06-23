function params = parse_params(dflts, varargin)
%parse_params - Helper function for parsing parameter values
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
narginchk(1, inf);

% Parse any remaining input arguments, ensuring the warnings are treated
% correctly (suppressing and eliminating)
[lastMsgPre, lastIDPre] = lastwarn();
wngIDOff = 'ParsePropVal:UnknownAttr';
wngState = warning('off', wngIDOff);
params = utils.parsepropval(dflts, varargin{:});
warning(wngState)
utils.clear_unwanted_wngs(wngIDOff, lastMsgPre, lastIDPre)

end
