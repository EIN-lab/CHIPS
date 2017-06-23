classdef Test_Config_params < matlab.unittest.TestCase
    %Test_Config_params Summary of this class goes here
    %   Detailed explanation goes here
    
    % ================================================================== %
    
    properties (TestParameter)
        classConf = utils.find_subclasses('Config');
    end

    % ================================================================== %
    
    methods (Test)
        
        function testConfigs(self, classConf)
            
            % Setup an 
            objPI = Test_ProcessedImg.MockPIObj();
            className = 'calcMock';
            
            % Create an object from the classname
            fConstructor = str2func(classConf);
            objConf = fConstructor();
            
            % Run the verification
            self.verifyClass(objConf, classConf);
            
            % Test that the opt_config works
            hFig = figure;
            [~, hPan0] = objConf.opt_config(objPI, className);
            self.verifyTrue(ishghandle(hPan0), ...
                'opt_config does not produce a figure.')
            close(hFig)
            
        end
        
    end
    
    % ================================================================== %
    
end
