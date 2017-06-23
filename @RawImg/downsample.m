function ridObj = downsample(self, dsamp, varargin)
%downsample - Downsample the images in space and/or time
%
%   OBJ_DS = downsample(OBJ, DSAMP) downsamples the raw image data of the
%   RawImg object OBJ, in space and/or time, using the utility function.
%
%   DSAMP, the downsampling factor, can be a numeric scalar or 2 element
%   vector. For DSAMP = 2, the raw image data of OBJ_DS will have half as
%   many pixels in both spatial dimensions compared to OBJ, and half as
%   many frames. DSAMP corresponds to [DSAMP_XY, DSAMP_T] when it has two
%   elements.
%
%   OBJ_DS, the downsampled RawImg object, will be returned as a
%   RawImgDummy object.
%
%   OBJ_DS = downsample(..., 'useParallel', TF) explicitly specifies
%   whether to perform the downsampling in parallel.  TF must be a scalar
%   value convertible to logical.
% 
%   downsample(..., 'attribute', value, ...) passes the attribute-value
%   pairs to the utility function.  See the utility function documentation
%   (link below) for more information about the parameter-value pairs.
%
%   See also utils.downsample, RawImgDummy

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
    
    %% Check input and output
    
    % Check the number of input arguments
    narginchk(2, inf);
    
    % Define the allowed optional arguments and default values, and create
    % a default parameters structure
    pnames = {'method', 'useParallel'};
    dflts  = {'bilinear', true};
    params = cell2struct(dflts, pnames, 2);
        
    % Parse function input arguments
    params = utils.parsepropval(params, varargin{:});
    paramsIn = rmfield(params, 'useParallel');
    
    % Check the useParallel
    utils.checks.scalar_logical_able(params.useParallel, 'useParallel');

    %% Check if function is called on array
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
            
            % Attempt to start parallel pool
            if ~isParallel
                [isStart] = utils.start_parallel();
                if ~isStart
                    warning('RawImg:Downsample:NoPoolParfor', ...
                        ['MATLAB couldn''t start the parallel pool. ', ...
                        'If creating it by hand doesn''t help, restart ', ...
                        'MATLAB or set ''useParallel'' to false.'])
                end
            end
            
            % Initialise a progress bar
            isWorker = utils.is_on_worker();
            if ~isWorker
                strMsg = 'Downsampling array';
                fnPB = utils.progbarpar('msg', strMsg);
            end
            
            parfor iObj = 1:lnObj
                
                sliceElem = self(iObj);
                ridObj{iObj} = downsample(sliceElem, dsamp, paramsIn);
                                
                % Update the progress bar
                if ~isWorker
                    utils.progbarpar(fnPB, lnObj, 'msg', strMsg);
                end
                
            end
            
            % Unpack the RID from its cell array
            ridObj = [ridObj{:}];
            
        else
            
            for iObj = 1:lnObj
                ridObj(iObj) = downsample(self(iObj), dsamp, paramsIn); %#ok<AGROW>
            end
            
        end
        
        return
        
    else
        
        % Perform downsampling
        rawdataDS = utils.downsample(self.rawdata, dsamp, ...
            'force4D', true, paramsIn);
        
        % Extract the old metadata
        acq = self.metadata.get_acq;
        chs = self.metadata.channels;
        calObj = self.metadata.calibration;
        
        % Compute metadata after downsampling
        spaceFactor = (size(rawdataDS, 1) * size(rawdataDS, 2)) / ...
            (self.metadata.nLinesPerFrame * self.metadata.nLinesPerFrame);
        timeFactor = size(rawdataDS, 4) / self.metadata.nFrames;
        
        % By binning pixels, we spend more time on each
        acq.pixelTime = acq.pixelTime * (spaceFactor * timeFactor)^-1;
        acq.lineTime = acq.lineTime * (spaceFactor * timeFactor)^-1;

        % As we output new object, we also change the 'original' dimensions
        acq.nPixelsPerLineOrig = size(rawdataDS, 2);
        acq.nLinesPerFrameOrig = size(rawdataDS, 1);
        
        % Create a new RawImgDummy object
        strName = [self.name , '_downsampled'];
        ridObj = RawImgDummy(strName, rawdataDS, chs, calObj, acq);
        
    end
    
end
