function varargout = output_data(self, fnCSV, varargin)
%output_data - Output the data
%
%   output_data(OBJ) prompts the user for a filename and outputs the data
%   from each Calc object contained in the ProcessedImg object OBJ using
%   the default formatting parameters.  There will be one file produced for
%   each Calc object, and the relevant suffix of the Calc class will be
%   appended to the chosen filename for each file.  If the ProcessedImg
%   object is non-scalar, the filename will also include a number
%   corresponding to the element number of the ProcessedImg object array.
%
%   output_data(OBJ, FILENAME) uses the supplied filename.  As above, the
%   relevant data class suffix will be appended to the filename, as well as
%   a number corresponding to the element number if the ProcessedImg
%   object is non-scalar.
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
%   that was actually output. FN is an M x N cell array of character arrays
%   where M is numel(OBJ) and N is the number of Calc objects found in the
%   concrete subclass of ProcessedImg.
%   
%   See also dlmwrite, Data.output_data, ImgGroup.output_data

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
    'precision',    '%.3f', ...
    'overwrite',    false);
params = utils.parsepropval(dflts, varargin{:});

doChooseFN = nargin < 2 || isempty(fnCSV);
if doChooseFN

    % Prompt the user to select a base filename
    fnCSV = utils.uiputfile_helper();

end

% Split out the extension so that the Data class method will add suffixes
[pathname, fnBase, ~] = fileparts(fnCSV);
fnCSV = fullfile(pathname, fnBase);

%%

% Find a list of calcs
calcList0 = self(1).calcList;
nCalcs = length(calcList0);
nElem = numel(self);
fnFull = cell(nElem, nCalcs);
for iCalcNum = 1:nCalcs

    % Pull out the relevent Calc name
    iCalc = calcList0{iCalcNum};

    if isscalar(self)
            
        % Call the data class to do the actual outputing
        try
            fnFull{1, iCalcNum} = self.(iCalc).data.output_data(fnCSV, ...
                'delimiter', params.delimiter, 'precision', ...
                params.precision, 'overwrite', params.overwrite);
        catch ME
            throw_err_as_warning(ME, iCalc)
        end

    else

        for jElem = 1:nElem

            % Create the filename
            iFN = fullfile(pathname, [fnBase, sprintf('_%03d_%s', ...
                jElem, self(jElem).name)]);

            % Call the data class to do the actual outputing
            try
                fnFull{jElem, iCalcNum} =  ...
                    self(jElem).(iCalc).data.output_data(iFN, ...
                    'delimiter', params.delimiter, 'precision', ...
                    params.precision, 'overwrite', params.overwrite);
            
            catch ME
                throw_err_as_warning(ME, iCalc)
            end

        end

    end

end

%% Output the filename, if required

if nargout > 0
    varargout{1} = fnFull;
end

end

function throw_err_as_warning(ME, iCalc)

isNotDone = strcmp(ME.identifier, 'Data:OutputData:NotDone');
if isNotDone
    warning('ProcessedImg:OutputData:NotDone', ['The Calc object "%s" ' ...
        'is not processed, so the data cannot be output.'], iCalc)
else
    throwAsCaller(ME)
end

end