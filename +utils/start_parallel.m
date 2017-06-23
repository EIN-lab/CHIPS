function [isStart, numWorkers] = start_parallel()
%start_parallel - start a parallel pool
%
%   isStart = start_parallel() is a utility function that tries to start a
%   parallel pool and returns a logical value specifying whether it
%   succeeded.
%
%   [isStart, numWorkers] = start_parallel() also returns the number of
%   workers in the parallel pool.  If there is no parallel pool, numWorkers
%   = NaN.

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

% Check the number of input arguments
narginchk(0, 0);

% Setup default values
isStart = false;
poolObj = [];
numWorkers = NaN;

% Check if we're already on a parallel pool worker
isWorker = utils.is_on_worker();
if isWorker
    isStart = true;
    numWorkers = NaN;
    return
end

% Attempt to access the current parallel pool. Try to start one if
% there is none already.
oldMatlab = verLessThan('matlab', '8.2');
if oldMatlab
    
    % Work out if we're already started
    numWorkers = matlabpool('size'); %#ok<DPOOL>
    if isfinite(numWorkers) && numWorkers > 0
        isStart = true;
        return
    end
    
    % Otherwise, open the pool
    matlabpool('open'); %#ok<DPOOL>
    numWorkers = matlabpool('size'); %#ok<DPOOL>
    if isfinite(numWorkers) && numWorkers > 0;
        isStart = true;
    elseif numWorkers == 0
        numWorkers = NaN;
    end
    
else
    
    % Use gcp with 'nocreate' option to avoid infinite IdleTimeout
    poolObj = gcp('nocreate');
    if isempty(poolObj)
        poolObj = parpool;
    else
        % Pool already running
    end

    % Update the return values if we have a parallel pool
    if ~isempty(poolObj)
        isStart = true;
        numWorkers = poolObj.NumWorkers;
    end
    
end

end
