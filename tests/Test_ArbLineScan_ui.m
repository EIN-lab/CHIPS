classdef Test_ArbLineScan_ui < matlab.unittest.TestCase
        
    % ================================================================== %
    
    methods (TestMethodSetup)
        function clear_persistent(~)
            utils.clear_persistent();
        end
    end
    
    % ================================================================== %
    
    methods (Test, TestTags = {'interactive'})
        
        function testNoArgs(self)
            
            % Create a timer to interact with the name select prompt
            tArray = Test_ArbLineScan.select_arblinescan();
            
            % Create the object
            start(tArray)
            ArbLineScanObj1 = ArbLineScan();
            ArbLineScanObj1.add()
            wait(tArray)
            
            % Run the verifications
            self.verifyClass(ArbLineScanObj1, 'ArbLineScan');
            
        end
        
    end
    
    % ================================================================== %
    
end