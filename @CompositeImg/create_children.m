function children = create_children(self, varargin)
%create_children - Protected class method to create children to add

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

% Parse the remaining arguments
[configIn, imgTypes, masksIn] = utils.parse_opt_args(...
    {[], [], [], []}, varargin);

if isempty(imgTypes)
    doChooseMany = false;
    imgTypes = CompositeImg.choose_imgtypes(doChooseMany);
elseif ~iscell(imgTypes)
    imgTypes = {imgTypes};
end
nTypes = length(imgTypes);

if isempty(configIn)
    configIn = repmat({[]}, [1, nTypes]);
elseif ~iscell(configIn)
    configIn = {configIn};
end

if ~iscell(masksIn)
    masksIn = {masksIn};
end

% Loop through the different ProcessedImg types

children = {};
for iType = 1:nTypes
    
    % Create a constructor of this type
    iImgType = imgTypes{iType};
    hConstructor = str2func(iImgType);
    
    if isempty(masksIn{iType})
        masksIn = self.choose_masks(imgTypes(iType));
    end
    
    if ~iscell(masksIn{iType})
        masksIn{iType} = {masksIn{iType}};
    end
    
    % Create the ProcessedImg objects
    for jImg = 1:numel(masksIn{iType})

        % Create the RawImage_Composite
        RawImgObj = RawImgComposite(self.rawImg, ...
            masksIn{iType}{jImg});

        % Create a name
        nameProcessed = sprintf('%s-%02d', self.rawImg.name, jImg);

        % Create the ProcessedImg object
        isFirstImg = (jImg == 1);
        if isFirstImg

            % Go through the full process for the first image
            ProcessedImgObj = hConstructor(nameProcessed, RawImgObj, ...
                configIn{iType});

        else

            % Only change the name and raw image for other images. Setting
            % the rawImg triggers updates in the processed image object.
            ProcessedImgObj = copy(children{end});
            ProcessedImgObj.rawImg = RawImgObj;
            ProcessedImgObj.name = nameProcessed;

        end

        % Assign the ProcessedImg as a child
        children{end+1} = ProcessedImgObj; %#ok<AGROW>

    end

end

end