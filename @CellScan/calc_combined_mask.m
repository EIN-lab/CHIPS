function maskCombined = calc_combined_mask(self, varargin)
%calc_combined_mask - Calculate a combined mask from a CellScan array
%
%   MASK = calc_combined_mask(OBJ) returns a ROI mask where a pixel is true
%   in the combined mask MASK if it is true in at least one of the ROI
%   masks contained in the CellScan array OBJ. Unprocessed elements of OBJ
%   will be skipped, and all ROI masks must be of the same shape.
%
%   MASK = calc_combined_mask(OBJ, METHOD) uses the specified METHOD to
%   determine whether a pixel should be true in the combine masks.  METHOD
%   must be one of the following:
%
%       'any' ->	A pixel in the combined mask is true if it is true
%                   in any of the individual masks.
%
%       'all' ->	A pixel in the combined mask is true if it is true
%                   in all of the individual masks.
%
%       X, (a scalar number) ->  A pixel in the combined mask is true if it
%                   is true in X or more of the individual masks
%
%   See also CellScan.combine_masks, any, all, ge

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
narginchk(1, 2)

nElem = numel(self);
if nElem < 2
    % This function only works on an array of Cellscans
    warning('CellScan:CombineMasks:NoArrayInput', ['This method ' ...
        'requires a CellScan array with more than one element']);
end

% Check the method argument
method = 'any';
hasMethod = (nargin > 1) && ~isempty(varargin{1});
if hasMethod
    method = varargin{1};
    if ischar(method)
        method = lower(method);
    end
end

% Extract masks
maskExclude = false(1, nElem);
for iElem = nElem:-1:1
    
    isProcessed = strcmp(self(iElem).state, 'processed');
    if ~isProcessed
        warning('CellScan:CalcCombinedMasks:NotProcessed', ['The image ' ...
            '"%s" is not processed and will not be included in the mask'], ...
            self(iElem).name)
        maskExclude(iElem) = true;
    end
    
    try
        
        % Attempt to combine the masks into a 3d array
        roiMask(:,:,iElem) = ...
            any(self(iElem).calcFindROIs.get_roiMask(), 3);
        
    catch ME_cat
        
        % Give a more informative error if they can't be combined
        if strcmp(ME_cat.identifier, 'MATLAB:subsassigndimmismatch')
            error('CellScan:CalcCombinedMasks:BadDims', ['The masks ' ...
                'could not be combined as the dimensions did not match.'])
        else
            rethrow(ME_cat)
        end
        
    end
end

% Eliminate unneeded masks
roiMask(:,:,maskExclude) = [];

% Combine the masks into a new 2D mask
switch method
    
    case 'any'
        
        % Set the mask where there is a mask in any of the elements
        maskCombined = any(roiMask, 3);
        
    case 'all'
        
        % Set the mask where there is a mask in all of the elements
        maskCombined = all(roiMask, 3);
        
    otherwise
        
        isThreshold = isnumeric(method) && isscalar(method);
        if isThreshold
            
            % Warn if the threshold value is stupid
            nMasksIn = size(roiMask, 3);
            if method > nMasksIn
                warning('CellScan:CalcCombinedMasks:ThresholdTooLarge', ...
                    ['The threshold value (%3.2f) is larger than the ' ...
                    'number of masks in the CellScan array (%d), so ' ...
                    'the resulting mask will be empty.'], method, nMasksIn)
            end
            
            % Use the method number 
            maskCombined = sum(roiMask, 3) >= method;
            
        else
            
            % Throw an error if we don't recognise the method
            error('CellScan:CalcCombinedMasks:UnknownMethod', ...
                'The method to combine masks is not recognised.')
            
        end
        
end

end
