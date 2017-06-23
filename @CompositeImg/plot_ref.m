function plot_ref(self)

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
    arrayfun(@plot_ref, self);
    return
end

% Check for the image processing toolbox
feature = 'Image_Toolbox';
className = 'CompositeImg';
utils.verify_license(feature, className)

% Plot the basic image
figure
self.plot_ref_helper()
hold on

% Pull out the current colour
colorSpecListInverted = 1 - self.colorSpecList;

% Plot the columns we've already selected
count = 1;
for iType = 1:size(self.masks, 2)
    
    if isempty(self.masks{iType})
        continue
    end
    
    % Pull out the current colour
    colorSpec = colorSpecListInverted(iType, :);
    
    % Loop through and plot all the masks for this type
    for jMask = 1:numel(self.masks{iType})
        
        propsStruct = regionprops(self.masks{iType}{jMask}, 'centroid');
        xCoord = propsStruct.Centroid(1);
        yCoord = propsStruct.Centroid(2);

        text(xCoord, yCoord, num2str(count), 'Color', colorSpec, ...
            'FontSize', 12, 'FontWeight', 'bold', ...
            'HorizontalAlignment', 'Center')

        count = count + 1;

    end
end

hold off

end