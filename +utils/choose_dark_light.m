function isDark = choose_dark_light(rawImg, strObject)
%choose_dark_light - Helper function for choosing dark or light plasma
%
%   This function is not intended to be called directly.

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

% Check the number of input arguments
narginchk(2, 2);

% Work out what channels we have
hasPlasma = rawImg.has_ch('blood_plasma');
hasRBCs = rawImg.has_ch('blood_rbcs');

if hasPlasma && hasRBCs

    % A list of options
    options = {sprintf('Light %s (labelled cells)', strObject), ...
        sprintf('Dark %s (labelled plasma)', strObject)};
    defOption = 1;

    % Ask the user to choose which image type to use
    isDark = utils.txtmenu({sprintf(['What type of %s should be ' ...
        'analysed?'], strObject), 'Answer:'}, defOption, options{:});

    % Convert the user answer to boolean
    isDark = logical(isDark);

elseif hasPlasma && ~hasRBCs

    % Assume dark if we only have plasma
    isDark = true;

elseif hasRBCs && ~hasPlasma

    % Assume bright if we only have rbcs
    isDark = false;

else

    % There are no available channels!
    error('Utils:ChooseDark:NoChannel', ['There are no channels ' ...
            'defined that can be used to analyse %s.'], strObject)

end

end
