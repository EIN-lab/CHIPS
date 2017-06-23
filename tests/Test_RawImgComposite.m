classdef Test_RawImgComposite < matlab.unittest.TestCase
    %TEST_RawImgComposite Summary of this class goes here
    %   Detailed explanation goes here


    % ================================================================== %
    
    methods (Test)
        
        function testConstructor(self)
            
            % Variables to establish
            rawImgIn = copy(Test_SCIM_Tif.LineScanVelSCIMObj);
            rawImgName = rawImgIn.name;
            rawImgData = rawImgIn.rawdata;
            
            % Create the object
            RawImgComposite2 = RawImgComposite(rawImgIn);
            
            % Run the verifications
            self.verifyEqual(RawImgComposite2.name(1:length(rawImgName)), ...
                rawImgName, ['RawImgComposite Constructor failed to ' ...
                'set the name correctly.']);
            self.verifyEqual(RawImgComposite2.rawdata, rawImgData, ...
                ['RawImgComposite Constructor failed to set the ' ...
                'rawdata correctly.']);
            
        end
        
        % -------------------------------------------------------------- %
        
%         function testBadRawImg(self)
%             
%         end
        
        % -------------------------------------------------------------- %
        
        function testAssignMask(self)
            
            % Variables to establish
            rawImgIn = copy(Test_SCIM_Tif.LineScanVelSCIMObj);
            maskIn = false(size(rawImgIn.rawdata(:,:,1,1)));
            colsToUse = 10:11;
            maskIn(:, colsToUse) = true;
            
            % Create the object
            RawImgComposite3 = RawImgComposite(rawImgIn, maskIn);
            
            % Run the verifications
            self.verifyEqual(RawImgComposite3.rawdata, ...
                rawImgIn.rawdata(:,colsToUse,:,:), ['RawImgComposite ' ...
                'Constructor failed to apply the mask correctly'])
            
        end
        
        % -------------------------------------------------------------- %
        
        function testBadMask(self)
            
            % Variables to establish
            rawImgIn = copy(Test_SCIM_Tif.LineScanVelSCIMObj);
            maskNotLogical = struct('field', 'not-logical');
            maskWrongSize = false(5);
            
            % Run the verifications
            self.verifyError(@() RawImgComposite(rawImgIn, maskNotLogical), ...
                'Utils:Checks:LogicalAble', ['RawImg allowed non ' ...
                'logical arrays as the mask.'])
            self.verifyError(@() RawImgComposite(rawImgIn, maskWrongSize), ...
                'Utils:Checks:SameSize', ['RawImg allowed a mask of a ' ...
                'different size to the raw data.'])
            
        end
        
        % -------------------------------------------------------------- %
        
        function testToLong(self)
            
            % Variables to establish
            rawImgIn = copy(Test_SCIM_Tif.LineScanVelSCIMObj);
            maskIn = false(size(rawImgIn.rawdata(:,:,1,1)));
            colsToUse = 15:100;
            maskIn(:, colsToUse) = true;
            RawImgComposite4 = RawImgComposite(rawImgIn, maskIn);
            
            % Call the static function to do the testing
            Test_RawImg.test_ToLong(self, RawImgComposite4)
            
        end
        
        % -------------------------------------------------------------- %
        
        function testSaveLoad(self)
            
            % Create the object
            RICObj = copy(Test_RawImgComposite.RawImgCompositeObj);
            
            % Prepare the function handles
            fnSaveLoad = [RICObj.name '.mat'];
            fSave = @(RICObj) save(fnSaveLoad, 'RICObj');
            fLoad = @() load(fnSaveLoad, 'RICObj');
            
            % Run the verifications
            self.verifyWarningFree(@() fSave(RICObj));
            lastwarn('')
            str = fLoad();
            [lastMsg, ~] = lastwarn();
            self.verifyTrue(isempty(lastMsg))
            
            % Tidy up the variable
            delete(fnSaveLoad)
            
        end
        
    end
    
    % ================================================================== %
    
    methods (Static)
        
        function tArray = select_RawImgComposite(varargin)
            
            % Parse optional arguments
            defFN = Test_SCIM_Tif.fnSCIMLineScanVel;
            [startTime, fileNameStart] = utils.parse_opt_args({0, defFN}, ...
                varargin);
            
            % Select the image format
            tObj1 = Test_ProcessedImg.select_rawimg_format(startTime);
            
            % Select the raw image
            tArrayRawImg = Test_SCIM_Tif.select_scim_tif(tObj1.StartDelay, ...
                fileNameStart);
            
            % Create the array of timer objects
            tArray = [tObj1 tArrayRawImg];
            
        end
        
        % -------------------------------------------------------------- %
        
        function obj = RawImgCompositeObj()
            
            persistent objTemp
            if isempty(objTemp)
                objTemp = RawImgComposite(Test_SCIM_Tif.LineScanVelSCIMObj);
            end
            obj = objTemp;
        
        end
        
    end
    
    % ================================================================== %
    
end
