classdef Test_CalcFindROIsFLIKA_params < matlab.unittest.TestCase
    %Test_CalcFindROIsFLIKA Summary of this class goes here
    %   Detailed explanation goes here
    
    % ================================================================== %
    
    properties (TestParameter)
        classCalc_FRF = utils.find_subclasses('CalcFindROIsFLIKA');
    end

    % ================================================================== %
    
    methods (Test)
        
        function testNoROIs(self, classCalc_FRF)
            
            % Create an object from the classname
            fConstructor = str2func(classCalc_FRF);
            objCFRF = fConstructor();
            
            % Do some magic to change the config
            classConfig = class(objCFRF.config);
            fConfigPreset = str2func([classConfig '.from_preset']);
            objCFRF.config = fConfigPreset('ca_cyto_astro');
            objCFRF.config.thresholdPuff = 1e3;
            
            % Process the object
            wngState = warning('Off', 'CalcFindROIs:plotROIs:NoROIFound');
            warning('off', 'CalcMeasureROIs:PlotTraces:NoROIsFound');
            warning('off', 'CalcFindROIs:MeasureROIs:NoROIs')
            objCFRF = Test_CalcFindROIs.processing_tests(self, objCFRF, ...
                Test_CellScan.imgSeq);
            
            % Test the measuring
            Test_CalcFindROIs.measure_NoROIs_tests(self, objCFRF);
            warning(wngState);
            
        end
        
        % -------------------------------------------------------------- %
        
        function testBadROIs(self, classCalc_FRF)
            
            % Create an object from the classname
            fConstructor = str2func(classCalc_FRF);
            objCFRF = fConstructor();
            
            % Do some magic to change the config
            classConfig = class(objCFRF.config);
            fConfigPreset = str2func([classConfig '.from_preset']);
            objCFRF.config = fConfigPreset('ca_cyto_astro');
            objCFRF.config.minROIArea = 1e5;
            
            % Process the object
            wngState = warning('Off', 'CalcFindROIs:plotROIs:NoROIFound');
            warning('Off', 'CalcMeasureROIs:PlotTraces:NoROIsFound');
            warning('off', 'CalcFindROIs:MeasureROIs:NoROIs')
            objCFRF = Test_CalcFindROIs.processing_tests(self, objCFRF, ...
                Test_CellScan.imgSeq);
            
            % Test the measuring
            Test_CalcFindROIs.measure_NoROIs_tests(self, objCFRF);
            warning(wngState);
            
        end
        
    end
    
    % ================================================================== %
    
end
