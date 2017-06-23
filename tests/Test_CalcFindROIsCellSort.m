classdef Test_CalcFindROIsCellSort < matlab.unittest.TestCase
    %Test_CalcFindROIsCellSort Summary of this class goes here
    %   Detailed explanation goes here

    % ================================================================== %
    
    methods (Test)
        
        function testNoROIs(self)
            
            % Create an object from the classname
            fConstructor = str2func('CalcFindROIsCellSort');
            objCFRCS = fConstructor();
            isMC = false;
            
            % Ensure that we can't find ROIs in this csae
            objCFRCS.config.minROIArea = 1e3;
            
            % Turn off the warnings
            wngState = warning('Off', 'CalcFindROIs:plotROIs:NoROIFound');
            warning('off', 'CalcMeasureROIs:PlotTraces:NoROIsFound')
            warning('off', 'CalcFindROIsCellSort:MeasureROIs:NoROIs')
            
            % Process the object
            objCFRCS = Test_CalcFindROIs.processing_tests(self, ...
                objCFRCS, isMC);
            
            % Test the measuring
            Test_CalcFindROIs.measure_NoROIs_tests(self, objCFRCS);
            warning(wngState);
            
        end
        
        % -------------------------------------------------------------- %
        
        function testT0(self)
            
            % Create an object from the classname
            fConstructor = str2func('CalcFindROIsCellSort');
            objCFRCS = fConstructor();
            csObj = copy(Test_CellScan.CellScanObj);
            t0 = 5;
            
            % Process the object, with the correct time offset
            csObj.rawImg.t0 = t0;
            objCFRCS = objCFRCS.process(csObj);
            
            % Test that it's processed
            tF1 = 0.5/csObj.rawImg.metadata.frameRate - t0;
            self.verifyEqual(objCFRCS.data.time(1), tF1, ['The ' ...
                'process method does not respect the RawImg t0.'])
            
        end
        
    end
    
    % ================================================================== %
    
end
