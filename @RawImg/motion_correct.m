function varargout = motion_correct(self, varargin)
%motion_correct - Motion correct the images
%
%   motion_correct(OBJ) motion corrects the OBJ using the utility function
%   with default parameters.
%
%   motion_correct(..., 'useParallel', TF) explicitly specifies whether to
%   perform the motion correction in parallel.  TF must be a scalar value
%   convertible to logical.
% 
%   motion_correct(..., 'attribute', value, ...) passes the attribute-value
%   pairs to the utility function.  See the utility function documentation
%   (link below) for more information about the parameter-value pairs.
%
%   Due to some unexpected behaviour in how MATLAB treats handle classes in
%   parfor loops, when motion correcting in parallel it is necessary to
%   explictly re-assign the output from the motion_correct method back to
%   the original object to ensure that it is updated, i.e. one must use
%   either:
%
%           OBJ = OBJ.motion_correct(USEPARALLEL, ...);
%   or
%           OBJ = motion_correct(OBJ, USEPARALLEL, ...);
%
%   Depending on the Parallel Computing Toolbox preferences, the
%   motion_correct method may automatically create a parallel pool if one
%   is requested (i.e. if numel(OBJ) > numWorkers or if USEPARALLEL ==
%   true); however, this behaviour can be adjusted as desired.
%
%   Please see the <a href="matlab:web(fullfile(utils.CHIPS_rootdir, 'doc', 'html', 'id_pp_motion_corr.html'))">motion correction quick start guide</a> for additional 
%   documentation and examples.
%
%   See also utils.motion_correct.

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
    
    % Define the allowed optional arguments and default values, and create
    % a default parameters structure
    pnames = {'ch', 'constantShift', 'method', 'refImg', ...
        'maxShift', 'minCorr', 'skipChs', 'doPlot', 'fillBadData', ...
        'inpaintIters', 'frameRate', 'verbose', 'useParallel'};
    dflts  = {1, false, 'convfft', [], [], 0.6, [], false, 'nan', 5, ...
        [], true, true};
    params = cell2struct(dflts, pnames, 2);
    
    % Parse function input arguments
    params = utils.parsepropval(params, varargin{:});
    paramsIn = rmfield(params, 'useParallel');
    
    % Check the useParallel
    utils.checks.scalar_logical_able(params.useParallel, 'useParallel');

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
                error('RawImg:MotionCorrect:NoOutputParfor', ...
                    ['When motion correcting in parallel, you must ' ...
                    'store the result in an output variable. ' ...
                    'E.g.:\n\n\timgVar = imgVar.motion_correct();\n\n' ...
                    'This is due to a limitation with MATLAB and '...
                    'handle classes, and this error is here to ' ...
                    'prevent you wondering why your data is not ' ...
                    'motion corrected and getting annoyed!'])
            end
            
            if params.doPlot
                warning('RawImg:MotionCorrect:NoPlotParfor', ...
                    ['Due to MATLAB limitations, plots cannot be ' ...
                    'displayed when motion correcting in parallel.'])
            end
            
            % Attempt to start parallel pool
            if ~isParallel
                [isStart] = utils.start_parallel();
                if ~isStart
                    warning('RawImg:MotionCorrect:NoPoolParfor', ...
                        ['MATLAB couldn''t start the parallel pool. ', ...
                        'If creating it by hand doesn''t help, restart ', ...
                        'MATLAB or set ''useParallel'' to false.'])
                end
            end
            
            % Initialise a progress bar
            isWorker = utils.is_on_worker();
            if ~isWorker
                strMsg = 'Motion correcting array';
                fnPB = utils.progbarpar('msg', strMsg);
            end
            
            parfor iObj = 1:lnObj
                
                sliceElem = self(iObj);
                motion_correct(sliceElem, paramsIn);
                self(iObj) = sliceElem;
                
                % Update the progress bar
                if ~isWorker
                    utils.progbarpar(fnPB, lnObj, 'msg', strMsg);
                end
                
            end
            
        else
            
            for iObj = 1:lnObj
                self(iObj).motion_correct(paramsIn);
            end
            
        end
        
        % Pass the output argument, if necessary
        if nargout > 0
            varargout{1} = self;
        end
        
        return
        
    else
        
        % Check if it's already motion corrected
        if self.isMotionCorrected
            warning('RawImg:MotionCorrect:Already', ['The image is ' ...
                'already motion corrected. Motion correcting more ' ...
                'than once may lead to unexpected results.'])
        end
        
        % Get frame rate from metadata
        paramsIn.frameRate = self.metadata.frameRate;
        params.frameRate = self.metadata.frameRate;
        
        % Perform the motion correction
        [self.rawdata, self.mcRefImg, self.mcShiftX, self.mcShiftY] = ...
            utils.motion_correct(self.rawdata, params);
        self.mcCh = paramsIn.ch;
        self.isMotionCorrected = true;

        % Pass the output argument, if necessary
        if nargout > 0
            varargout{1} = self;
        end
        
    end
    
end