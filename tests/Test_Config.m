classdef Test_Config < matlab.unittest.TestCase
    %TEST_CONFIG Summary of this class goes here
    %   Detailed explanation goes here
    
    % ================================================================== %
    
    properties (Constant)
        ConfigDef = Mock_Config();
        inputVals = {'value2', 2};
        inputValsBad = {2, 2};
    end
    
    % ================================================================== %
    
    methods (Test)
        
        function testNoArgs(self)
                       
            % Create the object
            Config1 = Mock_Config();
            
            % Run the verification
            self.verifyClass(Config1, 'Mock_Config');
            
        end
        
        % -------------------------------------------------------------- %
        
        function testConstructor(self)
            
            % Create the objects
            Config2 = Mock_Config();
            
            % Run the verifications
            self.verifyEqual(Config2, Test_Config.ConfigDef, ...
                'Config Constructor failed to correctly set name.');
            
        end
        
        % -------------------------------------------------------------- %
        
        function testCreateCalc(self)
            
            % Create the objects
            Config3 = Mock_Config('property1', 'value2');
            CalcObj = Config3.create_calc();
            
            % Run the verifications
            self.verifyClass(CalcObj, Config3.get_classCalc(), ...
                'Config constructor did not create a calc object')
            self.verifyEqual(CalcObj.config, Config3, ...
                'Config Constructor did not correctly set the config.');
            
        end
        
        % -------------------------------------------------------------- %
        
        function testParseProperties(self)
            
            % Variables to establish
            proplist = {'property1', 'value2', 'property2', 4};
            
            % Create the object
            Config4 = Mock_Config(proplist{:});
            
            % Run the verifications
            self.verifyEqual(Config4.(proplist{1}), proplist{2}, ...
                'Config Constructor did not set a property correctly.');
            self.verifyEqual(Config4.(proplist{3}), proplist{4}, ...
                'Config Constructor did not set a property correctly.');
            
        end
        
    end
    
    % ================================================================== %
    
end

