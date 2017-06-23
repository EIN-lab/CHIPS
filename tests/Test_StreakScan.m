classdef Test_StreakScan < matlab.unittest.TestCase
    % TEST_STREAKSCAN Summary of this class goes here
    %   Detailed explanation goes here
    
    % ================================================================== %
    
    properties (Constant)
        colsVelIn = [1 128];
    end

    % ================================================================== %
    
    methods (Test)
        
        function testConstructor(self)
            
            % Variables to establish
            name = 'test_name';
            isDarkStreaks = true;
            configVelocity = ConfigVelocityRadon();
            
            % Construct the object
            Mock_StreakScanObj2 = Mock_StreakScan(name, ...
                Test_SCIM_Tif.LineScanVelSCIMObj, configVelocity, ...
                isDarkStreaks, Test_StreakScan.colsVelIn);
            
            % Run the verifications
            self.verifyEqual(Mock_StreakScanObj2.name, name, ...
                'StreakScan constructor failed to set name correctly.');
            self.verifyEqual(Mock_StreakScanObj2.rawImg, ...
                Test_SCIM_Tif.LineScanVelSCIMObj, ['StreakScan ' ...
                'constructor failed to set rawImg correctly.']);
            % test parent
            self.verifyEqual(Mock_StreakScanObj2.isDarkStreaks, ...
                isDarkStreaks, ['StreakScan constructor failed to set ' ...
                'isDarkStreaks correctly.']);
            self.verifyEqual(Mock_StreakScanObj2.colsToUseVel, ...
                Test_StreakScan.colsVelIn, ['StreakScan constructor ' ...
                'failed to set colsToUseVel correctly.']);
            self.verifyEqual(Mock_StreakScanObj2.calcVelocity.config, ...
                configVelocity, ['StreakScan constructor ' ...
                'failed to set configVelocity correctly.']);
            
        end
        
        % -------------------------------------------------------------- %
        
        function testArray(self)
            
            % Variables to establish
            name = 'test_name';
            isDS = true;
            configVelocity = ConfigVelocityRadon();
            nReps = 3;
            nRepsSize = [1, nReps];
            rawImgArray(1:nReps) = copy(Test_SCIM_Tif.LineScanVelSCIMObj);
            
            % Construct the object
            Mock_StreakScanObj2 = Mock_StreakScan(name, rawImgArray, ...
                configVelocity, isDS, Test_StreakScan.colsVelIn);
            
            % Run the verifications
            self.verifySize(Mock_StreakScanObj2, nRepsSize);
            
        end

        % -------------------------------------------------------------- %
        
        function testBadDarkStreaks(self)
            
            % Variables to establish
            name = 'test_name';
            nonBoolDrkStrks = struct('field', 'I am so strung up');
            nonScalarDrkStrks = [true false true true];
            configVelocity = ConfigVelocityRadon();
            
            % Run the verifications
            self.verifyError(@() Mock_StreakScan(name, ...
                Test_SCIM_Tif.LineScanVelSCIMObj, configVelocity, ...
                nonBoolDrkStrks), 'Utils:Checks:LogicalAble', ...
                ['StreakScan set.isDarkStreaks allows non boolean ' ...
                'values to be set as isDarkStreaks.']);
            self.verifyError(@() Mock_StreakScan(name, ...
                Test_SCIM_Tif.LineScanVelSCIMObj, configVelocity, ...
                nonScalarDrkStrks), 'Utils:Checks:Scalar', ...
                ['StreakScan set.isDarkStreaks allows non-scalar ' ...
                'booleans to be set as isDarkStreaks.']);
            
        end
        
        % -------------------------------------------------------------- %
        
        function testBadColsToUseVel(self)
            
            % Variables to establish
            name = 'test_name';
            isDarkStreaks = true;
            configVelocity = ConfigVelocityRadon();
            
            nonNumericCols = 'I am so strung up';
            imagCols = [1 + 3i, 2 + 4i];
            nonIntCols = [2.8 99.3];
            longCols = [1 2 3 4];
            smallCols = [-5 128];
            bigCols = [1 500];
            equalCols = [50 50];
            nonIncreasingCols = [128 1];
            
            % Run the verifications
            self.verifyError(@() Mock_StreakScan(name, ...
                Test_SCIM_Tif.LineScanVelSCIMObj, configVelocity, ...
                isDarkStreaks, nonNumericCols), ...
                'CheckCropVals:NonRealColsToUseVel', ['StreakScan ' ...
                'set.colsToUseVel allows non-numeric values.']);
            self.verifyError(@() Mock_StreakScan(name, ...
                Test_SCIM_Tif.LineScanVelSCIMObj, configVelocity, ...
                isDarkStreaks, imagCols), ...
                'CheckCropVals:NonRealColsToUseVel', ['StreakScan ' ...
                'set.colsToUseVel allows imaginary values.']);
            self.verifyWarning(@() Mock_StreakScan(name, ...
                Test_SCIM_Tif.LineScanVelSCIMObj, configVelocity, ...
                isDarkStreaks, nonIntCols), ...
                'CheckCropVals:NonIntegerColsToUseVel', ['StreakScan ' ...
                'set.colsToUseVel does not warn about non-integer values'])
            self.verifyError(@() Mock_StreakScan(name, ...
                Test_SCIM_Tif.LineScanVelSCIMObj, configVelocity, ...
                isDarkStreaks, longCols), ...
                'CheckCropVals:BadLengthColsToUseVel', ['StreakScan ' ...
                'set.colsToUseVel allows imaginary values.']);
            self.verifyWarning(@() Mock_StreakScan(name, ...
                Test_SCIM_Tif.LineScanVelSCIMObj, configVelocity, ...
                isDarkStreaks, smallCols), ...
                'CheckCropVals:TooSmallColsToUseVel', ['StreakScan ' ...
                'set.colsToUseVel does not warn about small values'])
            self.verifyWarning(@() Mock_StreakScan(name, ...
                Test_SCIM_Tif.LineScanVelSCIMObj, configVelocity, ...
                isDarkStreaks, bigCols), ...
                'CheckCropVals:TooBigColsToUseVel',  ['StreakScan ' ...
                'set.colsToUseVel does not warn about big values'])
            self.verifyError(@() Mock_StreakScan(name, ...
                Test_SCIM_Tif.LineScanVelSCIMObj, configVelocity, ...
                isDarkStreaks, equalCols), ...
                'CheckCropVals:EqualColsToUseVel', ['StreakScan ' ...
                'set.colsToUseVel allows equal values.']);
            self.verifyWarning(@() Mock_StreakScan(name, ...
                Test_SCIM_Tif.LineScanVelSCIMObj, configVelocity, ...
                isDarkStreaks, nonIncreasingCols), ...
                'CheckCropVals:NonIncreasingColsToUseVel', ['StreakScan ' ...
                'set.colsToUseVel does not warn about non-increasing ' ...
                'values'])
            
        end
        
        % -------------------------------------------------------------- %
        
        function testBadConfig(self)
            
            % Variables to establish
            name = 'test_name';
            isDarkStreaks = true;
            configDiameter = ConfigDiameterTiRS();
            configVelocityArray = repmat(ConfigVelocityRadon(), [1, 3]);
            
            % Run the verifications
            self.verifyError(@() Mock_StreakScan(name, ...
                Test_SCIM_Tif.LineScanVelSCIMObj, configDiameter, ...
                isDarkStreaks, Test_StreakScan.colsVelIn), ...
                'Utils:Checks:IsClass', ['StreakScan set.calcVelocity ' ...
                'allows config objects of the wrong class.']);
            self.verifyError(@() Mock_StreakScan(name, ...
                Test_SCIM_Tif.LineScanVelSCIMObj, configVelocityArray, ...
                isDarkStreaks, Test_StreakScan.colsVelIn), ...
                'Utils:Checks:Scalar', ['StreakScan ' ...
                'set.calcVelocity allows config objects of the wrong ' ...
                'class.']);
            
        end
        
        % -------------------------------------------------------------- %
        
        function testChannelChoice(self)
            
            % Variables to establish
            name = 'test_name';
            channels1.blood_rbcs = 1;
            channels2.blood_plasma = 1;
            channels3.Ca_Neuron = 1;
            rawImg1 = SCIM_Tif(Test_SCIM_Tif.fnSCIMLineScanVel, ...
                channels1, Test_CalibrationPixelSize.CalObj);
            rawImg2 = SCIM_Tif(Test_SCIM_Tif.fnSCIMLineScanVel, ...
                channels2, Test_CalibrationPixelSize.CalObj);
            rawImg3 = SCIM_Tif(Test_SCIM_Tif.fnSCIMLineScanVel, ...
                channels3, Test_CalibrationPixelSize.CalObj);
            isDarkStreaksTrue = true;
            isDarkStreaksFalse = false;
            configVelocity = ConfigVelocityRadon();
            
            % Construct the objects
            testNoPlasma = LineScanVel(name, rawImg1, configVelocity, ...
                isDarkStreaksTrue, Test_StreakScan.colsVelIn);
            testNoRBCs = LineScanVel(name, rawImg2, configVelocity, ...
                isDarkStreaksFalse, Test_StreakScan.colsVelIn);
            testPlasma = LineScanVel(name, rawImg2, configVelocity, [], ...
                Test_StreakScan.colsVelIn);
            testRBCs = LineScanVel(name, rawImg1, configVelocity, [], ...
                Test_StreakScan.colsVelIn);
            
            % Run the verifications
            self.verifyEqual(testPlasma.isDarkStreaks, isDarkStreaksTrue, ...
                ['StreakScan choose_isDarkStreaks does not automatically ' ...
                'set isDarkStreaks when only the plasma channel is ' ...
                'present.'])
            self.verifyEqual(testRBCs.isDarkStreaks, isDarkStreaksFalse, ...
                ['StreakScan choose_isDarkStreaks does not automatically ' ...
                'set isDarkStreaks when only the plasma channel is ' ...
                'present.'])
            self.verifyError(@() Mock_StreakScan(name, rawImg3, ...
                configVelocity, [], Test_StreakScan.colsVelIn), ...
                'Metadata:CheckChannels:NoAnyChannels', ['There should ' ...
                'be an error when no streak channels are present.'])
            self.verifyError(@() testNoPlasma.process(), ...
                'StreakScan:GetStreakChannel:NoPlasma', ...
                ['get_channel_streak allows processing of dark streaks ' ...
                'without a plasma channel defined.'])
            self.verifyError(@() testNoRBCs.process(), ...
                'StreakScan:GetStreakChannel:NoRBCs', ...
                ['get_channel_streak allows processing of dark streaks ' ...
                'without a plasma channel defined.'])
            
        end
        
    end
    
    % ================================================================== %
    
    methods (Static)
        
        function tArrayOut = select_streakscan(varargin)
            
            % Parse optional arguments
            defFN = Test_SCIM_Tif.fnSCIMLineScanVel;
            [startTime, fileNameStart, calcVelType] = ...
                utils.parse_opt_args({2, defFN, 2}, varargin);
            
            % Select the ProcessedImg
            tArrayProcessedImg = Test_ProcessedImg.select_processedimg(...
                startTime, fileNameStart);
            
            % Select the type of velocity calculation
            tObj1 = Test_StreakScan.select_calcVelocity(...
                tArrayProcessedImg(end).StartDelay, calcVelType);
            
            % Create the array of timer objects
            tArrayOut = [tArrayProcessedImg, tObj1];
            
        end
        
        % -------------------------------------------------------------- %
        
        function tObj = select_isDarkStreaks(varargin)
            
            % Parse optional arguments
            startTime = utils.parse_opt_args({0}, varargin);
            
            % Select if the image is using dark streaks
            tObj = timer();
            tObj.StartDelay = startTime + 0.2;
            tObj.TimerFcn = @(~, ~) inputemu('key_normal', '\ENTER');
            
        end
        
        % -------------------------------------------------------------- %
        
        function tArray = select_pointsToUseVel(varargin)
            
            % Parse optional arguments
            [startTime, isLR] = utils.parse_opt_args({0, true}, varargin);
            
            % Click enter on the information
            tDelay = 1;
            tObj1 = timer();
            tObj1.StartDelay = startTime + tDelay;
            tObj1.TimerFcn = @(~, ~) Test_StreakScan.click_LRTB_fig(isLR);

            % Double click to select the ROI
            tDelayClick = 1;
            tObj2 = timer();
            tObj2.StartDelay = tObj1.StartDelay + tDelayClick;
            tObj2.TimerFcn = @(~, ~) Test_CompositeImg.select_roi();
            
            % Combine all the timers
            tArray = [tObj1, tObj2];
            
        end
        
        % -------------------------------------------------------------- %
        
        function click_LRTB_fig(isLR)
            
            % Get the figure position and 
            if ~isempty(findall(0, 'Type', 'Figure'))
                
                set(gcf, 'Units', 'pixels');
                figPos = get(gcf, 'position');
                
                [~, result] = system('hostname');
                screensize = get(0, 'screensize');
                doScale = strcmpi(strtrim(result), 'Matt-T440P') && ...
                    (screensize(3) == 1280);
                if doScale
                    scaleFactor = [1.5, 1, 1.5, 1];
                else
                    scaleFactor = ones(1, 4);
                end
                figPos = figPos.*scaleFactor;
                
            else
                return
            end
            
            % Apply both actions sequentially
            if isLR
                
                % Work out the LR click locations
                xLeft = figPos(1) + 0.4*figPos(3);
                xRight = figPos(1) + 0.6*figPos(3);
                yBoth = figPos(2) + 0.5*figPos(4);
                clickPos1 = [xLeft yBoth];
                clickPos2 = [xRight yBoth];
                
            else
                
                % Work out the TB click locations
                xBoth = figPos(1) + 0.5*figPos(3);
                yBottom = figPos(2) + 0.2*figPos(4);
                yTop = figPos(2) + 0.8*figPos(4);
                clickPos1 = [xBoth yBottom];
                clickPos2 = [xBoth yTop];
                
            end
            
            % Package the commands into a cell array
            cmds = {...
                'left_down', clickPos1; % Click down at first pos
                'left_up', clickPos2}'; % Release the left mouse button
            
            % Run the commands
            tInterval = 0.25;
            inputemu(cmds, tInterval)
            
        end
        
        % -------------------------------------------------------------- %
        
        function tObj = select_calcVelocity(varargin)
            
            % Parse optional arguments
            [startTime, calcVelType] = utils.parse_opt_args({0, 2}, ...
                varargin);
            
            % Select if the image is using dark streaks
            tObj = timer();
            tObj.StartDelay = startTime + 2;
            tObj.TimerFcn = @(~, ~) inputemu('key_normal', ...
                [num2str(calcVelType) '\ENTER']);
            
        end
        
        % -------------------------------------------------------------- %
        
        function obj = get_ssObj(classSS)

            persistent objTemp
            if isempty(objTemp)
                objTemp = struct(...
                    'FrameScan', copy(Test_FrameScan.FrameScanObj), ...
                    'LineScanVel', copy(Test_LineScanVel.LineScanVelObj));
            end
            obj = objTemp.(classSS);

        end
        
    end
    
    % ================================================================== %
    
end

