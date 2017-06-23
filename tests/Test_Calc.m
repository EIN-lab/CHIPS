classdef Test_Calc < matlab.unittest.TestCase
    %TEST_CALC Summary of this class goes here
    %   Detailed explanation goes here
    
    % ================================================================== %
    
    properties
    end
    
    % ================================================================== %
    
    methods (Test)
        
        function testNoArgs(self)
            
            % Create the object
            Calc1 = Mock_Calc();
            
            % Run the verification
            self.verifyClass(Calc1, 'Mock_Calc');
            
        end
        
        % -------------------------------------------------------------- %
        
        function testConstructor(self)
            
            % Variables to establish
            Calc2 = Mock_Calc(Test_Config.ConfigDef, ...
                Test_Data.DataObjEmpty);
            
            % Run the verifications
            self.verifyEqual(Calc2.config, Test_Config.ConfigDef, ...
                'Calc constructor failed to set config correctly.');
            self.verifyEqual(Calc2.data, Test_Data.DataObjEmpty, ...
                'Calc constructor failed to set data correctly.');
            
        end
        
        % -------------------------------------------------------------- %
        
        function testBadConfig(self)
            
            % Variables to establish
            nonConfig = 0;
            configArray(1:2) = Test_Config.ConfigDef;
            MockDataObj1 = Mock_Data();
            
            % Run the verifications
            self.verifyError(@() Mock_Calc(nonConfig, MockDataObj1), ...
                'Utils:Checks:IsClass', ['Calc allows config to be the ' ...
                'wrong class.']);
            self.verifyError(@() Mock_Calc(configArray, MockDataObj1), ...
                'Utils:Checks:Scalar', ['Calc allows config to be ' ...
                'non-scalar.']);
            
        end
        
        % -------------------------------------------------------------- %
        
        function testBadData(self)
            
            % Variables to establish
            notData = 1;
            dataArray(1:3) = Mock_Data();
            
            % Run the verifications
            self.verifyError(@() Mock_Calc(Test_Config.ConfigDef, ...
                notData), 'Utils:Checks:IsClass', ['Calc allows data ' ...
                'to be the wrong class.']);
            self.verifyError(@() Mock_Calc(Test_Config.ConfigDef, ...
                dataArray), 'Utils:Checks:Scalar', ['Calc allows data ' ...
                'to be non-scalar.']);
            
        end
        
    end
    
    % ================================================================== %
    
end

