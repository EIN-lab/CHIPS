function hProcessable = create_constructor_processable(varargin)
% create_constructor_processable - Protected helper function to create a
%   Processable object constructor 

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
    
    % Parse arguments
    strProcImgType = utils.parse_opt_args({''}, varargin);

    if isempty(strProcImgType)

        doAllowCancel = false;
        hProcessable = Processable.choose_Processable(...
            doAllowCancel);

    else

        % Check strProcImgType is a single row character array
        utils.checks.single_row_char(strProcImgType)

        % Check strProcImgType is a subclass of Processable
        isProcImg = utils.issubclass(...
            strProcImgType, 'Processable');
        if isProcImg
            %  Generate a constructor function handle 
            hProcessable = str2func(strProcImgType);
        else
            error(['The procImgType must be a subclass of ' ...
                'Processable, but you supplied "%s", which ' ...
                'is not.'], strProcImgType)
        end

    end

end