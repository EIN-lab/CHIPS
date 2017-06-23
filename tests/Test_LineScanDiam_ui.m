classdef Test_LineScanDiam_ui < matlab.unittest.TestCase
        
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
            tArray = Test_LineScanDiam.select_linescandiam();
            
            % Create the object
            start(tArray)
            LineScanDiamObj1 = LineScanDiam();
            wait(tArray)
            
            % Run the verification
            self.verifyClass(LineScanDiamObj1, 'LineScanDiam');
            
        end
        
    end
    
    % ================================================================== %
    
end