function mask = choose_mask(self, imgType, varargin)
%choose_mask - Protected class method to choose an individual mask

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
[maskType] = utils.parse_opt_args({''}, varargin);

% A list of known masks etc
knownMasks = {...
	'everything',   @(~) true(size(self.rawImg.rawdata(:,:,1,1))),  false;
	'columns',      @(self) choose_mask_columns(self, imgType),     false;
	'rows',         @(self) choose_mask_rows(self, imgType),        false;
	'square',       @(self) choose_mask_square(self, imgType),      false;
	'rectangle',    @(self) choose_mask_rectangle(self, imgType),   true;
	'polygon',      @(self) choose_mask_polygon(self, imgType),     true;
	'circle',       @(self) choose_mask_circle(self, imgType),      false;
	'ellipse',      @(self) choose_mask_ellipse(self, imgType),     true;
	'freehand',     @(self) choose_mask_freehand(self, imgType),    true;
	'even-lines',   @(self) choose_mask_altLines(self, true),       false;
	'odd-lines',    @(self) choose_mask_altLines(self, false),      false;
    'channels',     @(self) choose_mask_channels(self, imgType),	false;
        };
listMaskTypes = knownMasks(:, 1)';

% Initialise the mask to empty 
mask = false(0);

if isempty(maskType)

    % Choose which type of mask to use
    strTitle = 'Which type of mask would you like to select?';
    imgOptions = [{'<finished>'}, listMaskTypes];
    defOption = 0;
    maskNum = utils.txtmenu({strTitle, 'Select a maskType:'}, ...
        defOption, imgOptions);
    
    % Work out if the user cancelled, otherwise, recursively call this 
    % function again to choose the mask
    userCancelled = (maskNum == 0);
    if userCancelled
        return
    else
        maskType = listMaskTypes{maskNum};
        mask = self.choose_mask(imgType, maskType);
        return
    end

elseif ischar(maskType)

    % Match the input string to a known mask type
    idxMaskType = strncmpi(maskType, listMaskTypes, length(maskType));

    % Pull out which function to use
    nMatches = sum(idxMaskType);
    if nMatches == 1

        % Only one match
        maskFun = knownMasks{idxMaskType, 2};
        
        % Check for the image processing toolbox
        if knownMasks{idxMaskType, 3};
            feature = 'Image_Toolbox';
            className = 'CompositeImg:ChooseMask';
            utils.verify_license(feature, className);
        end

    else
        
        strMaskTypes = sprintf('\t%s\n', listMaskTypes{:});

        if nMatches <= 0

            % No matches
            error('CompositeImg:ChooseMask:NoMatch', ['The ' ...
                'string you provided, "%s", did not match any ' ...
                'known mask types.  Please choose from the ' ...
                'following:\n%s'], maskType, strMaskTypes)

        elseif nMatches > 1

            % More than one match
            error('CompositeImg:ChooseMask:MultipleMatches', ...
                ['The string you provided, "%s", matched more ' ...
                'than one known mask type.  Please use a ' ...
                'unique string from the following to ' ...
                'identify the mask type:\n%s'], maskType, ...
                strMaskTypes)

        end

    end

elseif isa(maskType, 'function_handle')

    error('This functionality is not implemented yet.')

else

    % Wrong class of input
    error('CompositeImg:ChooseMask:UnknownType', ['The '...
        'maskType variable must be a character array or ' ...
        'a function handle, whereas you supplied data of ' ...
        'class "%s"'], class(maskType))

end

% Call the mask function
mask = maskFun(self);

end