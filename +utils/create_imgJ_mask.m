function [ROImask, nameList] = create_imgJ_mask(varargin)
%create_imgJ_mask - Helper function to create a mask from ImageJ ROIs
%
%   ROI_MASK = create_imgJ_mask() prompts for all required information and
%   creates a mask (ROI_MASK) specifying the regions of interest (ROIs)
%   that were defined and saved using the external program ImageJ.  The
%   ROIs can be loaded from a *.roi file (for a single ROI) or a *.zip file
%   (for multiple ROIs).
%
%   ROI_MASK = create_imgJ_mask(ROI_FILE, NCOLS, NROWS, SCALE) uses the
%   specified ROI file (ROI_FILE), number of columns (NCOLS), number of
%   rows (NROWS), and scale factor (SCALE) to create the mask.  If any of
%   the arguments are empty or not specified, the function will prompt for
%   the required information.
%   ROI_FILE must be a single row character array
%   NCOLS and NROWS must be positive integer scalars
%   SCALE must be a positive real finite scalar specifying the scale factor
%   between the image that the ROIs were defined using, and the desired 
%   mask size. For example, if the ROIs were drawn on a 512 x 512 pixel 
%   image, the mask should be 256 x 256, the scale factor is 0.5.
%
%   [ROI_MASK, ROI_NAMES] = create_imgJ_mask(...) also returns the ROI
%   names that were defined in ImageJ.
%
%   See also utils.ReadImageJROI

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
narginchk(0, 4);

% Parse arguments
[ROIZip, x_pix, y_pix, scaleFactor] = utils.parse_opt_args(...
    {'', [], [], []}, varargin);

% Declare the 'guess' filename as a persistent variable so we
% can remember where to start from next time.
persistent fnGuess

% Ask for a file, if it is not provided
if isempty(ROIZip)

    % Prompt to select a file
    filterSpec = {'*.roi;*.zip', ...
        'ImageJ ROI files (*.roi, *.zip)'};
    strTitle = 'Select a file containing the ImageJ ROIs';
    [filename, pathname] = uigetfile(filterSpec, strTitle, ...
        fnGuess, 'MultiSelect', 'off');

    % Throw an error if the user cancelled, otherwise return 
    % the filename
    hasCancelled = ~(ischar(filename) || iscell(filename)) && ...
        (filename == 0) && (pathname == 0);
    if ~hasCancelled
        ROIZip = fullfile(pathname, filename);
        fnGuess = ROIZip;
    else
        error('CreateImgJMask:DidNotChooseFile', ...
            'You must select one or more mask files to load.')
    end

end

% Now check if file has the right extension to be loaded
[~, ~, ext] = fileparts(ROIZip);
isBadExt = ~ismember(ext, {'.zip', '.roi'});
if isBadExt
    strExtList = sprintf(' "%s",', filterSpec{2,:});
    error('CreateImgJMask:WrongFileFormat', ...
        ['Input file format "%s" is not supported. ' ...
        'Please use one of the following:%s'], ...
        ext, strExtList(1:end-1));
end

% Ask the user to specify the x dimension, if not provided
if isempty(x_pix)
    x_pix = input(['How many columns were in the image used to draw ' ...
        'the ROIs?\nNumber of columns: ']);
    fprintf('\n')
end
utils.checks.prfsi(x_pix, 'x_pix')

% Ask the user to specify the y dimension, if not provided
if isempty(y_pix)
    y_pix = input(['How many rows were in the image used to draw ' ...
        'the ROIs?\nNumber of rows: ']);
    fprintf('\n')    
end
utils.checks.prfsi(y_pix, 'y_pix')

% Ask the user to specify the scale factor, if not provided
if isempty(scaleFactor)
    scaleFactor = input(['What''s the scale factor of ', ...
        'the ImageJ mask?\nE.g., if you drew the mask on a ' ...
        '512*512 pixel image, but\nare analysing a 256x256 ' ...
        'pixel image, the scale factor is 2.\nScale factor: ']);
    fprintf('\n')
end
utils.checks.prfs(scaleFactor, 'scaleFactor')

%% Main part of the function

% Read ImageJ ROIs using utility function
ROIs = utils.ReadImageJROI(ROIZip);

% Convert ROIs to a cell array if it's a structure.  This happens when
% we're only reading a single file
if ~iscell(ROIs)
    ROIs = {ROIs};
end

% Create mask from ROIs
nROIs = numel(ROIs);
doCheck = true;
ROImask = zeros(y_pix, x_pix, nROIs);
nameList = cell(nROIs, 1);
for iROI = 1:nROIs
    
    % Create an empty 2d mask
    ROImask_2d = zeros(y_pix, x_pix);
    
    switch lower(ROIs{iROI}.strType)
        case 'oval'
            [X, Y]  = meshgrid(1:x_pix,1:y_pix);
            coords = ROIs{iROI}.vnRectBounds;
            coords(1:2) = coords(1:2) + 1;
            pos(1:2) = coords(2:-1:1);
            pos(3:4) = coords(4:-1:3) - coords(2:-1:1);
            xc     = pos(1)+0.5*pos(3);
            yc     = pos(2)+0.5*pos(4);
            A2     = (0.5*pos(3)+1)^2; % plus pixel size ('line width')
            B2     = (0.5*pos(4)+1)^2;
            A2B2   = A2*B2;
            inellipse   = B2*(X-xc).^2 + A2*(Y-yc).^2 <= A2B2;
            ROImask_2d(inellipse) = 1;
            
        case 'rectangle'
             coords = ROIs{iROI}.vnRectBounds;
             coords(1:2) = coords(1:2) + 1;
             % ImageJ indexing describes pixel borders, so we have to add 1         
             ROImask_2d(coords(1):coords(3), coords(2):coords(4)) = 1;
             
        case {'polygon', 'freehand'}
            
            if doCheck
                % Check for the image processing toolbox
                feature = 'Image_Toolbox';
                className = 'CalcDiameterTiRS';
                utils.verify_license(feature, className);
                doCheck = false;
            end
            
            coords = ROIs{1,iROI}.mnCoordinates;
            ind = poly2mask(coords(:,1),coords(:,2),y_pix, x_pix);
            ROImask_2d(ind)=1;
            
        case 'line'
            endPointCoords = ROIs{iROI}.vnLinePoints;
            [x,y]=utils.bresenham(endPointCoords(2),endPointCoords(1), ...
                endPointCoords(4), endPointCoords(3));
            linearInd = sub2ind(size(ROImask), x, y);
            ind = false(size(ROImask));
            ind(linearInd) = true;
            ROImask_2d(ind)=1;
            
        otherwise
            
            error('CreateImgJMask:UnknownROIType', ...
                ['ROI type ''', ROIs{iROI}.strType, ''' is not supported.'])
            
    end
    
    % Assign the 2d mask into the 3d one
    ROImask(:,:,iROI) = ROImask_2d;
    
    % Extract the ROI names
    nameList{iROI} = ROIs{iROI}.strName;
    
end

% Resize the ROI mask, if necesary
if scaleFactor ~= 1
    ROImask = imresize(ROImask, scaleFactor);
end
    
end
