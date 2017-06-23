function [tf, numWorkers] = is_parallel()
%is_parallel - Determine if a parallel pool currently exists
%
%   tf = is_parallel() is a utility function that returns a logical value
%   specifying whether a parallel pool currently exists.
%
%   [tf, numWorkers] = is_parallel() also returns the number of workers in
%   the parallel pool.  If there is no parallel pool, numWorkers = NaN.

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
tf = false;
poolObj = [];
numWorkers = NaN;

oldMatlab = verLessThan('matlab', '8.2');
if oldMatlab
    
    try
        numWorkers = matlabpool('size'); %#ok<DPOOL>
    catch
    end
    
    if isfinite(numWorkers)
        tf = numWorkers > 0;
    end
    
else

    % Attempt to access the current parallel pool.  We assume that if there
    % is an error that there is no parallel pool.
    try
        poolObj = gcp('nocreate');
    catch
    end

    % Update the return values if we have a parallel pool
    if ~isempty(poolObj)
        tf = true;
        numWorkers = poolObj.NumWorkers;
    end
    
end

end