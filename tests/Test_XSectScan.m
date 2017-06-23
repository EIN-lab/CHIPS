classdef Test_XSectScan < matlab.unittest.TestCase
    %TEST_XSECTSCAN Summary of this class goes here
    %   Detailed explanation goes here


    % ================================================================== %
    
    methods (Test)
        
        function testConstructor(self)
            
            % Variables to establish
            name = 'test_name';
            SCIM_Obj = copy(Test_SCIM_Tif.XSectScanSCIMObj);
            configDiam = ConfigDiameterTiRS();
            chToUseIn = 2;
            
            % Construct the object
            XSectScanObj2 = XSectScan(name, SCIM_Obj, configDiam, ...
                chToUseIn);
            
            % Run the verifications
            self.verifyEqual(XSectScanObj2.name, name, ...
                'XSectScan constructor failed to set name correctly.');
            self.verifyEqual(XSectScanObj2.rawImg, SCIM_Obj, ...
                'XSectScan constructor failed to set rawImg correctly.');
            self.verifyEqual(XSectScanObj2.calcDiameter.config, ...
                configDiam, ['XSectScan constructor failed to set ' ...
                'configDiam correctly.']);
            self.verifyEqual(XSectScanObj2.channelToUse, ...
                chToUseIn, ['XSectScan constructor failed to set ' ...
                'channelToUse correctly.']);
            
        end
        
        % -------------------------------------------------------------- %
        
        function testBadConfig(self)
            
            % Variables to establish
            name = 'test_name';
            configDiameterWrong = ConfigDiameterFWHM();
            configDiamArray(1:3) = ConfigDiameterTiRS();
            
            % Run the verifications
            self.verifyError(@() XSectScan(name, ...
                Test_SCIM_Tif.XSectScanSCIMObj, configDiameterWrong), ...
                'Utils:Checks:IsClass', ['XSectScan set.calcDiameter ' ...
                'allows config objects of the wrong class.']);
            self.verifyError(@() XSectScan(name, ...
                Test_SCIM_Tif.XSectScanSCIMObj, configDiamArray), ...
                'Utils:Checks:Scalar', ['XSectScan ' ...
                'set.calcDiameter allows non-scalar config objects.']);
            
        end
        
        % -------------------------------------------------------------- %
        
        function testProcess(self)
            
            % Test that there are no errors 
            XSectScanObj3 = copy(Test_XSectScan.XSectScanObj);
            XSectScanObj3.process()
            
            % Test that the states are correcty assigned
            self.verifyEqual(XSectScanObj3.state, 'processed')
            self.verifyEqual(XSectScanObj3.calcDiameter.data.state, ...
                'processed')
            
            % Test the plotting
            hFig = XSectScanObj3.plot();
            self.verifyTrue(ishghandle(hFig), ['plot does not ' ...
                'produce a valid graphics object handle.'])
            close(hFig)
            
            % Run the tests for plotList
            Test_ProcessedImg.test_plotList(self, XSectScanObj3);
            
            % Test the output
            fnOutput = 'XSectScan.csv';
            dirCheck = 'XSectScan';
            Test_ProcessedImg.check_output_data(self, XSectScanObj3, ...
                fnOutput, dirCheck);
            
        end
        
        % -------------------------------------------------------------- %
        
        function testArray(self)
            
            % Variables to establish
            name = 'test_name';
            configDiam = ConfigDiameterTiRS();
            nReps = 5;
            nRepsSize = [1, nReps];
            rawImgArray(1:nReps) = copy(Test_SCIM_Tif.XSectScanSCIMObj);
            rawImgArray = copy(rawImgArray);
            chToUseIn = 2;
            
            % Construct the object and test the size
            XSectScanObj4 = XSectScan(name, rawImgArray, configDiam, ...
                chToUseIn);
            self.verifySize(XSectScanObj4, nRepsSize);
            
            % Process the object
            XSectScanObj4 = XSectScanObj4.process();
            
            % Test that the states are correcty assigned
            self.verifyTrue(all(strcmp({XSectScanObj4.state}, ...
                'processed')))
            
            % Test the plotting
            hFig = XSectScanObj4.plot();
            self.verifyTrue(all(ishghandle(hFig)), ['plot does not ' ...
                'produce a valid graphics object handle.'])
            close(hFig)
            
        end
        
        % -------------------------------------------------------------- %
        
        function testOptConfig(self)
            
            Test_ProcessedImg.test_optconfig(self, ...
                copy(Test_XSectScan.XSectScanObj))
            
        end
        
        % -------------------------------------------------------------- %
        
        function testSaveLoad(self)
            
            % Create the object
            XSSObj = copy(Test_XSectScan.XSectScanObj);
            
            % Prepare the function handles
            fnSaveLoad = [XSSObj.name '.mat'];
            fSave = @(XSSObj) save(fnSaveLoad, 'XSSObj');
            fLoad = @() load(fnSaveLoad, 'XSSObj');
            
            % Run the verifications
            self.verifyWarningFree(@() fSave(XSSObj));
            lastwarn('')
            str = fLoad();
            [lastMsg, ~] = lastwarn();
            self.verifyTrue(isempty(lastMsg))
            
            % Tidy up the variable
            delete(fnSaveLoad)
            
        end
        
        % -------------------------------------------------------------- %
        
        function testT0(self)
            
            % Create the object
            XSSObj = copy(Test_XSectScan.XSectScanObj);
            t0 = 5;
            
            % Process the object, with the correct time offset
            XSSObj.rawImg.t0 = t0;
            XSSObj = XSSObj.process();
            
            % Test that it's processed
            tF1 = 0.5/XSSObj.rawImg.metadata.frameRate - t0;
            self.verifyEqual(XSSObj.calcDiameter.data.time(1), tF1, ...
                'The process method does not respect the RawImg t0.')
            
        end
        
    end
    
    % ================================================================== %
    
    methods (Static)
        
        function tArray = select_xsectscan(varargin)
            
            % Parse optional arguments
            startTime = utils.parse_opt_args({0}, varargin);
            
            % Select the ProcessedImg
            fileName = Test_SCIM_Tif.fnSCIMXSectScan;
            chs = [1, 0];
            tArray = Test_ProcessedImg.select_processedimg(...
                startTime, fileName, chs);
            
        end
        
        % -------------------------------------------------------------- %
        
        function obj = XSectScanObj()
            
            persistent objTemp
            if isempty(objTemp)
                objTemp = XSectScan('test_name', ...
                    copy(Test_SCIM_Tif.XSectScanSCIMObj), ...
                    ConfigDiameterTiRS(), 2);
            end
            obj = objTemp;
        
        end
        
        
    end
        
    % ================================================================== %
    
end
