function [dataOut, varargout] = check_data(self, dataIn, varargin)
%check_data - Check the data and do some other things here for convenience
%
%   YY = check_data(OBJ, XX)
%
%   MM = check_data(OBJ, XX, DOMEAN)
%
%   MM = check_data(OBJ, XX, DOMEAN, DATANAME)
%
%   [YY, SEM] = check_data(OBJ, ...)

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
    
% Parse optional arguments
[doMean, dataName] = utils.parse_opt_args({false, ''}, varargin);

% Check the optional arguments - doMean
utils.checks.scalar_logical_able(doMean, 'doMean');

% Check the optional arguments - dataName
utils.checks.char_array(dataName)
if ~isempty(dataName)
    utils.checks.single_row_char(dataName, 'dataName');
end

% Check the data is not empty
if isempty(dataIn)
    error('Data:CheckData:EmptyData', ['No %s data was supplied, or ' ...
        'the data was empty'], dataName)
end

% Do we want to calculate the s.e.m.?
doSEM = nargout > 1;

%%

% Check for character array
if ischar(dataIn)
    
    % Check it's a single row
    utils.checks.single_row_char(dataIn)
    
    % Check that the character field exists in the data object
    hasField = ismember(dataIn, properties(self));
    if hasField
        
        % Extract all the data
        dataOut = [self.(dataIn)];
        
        % Calculate the SEM if necessary
        if doSEM
            semOut = std(dataOut, [], 2)/sqrt(length(self));
            varargout{1} = semOut;
        end
        
        % Take the mean if necessary
        if doMean
            dataOut = mean(dataOut, 2);
        end
        
    else
        
        % Otherwise throw an error
        error('Data:CheckData:NoField', ['There is no field "%s" in ' ...
            'this data object.'], dataIn)
        
    end

elseif isnumeric(dataIn)
    
    % Don't need to do anything if it's a numeric array
    dataOut = dataIn;

else
    
    % Otherwise wrong data type
    error('Data:CheckData:WrongDataType', ['Invalid "%s" data.  ' ...
            'The data must be a character or numeric array'], dataIn)
    
end

end