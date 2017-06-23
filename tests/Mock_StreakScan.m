classdef Mock_StreakScan < StreakScan & IMock
    %MOCK_STREAKSCAN Summary of this class goes here
    %   Detailed explanation goes here
    
    % ================================================================== %
    
    properties
    end
    
    % ------------------------------------------------------------------ %
    
    properties (Constant)
        plotList = {};
    end
    
    % ================================================================== %
    
    methods
        function Mock_StreakScanObj = Mock_StreakScan(varargin)
            Mock_StreakScanObj = Mock_StreakScanObj@StreakScan(...
                varargin{:});
        end
        function configOut = get_config(~)
            configOut = [];
        end
        function split_into_windows(~)
        end
        function output_data(~)
        end
    end
    
    % ================================================================== %

    methods (Access = protected)
        function process_sub(self)
            self.process_velocity()
        end
        function cols = choose_cols_vel(~) 
            cols = [1 128];
        end
    end
    
    % ================================================================== %
    
    methods (Static, Access = protected)
        function objOut = loadobj(structIn)
            objOut = structIn;
        end
    end
    
    % ================================================================== %
    
end

