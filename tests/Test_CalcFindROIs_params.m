classdef Test_CalcFindROIs_params < matlab.unittest.TestCase
    %Test_CalcFindROIs Summary of this class goes here
    %   Detailed explanation goes here
    
    % ================================================================== %
    
    properties (TestParameter)
        classCFR = utils.find_subclasses('CalcFindROIs');
    end

    % ================================================================== %
    
    methods (Test)
        
        function testNoArgs(self, classCFR)
            
            % Create an object from the classname
            fConstructor = str2func(classCFR);
            objCFR = fConstructor();
            
            % Run the verification
            self.verifyClass(objCFR, classCFR);
            
        end
        
        % -------------------------------------------------------------- %
        
        function testProcess(self, classCFR)
            
            % Create an object from the classname
            fConstructor = str2func(classCFR);
            objCFR = fConstructor();
            
            % Do some magic to change the config
            classConfig = class(objCFR.config);
            fConfigPreset = str2func([classConfig '.from_preset']);
            try
                objCFR.config = fConfigPreset('ca_cyto_astro');
            catch
            end
            
            % Run most of the processing tests
            isMC = false;
            wngState = warning('off', 'CalcFindROIs:plotROIs:NoROIFound');
            objCFR = Test_CalcFindROIs.processing_tests(self, ...
                objCFR, isMC);
            warning(wngState);
            
            % Test the output
            fnOutput = [classCFR '.csv'];
            dirCheck = 'CalcFindROIs';
            Test_ProcessedImg.check_output_data(self, objCFR.data, ...
                fnOutput, dirCheck);
            
        end
        
        % -------------------------------------------------------------- %
        
        function testMotionCorr(self, classCFR)
            
            % Create an object from the classname
            fConstructor = str2func(classCFR);
            objCFR = fConstructor();
            
            % Do some magic to change the config
            classConfig = class(objCFR.config);
            fConfigPreset = str2func([classConfig '.from_preset']);
            try
                objCFR.config = fConfigPreset('ca_cyto_astro');
            catch
            end
            
            % Run most of the processing tests
            isMC = true;
            wngState = warning('off', 'CalcFindROIs:plotROIs:NoROIFound');
            Test_CalcFindROIs.processing_tests(self, ...
                objCFR, isMC);
            warning(wngState);
            
        end
        
    end
    
    % ================================================================== %
    
end
