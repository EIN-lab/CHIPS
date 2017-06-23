function masksOut = choose_masks(self, imgTypes)
%choose_masks - Protected class method to choose multiple masks

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

% Call the function one by one if we have an array
if ~isscalar(self)
    warning('CompositeImg:ChooseMasks:NonScalarObj', ['When using a ' ...
        'non-scalar object to choose masks, the first object will be ' ...
        'used and the masks will be applied to the other objects. To ' ...
        'choose different masks for each object, use the ImgGroup ' ...
        'class instead of a CompositeImg array.'])
end

% Loop through the different ProcessedImg types
nTypes = length(imgTypes);
masksOut = cell(1, nTypes);
for iType = 1:nTypes
    
    % Print some instructions
    iImgType = imgTypes{iType};
    fprintf('\n===== Select the masks for the %s images =====\n', iImgType)

    % Loop through and create as many sub-images as desired
    while true

        try

            % Choose the mask
            maskTemp = self(1).choose_mask(iImgType);
            userCancelled = isempty(maskTemp);
            if ~userCancelled
                if isempty(masksOut{iType})
                    masksOut{iType}{1} = maskTemp;
                else
                    masksOut{iType}{end + 1} = maskTemp;
                end
            else
                break
            end

        catch ME_choose_mask

            % Work out if the user closed the figure, and exit the loop 
            % if they did
            knownErrors = {...
                'MATLAB:ginput:Interrupted', ...
                'MATLAB:ginput:FigureDeletionPause', ...
                'MATLAB:ginput:FigureUnavailable',  ...
                'MATLAB:index:expected_one_output_from_expression' ...
                };
            userClosedFig = ismember(ME_choose_mask.identifier, ...
                knownErrors);
            if userClosedFig
                break
            else
                rethrow(ME_choose_mask)
            end

        end
        
    end

end

end