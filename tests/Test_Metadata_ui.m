classdef Test_Metadata_ui < matlab.unittest.TestCase
        
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
            tObj1 = Test_Metadata.select_metadata();
            
            % Create the object
            start(tObj1)
            MetadataObj1 = Metadata();
            wait(tObj1)
            
            % Run the verifications
            self.verifyClass(MetadataObj1, 'Metadata');
            
        end
        
    end
    
    % ================================================================== %
    
end