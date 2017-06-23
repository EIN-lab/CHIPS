function pointsToUse = crop_rows_cols(imgData, varargin)
%crop_rows_cols - Helper function to crop rows or columns
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
    narginchk(1, 4);

    % Parse input arguments
    [isLR, strBoundary, doSort] = ...
        utils.parse_opt_args({true, 'VELOCITY', true}, varargin);

    % Set up the information messages etc
    if isLR
        strLRTB = 'LEFT and RIGHT';
    else
        strLRTB = 'TOP and BOTTOM';
    end
    
    strFigTitle = sprintf(['Select the %s boundaries for %s.\n', ...
        'Click/drag to choose, adjust if needed, then double click ' ...
        'inside to finalise.'], strLRTB, strBoundary);

    % Create the figure
    hFig = figure;
    if isnumeric(imgData)
        
        sizeImgData = size(imgData);
        
        imagesc(imgData)
        hold on
        axis tight, axis image, axis off
        colormap('gray')
        title(strFigTitle)
        hold off
        
    elseif isa(imgData, 'function_handle')
        
        sizeImgData = imgData(strFigTitle);
        
    end
    
    xlim([0 sizeImgData(2)] + 0.5)
    ylim([0 sizeImgData(1)] + 0.5)
    
    % Check for the image and signal processing toolboxes
    featureImg = 'Image_Toolbox';
    className = 'crop_rows_cols';
    utils.verify_license(featureImg, className);
    
    % Set up the position constraint functions
    if isLR
        fConstrainPos = @(pos) fConstrainPos_cols(pos, sizeImgData);
    else
        fConstrainPos = @(pos) fConstrainPos_rows(pos, sizeImgData);
    end
    
    % Select the region for the current fluorophore
    hROI = imrect(gca, 'PositionConstraintFcn', fConstrainPos);
    wait(hROI);
    pos = hROI.getPosition();
    if ishghandle(hFig)
        close(hFig)
    end

    % Sort and return the points
    if isLR
        pointsToUse = round([pos(1), pos(1) + pos(3)]);
    else
        pointsToUse = round([pos(2), pos(2) + pos(4)]);
    end
    if doSort
        pointsToUse = sort(pointsToUse);
    end

end

% ---------------------------------------------------------------------- %

function pos = fConstrainPos_cols(pos, imgSize)

xmin = pos(1);
width = pos(3);
xmax = xmin + width;

xmin = max([0.5 + eps(0.5), xmin]);
ymin = 0.5;
width = min([xmax - xmin, imgSize(2) - xmin + 0.5  - 2*eps(imgSize(2))]);
height = imgSize(1);

pos = [xmin, ymin, width, height];

end

% ---------------------------------------------------------------------- %

function pos = fConstrainPos_rows(pos, imgSize)

ymin = pos(2);
height = pos(4);
ymax = ymin + height;

xmin = 0.5;
ymin = max([0.5 + eps(0.5), ymin]);
width = imgSize(2);
height = min([ymax - ymin, imgSize(1) - ymin + 0.5 - 2*eps(imgSize(1))]);

pos = [xmin, ymin, width, height];

end
