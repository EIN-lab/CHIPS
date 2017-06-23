function subclasses = find_subclasses(superclass, varargin)
%find_subclasses - Helper function to find subclasses
%
%   This function is not intended to be called directly.

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
narginchk(1, 5);

persistent classlist

% Parse arguments
[exclAbstract, exclMock, exclTest, inclParent] = ...
    utils.parse_opt_args({true, true, true, false}, varargin);

% Get the overall classlist, if required
if isempty(classlist)
    classlist = utils.find_classlist();    
end

% Loop through the classes to see if they're subclasses of the superclass
nFiles = length(classlist);
subclasses = {};
for iFile = 1:nFiles
    
    % Get only the filename
    [~, iFilename] = fileparts(classlist{iFile});
    
    % These are very rough checks, but should be sufficient
    if exclMock
        isProbMock = strncmp(iFilename, 'Mock_', 5);
        if isProbMock
            continue
        end
    end
    if exclTest
        isProbTest = strncmp(iFilename, 'Test_', 5);
        if isProbTest
            continue
        end
    end
    
    % Check if the desired superclass is a superclass of this class
    isSubClass = (inclParent && isequal(iFilename, superclass)) || ...
        utils.issubclass(iFilename, superclass);
    
    if isSubClass
        
        % Exclude abstract classes if desired
        if exclAbstract
            mcls = meta.class.fromName(iFilename);
            isAbstract = mcls.Abstract;
            if isAbstract
                continue
            end
        end
        
        % Exclude test classes and mock classes
        isTestClass = ismember('matlab.unittest.TestCase', ...
            superclasses(iFilename));
        isMockClass = ismember('IMock', superclasses(iFilename));
        if (exclMock && isMockClass) || (exclTest && isTestClass)
            continue
        end
        
        % Append this class if appropriate
        subclasses = [subclasses {iFilename}]; %#ok<AGROW>
        
    end
    
end

end
