classdef Mock_RawImg < RawImg & IMock
    %MOCK_RAWIMG Summary of this class goes here
    %   Detailed explanation goes here
    
    properties
    end
    
    properties (Dependent, Access = protected)
        fileFilterSpec
    end
    
    methods
        function Mock_RawImgObj = Mock_RawImg(varargin)
            Mock_RawImgObj = Mock_RawImgObj@RawImg(varargin{:});
        end
        function fileFilterSpec = get.fileFilterSpec(~)
            fileFilterSpec = {};
        end
    end
    
    methods (Access = protected)
        function import_image(~, ~)
        end
    end
    
end

