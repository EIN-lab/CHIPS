function CalObj = load(varargin)
%load - Load a CalibrationPixelSize object
%
%   CalibrationPixelSize.load() prompts to select a .mat file (which
%   should have been produced by the CalibrationPixelSize.save method) and
%   loads the CalibrationPixelSize object.
%
%   CalibrationPixelSize.load(FILENAME) loads the given filename
%   containing a CalibrationPixelSize object.
%
%   See also CalibrationPixelSize.save

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

    persistent fnGuess

    % Parse arguments
    [filename] = utils.parse_opt_args({[]}, varargin);
    
    % Check if the extension exists
    

    if isempty(filename)

        while true

            % Get the user to tell us which file to load
            filterspec = {'*.mat', 'MAT-files (*.mat*)'; 
                '*.*', 'All Files (*.*)'};
            [fileCal, pathCal] = uigetfile(filterspec, ...
                'Choose a Pixel Size Calibration Object', fnGuess);

            % Throw an error if the user cancelled, otherwise
            % return the filename
            hasCancelled = ~ischar(fileCal) && ...
                (fileCal == 0) && (pathCal == 0);
            if ~hasCancelled
                fnGuess = fullfile(pathCal, fileCal);
                filename = fnGuess;
            else
                error('CalibrationPixelSize:DidNotChooseFile', ...
                    'You must select a calibration file to load.')
            end

            if ~isempty(filename)
                break
            end

        end

    else

        utils.checks.single_row_char(filename);
        utils.checks.file_exists(filename);

    end

    % Do the actual loading
    load(filename, 'self')
    CalObj = self;
    
    % Refit the object after loading
    CalObj = fit(CalObj);

end