classdef Test_Data < matlab.unittest.TestCase
    %TEST_DATA Summary of this class goes here
    %   Detailed explanation goes here
    
    % ================================================================== %
    
    properties (Constant)
        time = [0 1 2]
        raw1 = Test_Data.time + 1;
        raw2 = Test_Data.raw1 + 1;
        processed1 = Test_Data.raw2 + 1;
        processed2 = Test_Data.processed1 + 1;
        mask1 = [false true false];
        mask2 = [false false true];
        
        DataObjEmpty = Mock_Data();
    end
    
    % ================================================================== %
    
    methods (Test)
        
        function testNoArgs(self)
                       
            % Create the object
            Data1 = Mock_Data();
            
            % Run the verification
            self.verifyClass(Data1, 'Mock_Data');
            
        end
        
        % -------------------------------------------------------------- %
        
        function testState(self)
            
            Data2 = Mock_Data();
            self.verifyEqual(Data2.state, 'unprocessed');
            
            Data2.time = Test_Data.time;
            Data2.raw1 = Test_Data.raw1;
            self.verifyEqual(Data2.state, 'error');
            
            Data2 = Data2.add_raw_data(Test_Data.time, Test_Data.raw1, ...
                Test_Data.raw2);
            Data2 = Data2.add_processed_data(Test_Data.processed1, ...
                Test_Data.processed2);
            Data2 = Data2.add_mask_data(Test_Data.mask1, Test_Data.mask2);
            self.verifyEqual(Data2.state, 'processed');
            
        end
        
    end
    
    % ================================================================== %
    
end

