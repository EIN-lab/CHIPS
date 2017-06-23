classdef Test_ProcessedImg < matlab.unittest.TestCase
    % TEST_PROCESSEDIMG Summary of this class goes here
    %   Detailed explanation goes here
    
    % ================================================================== %
    
    properties (Constant)
        name = 'test_name';
    end

    % ================================================================== %
    
    methods (Test)
        
        function testConstructor(self)
            
            % Create the object
            Mock_ProcessedImgObj1 = Mock_ProcessedImg(...
                Test_ProcessedImg.name, Test_SCIM_Tif.LineScanVelSCIMObj);
            
            % Run the verifications
            self.verifyEqual(Mock_ProcessedImgObj1.name, ...
                Test_ProcessedImg.name, ['ProcessedImg constructor ' ...
                'failed to set name correctly.']);
            self.verifyEqual(Mock_ProcessedImgObj1.rawImg, ...
                Test_SCIM_Tif.LineScanVelSCIMObj, ['ProcessedImg ' ...
                'constructor failed to set rawImg correctly.']);
            
        end
        
        % -------------------------------------------------------------- %
        
        function testBadName(self)
            
            % Variables to establish
            nonStrName = [0 1];
            RawImgObj = Mock_RawImg(Test_SCIM_Tif.fnSCIMLineScanVel);
            
            % Run the verification
            self.verifyError(@() Mock_ProcessedImg(nonStrName, ...
                RawImgObj), 'Utils:Checks:IsClass', ['ProcessedImg ' ...
                'set.name allows non character arrays to be set as name.']);
            
        end
        
        % -------------------------------------------------------------- %
        
        function testBadRawImg(self)
            
            % Variables to establish
            nonRawImg = [0 1];
            
            % Run the verifications
            self.verifyError(@() Mock_ProcessedImg(Test_ProcessedImg.name, ...
                nonRawImg), 'Utils:Checks:IsClass', ['ProcessedImg ' ...
                'allows rawImg to be the wrong class.']);
            
        end
        
    end
    
    % ================================================================== %
    
    methods (Static)
        
        function check_output_data(vrfy, objIn, fnIn, dirCheck)
            
            % Write output
            outPath = fullfile(utils.CHIPS_rootdir, 'tests', ...
                'output', fnIn);
            wngState = warning('off', 'Data:OutputData:NoOutput');
            fnOut = objIn.output_data(outPath, 'overwrite', 1);
            warning(wngState);
            
            % Return if there's no output
            if isempty(fnOut)
                return
            end
            
            % Check if we should compare the data
            isR2013a = strcmp(version('-release'), '2013a');
            if ~isR2013a
                dirTable = 'current';
            else
                dirTable = 'R2013a';
            end
            
            % Create paths for saved files
            if iscell(fnOut)
                [~, fnCheck, extCheck] = cellfun(@fileparts, ...
                    fnOut, 'UniformOutput', 0);
            else
                [~, fnCheck, extCheck] = fileparts(fnOut);
            end
            pathOut = strcat(fnCheck, extCheck);
            checkPath = fullfile(utils.CHIPS_rootdir, 'tests', ...
                'output', dirTable, dirCheck, pathOut);
            
            % Check that files are identical
            Test_ProcessedImg.verifyEqualFile(vrfy, fnOut, checkPath, ...
                'The output files appear to have changed.')
            
            % Delete files
            wngState = warning('off', 'MATLAB:DELETE:FileNotFound');
            if iscell(fnOut)
                delete(fnOut{:});
            else
                delete(fnOut);
            end
            warning(wngState)
            
        end
        
        % -------------------------------------------------------------- %
        
        function verifyEqualFile(vrfy, pathAct, pathExp, varargin)
            
            % Put the path inside a cell array, if necessary
            if ischar(pathAct)
                pathAct = {pathAct};
            end
            if ischar(pathExp)
                pathExp = {pathExp};
            end
            
            % Check we have the same number of paths
            vrfy.verifyEqual(size(pathAct), size(pathExp), varargin{:})
            
            % Call the function recursively if we have multiple paths
            nPaths = numel(pathExp);
            if nPaths > 1
                for iPath = 1:nPaths
                    hasNoFile = isempty(pathAct{iPath});
                    if hasNoFile
                        return
                    end
                    Test_ProcessedImg.verifyEqualFile(vrfy, ...
                        pathAct{iPath}, pathExp{iPath}, varargin{:})
                end
                return
            end
            
            % Don't bother with the comparison if there's no file
            hasNoFile = isempty(pathAct{1});
            if hasNoFile
                return
            end
            
            % Read the files contents
            fidAct = fopen(pathAct{1}, 'r');
            fidExp = fopen(pathExp{1}, 'r');

            linesAct = textscan(fidAct,'%s','delimiter','\n');
            linesExp = textscan(fidExp,'%s','delimiter','\n');
            linesAct = linesAct{1};
            linesExp = linesExp{1};
            fclose(fidAct);
            fclose(fidExp);
            
            % Check that everything's the same
            vrfy.verifyEqual(linesAct, linesExp, varargin{:})
            
        end
        
        % -------------------------------------------------------------- %
        
        function test_optconfig(vrfy, objPI)
            
            % Test that the opt_config works
            hFig = objPI.opt_config();
            vrfy.verifyTrue(ishghandle(hFig), ...
                'opt_config does not produce a figure.')
            close(hFig)
            
        end
        
        % -------------------------------------------------------------- %
        
        function test_plotList(vrfy, objPI)

            % Test all the plotNames
            plotList = objPI.plotList;
            calcs = fieldnames(plotList);
            for iCalc = 1:numel(calcs)
                iCalcName = calcs{iCalc};
                plots = plotList.(iCalcName);
                for jPlot = 1:numel(plots)
                    jPlotName = plots{jPlot};
                    hFig = objPI.plot(jPlotName);
                    isOK = isempty(hFig) || ishghandle(hFig);
                    vrfy.verifyTrue(isOK);
                    close(hFig)
                end
            end

        end
        
        % -------------------------------------------------------------- %
        
        function tArray = select_processedimg(varargin)
            
            % Parse optional arguments
            defFN = Test_SCIM_Tif.fnSCIMLineScanVel;
            defChannels = 1;
            [startTime, fileNameStart, channels] = utils.parse_opt_args(...
                {0, defFN, defChannels}, varargin);
            
            % Select the image format
            tObj1 = Test_ProcessedImg.select_rawimg_format(startTime);
            
            % Select the raw image
            tArrayRawImg = Test_SCIM_Tif.select_scim_tif(...
                tObj1.StartDelay, fileNameStart, channels);
            
            % Give the image a name
            tObj4 = Test_ProcessedImg.select_name(...
                tArrayRawImg(end).StartDelay);
            
            % Create the array of timer objects
            tArray = [tObj1 tArrayRawImg tObj4];
            
        end
        
        % -------------------------------------------------------------- %
        
        function tObj = select_rawimg_format(varargin)
            
            % Parse optional arguments
            startTime = utils.parse_opt_args({0}, varargin);
            
            % Establish a timer that waits for the input
            tObj = timer();
            tObj.StartDelay = startTime + 2.5;
            tObj.TimerFcn = @(~, ~) inputemu('key_normal', '2\ENTER');
            
        end
        
        % -------------------------------------------------------------- %
        
        function tObj = select_name(varargin)
            
            % Parse optional arguments
            startTime = utils.parse_opt_args({0}, varargin);
            
            % Establish a dummy timer
            tObj = timer();
            tObj.StartDelay = startTime + 2;
            tObj.TimerFcn = @utils.NOP;

        end
        
        % -------------------------------------------------------------- %
        
        function obj = MockPIObj()
            
            persistent objTemp
            if isempty(objTemp)
                objTemp = Mock_ProcessedImg('', ...
                    Test_SCIM_Tif.LineScanVelSCIMObj);
            end
            obj = objTemp;
        
        end
        
    end
    
    % ================================================================== %
    
end