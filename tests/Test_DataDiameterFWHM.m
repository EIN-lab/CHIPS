classdef Test_DataDiameterFWHM < matlab.unittest.TestCase
    %TEST_DATADIAMETERFWHM Summary of this class goes here
    %   Detailed explanation goes here
    
    % ================================================================== %
    
    properties (Constant)
        time = [0 1 2]';
        diamProfile = Test_DataDiameterFWHM.time + 1;
        diameter = Test_DataDiameterFWHM.diamProfile + 1;
        idxEdges = Test_DataDiameterFWHM.diameter(1:2)' + 1;
        maskSTD = logical([0 1 0])';
    end
    
    % ================================================================== %
    
    methods (Test)
        
        function testNoArgs(self)
            
            % Create the object
            DataDiameterFWHM1 = DataDiameterFWHM();
            
            % Run the verification
            self.verifyClass(DataDiameterFWHM1, 'DataDiameterFWHM');
            
        end
        
        % -------------------------------------------------------------- %
        
        function testConstructor(self)
            
            DataDiameterFWHM2 = DataDiameterFWHM();
            DataDiameterFWHM2 = DataDiameterFWHM2.add_raw_data(...
                Test_DataDiameterFWHM.time, ...
                Test_DataDiameterFWHM.diamProfile, ...
                Test_DataDiameterFWHM.idxEdges);
            DataDiameterFWHM2 = DataDiameterFWHM2.add_processed_data(...
                Test_DataDiameterFWHM.diameter);
            DataDiameterFWHM2 = DataDiameterFWHM2.add_mask_data(...
                Test_DataDiameterFWHM.maskSTD);
            
            % Run the verifications
            self.verifyEqual(DataDiameterFWHM2.time, self.time, ...
                'DataDiameter failed to set time correctly.');
            self.verifyEqual(DataDiameterFWHM2.diamProfile, self.diamProfile, ...
                'DataDiameter failed to set diamProfile correctly.')
            self.verifyEqual(DataDiameterFWHM2.diameter, self.diameter, ...
                'DataDiameter failed to set diameter correctly.')
            self.verifyEqual(DataDiameterFWHM2.idxEdges, self.idxEdges, ...
                'DataDiameter failed to set idxEdges correctly.')
            self.verifyEqual(DataDiameterFWHM2.maskSTD, self.maskSTD, ...
                'DataDiameter failed to set maskSTD correctly.')
            
        end
        
    end
    
    % ================================================================== %
    
end

