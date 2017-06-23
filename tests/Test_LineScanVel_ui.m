classdef Test_LineScanVel_ui < matlab.unittest.TestCase
        
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
            tArray = Test_LineScanVel.select_linescanvel();
            
            % Create the object
            start(tArray)
            LineScanVelObj1 = LineScanVel();
            wait(tArray)
            
            % Run the verification
            self.verifyClass(LineScanVelObj1, 'LineScanVel');
            
        end
        
    end
    
    % ================================================================== %
    
end