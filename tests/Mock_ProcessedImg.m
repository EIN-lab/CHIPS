classdef Mock_ProcessedImg < ProcessedImg & IMock
    %MOCK_PROCESSEDIMG Summary of this class goes here
    %   Detailed explanation goes here
    
    % ================================================================== %
    
    properties
        calcMock = Mock_Calc();
    end
    
    % ------------------------------------------------------------------ %
    
    properties (Constant)
        plotList = {};
    end
    
    % ================================================================== %
    
    methods
        function Mock_ProcessedImgObj = Mock_ProcessedImg(varargin)
            Mock_ProcessedImgObj = Mock_ProcessedImgObj@ProcessedImg(...
                varargin{:});
        end
        function plot(~)
        end
        function configOut = get_config(~)
            configOut = [];
        end
        function output_data(~)
        end
    end
    
    % ================================================================== %
    
    methods (Access=protected)
        function process_sub(~)
        end
        function update_rawImg_props(~)
            % Call the superclass method to do it's bit
            self.update_rawImg_props@ProcessedImg()
            % Call the function one by one if we have an array
            if ~isscalar(self)
                arrayfun(@update_rawImg_props, self);
                return
            end
        end
    end
    
    % ================================================================== %
    
    methods (Static)
        function chList = reqChannelAll()
            chList = {};
        end
        function chList = reqChannelAny()
            chList = {};
        end
    end
    
    % ================================================================== %
    
    methods (Static, Access = protected)
        function configObj = create_config()
            configObj = Mock_Config('');
        end
        function objOut = loadobj(structIn)
            objOut = structIn;
        end
    end
    
    % ================================================================== %
    
end

