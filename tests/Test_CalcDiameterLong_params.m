classdef Test_CalcDiameterLong_params < matlab.unittest.TestCase
    %Test_CalcDiameterLong_params Summary of this class goes here
    %   Detailed explanation goes here
    
    % ================================================================== %
    
    properties (TestParameter)
        classCDL = utils.find_subclasses('CalcDiameterLong');
        classDL = utils.find_subclasses('ICalcDiameterLong');
        isDP = {false, true};
    end

    % ================================================================== %
    
    methods (Test)
        
        function testNoArgs(self, classCDL)
            
            % Create an object from the classname
            fConstructor = str2func(classCDL);
            objCVS = fConstructor();
            
            % Run the verification
            self.verifyClass(objCVS, classCDL);
            
        end
        
        % -------------------------------------------------------------- %
        
        function testProcess(self, classCDL, classDL, isDP)
            
            % Create a copy to avoid any problems
            dlObj = copy(Test_CalcDiameterLong_params.get_dlObj(classDL));
            
            % Check the cases for dark plasma
            if isDP
                dlObj.rawImg.rawdata = max(dlObj.rawImg.rawdata(:)) - ...
                    dlObj.rawImg.rawdata;
                dlObj.isDarkPlasma = true;
            end
            
            % Create an object from the classname
            fConstructor = str2func(classCDL);
            objCDL = fConstructor();
            
            % Process the object
            objCDL = objCDL.process(dlObj);
            
            % Test that it's processed
            self.verifyEqual(objCDL.data.state, 'processed', ['The ' ...
                'process method does not appear to process the object.'])
            
            % Test the graphs plot
            hFig = figure();
            hAxes = objCDL.plot(dlObj, 'graphs');
            if ~isempty(hAxes)
                self.verifyTrue(ishghandle(hFig), ['The graphs plot ' ...
                    'does not produce a valid graphics object handle.'])
            end
            close(hFig)
            
            % Test the windows plot
            hFig = figure();
            hAxes = objCDL.plot(dlObj, 'diam_profile');
            if ~isempty(hAxes)
                self.verifyTrue(ishghandle(hFig), ['The diam_profile ' ...
                    'plot does not produce a valid graphics object handle.'])
            end
            close(hFig)
            
            % Test the output
            fnOutput = [classCDL '_' class(dlObj) '.csv'];
            dirCheck = 'CalcDiameterLong';
            Test_ProcessedImg.check_output_data(self, objCDL.data, ...
                fnOutput, dirCheck);
            
        end
        
        % -------------------------------------------------------------- %
        
        function testT0(self, classCDL)
            
            % Create an object from the classname
            fConstructor = str2func(classCDL);
            objCDL = fConstructor();
            classDLL = 'LineScanDiam';
            dlObj = copy(Test_CalcDiameterLong_params.get_dlObj(classDLL));
            t0 = 5;
            
            % Process the object, with the correct time offset
            dlObj.rawImg.t0 = t0;
            objCDL = objCDL.process(dlObj);
            
            % Test that it's processed
            [~, frameTime] = dlObj.get_diamProfile();
            tF1 = 0.5/frameTime - t0;
            self.verifyEqual(objCDL.data.time(1), tF1, 'RelTol', 0.01, ...
                'The process method does not respect the RawImg t0.')
            
        end
        
    end
    
    % ================================================================== %
    
    methods (Static)
        
        function obj = get_dlObj(classDL)

            persistent objTemp
            if isempty(objTemp)
                objTemp = struct(...
                    'FrameScan', copy(Test_FrameScan.FrameScanObj), ...
                    'LineScanDiam', copy(Test_LineScanDiam.LineScanDiamObj));
            end
            obj = objTemp.(classDL);

        end
        
    end
    
    % ================================================================== %
    
end
