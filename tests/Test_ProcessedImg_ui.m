classdef Test_ProcessedImg_ui < matlab.unittest.TestCase
        
    % ================================================================== %
    
    methods (TestMethodSetup)
        function clear_persistent(~)
            utils.clear_persistent();
        end
    end
    
    % ================================================================== %
    
    methods (Test, TestTags = {'interactive'})
        
        function testNoArgs(self)
            
            % This is here because something weird seemed to be happening
            % with the window minimizing and the subsequent commands not
            % behaving correctly
            commandwindow
            
            % Setup the timers
            tArray = Test_ProcessedImg.select_processedimg(0.5);
            
            % Create the object
            start(tArray)
            Mock_ProcessedImgObj = Mock_ProcessedImg();
            wait(tArray)
            
            % Run the verification
            self.verifyClass(Mock_ProcessedImgObj, 'Mock_ProcessedImg');

        end
        
    end
    
    % ================================================================== %
    
end