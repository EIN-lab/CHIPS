classdef Test_MultiChImg < matlab.unittest.TestCase
    %TEST_MULTICHIMG Summary of this class goes here
    %   Detailed explanation goes here


    % ================================================================== %
    
    methods (Test)
        
        function testConstructor(self)
            
            % Variables to establish
            name = 'Test Name 1';
            rawImg = copy(Test_SCIM_Tif.XSectScanSCIMObj);
            strClass = 'LineScanVel';
            masksAll = Test_MultiChImg.get_masksAll(rawImg);
            configIn = ConfigVelocityRadon();
            
            % Create the objects
            MultiChImgObj2 = MultiChImg(name, rawImg, configIn, ...
                strClass, masksAll);
            
            % Run the verifications
            self.verifyEqual(MultiChImgObj2.name, name, ['MultiChImg ' ...
                'constructor failed to set name correctly'])
            self.verifyEqual(MultiChImgObj2.rawImg, rawImg, ...
                'MultiChImg constructor failed to set name correctly')
            self.verifyEqual(MultiChImgObj2.imgTypes, {strClass}, ...
                ['MultiChImg constructor failed to set imgTypes ' ...
                'correctly'])
            self.verifyEqual(MultiChImgObj2.masks, masksAll, ...
                'MultiChImg constructor failed to set masks correctly')
            
        end
        
        % -------------------------------------------------------------- %
        
        function testSaveLoad(self)
            
            % Create the object
            MCIObj = copy(Test_MultiChImg.MultiChImgObj);
            
            % Prepare the function handles
            fnSaveLoad = [MCIObj.name '.mat'];
            fSave = @(MCIObj) save(fnSaveLoad, 'MCIObj');
            fLoad = @() load(fnSaveLoad, 'MCIObj');
            
            % Run the verifications
            self.verifyWarningFree(@() fSave(MCIObj));
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
        
        function masksAll = get_masksAll(rawImg)
            
            masksBlank = false(size(rawImg.rawdata(:,:,:,1)));
            maskCh1 = masksBlank;
            maskCh1(:,:,1) = true;
            maskCh2 = masksBlank;
            maskCh2(:,:,2) = true;
            masksAll = {{maskCh1, maskCh2}};
            
        end
        
        % -------------------------------------------------------------- %
        
        function tArray = select_multi_ch_img(varargin)
            
            % Parse optional arguments
            defFN = Test_SCIM_Tif.fnSCIMXSectScan;
            [startTime, fileNameStart] = utils.parse_opt_args({0, defFN}, ...
                varargin);
            
            % Select the image format
            tObj1 = Test_ProcessedImg.select_rawimg_format(startTime);
            
            % Select the raw image
            chs = [1, 2];
            tArrayRawImg = Test_SCIM_Tif.select_scim_tif(tObj1.StartDelay, ...
                fileNameStart, chs);
            
            % Select the ProcessedImg class:
            % LineScanVel
            tObj2 = timer();
            tObj2.StartDelay = tArrayRawImg(end).StartDelay + 4;
            tObj2.TimerFcn = @(~, ~) inputemu('key_normal', '4\ENTER');
            % Finish selecting
            tObj3 = timer();
            tObj3.StartDelay = tObj2.StartDelay + 2;
            tObj3.TimerFcn = @(~, ~) inputemu('key_normal', '\ENTER');
            
            % Select the masks
            tArrayMasks = Test_MultiChImg.select_ch_masks(tObj3.StartDelay);
            
            % Choose the default velocity calculation
            tObj4 = timer();
            tObj4.StartDelay = tArrayMasks(end).StartDelay + 2;
            tObj4.TimerFcn = @(~, ~) inputemu('key_normal', '\ENTER');
            
            % Create the array of timer objects
            tArray = [tObj1, tArrayRawImg, tObj2, tObj3, ...
                tArrayMasks, tObj4];
            
        end
        
        % -------------------------------------------------------------- %
        
        function tArray = select_ch_masks(varargin)
            
            startTime = utils.parse_opt_args({0}, varargin);
            
            tDelay = 0.5;
            
            % Plama
            tObj1 = timer();
            tObj1.StartDelay = startTime + tDelay;
            tObj1.TimerFcn = @(~, ~) inputemu('key_normal', '1\ENTER');
            
            % RBCs
            tObj2 = timer();
            tObj2.StartDelay = tObj1.StartDelay + tDelay;
            tObj2.TimerFcn = @(~, ~) inputemu('key_normal', '2\ENTER');
            
            % Finish selecting
            tObj3 = timer();
            tObj3.StartDelay = tObj2.StartDelay + tDelay;
            tObj3.TimerFcn = @(~, ~) inputemu('key_normal', '\ENTER');
            
            % Create the array of timer objects
            tArray = [tObj1, tObj2, tObj3];
            
        end
        
        % -------------------------------------------------------------- %
        
        function obj = MultiChImgObj()
            
            persistent objTemp
            if isempty(objTemp)
                objTemp = MultiChImg('test_multichimg', ...
                    Test_SCIM_Tif.XSectScanSCIMObj, ...
                    ConfigDiameterTiRS(), 'XSectScan', ...
                    Test_MultiChImg.get_masksAll(...
                        Test_SCIM_Tif.XSectScanSCIMObj));
            end
            obj = objTemp;
        
        end
        
    end
    
end
