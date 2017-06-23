classdef Test_RawImgComposite_ui < matlab.unittest.TestCase
        
    % ================================================================== %
    
    methods (TestMethodSetup)
        function clear_persistent(~)
            utils.clear_persistent();
        end
    end
    
    % ================================================================== %
    
    methods (Test, TestTags = {'interactive'})
        
        function testNoArgs(self)
            
            % Create a timer to interact with the file select gui
            tArray = Test_RawImgComposite.select_RawImgComposite();
            
            % Create the object
            start(tArray)
            RawImgComposite1 = RawImgComposite();
            wait(tArray)
            
            % Run the verification
            self.verifyClass(RawImgComposite1, 'RawImgComposite');
            
        end
        
    end
    
    % ================================================================== %
    
end