classdef Test_CellScan_params < matlab.unittest.TestCase
    %Test_CellScan Summary of this class goes here
    %   Detailed explanation goes here
    
    % ================================================================== %
    
    properties (TestParameter)
        fillBadData = {'nan', 'zero', 'median', 'inpaint'};
    end

    % ================================================================== %
    
    methods (Test)
        
        function testMotionCorr(self, fillBadData)
            
            % Variables to establish
            rawImg = copy(Test_SCIM_Tif.CellScanSCIMObj);
            rawImg.motion_correct('fillBadData', fillBadData);
            configDDD = ConfigCellScan(ConfigFindROIsDummy, ...
                ConfigMeasureROIsDummy(), ConfigDetectSigsDummy());
            
            % Create the objects
            CellScanObj3a = CellScan('Dummy-Dummy', rawImg, configDDD);
            
            % Run processing steps
            CellScanObj3a.process()
            
            % Test that the states are correcty assigned
            self.verifyEqual(CellScanObj3a.state, 'processed')
            self.verifyEqual(CellScanObj3a.calcFindROIs.data.state, ...
                'processed')
            
        end
        
    end
            
    % ================================================================== %
     
end