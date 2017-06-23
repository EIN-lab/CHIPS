classdef Test_Metadata < matlab.unittest.TestCase
    % TEST_STREAKSCAN Summary of this class goes here
    %   Detailed explanation goes here
    
    % ================================================================== %
    
    properties  (Constant)
        imgSize = [513 512 2 10];
        acq = struct('lineTime', 1, 'zoom', 15, 'isBiDi', false);
        channelsR = struct('blood_plasma', 1);
        channelsRG = struct('blood_rbcs', 2, 'blood_plasma', 1);
        channelsGR = struct('blood_rbcs', 1, 'blood_plasma', 2);
        channelsAC = struct('Ca_Cyto_Astro', 1);
        channelsCY = struct();
        MetadataObj = Metadata(Test_Metadata.imgSize, ...
                Test_Metadata.acq, Test_Metadata.channelsRG, ...
                Test_CalibrationPixelSize.CalObj);
    end
    
    % ================================================================== %
    
    methods (Test)
        
        function testConstructor(self)
            
            % Run the constructor with the arguments
            MetadataObj2 = Metadata(Test_Metadata.imgSize, ...
                Test_Metadata.acq, Test_Metadata.channelsRG, ...
                Test_CalibrationPixelSize.CalObj);
            
            % Check all the arguments have been set correctly
            self.verifyEqual(MetadataObj2.nLinesPerFrame, self.imgSize(1), ...
                ['Metadata constructor method failed to correctly set ' ...
                'nLinesPerFrame.']);
            self.verifyEqual(MetadataObj2.nPixelsPerLine, self.imgSize(2), ...
                ['Metadata constructor method failed to correctly set ' ...
                'nPixelsPerLine.']);
            self.verifyEqual(MetadataObj2.nChannels, self.imgSize(3), ...
                ['Metadata constructor method failed to correctly set ' ...
                'nChannels.']);
            self.verifyEqual(MetadataObj2.nFrames, self.imgSize(4), ...
                ['Metadata constructor method failed to correctly set ' ...
                'nFrames.']);
            self.verifyEqual(MetadataObj2.lineTime, self.acq.lineTime, ...
                ['Metadata constructor method failed to correctly set ' ...
                'lineTime.']);
            self.verifyEqual(MetadataObj2.zoom, self.acq.zoom, ...
                ['Metadata constructor method failed to correctly set ' ...
                'zoom.']);
            self.verifyEqual(MetadataObj2.channels.blood_rbcs, ...
                self.channelsRG.blood_rbcs, ['Metadata constructor method ' ...
                'failed to correctly set rbcs channel.']);
            self.verifyEqual(MetadataObj2.channels.blood_plasma, ...
                self.channelsRG.blood_plasma, ['Metadata constructor method ' ...
                'failed to correctly set plasma channel.']);
            self.verifyEqual(MetadataObj2.calibration, ...
                Test_CalibrationPixelSize.CalObj, ['Metadata constructor ' ...
                'method failed to correctly set calibration.']);
            
        end
        
        % -------------------------------------------------------------- %
        
        function testBadSizes(self)
            
            % Variables to establish
            imgSizeScalar = 1;
            imgSizeLong = ones(3, 4);
            imgSizeNegative = [1024 -512 10 2];
            imgSizeReal = [256.5 256 10 2];
            imgSizeZero = [256 256 0 2];
            
            % Run the verifications
            self.verifyError(@()Metadata(imgSizeScalar, [], ...
                Test_Metadata.channelsRG, ...
                Test_CalibrationPixelSize.CalObj), ...
                'Metadata:SetSizes:BadNumberOfDims', ['Metadata ' ...
                'constructor allows scalar image sizes.']);
            self.verifyError(@()Metadata(imgSizeLong, [], ...
                Test_Metadata.channelsRG, ...
                Test_CalibrationPixelSize.CalObj), ...
                'Metadata:SetSizes:BadNumberOfDims', ['Metadata ' ...
                'constructor allows matrix image sizes.']);
            self.verifyError(@()Metadata(imgSizeNegative, [], ...
                Test_Metadata.channelsRG, ...
                Test_CalibrationPixelSize.CalObj), ...
                'Utils:Checks:Positive', ['Metadata constructor ' ...
                'allows negative image sizes.']);
            self.verifyError(@()Metadata(imgSizeReal, [], ...
                Test_Metadata.channelsRG, ...
                Test_CalibrationPixelSize.CalObj), ...
                'Utils:Checks:Integer', ['Metadata constructor ' ...
                'allows non-integer image sizes.']);
            self.verifyError(@()Metadata(imgSizeZero, [], ...
                Test_Metadata.channelsRG, ...
                Test_CalibrationPixelSize.CalObj), ...
                'Utils:Checks:Positive', ['Metadata constructor ' ...
                'allows image sizes to be 0.']);
            
        end
        
        % -------------------------------------------------------------- %
        
        function testBadAcq(self)
            
            % Variables to establish
            acq1 = self.acq;
            acq1.lineTime = -3;
            acq2 = self.acq;
            acq2.zoom = [10 10];
            acq3 = self.acq;
            acq3.isBidi = 'test';
            
            % Run the verifications
            self.verifyError(@() Metadata(self.imgSize, acq1, ...
                Test_Metadata.channelsRG, ...
                Test_CalibrationPixelSize.CalObj), ...
                'Utils:Checks:Positive', ['Metadata constructor ' ...
                'allows negative values for lineTime.']);
            self.verifyError(@() Metadata(self.imgSize, acq2, ...
                Test_Metadata.channelsRG, ...
                Test_CalibrationPixelSize.CalObj), ...
                'Utils:Checks:Scalar', ['Metadata constructor ' ...
                'allows non-scalar values for zoom.']);
            
        end
        
        % -------------------------------------------------------------- %
        
        function testBadChannels(self)
            
            % Variables to establish
            nonStruct = 'test';
            structArray = repmat(struct(), [2, 1]);
            badFieldName = self.channelsRG;
            badFieldName.notRealName = 1;
            badVal = self.channelsRG;
            badVal.blood_plasma = 'test';
            badChannel = self.channelsRG;
            badChannel.blood_plasma = 5;
            calObj = Test_CalibrationPixelSize.CalObj;
            
            % Run the verifications
            self.verifyError(@() Metadata(self.imgSize, self.acq, ...
                nonStruct, calObj), 'Utils:Checks:IsClass', ...
                ['Metadata constructor allows non-structures for ' ...
                'channelsIn.']);
            self.verifyError(@() Metadata(self.imgSize, self.acq, ...
                structArray, calObj), 'Utils:Checks:Scalar', ...
                ['Metadata constructor allows non-scalar structures for ' ...
                'channelsIn.']);
            self.verifyError(@() Metadata(self.imgSize, self.acq, ...
                badFieldName, calObj), ...
                'Metadata:SetChannels:UnknownChannel', ['Metadata ' ...
                'constructor allows unknown field names in channelsIn.']);
            self.verifyError(@() Metadata(self.imgSize, self.acq, ...
                badVal, calObj), 'Utils:Checks:Scalar', ...
                ['Metadata constructor allows channel numbers to be non ' ...
                'positive scalar integers.']);
            self.verifyError(@() Metadata(self.imgSize, self.acq, ...
                badChannel, calObj), 'Metadata:SetChannels:BadChannel', ...
                ['Metadata constructor allows setting properties for ' ...
                'non-existant channels']);
            
        end
        
        % -------------------------------------------------------------- %

        function testBadCalibration(self)
            
            % Variables to establish
            notCal = 1;
            nonScalarCal(1:3) = Test_CalibrationPixelSize.CalObj;
            
            % Run the verifications
            self.verifyError(@() Metadata(Test_Metadata.imgSize, ...
                Test_Metadata.acq, Test_Metadata.channelsRG, notCal), ...
                'Utils:Checks:IsClass', ['Metadata ' ...
                'constructor allows non-calibration objects for ' ...
                'the calibration.']);
            self.verifyError(@() Metadata(Test_Metadata.imgSize, ...
                Test_Metadata.acq, Test_Metadata.channelsRG, nonScalarCal), ...
                'Utils:Checks:Scalar', ['Metadata constructor allows ' ...
                'non-scalar calibration objects.']);
            
        end
        
    end
    
    % ================================================================== %
    
    methods (Static)
        
        function tArray = select_metadata(varargin)
            
            % Parse optional arguments
            [startTime] = utils.parse_opt_args({0}, varargin);
            
            % Select the acquisition properties
            tArray1 = Test_Metadata.select_acq(startTime);
            
            % Select the calibration
            tArray2 = Test_Metadata.select_calibration(...
                tArray1(end).StartDelay + 0.5);
            
            % Combine the timers
            tArray = [tArray1, tArray2];
            
        end
        
        % -------------------------------------------------------------- %
        
        function tArray = select_acq(varargin)
            
            % Parse optional arguments
            [startTime] = utils.parse_opt_args({0}, varargin);
            
            tDelay = 0.5;
            
            % Select the isBiDi
            tObj1 = timer();
            tObj1.StartDelay = startTime + tDelay;
            tObj1.TimerFcn = @(~, ~) inputemu('key_normal', '0\ENTER');
            
            % Select the lineTime
            tObj2 = timer();
            tObj2.StartDelay = tObj1.StartDelay + tDelay;
            tObj2.TimerFcn = @(~, ~) inputemu('key_normal', '1\ENTER');
            
            % Select the zoom
            tObj3 = timer();
            tObj3.StartDelay = tObj2.StartDelay + tDelay;
            tObj3.TimerFcn = @(~, ~) inputemu('key_normal', '1\ENTER');
            
            tArray = [tObj1, tObj2, tObj3];
            
        end
        
        % -------------------------------------------------------------- %
        
        function tObj = select_calibration(varargin)
            
            % Parse optional arguments
            defFN = Test_CalibrationPixelSize.fnCalObj;
            [startTime, fileNameStart] = utils.parse_opt_args({0, defFN}, ...
                varargin);
            
            % Establish a timer that waits for the dialog box to load
            tObj = Test_RawImg.select_file(startTime, fileNameStart);
            
        end
        
        % -------------------------------------------------------------- %
        
        function tArray = select_channels(varargin)
            
            % Parse optional arguments
            defChannels = 1;
            [startTime, channels] = utils.parse_opt_args(...
                {0, defChannels}, varargin);
            
            % Establish the timers that enter the channels
            % Select the first channel
            tObj1 = timer();
            tObj1.StartDelay = startTime + 1;
            tObj1.TimerFcn = @(~, ~) Test_Metadata.select_channels_ui(...
                sprintf('%d\\ENTER', channels(1)));
            
            % Select the second channel, if possible
            if length(channels) > 1
                tObj2 = timer();
                tObj2.StartDelay = tObj1.StartDelay + 0.5;
                hasNum = channels(2) > 0;
                if hasNum
                    cmd = sprintf('%d\\ENTER', channels(2));
                else
                    cmd = '\ENTER';
                end
                tObj2.TimerFcn = @(~, ~) ...
                    Test_Metadata.select_channels_ui(cmd);
            else
                tObj2 = [];
            end
            
            tArray = [tObj1 tObj2];
            
        end
        
        % -------------------------------------------------------------- %
        
        function select_channels_ui(inputKeys)
            
            inputemu('key_normal', inputKeys);
            commandwindow
            
        end
        
    end
    
    % ================================================================== %
    
end