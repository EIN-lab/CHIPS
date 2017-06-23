classdef Test_CalibrationPixelSize_ui < matlab.unittest.TestCase
        
    % ================================================================== %
    
    methods (TestMethodSetup)
        function clear_persistent(~)
            utils.clear_persistent();
        end
    end
    
    % ================================================================== %
    
    methods (Test, TestTags = {'interactive'})
        
        function testMinArgs(self)
            
            % Variables to establish
            zoom = [1 2 3 4];
            pixelSize = [8 4 2 1];
            imgSize = 256;
            
            % Setup the timers
            tArray = Test_CalibrationPixelSize.select_calibration();
            
            % Construct the object
            start(tArray)
            CalObj0 = CalibrationPixelSize(zoom, pixelSize, imgSize);
            wait(tArray)
            
            % Run the verifications
            self.verifyClass(CalObj0, 'CalibrationPixelSize');
            
        end
        
    end
    
    % ================================================================== %
    
end