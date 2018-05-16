classdef Test_RawImg < matlab.unittest.TestCase
    % TEST_RAWIMG Summary of this class goes here
    %   Detailed explanation goes here
    
    properties (Constant)
        fnCheckDenoise = 'denoise.mat';
    end

    % ================================================================== %
    
    methods (Test)
        
        function testNoArgs(self)
            
            % Create the object
            RawImg1 = Mock_RawImg();
            
            % Run the verification
            self.verifyClass(RawImg1, 'Mock_RawImg');
            
        end
        
        % -------------------------------------------------------------- %
        
        function testConstructor(self)
            
            % Create the object
            RawImg2 = Mock_RawImg(Test_SCIM_Tif.fnSCIMLineScanVel);
            
            % Run the verifications
            self.verifyEqual(RawImg2.filename, ...
                Test_SCIM_Tif.fnSCIMLineScanVel, ['SCIM Constructor ' ...
                'failed to correctly set filename.']);
            self.verifyNotEmpty(RawImg2.name, ['SCIM Constructor ' ...
                'failed to set name.']);
            
        end
        
        % -------------------------------------------------------------- %
        
        function testArray(self)
            
            fnList = {Test_SCIM_Tif.fnSCIMLineScanVel, ...
                Test_SCIM_Tif.fnSCIMFrameScan, ...
                Test_SCIM_Tif.fnSCIMCellScan};
            
            % Create the object
            RawImg3 = Mock_RawImg(fnList);
            
            % Run the verifications
            self.verifySize(RawImg3, size(fnList));
            
        end
        
        % -------------------------------------------------------------- %
        
        function testBadFilename(self)
            
            % Establish some variables
            fnNonChar = [0 5 7];
            fnNonExistant = 'non-existant_file.tif';
            
            % Run the verifications
            self.verifyError(@() Mock_RawImg(fnNonChar), ...
                'Utils:Checks:IsClass', ['RawImg set.filename allows ' ...
                'non character array to be set as filename.']);
            self.verifyError(@() Mock_RawImg(fnNonExistant), ...
                'Utils:Checks:FileExists', ['RawImg set.filename ' ...
                'allows non existant file to be set as filename.']);
            
        end
        
        % -------------------------------------------------------------- %
        
        function testBadRawData(self)
            
            % Establish some variables
            nonNumData = 'test_string';
            scalarData = 1;
            vectorData = [1 2];
            
            % Create the object
            RawImg3 = Mock_RawImg(Test_SCIM_Tif.fnSCIMLineScanVel);
            
            % Setup a nested function to help test the assignment
            function testAssignment(RawImgObj, xx)
                RawImgObj.rawdata = xx;
            end
            
            % Run the verifications
            self.verifyError(@() testAssignment(RawImg3, nonNumData), ...
                'Utils:Checks:IsClass', ['RawData set.rawdata allows ' ...
                'rawdata to be non-numeric.']);
            self.verifyError(@() testAssignment(RawImg3, scalarData), ...
                'Utils:Checks:NumDims', ['RawData set.rawdata allows ' ...
                'rawdata to be a scalar.']);
            self.verifyError(@() testAssignment(RawImg3, vectorData), ...
                'Utils:Checks:NumDims', ['RawData set.rawdata ' ...
                'allows rawdata to be a vector.']);
            
        end
        
        % -------------------------------------------------------------- %
        
        function testCatData(self)
            
            % Variables to establish
            rawImg1 = copy(Test_SCIM_Tif.LineScanVelSCIMObj);
            rawImg2(1:2) = rawImg1;
            
            % Join the images
            wngState = warning('off', 'Metadata:SetSizes:NonSquare');
            self.verifyWarningFree(@() RawImg.cat_data(rawImg1, rawImg2));
            warning(wngState)
            
        end
        
        % -------------------------------------------------------------- %
        
        function testDenoise(self)
            
            % Prepare some variables
            nFrames = size(Test_SCIM_Tif.CellScanSCIMObj.rawdata, 4);
            nFramesUse = min([40, nFrames-1]);
            [riObj, ~] = split1(copy(Test_SCIM_Tif.CellScanSCIMObj), 4, ...
                [nFramesUse, nFrames - nFramesUse]);
            riObj = riObj.downsample(4);
            szPre = size(riObj.rawdata);
            % ----------------------------------------------------------- %
            % Run Denoising on Nan corrupted Object
            riObjNan = copy(riObj);
            
            % Nans can be defined only in double type
            riObjNan.rawdata = double(riObjNan.rawdata);
            
            % Read out data shape
            imShape = size(riObjNan.rawdata);
            
            % Create a random mask
            nanM = randi([0 1], imShape(1), imShape(2));
            
            % Create random integer to select frame number
            ind = randi([1 imShape(4)]);
            
            % Create matrix that will be corrupted with nans
            testM = riObjNan.rawdata(:, :, 1,  ind);
            % goodM = testM; % Save the matrix for later use
            
            % Corrupt matrix with randomly distributed nans
            testM(nanM == 1) = nan;
            
            % Put the frames to the initial object 
            riObjNan.rawdata(:, :, 1, ind) = testM;
            
            % Verify that denoising works even with Nans
            self.verifyWarningFree(@() riObjNan.denoise());
            
            % Clear Nan object
            clear riObjNan
            % ----------------------------------------------------------- %
            % Test that there are no errors/warnings
            self.verifyWarningFree(@() riObj.denoise());
            dataOut = riObj.rawdata;
            
            % Test that the property gets updated
            self.verifyTrue(riObj.isDenoised, ['The denoising does ', ...
                'not update the property'])
            
            % Test that the size is still the same
            self.verifyEqual(szPre, size(riObj.rawdata), ['The ' ...
                'denoising does not preserve the image size.'])
            
            % Check that new files are the same as previously
            checkPath = fullfile(utils.CHIPS_rootdir, 'tests', ...
                'output', 'current', 'denoise', self.fnCheckDenoise);
            
