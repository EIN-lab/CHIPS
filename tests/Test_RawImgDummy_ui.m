classdef Test_RawImgDummy_ui < matlab.unittest.TestCase
        
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
            tArray = Test_RawImgDummy.select_dummy_tif();
            
            % Create the object
            start(tArray)
            RID1 = RawImgDummy();
            wait(tArray)
            
            % Run the verification
            self.verifyClass(RID1, 'RawImgDummy');
            
        end
        
        % -------------------------------------------------------------- %
        
        function testFromFiles(self)
            
            % Create a timer to interact with the file select gui
            tArray = Test_RawImgDummy.select_dummy_tif();
            
            % Create the object
            start(tArray)
            RID11a = RawImgDummy.from_files();
            wait(tArray)
            
            % Run the verification
            self.verifyClass(RID11a, 'RawImgDummy');
            
        end
        
    end
    
    % ================================================================== %
    
end
