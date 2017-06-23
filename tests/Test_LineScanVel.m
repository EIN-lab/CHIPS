classdef Test_LineScanVel < matlab.unittest.TestCase
    %TEST_LINESCAN Summary of this class goes here
    %   Detailed explanation goes here


    % ================================================================== %
    
    methods (Test)
        
        function testConstructor(self)
            
            % Variables to establish
            name = 'test_name';
            isDarkStreaks = true;
            colsVelIn = [1 128];
            configVelocity = ConfigVelocityRadon();
            
            % Construct the object
            LineScanVelObj2 = LineScanVel(name, ...
                Test_SCIM_Tif.LineScanVelSCIMObj, configVelocity, ...
                isDarkStreaks, colsVelIn);
            
            % Run the verifications
            self.verifyEqual(LineScanVelObj2.name, name, ...
                'LineScan constructor failed to set name correctly.');
            self.verifyEqual(LineScanVelObj2.rawImg, ...
                Test_SCIM_Tif.LineScanVelSCIMObj, ['LineScan constructor ' ...
                'failed to set rawImg correctly.']);
            % test parent
            self.verifyEqual(LineScanVelObj2.isDarkStreaks, ...
                isDarkStreaks, ['LineScan constructor failed to set ' ...
                'isDarkStreaks correctly.']);
            self.verifyEqual(LineScanVelObj2.colsToUseVel, ...
                colsVelIn, ['LineScan constructor failed to set ' ...
                'colsToUseVel correctly.']);
            self.verifyEqual(LineScanVelObj2.calcVelocity.config, ...
                configVelocity, ['LineScan constructor ' ...
                'failed to set configVelocity correctly.']);
            
        end
        
        % -------------------------------------------------------------- %
        
        function testProcess(self)
            
            % Test that there are no errors
            LineScanVelObj3 = copy(Test_LineScanVel.LineScanVelObj);
            wngState = warning('off', 'Metadata:SetSizes:NonSquare');
            LineScanVelObj3.process()
            warning(wngState)
            
            % Test that the states are correcty assigned
            self.verifyEqual(LineScanVelObj3.state, 'processed')
            self.verifyEqual(LineScanVelObj3.calcVelocity.data.state, ...
                'processed')
            
            % Test the plotting
            hFig1 = LineScanVelObj3.plot();
            self.verifyTrue(ishghandle(hFig1), ['plot does not ' ...
                'produce a valid graphics object handle.'])
            close(hFig1)
            hFig2 = LineScanVelObj3.plot('windows');
            self.verifyTrue(ishghandle(hFig2), ['plot_windows does ' ...
                'not produce a valid graphics object handle.'])
            close(hFig2)
            
            % Run the tests for plotList
            Test_ProcessedImg.test_plotList(self, LineScanVelObj3);
            
            % Test the output
            fnOutput = 'LineScanVel.csv';
            dirCheck = 'LineScanVel';
            Test_ProcessedImg.check_output_data(self, LineScanVelObj3, ...
                fnOutput, dirCheck);
            
        end
        
        % -------------------------------------------------------------- %
        
        function testArray(self)
            
            % Variables to establish
            name = 'test_name';
            isDarkStreaks = true;
            colsVelIn = [1 128];
            configVelocity = ConfigVelocityRadon();
            nReps = 3;
            nRepsSize = [1, nReps];
            rawImgArray(1:nReps) = copy(Test_SCIM_Tif.LineScanVelSCIMObj);
            
            % Construct the object and test the size
            LineScanVelObj5 = LineScanVel(name, rawImgArray, ...
                configVelocity, isDarkStreaks, colsVelIn);
            self.verifySize(LineScanVelObj5, nRepsSize);
            
            % Process the object
            LineScanVelObj5 = LineScanVelObj5.process();
            
            % Test that the states are correcty assigned
            self.verifyTrue(all(strcmp({LineScanVelObj5.state}, ...
                'processed')))
            
            % Test the plotting
            hFig = LineScanVelObj5.plot();
            self.verifyTrue(all(ishghandle(hFig)), ['plot does not ' ...
                'produce a valid graphics object handle.'])
            close(hFig)
            
        end
        
        % -------------------------------------------------------------- %
        
        function testOptConfig(self)
            
            Test_ProcessedImg.test_optconfig(self, ...
                copy(Test_LineScanVel.LineScanVelObj))
            
        end
        
        % -------------------------------------------------------------- %
        
        function testSaveLoad(self)
            
            % Create the object
            LSVObj = copy(Test_LineScanVel.LineScanVelObj);
            
            % Prepare the function handles
            fnSaveLoad = [LSVObj.name '.mat'];
            fSave = @(LSVObj) save(fnSaveLoad, 'LSVObj');
            fLoad = @() load(fnSaveLoad, 'LSVObj');
            
            % Run the verifications
            self.verifyWarningFree(@() fSave(LSVObj));
            lastwarn('')
            str = fLoad();
            [lastMsg, ~] = lastwarn();
            self.verifyTrue(isempty(lastMsg))
            
            % Tidy up the variable
            delete(fnSaveLoad)
            
        end
        
    end
    
    % ================================================================== %
        
    methods (Static)
        
        function tArray = select_linescanvel(varargin)
            
            % Parse optional arguments
            defFN = Test_SCIM_Tif.fnSCIMLineScanVel;
            [startTime, fileNameStart, calcVelType] = ...
                utils.parse_opt_args({0, defFN, 2}, varargin);
            
            % Select the StreakScan
            tArrayStreakScan = Test_StreakScan.select_streakscan(...
                startTime, fileNameStart, calcVelType);
            
            % Select the LineScanVel additional things (colsToUseVel)
            tArray1 = Test_StreakScan.select_pointsToUseVel(...
                tArrayStreakScan(end).startDelay);
            
            % Create the array of timer objects
            tArray = [tArrayStreakScan, tArray1];
            
        end
        
        % -------------------------------------------------------------- %
        
        function obj = LineScanVelObj()
            
            persistent objTemp
            if isempty(objTemp)
                objTemp = LineScanVel('test_linescan', ...
                    copy(Test_SCIM_Tif.LineScanVelSCIMObj), ...
                    ConfigVelocityRadon(), true, [15 113]);
            end
            obj = objTemp;
        
        end
        
        
    end
    
    % ================================================================== %
    
end
