classdef Mock_Config < Config & IMock
    %MOCK_CONFIG Summary of this class goes here
    %   Detailed explanation goes here
    
    % ================================================================== %
    
    properties
        property1 = 'value1';
        property2 = 2;
        specprop = [0 5 9];
    end
    
    % ------------------------------------------------------------------ %
    
    properties (Constant, Access = protected)
        classCalc = 'Mock_Calc';
        optList = {};
    end
    
    % ================================================================== %
    
    methods
        
        function Mock_ConfigObj = Mock_Config(varargin)
            
            Mock_ConfigObj = Mock_ConfigObj@Config(varargin{:});
            
        end
        
        % -------------------------------------------------------------- %
        
        function classCalc = get_classCalc(self)
            classCalc = self.classCalc;
        end
        
    end
    
    % ================================================================== %
    
end

