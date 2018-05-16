function [imgSeq, barLabel] = scaleBar(imgSeq, pixelSize, varargin)
%scaleBar - Insert scale bar into an image
%
%   [IMGOUT, LABEL] = scaleBar(IMGIN, PIXELSIZE)is a utility function that
%   creates a scale bar for a given image and returns the image with scale
%   bar (IMGOUT), as well as the label (LABEL) for the scale bar. Length
%   and units are calculated from image dimensions and pixel size
%   (PIXELSIZE)
%
%   [IMGOUT, LABEL] = scaleBar(..., 'attribute', value, ...) uses the
%   specified attribute/value pairs.  Valid attributes (case insensitive)
%   are:
%
%       'barlength' ->  Scalar numeric specifying the desired length of the
%                       scale bar in micrometers. [default = []] 
%       'location'  ->  String describing the desired location of the scale 
%                       bar in the image. Possible options are 'northeast',
%                       'northwest', southeast, 'southwest'.
%                       [default = 'southeast']
%       'color'     ->  A numeric vector of length=3 that specifies the
%                       desired scale bar color in RGB images. In grayscale
%                       images, the bar will always be white.
%                       [default = [1,1,1]]

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

% ================================================================== %

    % Check the number of input arguments
    narginchk(2, inf)
    
    % Check the image sequence
    utils.checks.not_empty(imgSeq, 'image sequence')
    utils.checks.real_num(imgSeq, 'image sequence')
    
    % Check the pixel size
    utils.checks.not_empty(pixelSize, 'pixel size')
    utils.checks.prfs(pixelSize, 'pixel size')

    % Define allowed optional arguments and default values
    defColRGB = [1,1,1];
    dflts = struct(...
        'barlength',    [], ...
        'location',    'southeast', ...
        'color',    []);
    params = utils.parsepropval(dflts, varargin{:});

    dims = size(imgSeq);
    xDim = dims(2);
    yDim = dims(1);

    if ~isempty(params.barlength)

        % In case the user has specified a length
        actLengthUnits = params.barlength;

    else

        % Optimal ratio of scale bar length to image width
        optLengthRatio = .2;

        % Optimal length in pixels
        optLengthPx = optLengthRatio*xDim;

        % Convert to units
        optLengthUnits = optLengthPx*pixelSize;
        
        % Create a list of acceptable scale bar lengths (independent of the
        % power of 10)
        roundTargets = [1, 2, 5, 10];
        
        % Round the scale bar to the closest acceptable value, making sure
        % to account for the power of 10
        p10 = floor(log10(optLengthUnits));
        actLengthUnits = interp1(roundTargets, roundTargets, ...
            optLengthUnits/(10^p10), 'nearest', 'extrap');
        actLengthUnits = actLengthUnits*(10^p10);

    end

    % Convert final length back to pixels
    actLengthPx = round(actLengthUnits/pixelSize);

    % Optimal distance from image border
    optDistRatio = .04;
    optDistPx = round(optDistRatio*yDim);

    barHeightRatio = 0.01;
    barHeightPx = round(barHeightRatio*yDim);

    switch lower(params.location)
        case 'southeast'
            barStart = xDim-optDistPx-actLengthPx;
            barEnd = xDim-optDistPx;
            barBottom = yDim-optDistPx-barHeightPx;
            barTop = yDim-optDistPx;

        case 'southwest'
            barStart = optDistPx;
            barEnd = optDistPx+actLengthPx;
            barBottom = yDim-optDistPx-barHeightPx;
            barTop = yDim-optDistPx;

        case 'northeast'
            barStart = xDim-optDistPx-actLengthPx;
            barEnd = xDim-optDistPx;
            barBottom = optDistPx;
            barTop = optDistPx+barHeightPx;

        case 'northwest'
            barStart = optDistPx;
            barEnd = optDistPx+actLengthPx;
            barBottom = optDistPx;
            barTop = optDistPx+barHeightPx;

        otherwise
            error('utils:scaleBar:unknownLocation', ['Please specify ', ...
                'location as ''northwest'', ''northeast'', ''southwest''', ...
                ' or ''southeast''(default).']);

    end

    barHeight = barBottom:barTop;
    barLength = barStart:barEnd;

    % Find input type
    switch length(dims)
        case 4
            % RGB stack
            barValue = defColRGB;
            mode = 'rgb';

        case 3
            % Find out whether we have an RGB image or grayscale stack
            isRGB = dims(3) == 3;

            % Single RGB image
            if isRGB
                barValue = defColRGB;
                mode = 'rgb';

            % Grayscale stack
            else
                barValue = max(imgSeq(:));
                mode = 'grayscale';

            end

        case 2
            % Single grayscale image
            barValue = max(imgSeq(:));
            mode = 'grayscale';

        otherwise
            error('utils:scaleBar:WrongDataType', ['scaleBar only ', ...
                'supports RGB and grayscale images or stacks with 2 ', ...
                'to 4 dimensions. You provided an image with ', ...
                sprintf('%i dimensions.', length(dims))]);

    end
    
    % Choose the correct default colour
    if isempty(params.color)
        params.color = barValue;
    end

    switch mode
        
        case 'rgb'
            
            % Apply the colour to all channels, if necessary
            if isscalar(params.color)
                params.color = repmat(params.color, 1, 3);
            end
            
            for iCol = 1:3
                imgSeq(barHeight, barLength, iCol, :) = params.color(iCol);
            end
            
        case 'grayscale'
            
            if ~isscalar(params.color)
                warning('Utils:ScaleBar:BadColor', ['Overlaying a ' ...
                    'coloured scale bar with an RGB image is not '...
                    'currently supported. Using a white bar instead.'])
                params.color = barValue;
            end
            
            imgSeq(barHeight, barLength, :) = params.color;

    end

    % Create a label for the scale bar
    barLabel = sprintf('%d µm', actLengthUnits);

end
