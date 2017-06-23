function varargout = combine_masks(self, varargin)
%combine_masks - Combine and replace masks in a CellScan array
%
%   combine_masks(OBJ) combines masks from the CellScan object array OBJ
%   and updates the calcFindROIs property to a new CalcFindROIsDummy object
%   that contains the combined mask.
% 
%   combine_masks(OBJ, METHOD) Combines masks using the specified METHOD.
%   See the documentation of CellScan.calc_combined_mask for more details
%   on the options for METHOD.
%
%   NEWOBJ = combine_masks(...) returns a new CellScan object array NEWOBJ
%   with the combined masks.  Use this syntax to avoid making any changes
%   to the input CellScan object array.
%
%   See also CellScan.calc_combined_mask, CellScan.calcFindROIs,
%   CellScan.process, CalcFindROIsDummy, ConfigFindROIsDummy

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

%%

% Check the number of arguments in
narginchk(1, 2)

% Check if we're doing this on the existing object or a new one
if nargout > 0
    doNewObj = true;
else
    doNewObj = false;
    varargout = {};
end

% Combine the masks of the existing CellScans
maskCombined = self.calc_combined_mask(varargin{:});

% Create the new ConfigFindROIsDummy object to 
roiNames = utils.create_ROI_names(maskCombined);
cfrNew = ConfigFindROIsDummy('roiMask', maskCombined, ...
    'roiNames', roiNames);

% Update the configFindROIs on the CellScans with the new mask, and process
% the first stage of the CellScan object
if doNewObj
    
    % Do this in a new object
    newObj = copy(self);
    for iObj = 1:numel(newObj)
        newObj(iObj).calcFindROIs = cfrNew.create_calc;
    end
    varargout{1} = newObj;
    
else
    
    % Do this in the existing object
    for iObj = 1:numel(self)
        self(iObj).calcFindROIs = cfrNew.create_calc;
    end
    
end

end
