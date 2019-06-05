classdef Test_CalcMeasureROIs_params < matlab.unittest.TestCase
    %Test_CalcMeasureROIs Summary of this class goes here
    %   Detailed explanation goes here
    
    % ================================================================== %
    
    properties (TestParameter)
        classCMR = utils.find_subclasses('CalcMeasureROIs');
        classCFR = utils.find_subclasses('CalcFindROIs');
    end

    % ================================================================== %
    
    methods (Test)
        
        function testNoArgs(self, classCMR)
            
            % Create an object from the classname
            fConstructor = str2func(classCMR);
            objCMR = fConstructor();
            
            % Run the verification
            self.verifyClass(objCMR, classCMR);
            
        end
        
        % -------------------------------------------------------------- %
        
        function testProcess(self, classCMR, classCFR)
            
            % Create an object from the classname
            fConstructor = str2func(classCMR);
            objCMR = fConstructor();
            
            % Get the CalcFindROIs arguments
            objCFR = Test_CalcFindROIs.get_classCFR_args(classCFR);
            
            % Run most of the processing tests
            isMC = false;
            objCMR = Test_CalcMeasureROIs.processing_tests(self, ...
                objCMR, objCFR, isMC);
            
            % Test the output
            fnOutput = [classCMR '_' classCFR '.csv'];
            dirCheck = 'CalcMeasureROIs';
            Test_ProcessedImg.check_output_data(self, objCMR.data, ...
                fnOutput, dirCheck);
            
        end
        
        % -------------------------------------------------------------- %
        
        function testMotionCorr(self, classCMR, classCFR)
            
            % Create an object from the classname
            fConstructor = str2func(classCMR);
            objCMR = fConstructor();
            
            % Get the CalcFindROIs arguments
            objCFR = Test_CalcFindROIs.get_classCFR_args(classCFR);
            
            % Run most of the processing tests
            isMC = true;
            Test_CalcMeasureROIs.processing_tests(self, ...
                objCMR, objCFR, isMC);
            
        end
        
        % -------------------------------------------------------------- %
        
        function testNoROIs(self, classCMR)
            
            % Create an object from the classname
            fConstructor = str2func(classCMR);
            objCMR = fConstructor();
            
            % Prepare an empty set of ROIs
            objCFR = Test_CalcFindROIs.get_empty_CFR();
            
            % Run most of the processing tests
            isMC = false;
            wngState = warning('off', ...
                'CalcMeasureROIs:PlotTraces:NoROIsFound');
            warning('off', 'CalcMeasureROIs:MeasureROIs:NoROIs')
            Test_CalcMeasureROIs.processing_tests(self, ...
                objCMR, objCFR, isMC);
            warning(wngState)
            
            % Run data output test
            outPath = fullfile(utils.CHIPS_rootdir, 'tests', ...
                'output', 'dump');
            wngState = warning('off', 'Data:OutputData:NoOutput');            
            fnOut = self.verifyWarning(@() objCMR.data.output_data(outPath, ...
                'overwrite', 1), ...
                'Data:OutputData:DataIncomplete');
            warning(wngState);
            
            % Return if there's no output
            if isempty(fnOut)
                return
            end
                        
            % Delete files
            wngState = warning('off', 'MATLAB:DELETE:FileNotFound');
            if iscell(fnOut)
                delete(fnOut{:});
            else
                delete(fnOut);
            end
            warning(wngState)        
            
        end
        
        % -------------------------------------------------------------- %
        
        function testT0(self, classCMR)
            
            % Create an object from the classname
            fConstructor = str2func(classCMR);
            objCMR = fConstructor();
            csObj = copy(Test_CellScan.CellScanObj);
            classCFRD = 'CalcFindROIsDummy';
            t0 = 5;
            
            % Get the CalcFindROIs arguments
            objCFR = Test_CalcFindROIs.get_classCFR_args(classCFRD);
            
            % Process the object, with the correct time offset
            csObj.rawImg.t0 = t0;
            csObj.calcFindROIs = objCFR;
            objCMR = objCMR.process(csObj);
            
            % Test that it's processed
            tF1 = 0.5/csObj.rawImg.metadata.frameRate - t0;
            self.verifyEqual(objCMR.data.time(1), tF1, ['The ' ...
                'process method does not respect the RawImg t0.'])
            
        end
        
    end
    
    % ================================================================== %
    
end
