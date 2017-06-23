classdef Test_LineScanDiam < matlab.unittest.TestCase
    %TEST_LINESCAN Summary of this class goes here
    %   Detailed explanation goes here

    % ================================================================== %
    
    methods (Test)
        
        function testConstructor(self)
            
            % Variables to establish
            name = 'test_name';
            colsDiamIn = [1 128];
            configDiam = ConfigDiameterFWHM();
            chToUseIn = 1;
            
            % Construct the object
            LineScanDiamObj2 = LineScanDiam(name, ...
                Test_SCIM_Tif.LineScanDiamSCIMObj, configDiam, ...
                colsDiamIn, chToUseIn);
            
            % Run the verifications
            self.verifyEqual(LineScanDiamObj2.name, name, ...
                'LineScanDiam constructor failed to set name correctly.');
            self.verifyEqual(LineScanDiamObj2.rawImg, ...
                Test_SCIM_Tif.LineScanDiamSCIMObj, ['LineScanDiam ' ...
                'constructor failed to set rawImg correctly.']);
            self.verifyEqual(LineScanDiamObj2.calcDiameter.config, ...
                configDiam, ['LineScanDiam constructor ' ...
                'failed to set configDiameter correctly.']);
            self.verifyEqual(LineScanDiamObj2.colsToUseDiam, ...
                colsDiamIn, ['LineScan constructor failed to set ' ...
                'colsToUseDiam correctly.']);
            self.verifyEqual(LineScanDiamObj2.channelToUse, ...
                chToUseIn, ['LineScanDiam constructor ' ...
                'failed to set channelToUse correctly.']);
            
            
        end
        
        % -------------------------------------------------------------- %
        
        function testBadConfig(self)
            
            % Variables to establish
            name = 'test_name';
            colsDiamIn = [1 128];
            configDiameterWrong = ConfigDiameterTiRS();
            configDiamArray = repmat(ConfigDiameterFWHM(), [1, 3]);
            
            % Run the verifications
            self.verifyError(@() LineScanDiam(name, ...
                Test_SCIM_Tif.LineScanDiamSCIMObj, configDiameterWrong, ...
                colsDiamIn), 'Utils:Checks:IsClass', ...
                ['LineScanDiam set.calcDiameter allows config objects ' ...
                'of the wrong class.']);
            self.verifyError(@() LineScanDiam(name, ...
                Test_SCIM_Tif.LineScanDiamSCIMObj, configDiamArray, ...
                colsDiamIn), 'Utils:Checks:Scalar', ...
                ['LineScanDiam set.calcDiameter allows non-scalar ' ...
                'config objects.']);
            
        end
        
        % -------------------------------------------------------------- %
        
        function testProcess(self)
            
            % Test that there are no errors
            LineScanDiamObj3 = copy(Test_LineScanDiam.LineScanDiamObj);
            LineScanDiamObj3.process()
            
            % Test that the states are correcty assigned
            self.verifyEqual(LineScanDiamObj3.state, 'processed')
            self.verifyEqual(LineScanDiamObj3.calcDiameter.data.state, ...
                'processed')
            
            % Test the plotting
            hFig = LineScanDiamObj3.plot();
            self.verifyTrue(ishghandle(hFig), ['plot does not ' ...
                'produce a valid graphics object handle.'])
            close(hFig)
            
            % Run the tests for plotList
            Test_ProcessedImg.test_plotList(self, LineScanDiamObj3);
            
            % Test the output
            fnOutput = 'LineScanDiam.csv';
            dirCheck = 'LineScanDiam';
            Test_ProcessedImg.check_output_data(self, LineScanDiamObj3, ...
                fnOutput, dirCheck);
            
        end
        
        % -------------------------------------------------------------- %
        
        function testArrayProcess(self)
            
            % Variables to establish
            name = 'test_name';
            colsDiamIn = [1 128];
            configDiam = ConfigDiameterFWHM();
            nReps = 5;
            rawImgArray(1:nReps) = copy(Test_SCIM_Tif.LineScanDiamSCIMObj);
            chToUseIn = 1;
            
            % Construct the object
            LineScanDiamObj4 = LineScanDiam(name, rawImgArray, ...
                configDiam, colsDiamIn, chToUseIn);
            
            % Run the verifications
            self.verifySize(LineScanDiamObj4, [1, nReps]);
            LineScanDiamObj4 = LineScanDiamObj4.process();
            
            % Test that the states are correcty assigned
            self.verifyEqual({LineScanDiamObj4.state}, ...
                repmat({'processed'}, [1, nReps]))
            
            for iObj = 1:length(LineScanDiamObj4)
                self.verifyEqual(...
                    LineScanDiamObj4(iObj).calcDiameter.data.state, ...
                    'processed')
            end
            
            % Test the plotting
            hFig = LineScanDiamObj4.plot();
            self.verifyTrue(all(ishghandle(hFig)), ['plot does not ' ...
                'produce a valid graphics object handle.'])
            close(hFig)
            
        end
        
        % -------------------------------------------------------------- %
        
        function testOptConfig(self)
            
            Test_ProcessedImg.test_optconfig(self, ...
                copy(Test_LineScanDiam.LineScanDiamObj))
            
        end
        
        % -------------------------------------------------------------- %
        
        function testOutputDataWarning(self)
            
            % Variables to establish
            lsdObj = copy(Test_LineScanDiam.LineScanDiamObj);
            fnOutput = utils.GetFullPath.GetFullPath(fullfile('.', ...
                'testWarning.csv'));
            fOutput = @() lsdObj.output_data(fnOutput);
            
            % Run the verifications
            self.verifyWarning(fOutput, 'ProcessedImg:OutputData:NotDone')
            
            
        end
        % -------------------------------------------------------------- %
        
        function testSaveLoad(self)
            
            % Create the object
            LSDObj = copy(Test_LineScanDiam.LineScanDiamObj);
            
            % Prepare the function handles
            fnSaveLoad = [LSDObj.name '.mat'];
            fSave = @(LSDObj) save(fnSaveLoad, 'LSDObj');
            fLoad = @() load(fnSaveLoad, 'LSDObj');
            
            % Run the verifications
            self.verifyWarningFree(@() fSave(LSDObj));
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
        
        function tArray = select_linescandiam(varargin)
            
            % Parse optional arguments
            startTime = utils.parse_opt_args({0}, varargin);
            
            % Select the ProcessedImg
            fileName = Test_SCIM_Tif.fnSCIMLineScanDiam;
            tArrayProcessedImg = Test_ProcessedImg.select_processedimg(...
                startTime, fileName);
            
            % Select the channel to use
            tObj = Test_ProcessedImg.select_rawimg_format(...
                tArrayProcessedImg(end).StartDelay);
            
            % Select the StreakScan additional things (colsToUseVel)
            tArrayColsDiam = Test_StreakScan.select_pointsToUseVel(...
                tObj(end).StartDelay + 0.5);
            
            % Create the array of timer objects
            tArray = [tArrayProcessedImg, tObj, tArrayColsDiam];
            
        end
        
        % -------------------------------------------------------------- %
        
        function obj = LineScanDiamObj()
            
            persistent objTemp
            if isempty(objTemp)
                objTemp = LineScanDiam('test_linescandiam', ...
                    Test_SCIM_Tif.LineScanDiamSCIMObj, ...
                    ConfigDiameterFWHM(), [9 117], 1);
            end
            obj = objTemp;
        
        end
        
        
    end
    
    % ================================================================== %
    
end
