classdef Mock_Calc < Calc & IMock
    %Mock_Calc Summary of this class goes here
    %   Detailed explanation goes here
    
    properties
    end
    properties (Constant, Access = protected)
        validConfig = {'Mock_Config'};
        validData = {'Mock_Data'};
        validPlotNames = {};
        validProcessedImg = {};
    end
    
    methods
        function Mock_CalcObj = Mock_Calc(varargin)
            Mock_CalcObj = Mock_CalcObj@Calc(varargin{:});
        end
        function process(~)
        end
        function varargout = plot(~, ~, varargin)
            if nargout > 0
                varargout{1} = [];
            end
        end
    end
    
    methods (Static, Access = protected)
        function configObj = create_config()
            configObj = Mock_Config();
        end
        function dataObj = create_data()
            dataObj = Mock_Data();
        end
    end
    
end

