classdef Test_SCIM_Tif < matlab.unittest.TestCase
    %TEST_SCIM_TIF Summary of this class goes here
    %   Detailed explanation goes here
    
    properties (Constant)
        fnSCIMLineScanVel = 'linescanvel_scim.tif';
        fnSCIMFrameScan = 'framescan_scim.tif';
        fnSCIMLineScanDiam = 'linescandiam_scim.tif';
        fnSCIMXSectScan = 'xsectscan_scim.tif';
        fnSCIMCellScan = 'cellscan_scim.tif';
        fnSCIMFRET = 'xsectscan_scim.tif';
        skipImport = true;
    end
    
    % ================================================================== %
    
    methods (Test)
        
        function testConstructor(self)
            
            % Create the object
            SCIM2 = SCIM_Tif(Test_SCIM_Tif.fnSCIMLineScanVel, ...
                Test_Metadata.channelsR, ...
                Test_CalibrationPixelSize.CalObj);
            
            % Run the verifications
            self.verifyEqual(SCIM2.filename, ...
                Test_SCIM_Tif.fnSCIMLineScanVel, ['SCIM Constructor failed ' ...
                'to correctly set filename.']);
            self.verifyNotEmpty(SCIM2.name, ['SCIM Constructor failed ' ...
                'to set name.']);
            self.verifyNotEmpty(SCIM2.rawdata, ['SCIM constructor ' ...
                'method failed to set rawdata.']);
            self.verifyNotEmpty(SCIM2.metadata, ['SCIM constructor ' ...
                'method failed to set metadata.']);
            
        end
        
    end
    
    % ================================================================== %
    
    methods (Static)
        
        function SCIMobj = create_SCIM(varargin)
            
            wngState = warning('off', 'Metadata:SetSizes:NonSquare');
            SCIMobj = SCIM_Tif(varargin{:});
            warning(wngState)
            
        end
        
        % -------------------------------------------------------------- %
        
        function tArray = select_scim_tif(varargin)
            
            % Parse optional arguments
            defFN = Test_SCIM_Tif.fnSCIMLineScanVel;
            defChannels = 1;
            [startTime, fileNameStart, channels] = utils.parse_opt_args(...
                {0, defFN, defChannels}, varargin);
            
            % Create a timer to interact with the file select gui
            tObj1 = Test_RawImg.select_file(startTime, fileNameStart);
            
            tObj2 = Test_Metadata.select_calibration(...
                tObj1.StartDelay + 3);
            
            % Create a timer to enter the channel selection process
            tArray = Test_Metadata.select_channels(...
                tObj2.StartDelay + 2, channels);
            
            % Establish a timer that turns back on the warning
            wngState = warning('off', 'Metadata:SetSizes:NonSquare');
            tObjX = timer();
            tObjX.StartDelay = tArray(end).StartDelay;
            tObjX.TimerFcn = @(~, ~) warning(wngState);
            
            % Create the array of timer objects
            tArray = [tObj1, tObj2, tArray, tObjX];
            
        end
        
        % -------------------------------------------------------------- %
        
        function obj = CellScanSCIMObj()
            
            persistent objTemp
            if isempty(objTemp)
                scimTemp = Test_SCIM_Tif.create_SCIM(...
                    Test_SCIM_Tif.fnSCIMCellScan, ...
                    Test_Metadata.channelsAC, ...
                    Test_CalibrationPixelSize.CalObj);
                nFrames = size(scimTemp.rawdata, 4);
                nFramesUse = min([150, nFrames-1]);
                [objTemp, ~] = split1(scimTemp, 4, ...
                    [nFramesUse, nFrames - nFramesUse]);
            end
            obj = objTemp;
        
        end
        
        % -------------------------------------------------------------- %
        
        function obj = FrameScanSCIMObj()
            
            persistent objTemp
            if isempty(objTemp)
                objTemp = Test_SCIM_Tif.create_SCIM(...
                    Test_SCIM_Tif.fnSCIMFrameScan, ...
                    Test_Metadata.channelsR, ...
                    Test_CalibrationPixelSize.CalObj);
            end
            obj = objTemp;
        
        end
        
        % -------------------------------------------------------------- %
        
        function obj = LineScanDiamSCIMObj()
            
            persistent objTemp
            if isempty(objTemp)
                objTemp = Test_SCIM_Tif.create_SCIM(...
                    Test_SCIM_Tif.fnSCIMLineScanDiam, ...
                    Test_Metadata.channelsR, ...
                    Test_CalibrationPixelSize.CalObj);
            end
            obj = objTemp;
        
        end
        
        % -------------------------------------------------------------- %
        
        function obj = LineScanVelSCIMObj()
            
            persistent objTemp
            if isempty(objTemp)
                objTemp = Test_SCIM_Tif.create_SCIM(...
                    Test_SCIM_Tif.fnSCIMLineScanVel, ...
                    Test_Metadata.channelsR, ...
                    Test_CalibrationPixelSize.CalObj);
            end
            obj = objTemp;
        
        end
        
        % -------------------------------------------------------------- %
        
        function obj = XSectScanSCIMObj()
            
            persistent objTemp
            if isempty(objTemp)
                objTemp = Test_SCIM_Tif.create_SCIM(...
                    Test_SCIM_Tif.fnSCIMXSectScan, ...
                    Test_Metadata.channelsGR, ...
                    Test_CalibrationPixelSize.CalObj);
            end
            obj = objTemp;
        
        end
            
    end
    
    % ================================================================== %
    
end
