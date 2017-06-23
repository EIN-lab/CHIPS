function varargout = parse_opt_args(argsDef, argsIn)
%parse_opt_args - Parse optional arguments & replace w/user-supplied values
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

% ======================================================================= %
% Check if the number of optional arguments exceeds the limit, and display
% a warning if they do.

% Check the number of input arguments
narginchk(2, 2);

maxvarargs = length(argsDef);
numvarargs = length(argsIn);

if numvarargs > maxvarargs
    
    % Get the call stack (ignoring this function) so we can get the name 
    % of the function that called this.
    [ST, ~] = dbstack(1);
    
    % Setup some default warning display parameters
    strWngID = 'ParseOptArgs:TooManyInputs';
    strWngMsg = ['The function or method %s requires at most %d optional ' ...
        'inputs, but %d were supplied.'];
    
    % Display a warning
    warning(strWngID, strWngMsg, ST(1).name, maxvarargs, numvarargs)
    
end

% ======================================================================= %

% Set defaults for optional inputs
varargout = argsDef;

% Now put these defaults into the valuesToUse cell array, 
% and overwrite the ones specified in varargin.
varargout(1:numvarargs) = argsIn;

end
