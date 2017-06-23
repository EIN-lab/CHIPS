classdef Test_ArbLineScan < matlab.unittest.TestCase
    %TEST_ARBLINESCAN Summary of this class goes here
    %   Detailed explanation goes here
    
    % ================================================================== %
    
    properties
    end

    % ================================================================== %
    
    methods (Test)
        
        function testConstructor(self)
            
            % Variables to establish
            name = 'Test Name 1';
            rawImg = copy(Test_SCIM_Tif.LineScanVelSCIMObj);
            masks1 = {{true(size(rawImg.rawdata(:,:,1,1)))}};
            strClass = 'LineScanDiam';
            
            % Create the objects
            ArbLineScanObj2 = ArbLineScan(name, rawImg, strClass, masks1);
            
            % Run the verifications
            self.verifyEqual(ArbLineScanObj2.name, name, ['ArbLineScan ' ...
                'constructor failed to set name correctly'])
            self.verifyEqual(ArbLineScanObj2.rawImg, rawImg, ...
                'ArbLineScan constructor failed to set name correctly')
            self.verifyEqual(ArbLineScanObj2.imgTypes, {strClass}, ...
                ['ArbLineScan constructor failed to set imgTypes ' ...
                'correctly'])
            self.verifyEqual(ArbLineScanObj2.masks, masks1, ...
                'ArbLineScan constructor failed to set masks correctly')
            
        end
        
        % -------------------------------------------------------------- %
        
        function testArray(self)
            
            % Variables to establish
            name = 'Test Name 1';
            rawImg = copy(Test_SCIM_Tif.LineScanVelSCIMObj);
            masks1 = {{true(size(rawImg.rawdata(:,:,1,1)))}};
            strClass = 'LineScanDiam';
            nReps = 3;
            nRepsSize = [1, nReps];
            rawImgArray(1:nReps) =  rawImg;
            
            % Create the objects
            ArbLineScanObj3 = ArbLineScan(name, rawImgArray, ...
                strClass, masks1);
            
            % Run the verifications
            self.verifySize(ArbLineScanObj3, nRepsSize);
            
        end
        
        % -------------------------------------------------------------- %
        
        function testSaveLoad(self)
            
            % Create the object
            ALSObj = copy(Test_ArbLineScan.ArbLineScanObj);
            
            % Prepare the function handles
            fnSaveLoad = [ALSObj.name '.mat'];
            fSave = @(ALSObj) save(fnSaveLoad, 'ALSObj');
            fLoad = @() load(fnSaveLoad, 'ALSObj');
            
            % Run the verifications
            self.verifyWarningFree(@() fSave(ALSObj));
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
        
        function tArray = select_arblinescan(varargin)
            
            % Parse optional arguments
            defFN = Test_SCIM_Tif.fnSCIMLineScanVel;
            [startTime, fileNameStart] = utils.parse_opt_args({0, defFN}, ...
                varargin);
            
            % Select the image format
            tObj1 = Test_ProcessedImg.select_rawimg_format(startTime);
            
            % Select the raw image
            tArrayRawImg = Test_SCIM_Tif.select_scim_tif(tObj1.StartDelay, ...
                fileNameStart);
            
            % Select the ProcessedImg classes
            tArrayProcessedImg = ...
                Test_CompositeImg.select_processedimg_classes(...
                tArrayRawImg(end).StartDelay);
            
            % Select the masks
            tArrayMasks = Test_ArbLineScan.select_masks(...
                tArrayProcessedImg(end).StartDelay);
            
            % Create the array of timer objects
            tArray = [tObj1, tArrayRawImg, tArrayProcessedImg, ...
                tArrayMasks];
            
        end
        
        % -------------------------------------------------------------- %
        
        function tArray = select_masks(varargin)
            
            % Parse optional arguments
            startTime = utils.parse_opt_args({0}, varargin);
            tDelay = 1;
            
            % Press enter for the information popup
            tObj1 = timer();
            tObj1.StartDelay = startTime + tDelay;
            tObj1.TimerFcn = @(~, ~) inputemu('key_normal', '\ENTER');
            
            % Select one mask for the first imgType
            tArray1 = Test_StreakScan.select_pointsToUseVel(...
                tObj1.StartDelay + 2*tDelay);
            
            % Close the figure
            tObj2 = timer();
            tObj2.StartDelay = tArray1(end).StartDelay + 3*tDelay;
            tObj2.TimerFcn = @(~, ~) Test_ArbLineScan.press_altf4();
            
            % Accept the dark streaks
            tObj3 = timer();
            tObj3.StartDelay = tObj2.StartDelay + 3*tDelay;
            tObj3.TimerFcn = @(~, ~) inputemu('key_normal', '\ENTER');
            
            % Accept the velocity calc
            tObj4 = timer();
            tObj4.StartDelay = tObj3.StartDelay + 3*tDelay;
            tObj4.TimerFcn = @(~, ~) inputemu('key_normal', '\ENTER');
            
            % Press enter for the information popup
            tObj5 = timer();
            tObj5.StartDelay = tObj4.StartDelay + 2*tDelay;
            tObj5.TimerFcn = @(~, ~) inputemu('key_normal', '\ENTER');
            
            % Select one mask for the second imgType
            tArray2 = Test_StreakScan.select_pointsToUseVel(...
                tObj5.StartDelay + 2*tDelay);
            
            % Close the figure
            tObj6 = timer();
            tObj6.StartDelay = tArray2(end).StartDelay + 3*tDelay;
            tObj6.TimerFcn = @(~, ~) Test_ArbLineScan.press_altf4();
            
            % Accept the channel
            tObj7 = timer();
            tObj7.StartDelay = tObj6.StartDelay + 3*tDelay;
            tObj7.TimerFcn = @(~, ~) inputemu('key_normal', '\ENTER');
            
            % Create the array of timer objects
            tArray = [tObj1, tArray1, tObj2, tObj3, tObj4, tObj5, ...
                tArray2, tObj6, tObj7];
            
        end
        
        % -------------------------------------------------------------- %
        
        function press_altf4()
            
            if ~isempty(findall(0, 'Type', 'Figure'))
                close(gcf)
            end
            
        end
        
        % -------------------------------------------------------------- %
        
        function obj = ArbLineScanObj()
            
            persistent objTemp
            if isempty(objTemp)
                rawImg = copy(Test_SCIM_Tif.LineScanVelSCIMObj);
                maskIn = {{true(size(rawImg.rawdata(:,:,1,1)))}};
                objTemp = ArbLineScan('test_arblinescan', rawImg, ...
                    'LineScanDiam', maskIn);
            end
            obj = objTemp;
        
        end
        
    end
    
    % ================================================================== %
    
end