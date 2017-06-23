classdef Test_ConfigFrameScan < matlab.unittest.TestCase
    %TEST_CONFIGFRAMESCAN Summary of this class goes here
    %   Detailed explanation goes here
    
    % ================================================================== %
    
    properties
    end

    % ================================================================== %
    
    methods (Test)
        
        function testConstructor(self)
            
            % Variables to establish
            confVelStreaks = ConfigVelocityRadon('thresholdSNR', 4);
            confDiamLong = ConfigDiameterFWHM('maxRate', 30);
            
            % Construct the object
            ConfObj2 = ConfigFrameScan(confDiamLong, confVelStreaks);				% 
            ConfObj3 = ConfigFrameScan(confVelStreaks, confDiamLong);
            
            % Run the verifications
            self.verifyEqual(ConfObj2.configVelocity, confVelStreaks, ...
                ['ConfigFrameScan constructor failed to set ' ...
                'configVelocity correctly.']);
            self.verifyEqual(ConfObj2.configDiameter, confDiamLong, ...
                ['ConfigFrameScan constructor failed to set ' ...
                'configDiameter correctly.']);
            self.verifyEqual(ConfObj3.configVelocity, confVelStreaks, ...
                ['ConfigFrameScan constructor failed to set ' ...
                'configVelocity correctly with different order args.']);
            self.verifyEqual(ConfObj3.configDiameter, confDiamLong, ...
                ['ConfigFrameScan constructor failed to set ' ...
                'configDiameter correctly with different order args.']);
%             self.verifyEqual(ConfObj2, ConfObj3, ['ConfigFrameScan ' ...
%                 'constructor fails with different order argments.']);
            
        end
        
    end
    
    % ================================================================== %
    
end