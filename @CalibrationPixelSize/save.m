function save(self, varargin) %#ok<INUSL>
%save - Save CalibrationPixelSize objects
%
%   save(OBJ) prompts for a filename and saves the CalibrationPixelSize
%   object OBJ to a .mat file.
%
%   save(OBJ, FILENAME) saves the OBJ to the specified filename.
%
%   See also CalibrationPixelSize.load

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
%   along with this program.  If not, see <http://www.gnu.org/licenses/>

    % Parse arguments
    [filename] = utils.parse_opt_args({[]}, varargin);

    if isempty(filename)

        % Get the user to tell us where to save the file
        [fileCal, pathCal] = uiputfile('*.mat', ...
            'Save Pixel Size Calibration As ...');
        filename = fullfile(pathCal, fileCal);

    else

        utils.checks.single_row_char(filename, 'filename');
        
    end

    % Do the actual saving
    save(filename, 'self')

end