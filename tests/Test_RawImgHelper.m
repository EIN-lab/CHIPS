classdef Test_RawImgHelper < matlab.unittest.TestCase
    %TEST_RAWIMGHELPER Summary of this class goes here
    %   Detailed explanation goes here
    
    % ================================================================== %
    
    properties
    end

    % ================================================================== %
    
    methods (Test)
        
        function testNoArgs(self)
            
            % Create the object
            RawImgHelper1 = Mock_RawImgHelper();
            
            % Run the verification
            self.verifyClass(RawImgHelper1, 'Mock_RawImgHelper');
            
        end
        
        % -------------------------------------------------------------- %
        
        function testBadMetadata(self)
            
            % Establish some variables
            nonMetadata = [0 1];
            metadataArray(1:2) = Test_Metadata.MetadataObj;
            
            % Create the object
            RawImg4 = Mock_RawImg(Test_SCIM_Tif.fnSCIMLineScanVel);
            
            % Setup a nested function to help test the assignment
            function testAssignment(RawImgObj, xx)
                RawImgObj.metadata = xx;
            end
            
            % Run the verifications
            self.verifyError(@() testAssignment(RawImg4, nonMetadata), ...
                'Utils:Checks:IsClass', ['RawData set.metadata allows ' ...
                'metadata to be the wrong class.']);
            self.verifyError(@() testAssignment(RawImg4, metadataArray), ...
                'Utils:Checks:Scalar', ['RawData set.metadata allows ' ...
                'metadata to be non-scalar.']);
            
        end
        
    end
    
    % ================================================================== %
    
end

