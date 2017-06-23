function varargout = process(self, useParallel, varargin)
%process - Process the child objects
%
%   process(OBJ) processes the children of the ImgGroup object OBJ.
%
%   process(OBJ, USEPARALLEL) explicitly specifies whether to process the
%   ImgGroup object's children in parallel, using an available parallel
%   pool. By default, the processing will use a parallel pool when
%   ImgGroup.nChildren > numWorkers, where numWorkers is the number of
%   workers in the parallel pool.
%
%   process(OBJ, USEPARALLEL, ...) passes any additional arguments to the
%   children's processing method
%
%   OBJ = process(OBJ, ...) overwrites the ImgGroup object with the
%   processed version of itself.  See below for more information on this
%   syntax.
%
%   Due to some unexpected behaviour in how MATLAB treats handle classes in
%   parfor loops, when processing in parallel it is necessary to explictly
%   re-assign the output from the process method back to the original
%   object to ensure that it is updated, i.e. one must use either:
%
%           OBJ = OBJ.process(USEPARALLEL, ...);
%   or
%           OBJ = process(OBJ, USEPARALLEL, ...);
%
%   Depending on the Parallel Computing Toolbox preferences, the process
%   method may automatically create a parallel pool if one is requested
%   (i.e. if numel(OBJ) > numWorkers or if USEPARALLEL == true); however,
%   this behaviour can be adjusted as desired.
%
%   See also parfor, parpool, gcp, ProcessedImg.process

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
        
    % Check the arguments
    hasUP = (nargin > 1) && exist('useParallel', 'var');
    if hasUP
        isOK_UP = isempty(useParallel) || (isscalar(useParallel) && ...
            (islogical(useParallel) || isnumeric(useParallel)));
        if ~isOK_UP
            error('ProcessedImg:Process:BadUseParallel', ...
                ['useParallel must be a scalar logical or ' ...
                'numeric value.'])
        end
    else
        useParallel = [];
    end
    
    % Work out if we could use the parallel features
    [isParallel, numWorkers] = utils.is_parallel();
        
    % Call the function one by one if we have an array
    if ~isscalar(self)
        
        % Work out if we're using the parallel features
        nElem = numel(self);
        if isempty(useParallel)
            doPar = isParallel && (nElem > numWorkers);
        else
            doPar = useParallel;
        end
        
        % Process each of the elements, in parallel if desirable
        if doPar

            % Give the user an error so they know that their data won't
            % be stored if they don't capture it in an output variable.
            isNoOutput = nargout == 0;
            if isNoOutput
                error('ImgGroup:Process:NoOutputParfor', ...
                    ['When processing in parallel, you must ' ...
                    'store the result in an output variable. ' ...
                    'E.g.:\n\n\timgGroup = imgGroup.process();\n\n' ...
                    'This is due to a limitation with MATLAB and '...
                    'handle classes, and this error is here to ' ...
                    'prevent you wondering where your data is and ' ...
                    'getting annoyed!'])
            end
            
            % Attempt to start parallel pool
			if ~isParallel
				[isStart] = utils.start_parallel();
				if ~isStart
					warning('ImgGroup:ProcessElements:NoPoolParfor', ...
						['MATLAB couldn''t start the parallel pool. ', ...
						'If creating it by hand doesn''t help, restart ', ...
						'MATLAB or set ''useParallel'' to false.'])
				end
			end

            % Clear any pre-existing warnings on the parallel workers
            utils.clear_worker_wngs()

            % Initialise a progress bar
            isWorker = utils.is_on_worker();
            if ~isWorker
                strMsg = 'Processing array';
                fnPB = utils.progbarpar('msg', strMsg);
            end

            parfor iElem = 1:nElem

                % Process in parallel
                sliceElem = self(iElem);
                process(sliceElem, useParallel, varargin{:}); %#ok<PFBNS>
                self(iElem) = sliceElem;

                % Update the progress bar
                if ~isWorker
                    utils.progbarpar(fnPB, nElem, 'msg', strMsg);
                end

            end

            % Close the progress bar
            if ~isWorker
                utils.progbarpar(fnPB, 0, 'msg', strMsg);
            end

        else
            for iElem = 1:nElem
                self(iElem).process(useParallel, varargin{:});
            end
        end
        
    else
        
        % Work out if we're using the parallel features
        if isempty(useParallel)
            doPar = isParallel && (self.nChildren > numWorkers);
        else
            doPar = useParallel;
        end
    
        % Process each of the children, in parallel if possible/desirable
        if doPar
            
            % Clear any pre-existing warnings on the parallel workers
            utils.clear_worker_wngs()

            % Initialise a progress bar and start parallel pool
            isWorker = utils.is_on_worker();
            if ~isWorker
                
                % Attempt to start parallel pool
                [isStart] = utils.start_parallel();
                if ~isStart
                    error('ImgGroup:ProcessChildren:NoPoolParfor', ...
                        ['MATLAB couldn''t start the parallel pool. ', ...
                        'If creating it by hand doesn''t help, restart ', ...
                        'MATLAB or set ''useParallel'' to false.'])
                end
                
                strMsg = 'Processing children';
                fnPB = utils.progbarpar('msg', strMsg);
                
            end

            children = self.children;
            nChildren = self.nChildren;
            parfor iChildNum = 1:nChildren

                currChild = children{iChildNum};
                currChild = currChild.process(useParallel, varargin{:}); %#ok<PFBNS>
                children{iChildNum} = currChild;

                % Update the progress bar
                if ~isWorker
                    utils.progbarpar(fnPB, nChildren, 'msg', strMsg);
                end

            end

            self.children = children;

            % Close the progress bar
            if ~isWorker
                utils.progbarpar(fnPB, 0, 'msg', strMsg);
            end

        else
            for iChildNum = 1:self.nChildren
                self.children{iChildNum} = ...
                    self.children{iChildNum}.process(useParallel, varargin{:});
            end
        end
        
    end
    
    % Pass the output argument, if necessary
    if nargout > 0
        varargout{1} = self;
    end

end
