function add(self, varargin)
%add - Add children to the object
%
%   add(OBJ) prompts for all required information to load/create RawImg
%   objects, create Processable objects, and add them to the ImgGroup
%   object OBJ.
%
%   add(OBJ, RAWIMG, CONFIG, PROCTYPE) creates Processable objects of the
%   type specified by PROCTYPE from the specified RawImg object array
%   RAWIMG using the specified CONFIG and adds them to the ImgGroup object.
%   RAWIMG must be a RawImg object array; CONFIG must be a scalar Config
%   object; and PROCTYPE must be a single row character array corresponding
%   to the one of the concrete subclasses of Processable. Any of these
%   three argumentscan be empty or missing and the constructor will prompt
%   for them; however, if they are present, arguments must not appear
%   before arguments to their left in the list above. In addition, any of
%   these three arguments can be a cell array where all elements match the
%   expected type; however, any cell arrays must be either scalar or all
%   the same size.
%
%   add(OBJ, ..., PROCOBJ1, PROCOBJ2, ...) adds the specified Processable
%   objects to the ImgGroup object.  The processable objects can be any
%   dimension.  In addition, cell arrays containing Processable objects
%   will be added recursively to the ImgGroup object.  If Processable
%   objects are supplied without any of the three arguments in the previous
%   paragraph, the add method will simply add the Processable objects to
%   the ImgGroup object without prompting for/creating/adding any
%   additional Processable objects.
%
%   The add method of ImgGroup is only valid for scalar ImgGroup objects.
%
%   See also ImgGroup.children, ImgGroup.from_files, Processable, Config

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

	% Check if we're trying to add to an ImgGroup array
    isArray = ~isscalar(self);
    if isArray
        error('ImgGroup:Add:NonScalarObj', ['The add method of the ' ...
            'ImgGroup class only works for scalar objects.'])
    end

    %% Process the input arguments
    
    % Define where the 'extra arguments' start
    idxExtraArgs = 1;
    
    % Check the 'first' argument to see if there's a RawImgArray
    rawImgsIn = {[]};
    hasRawImgs = nargin > idxExtraArgs && ...
        (isa(varargin{idxExtraArgs}, 'RawImgHelper') || ...
        isempty(varargin{idxExtraArgs}) || ...
        (iscell(varargin{idxExtraArgs}) && ...
            (all(cellfun(@(xx) isa(xx, 'RawImgHelper'), ...
                varargin{idxExtraArgs})) || ...
            all(cellfun(@(xx) isempty(xx), varargin{idxExtraArgs})))));
    if hasRawImgs
        
        rawImgsIn = varargin{idxExtraArgs};
        
        isCellRawImg = iscell(rawImgsIn);
        if ~isCellRawImg
            rawImgsIn = {rawImgsIn};
        end
        
        idxExtraArgs = idxExtraArgs + 1;
        
    end
    
    % Check the 'second' argument to see if there's a Config
    configIn = {[]};
    hasConfig = nargin > idxExtraArgs && ...
        (isa(varargin{idxExtraArgs}, 'ConfigHelper') || ...
        isempty(varargin{idxExtraArgs}) || ...
        (iscell(varargin{idxExtraArgs}) && ...
            (all(cellfun(@(xx) isa(xx, 'ConfigHelper'), ...
            varargin{idxExtraArgs})) || ...
            all(cellfun(@(xx) isempty(xx), varargin{idxExtraArgs})))));
    if hasConfig
        
        configIn = varargin{idxExtraArgs};
        
        isCellConfig = iscell(configIn);
        if ~isCellConfig
            configIn = {configIn};
        end
        
        idxExtraArgs = idxExtraArgs + 1;
        
    end

    % Check the 'third' argument to see if there's a procImgType
    procImgTypeIn = {[]};
    hasProcImgType = nargin > idxExtraArgs && ...
        (ischar(varargin{idxExtraArgs}) || ...
        isempty(varargin{idxExtraArgs}) || ...
        (iscell(varargin{idxExtraArgs}) && ...
            (all(cellfun(@ischar, varargin{idxExtraArgs})) || ...
            all(cellfun(@(xx) isempty(xx), varargin{idxExtraArgs})))));
    if hasProcImgType
        
        procImgTypeIn = varargin{idxExtraArgs};
        
        isCellProcImgType = iscell(procImgTypeIn);
        if ~isCellProcImgType
            procImgTypeIn = {procImgTypeIn};
        end
        
        idxExtraArgs = idxExtraArgs + 1;
        
    end
    
    % Check that the cells are all the same length
    cellLengths = [length(rawImgsIn), length(configIn), ...
        length(procImgTypeIn)];
    nCells = unique(cellLengths(cellLengths ~= 1));
    if isempty(nCells), nCells = 1; end
    badCellDims = ~isscalar(nCells);
    if badCellDims
        error('ImgGroup:Add:WrongLengthCells', ['Cell arrays supplied ' ...
            'as arguments must be either scalar or all the same length.'])
    end
    
    % Check if there's any more arguments
    extraArgs = varargin(idxExtraArgs:end);
    nExtraArgs = length(extraArgs);
    
    %% Import/prepare any raw images for adding
    
    doAdd = hasRawImgs || hasConfig || hasRawImgs || (nExtraArgs == 0);
    if doAdd
        
        for iCell = 1:nCells

            % Prepare the rawImgsIn
            if cellLengths(1) == 1
                iRawImgsIn = rawImgsIn{1};
            else
                iRawImgsIn = rawImgsIn{iCell};
            end

            % Prepare the configIn
            if cellLengths(2) == 1
                iConfig = configIn{1};
            else
                iConfig = configIn{iCell};
            end
            if ~isempty(iConfig)
                utils.checks.scalar(iConfig, 'Config');
            end

            % Prepare the procImgTypeIn
            if cellLengths(3) == 1
                iProcImgTypeIn = procImgTypeIn{1};
            else
                iProcImgTypeIn = procImgTypeIn{iCell};
            end
            if ~isempty(iProcImgTypeIn)
                utils.checks.single_row_char(iProcImgTypeIn, 'procType');
            end

            if isempty(iRawImgsIn)

                % Select some images if none are specified
                extraArgs = [extraArgs, ImgGroup.from_files_sub(...
                    iRawImgsIn, iConfig, iProcImgTypeIn)]; %#ok<AGROW>

            else

                % Work out which class of ProcessedImg we want to create
                hProcessable = ImgGroup.create_constructor_processable(...
                    iProcImgTypeIn);

                % Create processed images from the raw images
                extraArgs = [extraArgs, ImgGroup.from_rawImgs(...
                    iRawImgsIn, iConfig, hProcessable)]; %#ok<AGROW>

            end

        end
    
    end
    
    %% Add the extra arguments (processed images) to the image group

    % Loop through all the arguments
    nArgs = length(extraArgs);
    for iArg = 1:nArgs

        if isa(extraArgs{iArg}, 'Processable')

            % Add any processed images directly to the children
            self.children{end+1} = extraArgs{iArg};

        elseif iscell(extraArgs{iArg})

            % Recursively call add for any cell arrays
            self.add(extraArgs{iArg}{:});

        else

            % Ignore anything else (for now) and throw a warning
            warning('ImgGroup:Add:UnknownChildType', ['Adding ' ...
                'data of type "%s" is not currently supported.'], ...
                class(extraArgs{iArg}))

        end

    end

end