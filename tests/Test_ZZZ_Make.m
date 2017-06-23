classdef Test_ZZZ_Make < matlab.unittest.TestCase
    %Test_ZZZ_Make Summary of this class goes here
    %   Detailed explanation goes here
    
    % ================================================================== %
    
    methods (Test)
        
%         function testMakeTlbx(self)
%                        
%             % Create the object
%             [status, branch] = system('git rev-parse --abbrev-ref HEAD');
%             branch = strtrim(branch);
%             
%             % Check that everything went ok with getting the branch
%             isOK = status == 0;
%             self.verifyTrue(isOK, ['The test could not get the ' ...
%                 'current git branch.  Perhaps git is not installed ' ...
%                 'or on the system path?'])
%             if ~isOK
%                 return
%             end
%             
%             % Build the toolbox
%             fnToolbox = fullfile(utils.CHIPS_rootdir, 'tests', ...
%                 'output', 'CHIPS_test.mltbx');
%             make_tlbx('branch', branch, 'incVersion', 0, ...
%                 'fnToolbox', fnToolbox, 'makeDocs', false)
%             
%             % Run the verification
%             isFile = exist(fnToolbox, 'file') == 2;
%             self.verifyTrue(isFile, ['The toolbox was not created ' ...
%                 'as expected']);
%             if isFile
%                 delete(fnToolbox)
%             end
%             
%         end
        
        % -------------------------------------------------------------- %
        
        function testDocs(self)
            
            % Find the contents of the folders beforehand, including both
            % the output directory and the current working directory
            dirOutput = fullfile(utils.CHIPS_rootdir, 'tests', 'output');
            ddPreOutput = dir(dirOutput);
            ffPreOutput = {ddPreOutput.name};
            ddPreWD = dir(pwd);
            ffPreWD = {ddPreWD.name};
            
            % Build the docs
            make_docs('outputDir', dirOutput);
            
            % Check that some new files have been created
            ddPostOutput = dir(dirOutput);
            ffPostOutput = {ddPostOutput.name};
            isNewHtml = ~ismember(ffPostOutput, ffPreOutput);
            self.verifyTrue(sum(isNewHtml) > 0)
            
            % Delete the new files, in both directories
            ddPostWD = dir(pwd);
            ffPostWD = {ddPostWD.name};
            isNewWD = ~ismember(ffPostWD, ffPreWD);
            ffDeleteWD = fullfile(pwd, ffPostWD(isNewWD));
            ffDeleteOutput = fullfile(dirOutput, ffPostOutput(isNewHtml));
            delete(ffDeleteOutput{:}, ffDeleteWD{:});
            
        end
        
        % -------------------------------------------------------------- %
        
%         function testBfmatlab(self)
%             
%             % Setup some directory names
%             dirOutput = fullfile(utils.CHIPS_rootdir, 'tests', 'output');
%             dirBfmatlab = fullfile(dirOutput, 'bfmatlab');
%             
%             % Check the warning
%             self.verifyWarning(@() utils.install_bfmatlab(dirOutput), ...
%                 'InstallBfmatlab:Licence');
%             
%             % Check the directory is created
%             self.verifyTrue(isdir(dirBfmatlab), ...
%                 'install_bfmatlab does not create the expected dir')
%             
%             % Delete the temporary directory
%             rmdir(dirBfmatlab, 's')
%             
%         end
%         
%         % -------------------------------------------------------------- %
%         
%         function testDenoise(self)
%             
%             % Setup some directory names
%             dirOutput = fullfile(utils.CHIPS_rootdir, 'tests', 'output');
%             dirDenoise = fullfile(dirOutput, {'BM3D', 'invansc'});
%             
%             % Check the warning
%             self.verifyWarning(@() utils.install_denoise(dirOutput), ...
%                 'InstallDenoise:Licence');
%             
%             % Check the directory is created
%             hasDirs = all(cellfun(@isdir, dirDenoise));
%             self.verifyTrue(hasDirs, ...
%                 'install_denoise does not create the expected dirs')
%             
%             % Delete the temporary directories
%             cellfun(@(xx) rmdir(xx, 's'), dirDenoise)
%             
%         end
%         
%         % -------------------------------------------------------------- %
%         
%         function testEgImgs(self)
%             
%             % Setup some directory names
%             dirOutput = fullfile(utils.CHIPS_rootdir, 'tests', 'output');
%             dirEgImgs = fullfile(dirOutput, 'res');
%             
%             % Download the example images
%             utils.download_example_imgs(dirEgImgs);
%             
%             % Check the directory is created
%             self.verifyTrue(isdir(dirEgImgs), ...
%                 'download_example_imgs does not create the expected dirs')
%             
%             % Delete the temporary directories
%             rmdir(dirEgImgs, 's');
%             
%         end
        
    end
    
    % ================================================================== %
    
end
