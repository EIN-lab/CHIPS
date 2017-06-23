classdef Test_CellScan_ui < matlab.unittest.TestCase
        
    % ================================================================== %
    
    methods (TestMethodSetup)
        function clear_persistent(~)
            utils.clear_persistent();
        end
    end
    
    % ================================================================== %
    
    methods (Test, TestTags = {'interactive'})
        
        function testNoArgs(self)
            
            % Setup the timers
            tArray = Test_CellScan.select_cellscan();
            
            % Create the object
            start(tArray)
            CellScanObj1 = CellScan();
            wait(tArray)
            
            % Run the verification
            self.verifyClass(CellScanObj1, 'CellScan');
            
        end
        
    end
    
    % ================================================================== %
    
end