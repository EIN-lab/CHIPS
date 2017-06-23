classdef Test_downsample < matlab.unittest.TestCase
    % Test_downsample Summary of this class goes here
    %   Detailed explanation goes here
    
    % ================================================================== %
    
    methods (Test)
        
        function testNoChange(self)
            
            % Prepare some variables
            xyDim = 20;
            Xfull = randi([1, 2^12], xyDim, xyDim, 2, 2, 'uint16');
            
            % Run the verification
            dsamp1 = [1, 1];
            self.verifyWarning(@() utils.downsample(Xfull, dsamp1), ...
                'Downsample:NoChange');
            
        end
        
    end
                  
    % ================================================================== %
    
    methods (Static)
        
        function testVals(vrfy, Xfull, Xds, dsamp)
            % Function to check everything is working
            
            % Just in case we want test with single digit input
            if isscalar(dsamp)
                dsamp = repmat(dsamp, 1, 2);
            end
            
            % Check the dimensions are as expected
            vrfy.verifyTrue(size(Xds, 1) == ceil(size(Xfull, 1)/dsamp(1)), ...
                'Downsampling did not produce the correct nRows')
            vrfy.verifyTrue(size(Xds, 2) == ceil(size(Xfull, 2)/dsamp(1)), ...
                'Downsampling did not produce the correct nCols')
            vrfy.verifyTrue(size(Xds, 4) == ceil(size(Xfull, 4)/dsamp(2)), ...
                'Downsampling did not produce the correct nFrames')
            
            % Do the verification
            % (this may not hold for 'bicubic' method of interpolation)
            meanFull = mean(Xfull(:));
            meanDs = mean(Xds(:));
            vrfy.verifyEqual(meanFull, meanDs, 'RelTol', 0.01);
            
            % Check that values are within the range (this may not hold for
            % 'bicubic' method of interpolation)
            limsFull = [min(Xfull(:)), max(Xfull(:))];
            limsDs = [min(Xds(:)), max(Xds(:))];
            vrfy.verifyTrue(limsDs(1) >= limsFull(1) && limsDs(2) <= limsFull(2))
            
        end
        
    end
    
    % ================================================================== %
    
end
