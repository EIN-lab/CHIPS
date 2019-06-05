function varargout = output_data(self, fnCSV, varargin)
%output_data - Output the data
%
%   output_data(OBJ) prompts the user for a filename and outputs the data
%   using the default formatting parameters.  If the filename includes an
%   extension, it will be used as-is; if it does not, the relevant data
%   class suffix will be appended to the filename along with the file
%   extension.
%
%   output_data(OBJ, FILENAME) uses the supplied filename.  As above, if
%   the the relevant data class suffix will be appended to the filename if
%   the filename does not include an extension.
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
%   FN = output_data(...) returns the full, absolute filename of the file
%   that was actually output. FN is a character array.
%
%   If all the data is numeric, output_data uses the built in function
%   dlmwrite to save the data.  If the data contains any non-numeric
%   elements, the built in function writetable is used if the matlab
%   version is recent enough, otherwise the function cell2csv from the file
%   exchange is used.
%
%   See also ProcessedImg.output_data, ImgGroup.output_data, dlmwrite,
%   utils.cell2csv, writetable, Data.listOutput

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

%% Argument parseing / manipulation etc

% Check that the data object is actually processed
if ~strcmp(self.state, 'processed')
    error('Data:OutputData:NotDone', ['The Calc object is not ' ...
        'processed, so the data cannot be output.'])
end

% Check that the data object has actual output properties defined
if isempty(self.listOutput)
    warning('Data:OutputData:NoOutput', ['The Data object has no ' ...
        'output defined, so no data will be output.'])
    
    varargout{1} = '';
    return
end

% Extract the relevant parameters from the input arguments
dflts = struct(...
    'delimiter',    ',', ...
    'precision',    '%.3f', ...
    'overwrite',    false);
params = utils.parsepropval(dflts, varargin{:});

% The delimeter must be a single row character array
utils.checks.single_row_char(params.delimiter, 'delimiter')

% The precision string must be a single row character array
utils.checks.single_row_char(params.precision, 'precision')

% The precision string must be a single row character array
utils.checks.scalar_logical_able(params.overwrite, 'overwrite flag')

doChooseFN = nargin < 2 || isempty(fnCSV);
if doChooseFN
    
    % Prompt the user to select a filename
    fnCSV = utils.uiputfile_helper();
    
else
    
    % Check the filename is a single row char array
    utils.checks.single_row_char(fnCSV)
    
end

%% Work out the filename

% Extract out the filename parts
[pathname, fnBase, ext] = fileparts(fnCSV);

% Add the relevant suffix if the user hasn't supplied an extension,
% otherwise use the full filename as supplied
addSuffix = isempty(ext);
if addSuffix
    fnFull = fullfile(pathname, ...
        [fnBase, '_', self.suffixDataClass, '.csv']);
else
    fnFull = fnCSV;
end

% Ensure the filename is full and absolute
fnFull = utils.GetFullPath.GetFullPath(fnFull);

% Check if we're overwriting an existing file
doesExist = exist(fnFull, 'file') > 1;
checkOverwrite = ~params.overwrite && doesExist;
if checkOverwrite
    
    % If so, ask the user what to do
    button = questdlg(['The specified file already exists.  Do you ' ...
        'want to overwrite it? Select "No" to choose another ' ...
        'filename, or "Cancel" to cancel.'], 'Warning!', 'No');
    
    % Take the appropriate action, depending on the response...
    switch button
        
        case 'Yes'
            
            % Continue as before and change nothing
            
        case 'No'
            
            % Recursively call output_data to select another file, 
            fnFull = self.output_data(pathname, ...
                'delimiter', params.delimiter, ...
                'precision', params.precision, ...
                'overwrite', params.overwrite);
            
            % Assign the output argument, as necessary
            if nargout > 0
                varargout{1} = fnFull;
            end
            
            % Return out of this level
            return
            
        case 'Cancel'
            
            % Return and do nothing
            return
            
    end
    
end

%% Write the actual data

% Create the header cells
hdrCell = self.get_headers(params.delimiter);

% Create the data matrix
dataMat = {};
nOutput = length(self.listOutput);
for iOutput = 1:nOutput
    dataTemp = self.(self.listOutput{iOutput});
    if ~iscell(dataTemp)
        dataTemp = num2cell(dataTemp);
    end
    try
        dataMat = [dataMat, dataTemp]; %#ok<AGROW>
    catch ME
        warning('Data:OutputData:DataIncomplete', ['The Data object ', ...
            'is incomplete.']);
    end
end

% Check if any cell contains non-numeric data
isNum = cellfun(@isnumeric, dataMat(1,:));
hasNumeric = any(isNum);
hasNonNumeric = any(~isNum);
if hasNonNumeric
    
    % Pre-format the numeric data to a char of the appropriate precision
    if hasNumeric
        idxNum = find(isNum);
        for ii = 1:numel(idxNum);
            iCol = idxNum(ii);
            isInt = all(cellfun(@is_int, dataMat(:, iCol)));
            if isInt
                precToUse = '%d';
            else
                precToUse = params.precision;
            end
            dataMat(:, iCol) = cellfun(@(cc) num2str(cc, precToUse), ...
                dataMat(:, iCol), 'UniformOutput', false); %#ok<AGROW>
        end
    end
        
    % Write to csv
    dataCell = vertcat(hdrCell, dataMat);
    utils.cell2csv(fnFull, dataCell, params.delimiter)
    
else
    
    % Write the data to a csv file
    hdrStr = sprintf(['%s' params.delimiter], hdrCell{:});
    dlmwrite(fnFull, hdrStr(1:end-1), 'delimiter', '');
    dlmwrite(fnFull, dataMat, '-append', 'delimiter', params.delimiter, ...
        'precision', params.precision);
    
end

%% Output the filename, if required

if nargout > 0
    varargout{1} = fnFull;
end

end

% ----------------------------------------------------------------------- %

function isInt = is_int(val)

isInt = isfinite(val(:)) & (round(val(:)) == val(:));

end
