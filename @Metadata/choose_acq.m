function self = choose_acq(self)
%choose_acq - Protected class method allowing the user to manually
%   specify/create the acq structure

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
    
    % Set this value to start with
    iField = 1;

    % Loop through all channels
    while iField <= numel(self.acqFieldsReq)
        
        % Setup a helper variable
        iFieldName = self.acqFieldsReq{iField};
        iFieldNameStr = self.acqFieldsReqStr{iField}; 
        
        % Skip over this field if it's not empty
        if ~isempty(self.(iFieldName))
            iField = iField + 1;
            continue
        end
        
        % Get input from the user
        strInput = sprintf('Please enter a value for %s: ', ...
            iFieldNameStr);
        val = input(strInput);
        
        try
            
            % Try to add the user's value directly
            self.(iFieldName) = val;
            
        catch ME
            
            % If there's a problem, give the user another chance
            warning('Metadata:ChooseAcq:BadVal', ['The value you ' ...
                'entered caused an error with the following message:' ...
                '\n\n\t%s\n\nPlease enter a new value.'], ME.message)
            continue
            
        end

        % If we've made it this far we can go on to the next field
        iField = iField + 1;

    end

end