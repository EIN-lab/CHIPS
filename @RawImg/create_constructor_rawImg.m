function [hRaw, strRawImgType] = create_constructor_rawImg(varargin)
%create_constructor_rawImg - Class method to create a concrete RawImg
%   subclass constructor.

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
    strRawImgType = utils.parse_opt_args({''}, varargin);

    if isempty(strRawImgType)
        
        % Choose a rawImg type
        [hRaw, strRawImgType] = RawImg.choose_rawImg_type();

    else

        % Check strRawImgType is a single row character array
        utils.checks.single_row_char(strRawImgType)

        % Check strRawImgType is a subclass of RawImg
        isRawImg = utils.issubclass(strRawImgType, 'RawImg');
        if isRawImg
            %  Generate a constructor function handle 
            hRaw = str2func(strRawImgType);
        else
            error(['The rawImgType must be a concrete subclass of ' ...
                'RawImg, but you supplied "%s", which is not.'], ...
                strRawImgType)
        end

    end

end