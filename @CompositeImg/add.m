function add(self, varargin)
%add - Add children to the object
%
%   add(OBJ) prompts for all required information to load/create
%   RawImgComposite objects, create ProcessedImg objects, and add them to
%   the CompositeImg object OBJ.
%
%   add(OBJ, CONFIG, PROCTYPE, MASK) creates Processable objects of the
%   type specified by PROCTYPE using the specified MASK and CONFIG and adds
%   them to the CompositeImg object. CONFIG must be a scalar Config object;
%   PROCTYPE must be a single row character array corresponding to the one
%   of the concrete subclasses of ProcessedImg; and MASK must be a logical
%   array suitable as a mask for creating a RawImgComposite object, or a
%   cell array containing such data types. Any of these three arguments can
%   be empty or missing and the constructor will prompt for them; however,
%   if they are present, arguments must not appear before arguments to
%   their left in the list above. In addition, any of these three arguments
%   can be a cell array where all elements match the expected type;
%   however, any cell arrays must be either scalar or all the same size.
%
%   For non-scalar OBJ, the same CONFIG, PROCTYPE, MASK will be applied to
%   all elements of OBJ, regardless of whether these arguments were
%   explicitly or implicitly supplied.
%
%   See also CompositeImg.children, CompositeImg.from_files, ImgGroup.add,
%   RawImgComposite, Processable, Config

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

	%% Process the input arguments
    
    % Define where the 'extra arguments' start
    idxArgs = 1;
    
    % Define some helper functions to check the arguments.  The first
    % function checks that an individual scalar argument is ok.  The 
    % second function checks also cell
    funCheck = @(arg, funCheckArg) funCheckArg(arg) || isempty(arg);
    funCheckAll = @(arg, funCheckArg) (funCheck(arg, funCheckArg) || ...
        (iscell(arg) && all(cellfun(@(xx) funCheck(xx, funCheckArg), arg))));

    % Check the 'first' argument to see if there's a Config
    configIn = {[]};
    funCheckConfig = @(arg) isa(arg, 'ConfigHelper');
    hasConfig = nargin > idxArgs && ...
        funCheckAll(varargin{idxArgs}, funCheckConfig);
    if hasConfig
        
        configIn = varargin{idxArgs};
        
        isCellConfig = iscell(configIn);
        if ~isCellConfig
            configIn = {configIn};
        end
        
        idxArgs = idxArgs + 1;
        
    end
    
    % ------------------------------------------------------------------- %
    
    % Check the 'second' argument to see if there's a procImgType
    funCheckProcImgType = @(arg) ischar(arg);
    hasProcImgType = nargin > idxArgs && ...
        funCheckAll(varargin{idxArgs}, funCheckProcImgType);
    if hasProcImgType
        
        procImgTypeIn = varargin{idxArgs};
        
        if isempty(procImgTypeIn)
            procImgTypeIn = CompositeImg.choose_imgtypes();
        end
        
        isCellProcImgType = iscell(procImgTypeIn);
        if ~isCellProcImgType
            procImgTypeIn = {procImgTypeIn};
        end
        
        idxArgs = idxArgs + 1;
    else
        
        procImgTypeIn = CompositeImg.choose_imgtypes();
        
    end
    
    % ------------------------------------------------------------------- %
    
    % Check the 'third' argument to see if there's a mask
    maskIn = {[]};
    funCheckMask = @(arg) islogical(arg) || (iscell(arg) &&...
        all(cellfun(@(xx) islogical(xx), arg)));
    hasMask = nargin > idxArgs && ...
        funCheckAll(varargin{idxArgs}, funCheckMask);
    if hasMask
        
        maskIn = varargin{idxArgs};
        
        isCellMask = iscell(maskIn);
        if ~isCellMask
            maskIn = {maskIn};
        end
        
    end
    
    % ------------------------------------------------------------------- %
    
    % Check that the cells are all the same length
    cellLengths = [length(configIn), length(procImgTypeIn), ...
        length(maskIn)];
    nCells = unique(cellLengths(cellLengths ~= 1));
    if isempty(nCells), nCells = 1; end
    badCellDims = ~isscalar(nCells);
    if badCellDims
        error('CompositeImg:Add:WrongLengthCells', ['Cell arrays ' ...
            'supplied as arguments must be either scalar or all the ' ...
            'same length.'])
    end
    
    %% Main part of the function!
    
    % Call the function one by one if we have an array
    if ~isscalar(self)
        for iObj = 1:numel(self)
            
            self(iObj).add(configIn, procImgTypeIn, maskIn)
            
            % Extract out the arguments in case we had to create them for
            % the first object. This means we shouldn't get prompted again.
            if iObj == 1
                
                if ~hasConfig
                    configIn = self(iObj).get_config();
                end
                
                procImgTypeIn = self(iObj).imgTypes;
                
                if ~hasMask
                    maskIn = self(iObj).masks;
                end
                
            end
            
        end
        return
    end
    
    % Loop through and create the sub-children
    newChildren = {};
    for iCell = 1:nCells
        
        % Prepare the configIn
        if cellLengths(1) == 1
            iConfig = configIn{1};
        else
            iConfig = configIn{iCell};
        end
        if ~isempty(iConfig)
            utils.checks.scalar(iConfig, 'Config');
        end

        % Prepare the procImgTypeIn
        if cellLengths(2) == 1
            iProcImgTypeIn = procImgTypeIn(1);
        else
            iProcImgTypeIn = procImgTypeIn(iCell);
        end
        if ~isempty(iProcImgTypeIn)
            utils.checks.single_row_char(iProcImgTypeIn{1}, 'procType');
        end
        
        % Prepare the maskIn
        if cellLengths(3) == 1
            iMaskIn = maskIn(1);
        else
            iMaskIn = maskIn(iCell);
        end
        
        % Create/add the ProcessedImgs
        newChildren = [newChildren, self.create_children(...
            iConfig, iProcImgTypeIn, iMaskIn)]; %#ok<AGROW>
    
    end

    % Pass into ImgGroup to add these ProcessedImgs
    self.add@ImgGroup(newChildren{:});

end