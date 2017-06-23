classdef Test_CompositeImg_ui < matlab.unittest.TestCase
        
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
            tArray1 = Test_CompositeImg.select_compositeimg();
            tArray2 = Test_CompositeImg.add_compositeimg();
            
            % Create the object
            start(tArray1)
            CompositeImgObj1 = CompositeImg();
            wait(tArray1)
            
            % Add stuff to it
            start(tArray2)
            CompositeImgObj1.add()
            wait(tArray2)
            
            % Run the verifications
            self.verifyClass(CompositeImgObj1, 'CompositeImg');
            
        end
        
        % -------------------------------------------------------------- %
        
        function testFromFiles(self)
            
            % Create a timer to interact with the name select prompt
            tArray1 = Test_CompositeImg.select_compositeimg();
            tArray2 = Test_CompositeImg.add_compositeimg(...
                tArray1(end).StartDelay + 0.5);
            tArray = [tArray1, tArray2];
            
            % Create the object
            start(tArray)
            CompositeImgObj1a = CompositeImg.from_files();
            wait(tArray)
            
            % Run the verifications
            self.verifyClass(CompositeImgObj1a, 'CompositeImg');
            
        end
        
    end
    
    % ================================================================== %
    
end