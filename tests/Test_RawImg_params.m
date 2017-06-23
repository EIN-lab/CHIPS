classdef Test_RawImg_params < matlab.unittest.TestCase
    % TEST_RAWIMG_PARAMS Summary of this class goes here
    %   Detailed explanation goes here
    
    % ================================================================== %
    
    properties (TestParameter)
        mcMethod = {'convfft', 'hmm'};
        dsamp = {[2, 1], 2, [3, 4]};
    end

    % ================================================================== %
    
    methods (Test)
        
        function testMotionCorrect(self, mcMethod)
            
            % Prepare some variables
            riObj = copy(Test_SCIM_Tif.XSectScanSCIMObj);
            szPre = size(riObj.rawdata);
            
            % Test that there are no errors/warnings
            self.verifyWarningFree(@() riObj.motion_correct(...
                'method', mcMethod));
            
            % Test that the property gets updated
            self.verifyTrue(riObj.isMotionCorrected, ['The motion ', ...
                'correction does not update the property'])
            strMC = riObj.get_mc();
            self.verifyTrue(strMC.isMotionCorrected, ['get_mc ', ...
                'is not correct'])
            
            % Test that the size is still the same
            self.verifyEqual(szPre, size(riObj.rawdata), ['The ' ...
                'motion correction does not preserve the image size.'])
            
            % Test that the plotting works
            hFig = riObj.plot('motion');
            self.verifyTrue(all(ishghandle(hFig)), ['The motion plot ' ...
                'does not produce a valid axes handle.'])
            close(hFig)
            
        end
        
        % -------------------------------------------------------------- %
        
        function testDownsample(self, dsamp)
                       
            % Prepare some variables
            scimObj = copy(Test_SCIM_Tif.CellScanSCIMObj);
            
            % Test that there are no errors/warnings for diverse setups
            dsObj =  self.verifyWarningFree(@() scimObj.downsample(dsamp));
            
            % Run the verification for the image
            Test_downsample.testVals(self, scimObj.rawdata, ...
                dsObj.rawdata, dsamp);
            
            % Check metadata
            self.testMetadata(dsamp, dsObj.metadata, scimObj.metadata);
            
        end
        
    end
    
    % ================================================================== %
    
    methods
        
        function testMetadata(self, dsamp, metaNew, metaOld)
            % Function to check whether we are assigning metadata properly
            
            % Just in case we want test with single digit input
            if isscalar(dsamp)
                dsamp = repmat(dsamp, 1, 2);
            end
            
            % Metadata values that we have changed due to downsampling
            isVals = [metaNew.frameRate ,...
                      metaNew.lineTime, ... 
                      metaNew.nFrames, ...
                      metaNew.nLinesPerFrame, ...
                      metaNew.nPixelsPerLine, ...
                      metaNew.pixelSize, ...
                      metaNew.pixelTime];
                  
            % Metadata values we should obtain (within some tolerance)      
            shouldVals = [metaOld.frameRate * (1 / prod(dsamp)), ...
                          metaOld.lineTime * (dsamp(1)^2 * dsamp(2)), ....
                          metaOld.nFrames * (1 / dsamp(2)), ...
                          metaOld.nLinesPerFrame * (1 / dsamp(1)), ...
                          metaOld.nPixelsPerLine * (1 / dsamp(1)), ...
                          metaOld.pixelSize * (dsamp(1)), ...
                          metaOld.pixelTime * (dsamp(1)^2 * dsamp(2))];
            
            % Do the verification, allow 5% tolerance
            self.verifyEqual(isVals, shouldVals, 'RelTol', 0.05);
            
        end
    end
    
    % ================================================================== %
    
end
