function fnFullRaw = uiputfile_helper(varargin)
%uiputfile_helper - Helper function for saving files
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
narginchk(0, 1);

% Parse optional arguments
fnBaseGuess = utils.parse_opt_args({[]}, varargin);

persistent pathGuess

% Make a guess for the path/filename
if ~isempty(fnBaseGuess)
    fnGuess = fullfile(pathGuess, fnBaseGuess);
else
    fnGuess = pathGuess;
end

% Prompt to select where to save the file
filterSpec = {'*.csv', 'Comma-separated values file (*.csv)'};
strTitle = sprintf('Save data as');
[fnRaw, pathname] = uiputfile(filterSpec, strTitle, fnGuess);
fnFullRaw = fullfile(pathname, fnRaw);

% Throw an error if user cancelled, otherwise return filename
hasCancelled = ~ischar(fnRaw) && (fnRaw == 0) && (pathname == 0);
if hasCancelled
    error('UIPutFileHelper:DidNotChooseFile', ['You must choose ' ...
        'where to save the data file.'])
end

% Update the path guess
pathGuess = pathname;

end
