classdef Test_ImgGroup_ui < matlab.unittest.TestCase
        
    % ================================================================== %
    
    methods (TestMethodSetup)
        function clear_persistent(~)
            utils.clear_persistent();
        end
    end
    
    % ================================================================== %
    
    methods (Test, TestTags = {'interactive'})
        
        function testNoArgs(self)
            
            % Create a timer to interact with the name select prompt
            tObj1 = Test_ImgGroup.select_name();
            
            % Create the object
            start(tObj1)
            ImgGroupObj1 = ImgGroup();
            wait(tObj1)
            
            % Run the verifications
            self.verifyClass(ImgGroupObj1, 'ImgGroup');
            
        end
        
        % -------------------------------------------------------------- %
        
        function testAdd2(self)
            
            % Variables to establish
            testName = 'test-name';
            procImgType = 'LineScanDiam';
            rawImgArray(1:2) = copy(Test_SCIM_Tif.LineScanVelSCIMObj);
            rawImgArray = copy(rawImgArray);
            configLSD = ConfigDiameterFWHM('maxRate', 10);
            testLSD = copy(Test_LineScanDiam.LineScanDiamObj);
            
            % Test adding RawImgArray
            tArrayProcAndEdges = ...
                Test_ImgGroup.select_processable_and_edges();
            start(tArrayProcAndEdges)
            ImgGroup4_r = ImgGroup(testName, rawImgArray);
            wait(tArrayProcAndEdges)
            self.verifyEqual(ImgGroup4_r.children{2}.rawImg, rawImgArray(2))
            
            utils.clear_persistent();
            
            % Test adding RawImgArray and non-standard config
            start(tArrayProcAndEdges)
            ImgGroup4_rc = ImgGroup(testName, rawImgArray, configLSD);
            wait(tArrayProcAndEdges)
            self.verifyEqual(...
                ImgGroup4_rc.children{2}.calcDiameter.config, configLSD)
            
            utils.clear_persistent();
            
            % Test adding RawImgArray, non-standard config and procImgType
            tObjSelectEdges = Test_ImgGroup.select_linescandiam_x2(1);
            start(tObjSelectEdges)
            ImgGroup4_rcp = ImgGroup(testName, rawImgArray, configLSD, ...
                procImgType);
            wait(tObjSelectEdges)
            self.verifyClass(ImgGroup4_rcp.children{1}, procImgType)
            
            utils.clear_persistent();
            
            % Test adding non-standard config
            tArrayRIProcAndLSD = Test_ImgGroup.select_rawimg_proc_and_lsd();
            start(tArrayRIProcAndLSD)
            ImgGroup4_c = ImgGroup(testName, configLSD);
            wait(tArrayRIProcAndLSD)
            self.verifyEqual(...
                ImgGroup4_c.children{1}.calcDiameter.config, configLSD)
            
            utils.clear_persistent();
            
            % Test adding non-standard config and procImgType
            tArrayLSD = Test_ImgGroup.select_rawimg_and_lsd();
            start(tArrayLSD)
            ImgGroup4_cp = ImgGroup(testName, configLSD, procImgType);
            wait(tArrayLSD)
            self.verifyClass(ImgGroup4_cp.children{1}, procImgType)
            self.verifyEqual(...
                ImgGroup4_cp.children{1}.calcDiameter.config, configLSD)
            
            utils.clear_persistent();
            
            % Test adding non-standard config and procImgType via
            % from_files instead of the constructor directly
            start(tArrayLSD)
            ImgGroup4_cp_f = ImgGroup.from_files(testName, [], ...
                configLSD, procImgType);
            wait(tArrayLSD)
            self.verifyClass(ImgGroup4_cp_f.children{1}, procImgType)
            self.verifyEqual(...
                ImgGroup4_cp_f.children{1}.calcDiameter.config, configLSD)
            
            utils.clear_persistent();
            
            % Test adding procImgType
            start(tArrayLSD)
            ImgGroup4_p = ImgGroup(testName, procImgType);
            wait(tArrayLSD)
            self.verifyClass(ImgGroup4_p.children{1}, procImgType)
            
            utils.clear_persistent();
            
            % Test adding RawImgArray, non-standard config, procImgType and
            % other processed images
            tObjSelectEdges = Test_ImgGroup.select_linescandiam_x2();
            start(tObjSelectEdges)
            ImgGroup4_rcpe = ImgGroup(testName, rawImgArray, configLSD, ...
                procImgType, testLSD);
            wait(tObjSelectEdges)
            self.verifyEqual(ImgGroup4_rcpe.children{1}, testLSD)
            
        end
        
        % -------------------------------------------------------------- %
        
        function testAdd3(self)
            
            % Variables to establish
            testName = 'test-name';
            rawImgArray1(1:2) = copy(Test_SCIM_Tif.LineScanVelSCIMObj);
            rawImgArray1 = copy(rawImgArray1);
            rawImgArray2 = copy(Test_SCIM_Tif.FrameScanSCIMObj);
            configLSD = ConfigDiameterFWHM('maxRate', 10);
            configFS = ConfigFrameScan(...
                ConfigVelocityRadon('windowTime', 100));
            procImgType = {'LineScanDiam', 'FrameScan'};
            testLSD = Test_LineScanDiam.LineScanDiamObj;
            
            utils.clear_persistent();            
            
            tObjSelectStuff = Test_ImgGroup.select_cell_stuff();
            wngState = warning('off', ...
                'CheckCropVals:TooSmallRowsToUseVel');
            start(tObjSelectStuff)
            ImgGroupObj5 = ImgGroup(testName, ...
                {rawImgArray1, rawImgArray2}, {configLSD, configFS}, ...
                procImgType, testLSD);
            wait(tObjSelectStuff)
            warning(wngState)
            
            self.verifyEqual(ImgGroupObj5.children{1}, testLSD)
            self.verifyClass(ImgGroupObj5.children{2}, procImgType{1})
            self.verifyClass(ImgGroupObj5.children{4}, procImgType{2})
            self.verifyEqual(...
                ImgGroupObj5.children{3}.calcDiameter.config, configLSD)
            self.verifyEqual(...
                ImgGroupObj5.children{4}.calcVelocity.config, ...
                configFS.configVelocity)
            
        end
        
    end
    
    % ================================================================== %
    
end