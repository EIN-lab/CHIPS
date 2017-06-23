function varargout = num_dims(val, nDimIn, varargin)
%num_dims - Check that the variable has the assumed dimensionality
%
%   num_dims(val, nDimIn) checks that val has number of dimensions
%   specified with nDimIn. If it has, nothing else happens; if it has not,
%   the function throws an exception from the calling function. nDimIn can
%   be a scalar or vector listing all allowed numbers of dimensions.
%
%   num_dims(val, nDimIn, 'VarName') includes VarName in the exception
%   message.
%
%   ME = num_dims(...) returns the MException object instead of throwing it
%   internally.  If no exception is created, ME will be an empty array.
%   This can be useful for combining multiple checks while still throwing
%   the exception from the original calling function.
%
%   See also ndims, error, MException, MException.throwAsCaller

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

% Check the number of arguments in
narginchk(2, 3)

% Work out if we want to return the exception or throw it internally, and
% initialise the output argument if necessary
doReturnME = nargout > 0;
if doReturnME
    varargout{1} = [];
end

%% Check the value is a scalar

isGood = any(ndims(val) == nDimIn); % multiple dimensions can be allowed
if ~isGood
    
    % Get the varName, if supplied, or a default string
    varName = utils.checks.varName(varargin{:});
    
    % Format a string for the number of dimensions
    if isscalar(nDimIn)
        strDims = sprintf('exactly %d', nDimIn);
    else
        strDimsTemp = sprintf('%d ', nDimIn);
        strDimsTemp = strDimsTemp(1:end-1);
        strDims = sprintf('any of [%s]', strDimsTemp);
    end
    
    % Create the MException object
    ME = MException('Utils:Checks:NumDims', ['The %s must have %s ', ...
        'dimensions, but the data provided has %i dimensions.'], ...
        varName, strDims, ndims(val));
    
    % Return the MException object, or else throw it as the caller function
    if doReturnME
        varargout{1} = ME;
    else
        throwAsCaller(ME)
    end
    
end

end
