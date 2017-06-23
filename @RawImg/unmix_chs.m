function varargout = unmix_chs(self, useParallel, varargin)
%unmix_chs - Unmix image channels
%
%   unmix_chs(OBJ) interactively unmixes image channels in OBJ using the
%   utility function with the default method.
%
%   unmix_chs(OBJ, USEPARALLEL) explicitly specifies whether to unmix the
%   RawImg object in parallel, using an available parallel pool. By
%   default, the processing will use a parallel pool when numel(OBJ) >
%   numWorkers, where numWorkers is the number of workers in the parallel
%   pool.
%
%   unmix_chs(OBJ, USEPARALLEL, ...) passes all additional arguments to the
%   utility function.  See the utility function documentation (link below)
%   for more information about the arguments.
%
%   OBJ = unmix_ch(...) overwrites the RawImg object with the umixed
%   version of itself.  See below for more information on this syntax.
% 
%   [OBJ, P] = unmix_ch(...) explicitly specifies the
%   path to an ImageJ RoiSet.zip file containign the ROIs to be used for
%   calculation of channel contribution in non-interactive mode.
%
%   Due to some unexpected behaviour in how MATLAB treats handle classes in
%   parfor loops, when processing in parallel it is necessary to explictly
%   re-assign the output from the process method back to the original
%   object to ensure that it is updated, i.e. one must use either:
%
%           OBJ = OBJ.unmix_chs(USEPARALLEL, ...);
%   or
%           OBJ = unmix_chs(OBJ, USEPARALLEL, ...);
%
%   Depending on the Parallel Computing Toolbox preferences, the process
%   method may automatically create a parallel pool if one is requested
%   (i.e. if numel(OBJ) > numWorkers or if USEPARALLEL == true); however,
%   this behaviour can be adjusted as desired.
% 
%   See also utils.unmix_chs, parfor, parpool, gcp

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
        isOK_UP = isempty(useParallel) || ...
            (isscalar(useParallel) && (islogical(useParallel) || ...
            isnumeric(useParallel)));
        if ~isOK_UP
            error('RawImg:UnmixChannels:BadUseParallel', ...
                ['useParallel must be a scalar logical or ' ...
                'numeric value.'])
        end
    else
        useParallel = [];
    end

    % Work out if we're using the parallel features
    nElems = numel(self);
    [isParallel, numWorkers] = utils.is_parallel();
    if isempty(useParallel)
        doPar = isParallel && (nElems > numWorkers);
    else
        doPar = useParallel;
    end
    
    % Initialise a progress bar
    isWorker = utils.is_on_worker();
    doProgBar = ~isWorker && (nElems > 1);
    if doProgBar
        strMsg = 'Unmixing array';
    else
        strMsg = '';
    end

    % Process each of the children, in parallel if possible/desirable
    if doPar

        % Give the user an error so they know that their data won't
        % be stored if they don't capture it in an output variable.
        isNoOutput = nargout == 0;
        if isNoOutput
            error('RawImg:UnmixChannels:NoOutputParfor', ...
                ['When unmixing in parallel, you must ' ...
                'store the result in an output variable. ' ...
                'E.g.:\n\n\timgVar = imgVar.unmix_ch();\n\n' ...
                'This is due to a limitation with MATLAB and '...
                'handle classes, and this error is here to ' ...
                'prevent you wondering why your data is not ' ...
                'unmixed and getting annoyed!'])
        end
        
        % Attempt to start parallel pool
        if ~isParallel
            [isStart] = utils.start_parallel();
            if ~isStart
                warning('RawImg:UnmixChannels:NoPoolParfor', ...
                    ['MATLAB couldn''t start the parallel pool. ', ...
                    'If creating it by hand doesn''t help, restart ', ...
                    'MATLAB or set ''useParallel'' to false.'])
            end
        end

        % Initialise a progress bar
        if doProgBar
            fnPB = utils.progbarpar('msg', strMsg);
        else
            fnPB = '';
        end

        parfor iElem = 1:nElems
            
            % Do the actual unmixing
            sliceElem = self(iElem);
            [sliceElem.rawdata, paramsOut{iElem}] = ...
                utils.unmix_chs(sliceElem.rawdata, varargin{:}) %#ok<PFBNS>
            
            % Tidy up the channels
            sliceElem = update_unmixed_chs(sliceElem);
            self(iElem) = sliceElem;

            % Update the progress bar
            if doProgBar
                utils.progbarpar(fnPB, nElems, 'msg', strMsg);
            end

        end
        
        % Close the progress bar
        if doProgBar
            utils.progbarpar(fnPB, 0, 'msg', strMsg);
        end
        
    else
        
        % Initialise a progress bar
        if doProgBar
            utils.progbar(0, 'msg', strMsg);
        end
        
        % Loop through the objects
        paramsOut = cell(1, nElems);
        for iElem = 1:nElems
            
            % Do the actual unmixing
            [self(iElem).rawdata, paramsOut{iElem}] = ...
                utils.unmix_chs(self(iElem).rawdata, varargin{:});
            
            % Tidy up the channels
            self(iElem) = update_unmixed_chs(self(iElem));  
            
            % Update the progress bar
            if doProgBar
                utils.progbar(iElem/nElems, 'msg', strMsg, ...
                    'doBackspace', true);
            end
    
        end
        
    end

     % Pass the output argument, if necessary
    if nargout > 0
        varargout{1} = self;
        varargout{2} = paramsOut;
    end
    
end

% ---------------------------------------------------------------------- %

function self = update_unmixed_chs(self)

% Work out if the number of channels has changed, and if so
% prompt the user for any required input
imgSizeNew = size(self.rawdata);
nNewChs = imgSizeNew(3);
hasChsChanged = nNewChs ~= self.metadata.nChannels;
if hasChsChanged

    % Extract the useful parts of the metadata
    acq = self.metadata.get_acq;
    calObj = self.metadata.calibration;

    % Work out if we have the same number of named channels
    % as actual channels, in which case we can assume the named
    % channels are the ones that got output from unmix_chs
    chs = self.metadata.channels;
    chNames = fieldnames(chs);
    hasPerfectNums = nNewChs == numel(chNames);

    if hasPerfectNums

        % Sort out the correct order for the channel names
        for jCh = nNewChs:-1:1
            chNums(jCh) = chs.(chNames{jCh});
        end
        [~, idxSort] = sort(chNums);
        chNames = chNames(idxSort);

        % Create the new channels structure
        for jCh = 1:nNewChs
            chsNew.(chNames{jCh}) = jCh;
        end

    else

        for jCh = 1:nNewChs

            % Prompt the user to select the channel
            strMenu = sprintf(['What is shown on the ' ...
                'new (i.e. unmixed) channel %d?'], jCh);
            chName = Metadata.choose_channel([], strMenu);

            % Create the channels structure
            if ~isempty(chName)
                chsNew.(chName) = jCh;
            end

        end

    end

    % Create and assign the new metadata
    self.metadata = ...
        Metadata(imgSizeNew, acq, chsNew, calObj);

end

end