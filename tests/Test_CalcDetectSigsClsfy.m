classdef Test_CalcDetectSigsClsfy < matlab.unittest.TestCase
    %Test_CalcDetectSigsClsfy Summary of this class goes here
    %   Detailed explanation goes here
    
    % ================================================================== %
    
    properties (Constant)
    end

    % ================================================================== %
    
    methods (Test)
        
        function testNoSigs(self)
            
            % Create an object and change the config
            objCDS = CalcDetectSigsClsfy();
            objCDS.config.thresholdLP = 1e3;
            objCDS.config.thresholdSP = 1e3;
            
            % Get the CalcMeasureROIs arguments
            classCMR = 'CalcMeasureROIsDummy';
            classCFR = 'CalcFindROIsFLIKA_2D';
            doMC = false;
            objCFR = Test_CalcFindROIs.get_classCFR_args(classCFR);
            objCMR = Test_CalcMeasureROIs.get_classCMR_args(...
                classCMR, classCFR, doMC);
            
            % Run most of the processing tests
            Test_CalcDetectSigs.processing_tests(self, ...
                objCDS, objCMR, objCFR, doMC);
            
        end
        
    end
    
    % ================================================================== %
    
end
