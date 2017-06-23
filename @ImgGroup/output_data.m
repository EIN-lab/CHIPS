function varargout = output_data(self, fnCSV, varargin)
%output_data - Output the data
%
%   output_data(OBJ) prompts the user for a filename and outputs the data
%   from each Processable object contained in the ImgGroup object OBJ using
%   the default formatting parameters.  There will one or more files
%   produced for each Processable object, with the exact number depending
%   on how many Calc objects are contained in each Processable object, if
%   the Processable objects are scalar, and if the Processable objects are
%   also ImgGroup objects.  The filename will include the relevant name and
%   number of the child object.  If the ImgGroup object is non-scalar, the
%   filename will also include a number corresponding to the element number
%   of the ProcessedImg object array.
%
%   output_data(OBJ, FILENAME) uses the supplied filename.  As above, extra
%   names and numbers may be included in the filename based on the child
%   name, child number and the element number of the ImgGroup array (if it
%   is non-scalar).
%
%   output_data(..., 'attribute', value, ...) uses the specified
%   attribute/value pairs.  Valid attributes (case insensitive) are:
%
%       'delimiter' ->  Delimiter string to be used in separating data
%                       elements. [default = ',']
%       'precision' ->  Numeric precision to use in writing data to the
%                       file, as significant digits or a C-style format
%                       string, starting with '%', such as '%10.5f'.  Note
%                       that this uses the operating system standard
%                       library to truncate the number. [default = '%.5f']
%       'overwrite' ->  true/false scalar logical value specifying whether
%                       to overwrite a file if it already exists
%                       [default = false]
%
%   FN = output_data(...) returns the full, absolute filenames of the files
%   that were actually output. FN is a nested cell array where the number
%   and size of the dimensions varies depending on the number of the
%   elements in the ImgGroup object array, the number of children in each
%   element of the ImgGroup object array, and the nature of the children.
%   
%   See also dlmwrite, Data.output_data, ProcessedImg.output_data  

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
    
% Extract the relevant parameters from the input arguments
dflts = struct(...
    'delimiter',    ',', ...
    'precision',    '%.5f', ...
    'overwrite',    false);
params = utils.parsepropval(dflts, varargin{:});

doChooseFN = nargin < 2 || isempty(fnCSV);
if doChooseFN

    % Prompt the user to select a base filename
    fnCSV = utils.uiputfile_helper();

else

    % Check the filename is a single row char array
    utils.checks.single_row_char(fnCSV)

end

% Extract out only the name root, ignoring extension
[pathname, fnCSVBase, ~] = fileparts(fnCSV);

%%

% Call the function one by one if we have an array, but only after we've
% chosen the base filename
if ~isscalar(self)
    
    nElem = numel(self);
    fnFull = cell(nElem, 1);
    
    for iElem = 1:nElem
        
        iFNElem = fullfile(pathname, [fnCSVBase, sprintf('_%03d', iElem)]);
        fnFull{iElem} = self(iElem).output_data(iFNElem, ...
            'delimiter', params.delimiter, 'precision', params.precision, ...
            'overwrite', params.overwrite);
    end
    
    if nargout > 0
        varargout{1} = fnFull;
    end
    
    return
    
end

% Loop through the children of the ImgGroup and call their appropriate
% output_data methods
fnFull = cell(self.nChildren, 1);
for iChild = 1:self.nChildren

    % Create the filename
    iFNChild = fullfile(pathname, [fnCSVBase, sprintf('_%03d', iChild)]);

    % Call the data class to do the actual outputing
    fnFull{iChild} = self.children{iChild}.output_data(iFNChild, ...
        'delimiter', params.delimiter, 'precision', params.precision, ...
        'overwrite', params.overwrite);

end

%% Output the filename, if required

if nargout > 0
    varargout{1} = fnFull;
end

end