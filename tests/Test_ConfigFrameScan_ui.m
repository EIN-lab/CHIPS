classdef Test_ConfigFrameScan_ui < matlab.unittest.TestCase
        
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
            tObj = Test_StreakScan.select_calcVelocity();
            
            % Create the object
            start(tObj)
            ConfObj1 = ConfigFrameScan();
            wait(tObj)
            
            % Run the verification
            self.verifyClass(ConfObj1, 'ConfigFrameScan');
            
        end
        
    end
    
    % ================================================================== %
    
end