function varargout = same_file(x1, x2, varargin)
%same_file - Check that two files are identical
%
%   same_file(x1, x2) checks that x1 and x2 are identical text files.  If
%   they are, nothing else happens; if they are not, the function throws an
%   exception from the calling function.
%
%   same_file(x1, x2, 'VarName') includes VarName in the exception message.
%   The VarName string can include the names of both files for a more
%   useful error message
%
%   ME = same_file(...) returns the MException object instead of throwing
%   it internally.  If no exception is created, ME will be an empty array.
%   This can be useful for combining multiple checks while still throwing
%   the exception from the original calling function.
%
%   See also size, isequal, error, MException, MException.throwAsCaller

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

%% Check that values are of the correct class
if ischar(x1)
    x1 = {x1};
end

if ischar(x2)
    x2 = {x2};
end

%% Check that x1 and x2 have the same number of files
hasSameNumberOfFiles = isscalar(x1) || isequal(size(x1), size(x2));
if ~hasSameNumberOfFiles
    
    % Get the varName, if supplied, or a default string
    varName = utils.checks.varName(varargin{:}, 'values');
    
    % Create the MException object
    ME = MException('Utils:Checks:SameOutput:NumFiles', ['The %s must', ...
        ' have the same number of files.'], varName);
    
    % Return the MException object, or else throw it as the caller function
    if doReturnME
        varargout{1} = ME;
    else
        throwAsCaller(ME)
    end
    
end

%% Call the function one by one if we have an array 
nFiles = numel(x1);

for iFile = 1:nFiles
    
    if isempty(x1{iFile})
        return
    elseif ~isscalar(x1)
        utils.checks.same_file(x1(iFile), x2(iFile)); 
    end

end

%% Do actual comparison
if isscalar(x1)
    
    fid1 = fopen(x1{:}, 'r');
    fid2 = fopen(x2{:}, 'r');
    
    lines1 = textscan(fid1,'%s','delimiter','\n');
    lines2 = textscan(fid2,'%s','delimiter','\n');
    lines1 = lines1{1};
    lines2 = lines2{1};
    
    fclose(fid1);
    fclose(fid2);
    
    is_equal = isequal(lines1,lines2);
    
    if ~is_equal
        
        % Get the varName, if supplied, or a default string
        varName = utils.checks.varName(varargin{:}, 'values');
        
        % Create the MException object
        ME = MException('Utils:Checks:SameOutput:NotEqual', ['The %s ', ...
            'must have the contents.'], varName);
        
        % Return the MException object, or else throw it as the caller function
        if doReturnME
            varargout{1} = ME;
        else
            throwAsCaller(ME)
        end
        
    end
    
end

end