%             % Save file for the first run
%             save(checkPath, 'dataOut')
            
            structCheck = load(checkPath);
            dataCheck = structCheck.dataOut;
            self.verifyEqual(dataOut, dataCheck, 'RelTol', 0.005, ...
                'The denoised data has changed')
            
        end
        
        % -------------------------------------------------------------- %
        
        function testDenoiseArray(self)
            
            % Check processing on array, use prepared cut-out
            nReps = 5; % This will start parpool if we have 2 or less workers
            scimObjArray(1:nReps) = copy(Test_SCIM_Tif.CellScanSCIMObj);
            
            % Break a pointer to/from individual copies
            scimObjArray = copy(scimObjArray);
            
            % Test that there are no errors/warnings; need output for
            % parallel processing
            scimObjArray = self.verifyWarningFree(...
                @() scimObjArray.denoise());
            
            % Test that the property gets updated
            self.verifyTrue(all([scimObjArray.isDenoised]), ...
                'The denoising does not update the property')
                        
        end
        
        % -------------------------------------------------------------- %
        
        function testDownsampleArray(self)
            
            % Test that there are no errors
            nReps = 5; % This will start parpool if we have 2 or less workers
            scimObjArray(1:nReps) = copy(Test_SCIM_Tif.CellScanSCIMObj);
            scimObjArray = copy(scimObjArray);
            
            % Pick just one instance of dsamp parameter
            dsamp2 = 2;
            [~] =  self.verifyWarningFree(@() ...
                scimObjArray.downsample(dsamp2));
            
        end
        
        % -------------------------------------------------------------- %
        
        function testExcludeFrames(self)
            
            % Create the object
            riObj = copy(Test_SCIM_Tif.LineScanDiamSCIMObj());
            badFrames = [1, 5, 10];
            framesPre = riObj.rawdata(:,:,:,badFrames + 1);
            
            % Calculate the sum
            riObj.exclude_frames(badFrames);
            
            % Run the verifications
            framesExcl = riObj.rawdata(:,:,:,badFrames);
            self.verifyTrue(all(isnan(framesExcl(:))), ['exclude_frames ', ...
                'didn''t exclude the frames '])
            framesPost = riObj.rawdata(:,:,:,badFrames + 1);
            self.verifyEqual(framesPost, double(framesPre), ...
                'exclude_frames messed with frames it shouldn''t have.');
            
        end
        
        % -------------------------------------------------------------- %
        
        function testFRET(self)
            
            wngState = warning('off', 'Metadata:SetSizes:NonSquare');
            
            % Create the object
            riObj = SCIM_Tif(Test_SCIM_Tif.fnSCIMFRET, ...
                Test_Metadata.channelsCY, ...
                Test_CalibrationPixelSize.CalObj);
            
            % Calculate the ratio
            chNums = [1 2];
            chName = 'FRET_ratio';
            riObj.ch_calc_ratio(chNums, chName);
            
            warning(wngState)
            
            % Run the verifications
            hasRatio = isfield(riObj.metadata.channels, chName);
            self.verifyTrue(hasRatio, ['RawImg constructor failed ' ...
                'to create the FRET Ratio channel.']);
            
        end
        
        % -------------------------------------------------------------- %
        
        function testMotionCorrectArray(self)
            
            % Prepare some variables
            mcMethod = 'convfft';
            nReps = 5; % This will start parpool if we have 2 or less workers
            scimObjArray(1:nReps) = copy(...
                Test_SCIM_Tif.XSectScanSCIMObj);
            scimObjArray = copy(scimObjArray);
            
            % Test that there are no errors/warnings
            scimObjArray = self.verifyWarningFree(...
                @() scimObjArray.motion_correct('method', mcMethod));
            
            % Test that the property gets updated
            self.verifyTrue(all([scimObjArray.isMotionCorrected]), ...
                'The motion correction does not update the property')
            
        end
        
        % -------------------------------------------------------------- %
        
        function testPlotArray(self)
            
            % Prepare some variables
            nReps = 5; % This will start parpool if we have 2 or less workers
            scimObjArray(1:nReps) = copy(Test_SCIM_Tif.LineScanVelSCIMObj);
            scimObjArray = copy(scimObjArray);
            
            % Test the plotting
            hFig = scimObjArray.plot();
            self.verifyTrue(all(ishghandle(hFig)), ['plot does not ' ...
                'produce a valid graphics object handle.'])
            close(hFig)
            
        end
        
        % -------------------------------------------------------------- %
        
        function testSplit1(self)
            
            % Variables to establish
            rawImg1 = copy(Test_SCIM_Tif.XSectScanSCIMObj);
            
            % Split the image
            [new1, new2] = rawImg1.split1(3, [1 1]);
            
            wngState = warning('off', 'Metadata:SetSizes:NonSquare');
            self.verifyEqual(new1.rawdata, rawImg1.rawdata(:,:,1,:));
            self.verifyEqual(new2.rawdata, rawImg1.rawdata(:,:,2,:));
            warning(wngState)
            
        end
        
        % -------------------------------------------------------------- %
        
        function testSplitArray(self)
            
            % Test that there are no errors
            nReps = 5; % This will start parpool if we have 2 or less workers
            scimObjArray(1:nReps) = copy(Test_SCIM_Tif.XSectScanSCIMObj);
            
            % Pick just one instance of dsamp parameter
            [~, ~] =  self.verifyWarningFree(@() ...
                scimObjArray.split1(3, [1 1]));
            
        end
        
        % -------------------------------------------------------------- %
        
        function testSum2(self)
            
            % Create the object
            riObj = copy(Test_SCIM_Tif.XSectScanSCIMObj());
            
            % Calculate the sum
            chNums = [1 2];
            chName = 'cellular_signal';
            newClass = 'uint64';
            riObj.ch_calc_sum2(chNums, chName, newClass);
            
            % Run the verifications
            hasSum = isfield(riObj.metadata.channels, chName);
            self.verifyTrue(hasSum, ['RawImg constructor failed ' ...
                'to create the sum channel.']);
            
        end
        
        % -------------------------------------------------------------- %
        
        function testToLong(self)
            
            % Variables to establish
            rawImg1 = copy(Test_SCIM_Tif.LineScanVelSCIMObj);
            
            % Call the static function to do the testing
            Test_RawImg.test_ToLong(self, rawImg1)
            
        end
        
        % -------------------------------------------------------------- %
        
        function testUnmix(self)
            
            % Variables to establish
            riObj = copy(Test_XSectScan.XSectScanObj);
            riObj = riObj.rawImg;
            x_pix = 128;
            y_pix = 128;
            scaleFactor = 1;
            fnZip = fullfile(utils.CHIPS_rootdir, 'tests', 'res', ...
                'RoiSet_xss_unmix.zip');
            maskFPBG = utils.create_imgJ_mask(fnZip, x_pix, y_pix, ...
                scaleFactor);
            
            % Unmix the image
            [MM, bgCh] = utils.linear_unmix.assemble_mixmat(...
                riObj.rawdata, maskFPBG);
            nFPs = size(MM, 2);
            usePar = true;
            [~] = self.verifyWarningFree(@() riObj.unmix_chs(usePar, ...
                nFPs, MM, bgCh));
            
        end
        
    end
    
    % ================================================================== %
    
    methods (Static)
        
        function tObj = select_file(varargin)
            
            % Parse optional arguments
            defFN = Test_SCIM_Tif.fnSCIMLineScanVel;
            [startTime, fileNameStart] = utils.parse_opt_args({0, defFN}, ...
                varargin);
            
            % Establish a timer that waits for the dialog box to load
            tObj = timer();
            tObj.StartDelay = startTime + 2;
            tObj.TimerFcn = @(~, ~) Test_RawImg.select_file_ui(...
                fileNameStart);
            
        end
        
        % -------------------------------------------------------------- %
        
        function select_file_ui(varargin)
            
            % Parse optional arguments
            defFN = Test_SCIM_Tif.fnSCIMLineScanVel;
            fileName = utils.parse_opt_args({defFN}, varargin);
            
            % Select the file
            waitSecs = 0.5;
            inputemu('key_normal', 'res');
            pause(waitSecs)
            inputemu('key_normal', '\ENTER');
            pause(waitSecs)
            if isunix
                inputemu('key_normal', '\BACKSPACE\BACKSPACE\BACKSPACE');
                pause(0.1)
            end
            inputemu('key_normal', fileName);
            pause(waitSecs)
            inputemu('key_normal', '\ENTER');
            pause(waitSecs)
            commandwindow
            
        end
        
        % -------------------------------------------------------------- %
        
        function cancel_filename()
            
            % Establish the timer that waits for the dialog box to load
            tObj = timer;
            tObj.StartDelay = 0.5;
            tObj.TimerFcn = @(~, ~) inputemu('key_normal', '\ESC');
            start(tObj)
            
            % Call the RawImg constructor without supplying a filename
            RawImg5 = Mock_RawImg(); %#ok<NASGU>
            
            % Wait for the timer to finish before leaving the function
            wait(tObj)
            
        end
        
        % -------------------------------------------------------------- %
        
        function test_ToLong(vrfy, rawImg)
            
            % Variables to establish
            szPre = size(rawImg.rawdata);
            framesPre = rawImg.rawdata(:,:,:,[1,end]);
            
            % Convert to long
            rawImg.to_long()
            
            % Verify the sizes
            vrfy.verifyEqual(size(rawImg.rawdata, 1), szPre(1)*szPre(4), ...
                'The number of rows must make sense')
            vrfy.verifyEqual(size(rawImg.rawdata, 2), szPre(2), ...
                'The number of columns must remain the same')
            vrfy.verifyEqual(size(rawImg.rawdata, 3), szPre(3), ...
                'The number of channels must remain the same')
            
            % Verify the content
            vrfy.verifyEqual(rawImg.rawdata(1:szPre(1),:,:,:), ...
                framesPre(:,:,:,1), 'The first frame''s data must match')
            vrfy.verifyEqual(rawImg.rawdata(end-szPre(1)+1:end,:,:,:), ...
                framesPre(:,:,:,2), 'The first frame''s data must match')
            
        end
        
    end
    
    % ================================================================== %
    
end
