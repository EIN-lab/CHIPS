function valsToUse = check_crop_vals(imgSize, valsToUseIn, varargin)
%check_crop_vals - Check the values for cropping are appropriate
%
%   VAL = check_crop_vals(IMG_SIZE, VAL) checks that the values to crop VAL
%   are appropriate, based on the image size IMG_SIZE, and returns VAL,
%   corrected when necessary.  VAL must be a numeric vector of integers of
%   length 2, where the values fall within the image size.  IMG_SIZE must
%   be a numeric vector where each element represents the size of the image
%   along the corresponding dimension. Unless specified otherwise,
%   check_crop_vals checks along the second dimension (i.e. the second
%   element of IMG_SIZE), and assumes the variable being checked is
%   'colsToUseVel'.
%
%   VAL = check_crop_vals(IMG_SIZE, VAL, DIM, VAR_NAME) specifies the
%   dimension DIM and variable name VAR_NAME to be checked.  VAR_NAME is
%   used only to improve the relevance of any warning/error messages.
%
%   See also LineScanDiam, LineScanVel, FrameScan, DCScan, StreakScan

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

% Check the number of arguments in
narginchk(2, 4)

% Parse arguments
[imgDim, varName] = utils.parse_opt_args({2, 'colsToUseVel'}, varargin);

% Set the property, ensuring it's the correct dimensions
valsToUse = valsToUseIn(:)';

% Check we have a valid imgDim (i.e. width or height only)
if imgDim == 1
    imgDimName = 'height';
elseif imgDim == 2
    imgDimName = 'width';
else
    error('CheckCropVals:BadImgDim',['The image dimension ' ...
        'must be 1 or 2 (corresponding to height or width, respectively), ' ...
        'and you have supplied "%d"'], imgDim)
end

% Make an alternative name for the error ids.
varNameAlt = [upper(varName(1)) varName(2:end)];

% Check it's real
if ~isnumeric(valsToUse) || ~isreal(valsToUse)
    error(['CheckCropVals:NonReal' varNameAlt], ['%s must be numeric and ' ...
        'real, and you have provided data of class: %s.'], varName, ...
        class(valsToUse)) 
end

% Check it's integer
isInt = (valsToUse == round(valsToUse));
if ~isInt
    warning(['CheckCropVals:NonInteger' varNameAlt], ['%s must be an array of' ...
        ' integers.  The array has been automatically rounded.'], varName)
    valsToUse = round(valsToUse);
end

% Check it's length 2
isBadLength = length(valsToUse) ~= 2;
if isBadLength
    error(['CheckCropVals:BadLength' varNameAlt], ['%s must be of length 2, ' ...
        'and you have provided data of length: %d.'], varName, ...
        length(valsToUse)) 
end

% Check it's > 0 and <= size of the image
if ~isempty(imgSize)
    imgDimSize = imgSize(imgDim);
    maskTooSmall = valsToUse <= 0;
    if any(maskTooSmall)
        warning(['CheckCropVals:TooSmall' varNameAlt], ['The elements ' ...
            'of %s must be greater than zero, and you have provided ' ...
            'values of [%d %d], where the image %s is %d. This has ' ...
            'been automatically fixed.'], varName, valsToUse(1), ...
            valsToUse(2), imgDimName, imgDimSize)
        valsToUse(maskTooSmall) = 1;
    end
    maskTooBig = valsToUse > imgDimSize;
    if any(maskTooBig)
        warning(['CheckCropVals:TooBig' varNameAlt], ['The elements ' ...
            'of %s must be less than the image %s, and you have ' ...
            'provided values of [%d %d], where the image %s is %d. ' ...
            'This has been automatically fixed.'], varName, imgDimName, ...
            valsToUse(1), valsToUse(2), imgDimName, imgDimSize)
        valsToUse(maskTooBig) = imgDimSize;
    end
end

% Check the elements not the same
if isequal(valsToUse(1), valsToUse(2))
    error(['CheckCropVals:Equal' varNameAlt], ...
        'The elements of %s must not be equal.', varName) 
end

% Check it's increasing, and if it's not, reverse it
isIncreasing = valsToUse(2)  > valsToUse(1);
if ~isIncreasing
    warning(['CheckCropVals:NonIncreasing' varNameAlt], ['The ' ...
        'elements of %s must be increasing.  This ' ...
        'has been automatically fixed.'], varName)
    valsToUse = valsToUse([2, 1]);
end
            
end
