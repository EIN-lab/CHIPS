function varargout = denoise(self, varargin)
%denoise - Denoise the images
%
%   This function implements a block matching 3D (BM3D) algorithm for
%   improving signal-to-noise ratio in two-photon imaging data. For further
%   information about BM3D, please refer to <a href="matlab:web('http://doi.org/10.1016/j.ymeth.2014.03.010', '-browser')">Danielyan et al. (2014)</a>, 
%   Methods 68(2):308-316.
%
%   denoise(OBJ) denoises the OBJ using the utility function with default
%   parameters.
%
%   denoise(..., 'useParallel', TF) explicitly specifies whether to perform
%   the denoising in parallel.  TF must be a scalar value convertible to
%   logical.
% 
%   denoise(..., 'attribute', value, ...) passes the attribute-value pairs
%   to the utility function.  See the utility function documentation (link
%   below) for more information about the parameter-value pairs.
%
%   Due to some unexpected behaviour in how MATLAB treats handle classes in
%   parfor loops, when denoise-ing in parallel it is necessary to explictly
%   re-assign the output from the denoise method back to the original
%   object to ensure that it is updated, i.e. one must use either:
%
%           OBJ = OBJ.denoise(USEPARALLEL, ...);
%   or
%           OBJ = denoise(OBJ, USEPARALLEL, ...);
%
%   Depending on the Parallel Computing Toolbox preferences, the denoise
%   method may automatically create a parallel pool if one is requested
%   (i.e. if numel(OBJ) > numWorkers or if USEPARALLEL == true); however,
%   this behaviour can be adjusted as desired.
%
%   See also utils.denoise

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
    
    % Define allowed optional arguments and default values
    pNames = {...
        'useParallel';
        'force4D'; ...
        'skipChs'; ...
        'profile'; ...
        };
    pValues  = {...
        true;
        []; ...
        []; ...
        'np'; ...
        };
    dflts = cell2struct(pValues, pNames);

    % Parse function input arguments
    params = utils.parsepropval(dflts, varargin{:});
    paramsIn = rmfield(params, 'useParallel');
    
    % Check the useParallel
    utils.checks.scalar_logical_able(params.useParallel, 'useParallel');
    
    % Validate profile
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    %%%%  profile --> Quality/complexity trade-off (previously bm3dProfile)
    %%%%
    %%%%  'np' --> Normal Profile (balanced quality)
    %%%%  'lc' --> Low Complexity Profile (fast, lower quality)
    %%%%  'hi' --> High profile
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

    if ~ismember(paramsIn.profile, {'np', 'lc', 'hi'})
        warning('RawImg:Denoise:Profile',...
            ['Suppled value for "profile" attribute is unknown. ', ...
            'Selecting normal profile ("np") instead.'])
        paramsIn.profile = 'np';
    end
    
    %% Do the denoising
    % Check if function is called on array
    if ~isscalar(self)
        
        % Work out if we're using the parallel features
        lnObj = length(self);
        [isParallel, numWorkers] = utils.is_parallel();
        if isempty(params.useParallel)
            doPar = isParallel && (lnObj > numWorkers);
        else
            doPar = params.useParallel;
        end

        % Process each of the children, in parallel if possible/desirable
        if doPar
            
            % Give the user an error so they know that their data won't
            % be stored if they don't capture it in an output variable.
            isNoOutput = nargout == 0;
            if isNoOutput
                error('RawImg:Denoise:NoOutputParfor', ...
                    ['When denoising in parallel, you must ' ...
                    'store the result in an output variable. ' ...
                    'E.g.:\n\n\timgVar = imgVar.denoise();\n\n' ...
                    'This is due to a limitation with MATLAB and '...
                    'handle classes, and this error is here to ' ...
                    'prevent you wondering why your data is not ' ...
                    'denoised and getting annoyed!'])
            end
            
            % Attempt to start parallel pool
            if ~isParallel
                [isStart] = utils.start_parallel();
                if ~isStart
                    warning('RawImg:Denoise:NoPoolParfor', ...
                        ['MATLAB couldn''t start the parallel pool. ', ...
                        'If creating it by hand doesn''t help, restart ', ...
                        'MATLAB or set ''useParallel'' to false.'])
                end
            end
            
            % Initialise a progress bar
            isWorker = utils.is_on_worker();
            if ~isWorker
                strMsg = 'Denoising array';
                fnPB = utils.progbarpar('msg', strMsg);
            end
            
            % Clear any pre-existing warnings on the parallel workers
            utils.clear_worker_wngs()
            
            parfor iObj = 1:lnObj
                
                sliceElem = self(iObj);
                denoise(sliceElem, paramsIn);
                self(iObj) = sliceElem;
                
                % Update the progress bar
                if ~isWorker
                    utils.progbarpar(fnPB, lnObj, 'msg', strMsg);
                end
                
            end
            
        else
            
            for iObj = 1:lnObj
                self(iObj).denoise(paramsIn);
            end
            
        end
        
        % Pass the output argument, if necessary
        if nargout > 0
            varargout{1} = self;
        end
        
        return
        
    else
        
        % Check if it's already denoised
        if self.isDenoised
            warning('RawImg:Denoise:Already', ['The image is ' ...
                'already denoised. Denoising more ' ...
                'than once is not recommended.'])
        end
        
        % Perform denoising
        [self.rawdata, usedChs] = utils.denoise(self.rawdata, paramsIn);
        self.dChs = usedChs;
        self.isDenoised = true;

        % Pass the output argument, if necessary
        if nargout > 0
            varargout{1} = self;
        end
        
    end
    
end
