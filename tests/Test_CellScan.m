classdef Test_CellScan < matlab.unittest.TestCase
    %Test_CellScan Summary of this class goes here
    %   Detailed explanation goes here

    % ================================================================== %
    
    methods (Test)
        
        function testConstructor(self)
            
            % Variables to establish
            name = 'test_name';
            SCIM_Obj = copy(Test_SCIM_Tif.CellScanSCIMObj);
            configFLIKA = ConfigFindROIsFLIKA_2D();
            configMeasure = ConfigMeasureROIsDummy();
            configClsfy = ConfigDetectSigsClsfy();
            configCS = ConfigCellScan(configFLIKA, configMeasure, ...
                configClsfy);
            
            % Construct the object
            CellScanObj2 = CellScan(name, SCIM_Obj, configCS);
            
            % Run the verifications
            self.verifyEqual(CellScanObj2.name, name, ...
                'CellScan constructor failed to set name correctly.');
            self.verifyEqual(CellScanObj2.rawImg, SCIM_Obj, ...
                'CellScan constructor failed to set rawImg correctly.');
            self.verifyEqual(CellScanObj2.calcFindROIs.config, ...
                configFLIKA, ['CellScan constructor failed to set ' ...
                'configFLIKA correctly.']);
            self.verifyEqual(CellScanObj2.calcMeasureROIs.config, ...
                configMeasure, ['CellScan constructor failed to set ' ...
                'configMeasure correctly.']);
            self.verifyEqual(CellScanObj2.calcDetectSigs.config, ...
                configClsfy, ['CellScan constructor failed to set ' ...
                'configClsfy correctly.']);
            
        end
        
        % -------------------------------------------------------------- %
        
        function testBadConfig(self)
            
            % Variables to establish
            name = 'test_name';
            configFindWrong = ConfigFrameScan(ConfigVelocityRadon());
            configFindScalar = ConfigCellScan(ConfigFindROIsFLIKA_2D(), ...
                ConfigMeasureROIsDummy(), ConfigDetectSigsDummy());
            configFindArray(1:3) = configFindScalar;
            
            % Run the verifications
            self.verifyError(@() CellScan(name, ...
                Test_SCIM_Tif.CellScanSCIMObj, configFindWrong), ...
                'CellScan:WrongClassConfig', ['CellScan set.calcFindROIs ' ...
                'allows config objects of the wrong class.']);
            self.verifyError(@() CellScan(name, ...
                Test_SCIM_Tif.CellScanSCIMObj, configFindArray), ...
                'CellScan:NonScalarConfig', ['CellScan ' ...
                'set.calcFindROIs allows non-scalar config objects.']);
            
        end
        
        % -------------------------------------------------------------- %
        
        function testCombineMasks(self)
            
            % Setup a CellScan array
            nReps = 3;
            csArray(1:nReps) = copy(Test_CellScan.CellScanObj);
            csArray = copy(csArray);
            cfrf2d = ConfigFindROIsFLIKA_2D.from_preset('ca_cyto_astro');
            csArray(2).calcFindROIs = cfrf2d.create_calc();
            
            % Test the 'any' case
            csArray = csArray.process();
            csArray1 = csArray.combine_masks('any');
            csArray1 = csArray1.process();
            self.verifyClass([csArray1(:).calcFindROIs], ...
                'CalcFindROIsDummy')
            self.verifyTrue(all(csArray1(2).calcFindROIs.data.roiMask(:)))
            
            % Test the 'all' case
            csArray2 = csArray.combine_masks('all');
            csArray2 = csArray2.process();
            self.verifyClass([csArray2(:).calcFindROIs], ...
                'CalcFindROIsDummy')
            self.verifyEqual(csArray2(2).calcFindROIs.data.roiMask, ...
                csArray(2).calcFindROIs.data.roiMask)
            
        end
        
        % -------------------------------------------------------------- %
        
        function testProcess(self)
            
            % Variables to establish
            rawImg = copy(Test_SCIM_Tif.CellScanSCIMObj);
            configDDD = ConfigCellScan(ConfigFindROIsDummy, ...
                ConfigMeasureROIsDummy(), ConfigDetectSigsDummy());
            
            % Create the objects
            CellScanObj3a = CellScan('Dummy-Dummy', rawImg, configDDD);
            
            % Run processing steps
            CellScanObj3a.process()
            
            % Test that the states are correcty assigned
            self.verifyEqual(CellScanObj3a.state, 'processed')
            
            % Test the plotting
            hFig3a = CellScanObj3a.plot();
            self.verifyTrue(ishghandle(hFig3a), ['plot does ' ...
                'not produce a valid graphics object handle.'])
            close(hFig3a)

            % Run the tests for plotList
            wngState = warning('off', ...
                'CalcDetectSigsDummy:PlotSigs:NoClsfy');
            warning('off', 'CalcDetectSigsDummy:PlotClsfy:NoClsfy')
            warning('off', 'CalcFindROIs:PlotPCSpectrum:NoPCs')
            warning('off', 'CalcFindROIs:PlotICASigs:NoICAs')
            warning('off', 'CalcFindROIs:PlotPCFilters:NoPCs')
            Test_ProcessedImg.test_plotList(self, CellScanObj3a);
            warning(wngState)
            
            % Test the output
            fnOutput = 'CellScan.csv';
            dirCheck = 'CellScan';
            Test_ProcessedImg.check_output_data(self, CellScanObj3a, ...
                fnOutput, dirCheck);
            
        end
        
        % -------------------------------------------------------------- %
        
        function testProcessPartial(self)
            
            % Variables to establish
            rawImg = copy(Test_SCIM_Tif.CellScanSCIMObj);
            configDDD = ConfigCellScan(ConfigFindROIsDummy, ...
                ConfigMeasureROIsDummy(), ConfigDetectSigsDummy());
            
            % Run processing step-wise - find
            CellScanObj3j = CellScan('Dummy-Dummy', rawImg, configDDD);
            CellScanObj3j.process(false, 'calcFindROIs');
            self.verifyEqual(CellScanObj3j.state, 'partially processed')
            self.verifyEqual(CellScanObj3j.calcFindROIs.data.state, ...
                'processed')
            self.verifyEqual(CellScanObj3j.calcMeasureROIs.data.state, ...
                'unprocessed')
            self.verifyEqual(CellScanObj3j.calcDetectSigs.data.state, ...
                'unprocessed')
            
            % Run processing step-wise - measure
            CellScanObj3j.process(false, 'calcMeasureROIs');
            self.verifyEqual(CellScanObj3j.state, 'partially processed')
            self.verifyEqual(CellScanObj3j.calcMeasureROIs.data.state, ...
                'processed')
            self.verifyEqual(CellScanObj3j.calcDetectSigs.data.state, ...
                'unprocessed')
            
            % Run processing step-wise - detect
            CellScanObj3j.process(false, 'calcDetectSigs');
            self.verifyEqual(CellScanObj3j.state, 'processed')
            self.verifyEqual(CellScanObj3j.calcDetectSigs.data.state, ...
                'processed')
            
        end
        
        % -------------------------------------------------------------- %
        
        function testArrayProcess(self)
            
            % Test that there are no errors
            nReps = 5;
            CellScanObj4(1:nReps) = copy(Test_CellScan.CellScanObj);
            CellScanObj4 = CellScanObj4.process();
            
            % Test that the states are correcty assigned
            self.verifyEqual({CellScanObj4.state}, ...
                repmat({'processed'},[1,nReps]))
            
            for iObj = 1:length(CellScanObj4)
                self.verifyEqual(...
                    CellScanObj4(iObj).calcFindROIs.data.state, ...
                    'processed')
            end
            
            % Test the plotting
            wngState = warning('off', ...
                'CalcMeasureROIs:PlotTraces:TruncatingROIList');
            hFig = CellScanObj4.plot();
            self.verifyTrue(all(ishghandle(hFig)), ['plot does not ' ...
                'produce a valid graphics object handle.'])
            close(hFig)
            warning(wngState);
            
        end
        
        % -------------------------------------------------------------- %
        
        function testGetConfig(self)
            
            % Variables to establish
            csObj = copy(Test_CellScan.CellScanObj);
            
            % Get the config object
            conf = csObj.get_config();
            
            % Test the class and the individual configs
            self.verifyClass(conf, 'ConfigCellScan');
            self.verifyEqual(conf.configFindROIs, ...
                csObj.calcFindROIs.config, ...
                'The ConfigFindROIs must match')
            self.verifyEqual(conf.configMeasureROIs, ...
                csObj.calcMeasureROIs.config, ...
                'The ConfigMeasureROIs must match')
            self.verifyEqual(conf.configDetectSigs, ...
                csObj.calcDetectSigs.config, ...
                'The ConfigDetectSigs must match')
            
        end
        
        % -------------------------------------------------------------- %
        
        function testOptConfig(self)
            
            Test_ProcessedImg.test_optconfig(self, ...
                copy(Test_CellScan.CellScanObj))
            
        end
        
        % -------------------------------------------------------------- %
        
        function testSaveLoad(self)
            
            % Create the object
            CSObj = copy(Test_CellScan.CellScanObj);
            
            % Prepare the function handles
            fnSaveLoad = [CSObj.name '.mat'];
            fSave = @(CSObj) save(fnSaveLoad, 'CSObj');
            fLoad = @() load(fnSaveLoad, 'CSObj');
            
            % Run the verifications
            self.verifyWarningFree(@() fSave(CSObj));
            lastwarn('')
            str = fLoad(); %#ok<NASGU>
            [lastMsg, ~] = lastwarn();
            self.verifyTrue(isempty(lastMsg))
            
            % Tidy up the variable
            delete(fnSaveLoad)
            
        end
        
    end
    
    % ================================================================== %
    
    methods (Static)
        
        function tArrayOut = select_cellscan(varargin)
            
             % Parse optional arguments
            defFN = Test_SCIM_Tif.fnSCIMCellScan;
            [startTime, fileNameStart, calcFindROIs, calcMeasureROIs, ...
                calcDetectSigs] = utils.parse_opt_args(...
                {2, defFN, 4, 1, 1}, varargin);
            
            % Select the ProcessedImg
            chNum = 1;
            tArrayProcessedImg = Test_ProcessedImg.select_processedimg(...
                startTime, fileNameStart, chNum);
            
            % Select the type of roi finding calculation
            tObj1 = Test_CellScan.select_calcFindROIs(...
                tArrayProcessedImg(end).StartDelay, calcFindROIs);
            
            % Select the type of roi measuring calculation
            tObj2 = Test_CellScan.select_calcFindROIs(...
                tObj1(end).StartDelay+0.5, calcMeasureROIs);
            
            % Select the type of signal detection calculation
            tObj3 = Test_CellScan.select_calcFindROIs(...
                tObj2(end).StartDelay+0.5, calcDetectSigs);
            
            % Create the array of timer objects
            tArrayOut = [tArrayProcessedImg, tObj1, tObj2, tObj3];
            
        end
        
        % -------------------------------------------------------------- %
        
        function tObj = select_imgType(varargin)
            
            % Parse optional arguments
            startTime = utils.parse_opt_args({0}, varargin);
            
            % Select what's on the channel
            tObj = timer();
            tObj.StartDelay = startTime + 0.05;
            tObj.TimerFcn = @(~, ~) inputemu('key_normal', '5\ENTER');
            
        end
        
        % -------------------------------------------------------------- %
        
        function tObj = select_calcFindROIs(varargin)
            
            % Parse optional arguments
            [startTime, calcFindROIs] = utils.parse_opt_args({0, 4}, ...
                varargin);
            
            % Select if the image is using dark streaks
            tObj = timer();
            tObj.StartDelay = startTime + 0.05;
            tObj.TimerFcn = @(~, ~) inputemu('key_normal', ...
                [num2str(calcFindROIs), '\ENTER']);
            
        end
        
        % -------------------------------------------------------------- %
        
        function obj = CellScanObj()
            
            % Only create this the first time it's asked for
            persistent objTemp
            if isempty(objTemp)
                objTemp = CellScan('test_name', ...
                    copy(Test_SCIM_Tif.CellScanSCIMObj), ...
                    ConfigCellScan(ConfigFindROIsDummy(), ...
                    ConfigMeasureROIsDummy(),ConfigDetectSigsDummy()));
            end
            obj = objTemp;
            
        end
        
        % -------------------------------------------------------------- %
        
        function csObj_mc = get_csObj_MC()
            
            % Only do the motion correction the first time it's asked for
            persistent tempVar
            if isempty(tempVar)
                tempVar = copy(Test_CellScan.CellScanObj);
                tempVar.rawImg.motion_correct();
            end
            csObj_mc = tempVar;
            
        end
        
        % -------------------------------------------------------------- %
        
        function obj = imgSeq()
            
            % Only create this the first time it's asked for
            persistent objTemp
            if isempty(objTemp)
                csObj = Test_CellScan.CellScanObj;
                objTemp = squeeze(csObj.rawImg.rawdata(...
                    :,:,Test_CellScan.CellScanObj.channelToUse,:));
            end
            obj = objTemp;
            
        end
        
         % -------------------------------------------------------------- %
        
        function obj = frameRate()
            
            % Only create this the first time it's asked for
            persistent objTemp
            if isempty(objTemp)
                csObj = Test_CellScan.CellScanObj;
                objTemp = csObj.rawImg.metadata.frameRate;
            end
            obj = objTemp;
            
        end
        
        % -------------------------------------------------------------- %
        
        function obj = pixelSize()
            
            % Only create this the first time it's asked for
            persistent objTemp
            if isempty(objTemp)
                csObj = Test_CellScan.CellScanObj;
                objTemp = csObj.rawImg.metadata.pixelSize;
            end
            obj = objTemp;
            
        end
        
        % -------------------------------------------------------------- %
        
        function obj = refImg()
            
            % Only create this the first time it's asked for
            persistent objTemp
            if isempty(objTemp)
                csObj = Test_CellScan.CellScanObj;
                objTemp = csObj.get_refImg();
            end
            obj = objTemp;
            
        end
        
    end
        
    % ================================================================== %
    
end
