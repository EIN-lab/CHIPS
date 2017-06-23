function flag = replace_in_file(fnIn, fnOut, strIn, strOut)
%replace_in_file - Replace text in a file with new text
%
%   replace_in_file(FN_IN, FN_OUT, STR_IN, STR_OUT) replaces all instances
%   of the string STR_IN in a file FN_IN with the new string STR_OUT, and
%   writes the resulting output to a file FN_OUT. FN_IN and FN_OUT must be
%   single line character arrays representing the path to a text file.  If
%   FN_OUT is empty, FN_IN is used as FN_OUT (i.e. the original file is
%   overwritten).
%
%   FLAG = replace_in_file()
%
%   See also strrep

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

%% Check inputs

narginchk(4, 4)
utils.checks.single_row_char(fnIn, 'fnIn')
utils.checks.file_exists(fnIn)

if isempty(fnOut)
    fnOut = fnIn;
else
    utils.checks.single_row_char(fnOut, 'fnOut')
    utils.checks.file_exists(fnOut)
end

utils.checks.single_row_char(strIn, 'strIn')

if isempty(strOut)
    strOut = '';
else
    utils.checks.single_row_char(strOut, 'strOut')
end

%% Main part of the file

% Read in the contents of the project file
fID1 = fopen(fnIn, 'r');
lines = textscan(fID1, '%s', 'Delimiter', '\n', 'Whitespace', '');
fclose(fID1);

% Replace the parts of the old file to give the correct path
lines = [lines{:}];
idx = find(~cellfun(@isempty, strfind(lines, strIn)));
try
    lines(idx) = strrep(lines(idx), strIn, strOut);
catch ME
    if isempty(idx)
        warning('ReplaceInFile:NoLines', ['The file %s does not ' ...
            'contain any instances of the string "%s"'], fnIn, strIn)
        flag = 0;
        return
    else
        rethrow(ME)
    end
end

% Write new file (or overwrite the old one) with the new details
fID2 = fopen(fnOut, 'w');
fprintf(fID2, '%s\n', lines{:});
fclose(fID2);

% Set the flag appropriately
flag = 1;

end
