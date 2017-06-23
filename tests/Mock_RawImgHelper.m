classdef Mock_RawImgHelper < RawImgHelper & IMock
    %MOCK_RAWIMGHELPER Summary of this class goes here
    %   Detailed explanation goes here
    
    properties (Dependent)
        name
        rawdata
        t0
    end
    
    methods
        function to_long(~)
        end
    end
    
end

