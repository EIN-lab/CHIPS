classdef Test_RawImgDummy < matlab.unittest.TestCase
    % TEST_RAWIMGDUMMY Summary of this class goes here
    %   Detailed explanation goes here
    
    % ================================================================== %
    
    methods (Test)
        
        function testConstructorData(self)
            
            % Variables to establish
            nameIn = 'yay name';
            rawdataIn = Test_SCIM_Tif.LineScanVelSCIMObj.rawdata;
            acqIn = Test_SCIM_Tif.LineScanVelSCIMObj.metadata.get_acq();
            channelsIn = Test_Metadata.channelsR;
            calibrationIn = Test_CalibrationPixelSize.CalObj;
            
            % Create the object
            wngState = warning('off', 'Metadata:SetSizes:NonSquare');
            RawImgDummyObj1 = RawImgDummy(nameIn, rawdataIn, ...
                channelsIn, calibrationIn, acqIn);
            warning(wngState)
            
            % Run the verifications
            self.verifyClass(RawImgDummyObj1, 'RawImgDummy');
            self.verifyEqual(RawImgDummyObj1.name, nameIn, ...
                'RawImgDummy Constructor failed to correctly set name.');
            self.verifyEqual(RawImgDummyObj1.rawdata, rawdataIn, ...
                'RawImgDummy Constructor failed to correctly set rawdata.');
            self.verifyEqual(RawImgDummyObj1.metadata.get_acq(), acqIn, ...
                'RawImgDummy Constructor failed to correctly set name.');
            self.verifyEqual(RawImgDummyObj1.metadata.calibration, ...
                calibrationIn, ['RawImgDummy Constructor failed ' ...
                'to correctly set calibration.']);
            
        end
        
        % -------------------------------------------------------------- %
        
        function testConstructorFile(self)
            
            % Variables to establish
            fnIn = Test_SCIM_Tif.fnSCIMCellScan;
            chsIn = Test_Metadata.channelsAC;
            calIn = Test_CalibrationPixelSize.CalObj;
            acqIn = Test_SCIM_Tif.CellScanSCIMObj.metadata.get_acq();
            
            % Create the object
            RawImgDummyObj2 = RawImgDummy(fnIn, chsIn, calIn, acqIn);
            
            % Run the verifications
            self.verifyClass(RawImgDummyObj2, 'RawImgDummy');
            self.verifyEqual(RawImgDummyObj2.filename, fnIn, ...
                'RawImgDummy Constructor failed to correctly set name.');
            self.verifyEqual(RawImgDummyObj2.metadata.get_acq(), acqIn, ...
                'RawImgDummy Constructor failed to correctly set name.');
            self.verifyEqual(RawImgDummyObj2.metadata.calibration, ...
                calIn, ['RawImgDummy Constructor failed ' ...
                'to correctly set calibration.']);
            
        end
        
    end
    
    % ================================================================== %
    
end
