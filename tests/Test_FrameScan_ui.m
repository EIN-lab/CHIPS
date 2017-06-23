classdef Test_FrameScan_ui < matlab.unittest.TestCase
        
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
            tArray = Test_FrameScan.select_framescan();
            
            % Create the object
            wngState = warning('off', ...
                'CheckCropVals:TooSmallRowsToUseVel');
            start(tArray)
            FrameScanObj1 = FrameScan();
            wait(tArray)
            warning(wngState)
            
            % Run the verification
            self.verifyClass(FrameScanObj1, 'FrameScan');
            
        end
        
    end
    
    % ================================================================== %
    
end