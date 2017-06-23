classdef Test_downsample_params < matlab.unittest.TestCase
    % Test_downsample_params Summary of this class goes here
    %   Detailed explanation goes here
    
    % ================================================================== %
    
    properties (TestParameter)
        
        dsamp = {[2, 1], 2, [3, 4]};
        
    end

    % ================================================================== %
    
    methods (Test)
        
        function testDownsample(self, dsamp)
                       
            % Prepare some variables
            xyDim = 20;
            dimsImg = [xyDim, xyDim, 2, 12];
            Xfull = randi([1, 2^12], dimsImg, 'uint16');
            
            % Do the downsampling
            Xds = utils.downsample(Xfull, dsamp);
            
            % Run the verification
            Test_downsample.testVals(self, Xfull, Xds, dsamp);
            
        end
        
    end
    
    % ================================================================== %
    
end
