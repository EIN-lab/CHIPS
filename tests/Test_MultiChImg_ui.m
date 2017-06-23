classdef Test_MultiChImg_ui < matlab.unittest.TestCase
        
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
            tArray = Test_MultiChImg.select_multi_ch_img();
            
            % Create the object
            start(tArray)
            MultiChImgObj1 = MultiChImg();
            MultiChImgObj1.add()
            wait(tArray)
            
            % Run the verifications
            self.verifyClass(MultiChImgObj1, 'MultiChImg');
            
        end
        
    end
    
    % ================================================================== %
    
end