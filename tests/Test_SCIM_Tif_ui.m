classdef Test_SCIM_Tif_ui < matlab.unittest.TestCase
        
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
            tArray = Test_SCIM_Tif.select_scim_tif();
            
            % Create the object
            start(tArray)
            SCIM1 = SCIM_Tif();
            wait(tArray)
            
            % Run the verification
            self.verifyClass(SCIM1, 'SCIM_Tif');
            
        end
        
        % -------------------------------------------------------------- %
        
        function testFromFiles(self)
            
            % Create a timer to interact with the file select gui
            tArray = Test_SCIM_Tif.select_scim_tif();
            
            % Create the object
            start(tArray)
            SCIM1a = SCIM_Tif.from_files();
            wait(tArray)
            
            % Run the verification
            self.verifyClass(SCIM1a, 'SCIM_Tif');
            
        end
        
    end
    
    % ================================================================== %
    
end