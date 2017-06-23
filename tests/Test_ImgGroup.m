classdef Test_ImgGroup < matlab.unittest.TestCase
    %TEST_IMGGROUP Summary of this class goes here
    %   Detailed explanation goes here
    
    % ================================================================== %
    
    properties
    end

    % ================================================================== %
    
    methods (Test)
        
        function testConstructor(self)
            
            % Variables to establish
            testName = 'test-name';
            
            % Create the object
            ImgGroupObj2 = ImgGroup(testName);
            
            % Run the verifications
            self.verifyEqual(ImgGroupObj2.name, testName, ['ImgGroup ' ... 
                'Constructor failed to correctly set name.']);
            
        end
        
        % -------------------------------------------------------------- %
        
        function testBadName(self)
            
            % Variables to establish
            twoLineChar = ['12' ; '34'];
            
            % Run the verification
            self.verifyError(@() ImgGroup(twoLineChar), ...
                'Utils:Checks:SingleRowChar', ['ImgGroup set.name ' ...
                'allows multi-line character arrays to be set as name.']);
            
        end
        
        % -------------------------------------------------------------- %
        
        function testBadChild(self)
            
            % Variables to establish
            testName = 'test-name';
            nonProcessedImg = [1 2];
            ImgGroupObj6 = ImgGroup(testName);
            
            % Setup a nested function to help test the assignment
            function testAssignment(ImgGroupObj, xx)
                ImgGroupObj.children = xx;
            end
            
            % Run the verification
            self.verifyWarning(@() ImgGroup(testName, nonProcessedImg), ...
                'ImgGroup:Add:UnknownChildType', ['ImgGroup add method ' ...
                'does not warn about bad image types.']);
            self.verifyError(...
                @() testAssignment(ImgGroupObj6, nonProcessedImg), ...
                'ImgGroup:Children:NotProcessable', ['ImgGroup ' ...
                'set.children allows non-ProcessedImgs to be set as ' ...
                'children.']);
            
        end
        
        % -------------------------------------------------------------- %
        
        function testAdd(self)
            
            % Variables to establish
            testName = 'test-name';
            testLSV = copy(Test_LineScanVel.LineScanVelObj);
            testLSD = copy(Test_LineScanDiam.LineScanDiamObj);
            testFS = copy(Test_FrameScan.FrameScanObj);
            
            % Test adding a single img via constructor
            ImgGroupObj3a = ImgGroup(testName, testLSV);
            self.verifyEqual(ImgGroupObj3a.children, {testLSV}, ['The ' ...
                'ImgGroup constructor did not add a processed image.'])
            
            % Test adding a single img via add
            ImgGroupObj3b = ImgGroup(testName);
            ImgGroupObj3b.add(testLSV);
            self.verifyEqual(ImgGroupObj3b.children, {testLSV}, ['The ' ...
                'ImgGroup add method did not add a processed image.'])
            
            % Test adding another img
            ImgGroupObj3b.add(testLSD);
            self.verifyEqual(ImgGroupObj3b.children, {testLSV, testLSD}, ...
                ['The ImgGroup add method did not add a processed image ' ...
                'when one already existed.'])
            
            % Test adding a cell
            ImgGroupObj3d = ImgGroup(testName, {testLSV, testLSD});
            self.verifyEqual(ImgGroupObj3d.children, {testLSV, testLSD}, ...
                ['The ImgGroup constructordid not add a cell of processed ' ...
                'images.'])
            
            % Test adding both
            ImgGroupObj3e = ImgGroup(testName, {testLSV, testLSD}, testFS);
            self.verifyEqual(ImgGroupObj3e.children, {testLSV, testLSD, ...
                testFS}, ['The ImgGroup constructor did not add a ' ...
                'processed image and a cell of processed images.'])
            
        end
        
        % -------------------------------------------------------------- %
        
        function testProcess(self)
            
            % Create the object and process it to test there's no errors
            ImgGroupObj7 = copy(Test_ImgGroup.ImgGroupObj);
            ImgGroupObj7.process
            
            % Test the data output
            fnData = 'test_IG7';
            ImgGroupObj7.output_data(fnData)
            fnDataFull = [fnData '*.csv'];
            dirStruct = dir(fnDataFull);
            doesExist = size(dirStruct, 1) == ImgGroupObj7.nChildren;
            self.verifyTrue(doesExist, ['output_data does not ' ...
                'correctly output the data.'])
            delete(fnDataFull)
            
        end
        
        % -------------------------------------------------------------- %
        
        function testArrayProcess(self)
            
            % Variables to establish
            nReps = 5;
            ImgGroupObj8(1:nReps) = copy(Test_ImgGroup.ImgGroupObj);
            ImgGroupObj8 = copy(ImgGroupObj8);
            
            % Run the verifications
            self.verifySize(ImgGroupObj8, [1, nReps]);
            ImgGroupObj8 = ImgGroupObj8.process();
            
            % Test that the states are correcty assigned
            self.verifyEqual({ImgGroupObj8.state}, ...
                repmat({'processed'}, [1, nReps]))
            for iObj = 1:length(ImgGroupObj8)
                for jChild = 1:ImgGroupObj8(iObj).nChildren
                    self.verifyEqual(...
                        ImgGroupObj8(iObj).children{jChild}.state, ...
                        'processed')
                end
            end
            
            % Test the plotting
            hFig = ImgGroupObj8.plot();
            hFig = [hFig{:}];
            self.verifyTrue(all(ishghandle(hFig)), ['plot does not ' ...
                'produce a valid graphics object handle.'])
            close(hFig)
            
        end
        
    end
    
    % ================================================================== %
    
    methods (Static)
        
        function tObj = select_name(varargin)
            
            % Parse optional arguments
            startTime = utils.parse_opt_args({0}, varargin);
            
            % Select the default image name
            tObj = timer();
            tObj.StartDelay = startTime + 0.2;
            tObj.TimerFcn = @(~, ~) inputemu('key_normal', '\ENTER');
            
        end
        
        % -------------------------------------------------------------- %
        
        function tArray = select_processable_and_edges(varargin)
            
            % Parse optional arguments
            startTime = utils.parse_opt_args({0}, varargin);
            
            tObj1 = Test_ImgGroup.select_processable(startTime);
            
            tArraySelLSDx2 = Test_ImgGroup.select_linescandiam_x2(...
                tObj1.StartDelay+1);
            
            tArray = [tObj1, tArraySelLSDx2];
            
        end
        
        % -------------------------------------------------------------- %
        
        function tArray = select_rawimg_proc_and_lsd(varargin)
            
            % Parse optional arguments
            startTime = utils.parse_opt_args({0}, varargin);
            
            tObj1 = Test_ImgGroup.select_processable(startTime);
            
            tObj2 = Test_ProcessedImg.select_rawimg_format(tObj1.StartDelay+1);
            
            tArrayLSD = Test_ImgGroup.select_linescandiam(...
                tObj2.StartDelay+1);
            
            tArray = [tObj1, tObj2, tArrayLSD];
            
        end
        
        % -------------------------------------------------------------- %
        
        function tArray = select_rawimg_and_lsd(varargin)
            
            % Parse optional arguments
            startTime = utils.parse_opt_args({0}, varargin);
            
            tObj1 = Test_ProcessedImg.select_rawimg_format(startTime);
            
            tArrayLSD = Test_ImgGroup.select_linescandiam(...
                tObj1.StartDelay+1);
            
            tArray = [tObj1, tArrayLSD];
            
        end
        
        % -------------------------------------------------------------- %
        
        function tArray = select_proc_and_lsd_x2(varargin)
            
            % Parse optional arguments
            startTime = utils.parse_opt_args({0}, varargin);
            
            tObj1 = Test_ImgGroup.select_processable(startTime);
            
            tArrayLSD = Test_ImgGroup.select_linescandiam_x2(...
                tObj1.StartDelay+1);
            
            tArray = [tObj1, tArrayLSD];
            
        end
        
        % -------------------------------------------------------------- %
        
        function tArray = select_cell_stuff(varargin)
            
            % Parse optional arguments
            startTime = utils.parse_opt_args({0}, varargin);
            
            tArrayLSD = Test_ImgGroup.select_linescandiam_x2(...
                startTime+1);
            
            tObj1 = Test_StreakScan.select_isDarkStreaks(...
                tArrayLSD(end).StartDelay + 1);
            
            tArrayVel1 = Test_StreakScan.select_pointsToUseVel(...
                tObj1.StartDelay + 0.5);
            
            % Select the FrameScan additional things (rowsToUseVel)
            isLR_rows = false;
            tArrayVel2 = Test_StreakScan.select_pointsToUseVel(...
                tArrayVel1(end).startDelay, isLR_rows);
            
            % Select the FrameScan additional things (colsToUseDiam)
            tArrayDiam = Test_StreakScan.select_pointsToUseVel(...
                tArrayVel2(end).startDelay);
            
            tArray = [tArrayLSD, tObj1, tArrayVel1, tArrayVel2, ...
                tArrayDiam];
            
        end
        
        % -------------------------------------------------------------- %
        
        function tObj = select_processable(varargin)
            
            % Parse optional arguments
            [startTime, imgNum] = utils.parse_opt_args({0, 6}, varargin);
            
            tObj = timer();
            tObj.StartDelay = startTime + 4;
            tObj.TimerFcn = @(~, ~) inputemu('key_normal', ...
                sprintf('%d\\ENTER', imgNum));
            
        end
        
        % -------------------------------------------------------------- %
        
        function tArray = select_linescandiam(varargin)
            
            % Parse optional arguments
            startTime = utils.parse_opt_args({0}, varargin);
            
            % Select the ProcessedImg
            fileName = Test_SCIM_Tif.fnSCIMLineScanDiam;
            channels = 1;
            
            % Select the raw image
            tArrayRawImg = Test_SCIM_Tif.select_scim_tif(startTime, ...
                fileName, channels);
            
            % Select the channel
            tObj2 = Test_ProcessedImg.select_rawimg_format(...
                tArrayRawImg(end).StartDelay);
            
            % Select the StreakScan additional things (colsToUseVel)
            tArrayColsDiam = Test_StreakScan.select_pointsToUseVel(...
                tObj2.StartDelay);
            
            % Create the array of timer objects
            tArray = [tArrayRawImg, tObj2, tArrayColsDiam];
            
        end
        
        % -------------------------------------------------------------- %
        
        function tArray = select_linescandiam_x2(varargin)
            
            % Parse optional arguments
            startTime = utils.parse_opt_args({0}, varargin);
            
            % Select the StreakScan additional things (colsToUseVel)
            tArrayColsDiam1 = Test_StreakScan.select_pointsToUseVel(...
                startTime);
            
            % Select the StreakScan additional things (colsToUseVel)
            tArrayColsDiam2 = Test_StreakScan.select_pointsToUseVel(...
                tArrayColsDiam1(end).StartDelay);
            
            % Create the array of timer objects
            tArray = [tArrayColsDiam1 tArrayColsDiam2];
            
        end
        
        % -------------------------------------------------------------- %
        
        function obj = ImgGroupObj()
            
            persistent objTemp
            if isempty(objTemp)
                testName = 'test-name';
                testLSV = copy(Test_LineScanVel.LineScanVelObj);
                testLSD = copy(Test_LineScanDiam.LineScanDiamObj);
                objTemp = ImgGroup(testName, testLSV, testLSD);
            end
            obj = objTemp;
        
        end
        
    end
    
    % ================================================================== %
    
end
