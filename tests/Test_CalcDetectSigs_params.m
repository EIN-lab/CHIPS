classdef Test_CalcDetectSigs_params < matlab.unittest.TestCase
    %Test_DetectSigs Summary of this class goes here
    %   Detailed explanation goes here
    
    % ================================================================== %
    
    properties (TestParameter)
        classCDS = utils.find_subclasses('CalcDetectSigs');
        classCMR = utils.find_subclasses('CalcMeasureROIs');
        classCFR = utils.find_subclasses('CalcFindROIs');
    end

    % ================================================================== %
    
    methods (Test)
        
        function testNoArgs(self, classCDS)
            
            % Create an object from the classname
            fConstructor = str2func(classCDS);
            objCMR = fConstructor();
            
            % Run the verification
            self.verifyClass(objCMR, classCDS);
            
        end
        
        % -------------------------------------------------------------- %
        
        function testProcess(self, classCDS, classCMR, classCFR)
            
            % Create an object from the classname
            fConstructor = str2func(classCDS);
            objCDS = fConstructor();
            
            % Get the CalcFindROIs and CalcMeasureROIs arguments
            doMC = false;
            objCFR = Test_CalcFindROIs.get_classCFR_args(classCFR);
            objCMR = Test_CalcMeasureROIs.get_classCMR_args(classCMR, ...
                classCFR, doMC);
            
            % Run most of the processing tests
            objCDS = Test_CalcDetectSigs.processing_tests(self, ...
                objCDS, objCMR, objCFR, doMC);
            
            % Test the output
            fnOutput = [classCDS '_' classCMR '_' classCFR '.csv'];
            dirCheck = 'CalcDetectSigs';
            Test_ProcessedImg.check_output_data(self, objCDS.data, ...
                fnOutput, dirCheck);
            
        end
        
        % -------------------------------------------------------------- %
        
        function testMotionCorr(self, classCDS, classCMR, classCFR)
            
            % Create an object from the classname
            fConstructor = str2func(classCDS);
            objCDS = fConstructor();
            
            % Get the CalcFindROIs and CalcMeasureROIs arguments
            doMC = true;
            objCFR = Test_CalcFindROIs.get_classCFR_args(classCFR);
            objCMR = Test_CalcMeasureROIs.get_classCMR_args(classCMR, ...
                classCFR, doMC);
            
            % Run most of the processing tests
            wngState = warning('off', ...
                'CalcDetectSigsClsfy:DetectSigs:EmptyROI');
            warning('off', 'CalcDetectSigsClsfy:DetectSigs:NaNROI')
            Test_CalcDetectSigs.processing_tests(self, ...
                objCDS, objCMR, objCFR, doMC);
            warning(wngState)
            
        end
        
        % -------------------------------------------------------------- %
        
        function testNoROIs(self, classCDS)
            
            % Create an object from the classname
            fConstructor = str2func(classCDS);
            objCDS = fConstructor();
            
            % Supress some warnings
            wngState = warning('off', 'CalcFindROIs:MeasureROIs:NoROIs');
            warning('off', 'CalcMeasureROIs:PlotTraces:NoROIsFound')
            warning('off', 'CalcDetectSigsClsfy:DetectSigs:NoROIs');
            warning('off', 'CalcDetectSigsCellSort:DetectSigs:NoROIs');
            warning('off', 'CalcDetectSigsClsfy:DetectSigs:EmptyROI')
            warning('off','CalcDetectSigs:PlotSignals:NoROIsFound')
            
            % Prepare an empty set of ROIs
            objCFR = Test_CalcFindROIs.get_empty_CFR();
            objCMR = Test_CalcMeasureROIs.get_empty_CMR();
            
            % Run most of the processing tests
            doMC = false;
            Test_CalcDetectSigs.processing_tests(self, ...
                objCDS, objCMR, objCFR, doMC);
            warning(wngState)
            
        end
        
    end
    
    % ================================================================== %
    
end
