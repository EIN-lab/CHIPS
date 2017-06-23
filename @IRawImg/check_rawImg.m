function varargout = check_rawImg(self, rawImg)
%check_rawImg - Class method to check that a rawImg meets the requirements
%   to be added as the rawImg property in IRawImg objects.

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
    
% Initialise the output argument
varargout{1} = [];

% Work out if we want to return any exception or throw it internally
doReturnME = nargout > 0;

% Call the utility function to do the checks
ME = utils.checks.rawImg(rawImg, self.reqChannelAll, ...
    self.reqChannelAny, class(self));
if ~isempty(ME)
    if doReturnME
        varargout{1} = ME;
        return
    else
        throwAsCaller(ME)
    end
end

end