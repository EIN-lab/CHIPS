classdef Test_StreakScan_ui < matlab.unittest.TestCase
    
    % ================================================================== %
    
    methods (TestMethodSetup)
        function clear_persistent(~)
            utils.clear_persistent();
        end
    end
    
    % ================================================================== %
    
    methods (Test, TestTags = {'interactive'})
        
        function testNoArgs(self)
            
            commandwindow
            
            % Setup the timers
            tArray = Test_StreakScan.select_streakscan();
            
            % Create the object
            start(tArray)
            Mock_StreakScanObj1 = Mock_StreakScan();
            wait(tArray)
            
            % Run the verification
            self.verifyClass(Mock_StreakScanObj1, 'Mock_StreakScan');
            
        end
        
    end
    
    % ================================================================== %
    
end
