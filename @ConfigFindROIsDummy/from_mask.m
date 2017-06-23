function cfrdObj = from_mask(varargin)
%from_mask - Load ROIs from a mask or binary image
%
%   OBJ = from_mask() prompts the user to select a file containing
%   the mask and will create a ConfigFindROIsDummy object using the
%   provided information. Supported file types are as follows:
%
%     - MAT-files containing a single variable with a mask stored 
%       in that is convertible to logical.
%
%     - TIF-files containing an image that is convertible to 
%       logical
%
%   OBJ = from_mask(FILENAME) uses the supplied FILENAME to create
%   a ConfigFindROIsDummy object. As above, supported filetypes are
%   MAT and TIF-files.
%
%   See also ConfigFindROIsDummy.from_ImageJ, imread

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
    fnMask = utils.parse_opt_args({''}, varargin);

    % Ask for a file, if it is not provided
    if isempty(fnMask)

        % Prompt to select a file
        filterSpec = {'*.*', 'All files'
                      '*.mat', 'MATLAB files'
                      '*.tif', 'Image files'};

        strTitle = 'Select a file containing the ROI mask';
        [filename, pathname] = uigetfile(filterSpec, strTitle, ...
            'MultiSelect', 'off');
        fnMask = fullfile(pathname, filename);

    end

    % Now check if file has the right extension to be loaded
    [~, ~, ext] = fileparts(fnMask);
    switch ext
        case '.mat'

            tempMask = load(fnMask);
            fields = fieldnames(tempMask);
            if length(fields) > 1
                error('ConfigFindROIsDummy:from_mask:CantResolve', ...
                    ['Input file can''t be resolved, because ',...
                    'multiple variables were stored in the file'])
            else
                roiMaskTemp = tempMask.(fields{1});
            end

        case '.tif'

             roiMaskTemp = im2double(imread(fnMask));

        otherwise

            error('ConfigFindROIsDummy:from_mask:WrongFileFormat', ...
                ['Input file format', sprintf('''%s''', ext), ...
                ' is not supported. please use one of the', ...
                ' following: ', sprintf('''%s'' ', filterSpec{:})]);

    end

    cfrdObj = ConfigFindROIsDummy('roiMask', roiMaskTemp);

end