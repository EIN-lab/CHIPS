function make_mex()
%make_mex - Compile relevant C, C++, and MATLAB functions into MEX files
%
%   make_mex() compiles relevant C, C++, and MATLAB functions included with
%   this package into MEX files using the InstallMex utility function (for
%   C and C++ files) and the MATLAB coder (for MATLAB functions).
%
%   Before running this function ensure that an appropriate compiler is
%   installed and configured (e.g. with mex -setup).  In addition,
%   compiling MATLAB functions to MEX files requires MATLAB Coder.
%
%   Note: some functions will only compile on certain platforms.  For
%   example, the function GetFullPath.c will only compile on Windows, and
%   will fail to compile on other platforms.  This does not influence the
%   functionality, but the function will run much faster using the MEX file
%   on Windows than using the MATLAB function.
%
%   See also mex, codegen, utils.GetFullPath.InstallMex

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

% Extract the CHIPS root directory
dirRoot = utils.CHIPS_rootdir();

% A list of C (or C++) files to be compiled
listC = {...
    ['+utils' filesep  '+GetFullPath' filesep 'GetFullPath.c'], ...
    ['+utils' filesep  '+convnfft' filesep 'inplaceprod.c']
    };

% A list of MATLAB files to be compiled
listM = {...
    ['+utils' filesep  '+hmm' filesep 'makepi.m']
    };

% Loop through and compile the C/C++ files using the utility function
nC = numel(listC);
for iC = 1:nC
    try 
        utils.GetFullPath.InstallMex(fullfile(dirRoot, listC{iC}))
    catch ME
        warning('MakeMex:CompileErrorC', ['An error occured while ', ...
            'compiling %s (see below)\n\n%s'], listC{iC}, ME.message)
    end
    fprintf('\n')
end

% Check that there is a licence for MATLAB Coder available
utils.verify_license('matlab_coder', 'make_mex')

% Loop through and compile the MATLAB functions using codegen
nM = numel(listM);
for iM = 1:nM
    
    % Setup the file paths
    iInput = fullfile(dirRoot, listM{iM});
    [dirBase, fnBase, ~] = fileparts(iInput);
    iOutput = fullfile(dirBase, fnBase);
    
    % Compile the functions
    fprintf('== Compile %s\n', iInput)
    try
        codegen(iInput, '-o', iOutput)
        fprintf('Success:\n  %s.%s\n\n', iOutput, mexext())
    catch ME
        warning('MakeMex:CompileErrorC', ['An error occured while ', ...
            'compiling %s (see below)\n\n%s'], listM{iM}, ME.message)
    end
    
    % Give some output about the residual
    if iM ==nM
        fprintf(['You may wish to remove intermediary build files ' ...
            'in the "codegen" directory.\n\n'])
    end
    
end

end