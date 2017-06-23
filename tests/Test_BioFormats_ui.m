classdef Test_BioFormats_ui < matlab.unittest.TestCase
        
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
            tArray = Test_BioFormats.select_ome_tif();
            
            % Create the object
            start(tArray)
            BF1 = BioFormats();
            wait(tArray)
            
            % Run the verification
            self.verifyClass(BF1, 'BioFormats');
            
        end
        
        % -------------------------------------------------------------- %
        
        function testFromFiles(self)
            
            % Create a timer to interact with the file select gui
            tArray = Test_BioFormats.select_ome_tif();
            
            % Create the object
            start(tArray)
            BF1a = BioFormats.from_files();
            wait(tArray)
            
            % Run the verification
            self.verifyClass(BF1a, 'BioFormats');
            
        end
        
    end
    
    % ================================================================== %
    
end
