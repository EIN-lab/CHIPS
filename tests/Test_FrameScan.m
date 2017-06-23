classdef Test_FrameScan < matlab.unittest.TestCase
    %TEST_FRAMESCAN Summary of this class goes here
    %   Detailed explanation goes here

    % ================================================================== %
    
    methods (Test)
        
        function testConstructor(self)
            
            % Variables to establish
            name = 'test_name';
            isDarkStreaks = true;
            colsVelIn = [16 116];
            rowsToUseVelIn = [27 93];
            colsToUseDiamIn = [17 117];
            configVelocity = ConfigVelocityRadon('thresholdSNR', 4);
            configDiameter = ConfigDiameterFWHM('maxRate', 30);
            configFrameScan = ConfigFrameScan(configVelocity, ...
                configDiameter);
            
            % Construct the object
            FrameScanObj2 = FrameScan(name, Test_SCIM_Tif.FrameScanSCIMObj, ...
                 configFrameScan, isDarkStreaks, colsVelIn, ...
                 rowsToUseVelIn, colsToUseDiamIn);
            
            % Run the verifications
            self.verifyEqual(FrameScanObj2.name, name, ...
                'FrameScan constructor failed to set name correctly.');
            self.verifyEqual(FrameScanObj2.rawImg, ...
                Test_SCIM_Tif.FrameScanSCIMObj, ['FrameScan constructor ' ...
                'failed to set rawImg correctly.']);
            % test parent
            self.verifyEqual(FrameScanObj2.isDarkStreaks, ...
                isDarkStreaks, ['FrameScan constructor failed to set ' ...
                'isDarkStreaks correctly.']);
            self.verifyEqual(FrameScanObj2.colsToUseVel, ...
                colsVelIn, ['FrameScan constructor failed to set ' ...
                'colsToUseVel correctly.']);
            self.verifyEqual(FrameScanObj2.rowsToUseVel, ...
                rowsToUseVelIn, ['FrameScan constructor failed to set ' ...
                'colsToUseVel correctly.']);
            self.verifyEqual(FrameScanObj2.calcVelocity.config, ...
                configVelocity, ['FrameScan constructor failed to set ' ...
                'calcVelocity correctly.']);
            self.verifyEqual(FrameScanObj2.colsToUseDiam, ...
                colsToUseDiamIn, ['FrameScan constructor failed to set ' ...
                'colsToUseVel correctly.']);
            self.verifyEqual(FrameScanObj2.calcDiameter.config, ...
                configDiameter, ['FrameScan constructor failed to set ' ...
                'calcDiameter correctly.']);
            
        end
        
        % -------------------------------------------------------------- %
        
        function testProcess(self)
            
            % Test that there are no errors 
            wngState = warning('off', 'GetWindow:ExtendWindow');
            warning('off', 'GetWindow:TooBigWindow')
            FrameScanObj3 = copy(Test_FrameScan.FrameScanObj);
            FrameScanObj3.process()
            
            % Test that the states are correctly assigned
            self.verifyEqual(FrameScanObj3.state, 'processed')
            self.verifyEqual(FrameScanObj3.calcVelocity.data.state, 'processed')
            self.verifyEqual(FrameScanObj3.calcDiameter.data.state, 'processed')
            
            % Test the plotting
            hFig1 = FrameScanObj3.plot();
            self.verifyTrue(ishghandle(hFig1), ['plot does not ' ...
                'produce a valid graphics object handle.'])
            close(hFig1)
            
            % Run the tests for plotList
            Test_ProcessedImg.test_plotList(self, FrameScanObj3);
            warning(wngState)
            
            % Test the output
            fnOutput = 'FrameScan.csv';
            dirCheck = 'FrameScan';
            Test_ProcessedImg.check_output_data(self, FrameScanObj3, ...
                fnOutput, dirCheck);
            
        end
        
        % -------------------------------------------------------------- %
        
        function testArray(self)
            
            % Variables to establish
            name = 'test_name';
            isDarkStreaks = true;
            colsVelIn = [16 116];
            rowsVelIn = [27 93];
            colsDiamIn = [17 117];
            configVelocity = ConfigVelocityRadon('windowTime', 40);
            configDiameter = ConfigDiameterFWHM();
            configFrameScan = ConfigFrameScan(configVelocity, ...
                configDiameter);
            nReps = 5;
            nRepsSize = [1, nReps];
            rawImgArray(1:nReps) = copy(Test_SCIM_Tif.FrameScanSCIMObj);
            
            % Construct the object and test the size
            FrameScanObj5 = FrameScan(name, rawImgArray, configFrameScan, ...
                isDarkStreaks, colsVelIn, rowsVelIn, colsDiamIn);
            self.verifySize(FrameScanObj5, nRepsSize);
            
            % Process the object
            wngState = warning('off', 'GetWindow:ExtendWindow');
            FrameScanObj5 = FrameScanObj5.process();
            warning(wngState)
            
            % Test that the states are correcty assigned
            self.verifyTrue(all(strcmp({FrameScanObj5.state}, ...
                'processed')))
            
            % Test the plotting
            hFig = FrameScanObj5.plot();
            self.verifyTrue(all(ishghandle(hFig)), ['plot does not ' ...
                'produce a valid graphics object handle.'])
            close(hFig)
            
        end
        
        % -------------------------------------------------------------- %
        
        function testGetConfig(self)
            
            % Variables to establish
            fsObj = copy(Test_FrameScan.FrameScanObj);
            
            % Get the config object
            conf = fsObj.get_config();
            
            % Test the class and the individual configs
            self.verifyClass(conf, 'ConfigFrameScan');
            self.verifyEqual(conf.configVelocity, ...
                fsObj.calcVelocity.config, ...
                'The ConfigVelocity must match')
            self.verifyEqual(conf.configDiameter, ...
                fsObj.calcDiameter.config, ...
                'The ConfigDiameter must match')
            
        end
        
        % -------------------------------------------------------------- %
        
        function testOptConfig(self)
            
            Test_ProcessedImg.test_optconfig(self, ...
                copy(Test_FrameScan.FrameScanObj))
            
        end
        
        % -------------------------------------------------------------- %
        
        function testSaveLoad(self)
            
            % Create the object
            FSObj = copy(Test_FrameScan.FrameScanObj);
            
            % Prepare the function handles
            fnSaveLoad = [FSObj.name '.mat'];
            fSave = @(FSObj) save(fnSaveLoad, 'FSObj');
            fLoad = @() load(fnSaveLoad, 'FSObj');
            
            % Run the verifications
            self.verifyWarningFree(@() fSave(FSObj));
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
        
        function tArray = select_framescan(varargin)
            
            % Parse optional arguments
            startTime = utils.parse_opt_args({0}, varargin);
            
            % Select the StreakScan
            fileName = Test_SCIM_Tif.fnSCIMFrameScan;
            tArrayLineScan = Test_LineScanVel.select_linescanvel(...
                startTime, fileName);
            
            % Select the FrameScan additional things (rowsToUseVel)
            isLR_rows = false;
            tArray1 = Test_StreakScan.select_pointsToUseVel(...
                tArrayLineScan(end).startDelay, isLR_rows);
            
            % Select the FrameScan additional things (colsToUseDiam)
            tArray2 = Test_StreakScan.select_pointsToUseVel(...
                tArray1(end).startDelay);
            
            % Create the array of timer objects
            tArray = [tArrayLineScan, tArray1, tArray2];
            
        end
        
        % -------------------------------------------------------------- %
        
        function obj = FrameScanObj()
            
            persistent objTemp
            if isempty(objTemp)
                objTemp = FrameScan('test_name', ...
                    copy(Test_SCIM_Tif.FrameScanSCIMObj), ...
                    ConfigFrameScan(ConfigVelocityRadon()), ...
                    true, [16 116], [27 93], [16 116]);
            end
            obj = objTemp;
        
        end
        
        
    end
    
    % ================================================================== %
    
end
