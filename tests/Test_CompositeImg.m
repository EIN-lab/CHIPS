classdef Test_CompositeImg < matlab.unittest.TestCase
    %TEST_COMPOSITEIMG Summary of this class goes here
    %   Detailed explanation goes here

    % ================================================================== %
    
    methods (Test)
        
        function testConstructor(self)
            
            % Variables to establish
            name = 'Test Name 1';
            rawImg = copy(Test_SCIM_Tif.LineScanVelSCIMObj);
            masks1 = {{true(size(rawImg.rawdata(:,:,1,1)))}};
            masks2(1:2) = masks1;
            strClass = 'LineScanDiam';
            cellClass = {strClass, 'XSectScan'};
            
            % Create the objects
            CompositeImgObj3 = CompositeImg(name, rawImg, cellClass, masks2);
            CompositeImgObj4 = CompositeImg(name, rawImg, strClass, masks1);
            
            % Run the verifications
            self.verifyEqual(CompositeImgObj3.name, name, ['CompositeImg ' ...
                'constructor failed to set name correctly'])
            self.verifyEqual(CompositeImgObj3.rawImg, rawImg, ...
                'CompositeImg constructor failed to set name correctly')
            self.verifyEqual(CompositeImgObj3.imgTypes, cellClass, ...
                ['CompositeImg constructor failed to set imgTypes ' ...
                'correctly'])
            self.verifyEqual(CompositeImgObj4.imgTypes, {strClass}, ...
                ['CompositeImg constructor failed to set imgTypes ' ...
                'correctly'])
            self.verifyEqual(CompositeImgObj3.masks, masks2, ...
                'CompositeImg constructor failed to set masks correctly')
            self.verifyEqual(CompositeImgObj4.masks, masks1, ...
                'CompositeImg constructor failed to set masks correctly')
            
        end
        
        % -------------------------------------------------------------- %
        
%         function testAdd(self)
%             
%             
%             
%         end
        
        % -------------------------------------------------------------- %

        function testAdd2(self)
            
            % Variables to establish
            name = '';
            rawImg = copy(Test_SCIM_Tif.LineScanVelSCIMObj);
            maskTrue = {true(size(rawImg.rawdata(:,:,1,1)))};
            maskFalse = {false(size(maskTrue{1}))};
            maskFalse{1}(:, 5:10) = true;
            masks1T = {maskTrue};
            masks1F = {maskFalse};
            masks2a = [masks1F masks1T];
            masks2b = [masks1T masks1F];
            masksResult = {[masks2a{1} masks2b{1}], ...
                [masks2a{2} masks2b{2}]};
            strClass = 'LineScanDiam';
            cellClass = {strClass, 'XSectScan'};
            
            % Create the objects
            CompositeImgObj5 = CompositeImg(name, rawImg, cellClass, ...
                masks2a);
            CompositeImgObj5.add(cellClass, masks2b)
            
            % Run the verifications
            self.verifyEqual(CompositeImgObj5.masks, masksResult)
            
        end
        
        % -------------------------------------------------------------- %
        
        function testArray(self)
            
            % Variables to establish
            name = 'Test Name 1';
            rawImg = copy(Test_SCIM_Tif.LineScanVelSCIMObj);
            masks1 = {{true(size(rawImg.rawdata(:,:,1,1)))}};
            masks2(1:2) = masks1;
            strClass = 'LineScanDiam';
            cellClass = {strClass, 'XSectScan'};
            nReps = 3;
            nRepsSize = [1, nReps];
            rawImgArray(1:nReps) =  rawImg;
            
            % Create the objects
            CompositeImgObj4 = CompositeImg(name, rawImgArray, ...
                cellClass, masks2);
            
            % Run the verifications
            self.verifySize(CompositeImgObj4, nRepsSize);
            
        end
        
        % -------------------------------------------------------------- %
        
        function testSaveLoad(self)
            
            % Create the object
            CIObj = copy(Test_CompositeImg.CompositeImgObj);
            
            % Prepare the function handles
            fnSaveLoad = [CIObj.name '.mat'];
            fSave = @(CIObj) save(fnSaveLoad, 'CIObj');
            fLoad = @() load(fnSaveLoad, 'CIObj');
            
            % Run the verifications
            self.verifyWarningFree(@() fSave(CIObj));
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
        
        function tArray = select_compositeimg(varargin)
            
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
            
            % Create the array of timer objects
            tArray = [tObj1, tArrayRawImg];
            
        end
        
        % -------------------------------------------------------------- %
        
        function tArray = add_compositeimg(varargin)
            
            % Parse optional arguments
            startTime = utils.parse_opt_args({0}, varargin);
            
            % Select the ProcessedImg classes
            tArraryProcessedImg = ...
                Test_CompositeImg.select_processedimg_classes(...
                startTime + 2);
            
            % Select the masks
            tArrayMasks = Test_CompositeImg.select_masks(...
                tArraryProcessedImg(end).StartDelay);
            
            % Create the array of timer objects
            tArray = [tArraryProcessedImg, tArrayMasks];
            
        end
        
        % -------------------------------------------------------------- %
        
        function tArray = select_processedimg_classes(varargin)
            
            % Parse optional arguments
            startTime = utils.parse_opt_args({0}, varargin);
            
            % LineScanVel
            tObj1 = timer();
            tObj1.StartDelay = startTime + 2;
            tObj1.TimerFcn = @(~, ~) inputemu('key_normal', '4\ENTER');
            
            % LineScanDiam
            tObj2 = timer();
            tObj2.StartDelay = tObj1.StartDelay + 1;
            tObj2.TimerFcn = @(~, ~) inputemu('key_normal', '3\ENTER');
            
            % Finish selecting
            tObj3 = timer();
            tObj3.StartDelay = tObj2.StartDelay + 1;
            tObj3.TimerFcn = @(~, ~) inputemu('key_normal', '\ENTER');
            
            % Create the array of timer objects
            tArray = [tObj1 tObj2 tObj3];
            
        end
        
        % -------------------------------------------------------------- %
        
        function tArray = select_masks(varargin)
            
            % Parse optional arguments
            startTime = utils.parse_opt_args({0}, varargin);
            
            % The delay betwen things
            tDelayText = 1;
            tDelayClick = 2;
            
            % Select everything
            tObj1 = timer();
            tObj1.StartDelay = startTime + tDelayText;
            tObj1.TimerFcn = @(~, ~) inputemu('key_normal', '1\ENTER');
            
            % Select a rectangle
            maskNumRect = 5;
            funClickRect = @(~, ~) Test_CompositeImg.click_drag_fig();
            tArrayRect = Test_CompositeImg.select_shape(tObj1.StartDelay + ...
                tDelayText, maskNumRect, funClickRect, tDelayText, ...
                tDelayClick);
            
            % Finish selecting masks for this imgType
            tObj2 = timer();
            tObj2.StartDelay = tArrayRect(end).StartDelay + tDelayText;
            tObj2.TimerFcn = @(~, ~) inputemu('key_normal', '\ENTER');
            
            % Select Dark Streaks
            tObj3 = timer();
            tObj3.StartDelay = tObj2.StartDelay + tDelayText;
            tObj3.TimerFcn = @(~, ~) inputemu('key_normal', '\ENTER');
            
            % Select CalcVelocityRadon
            tObj4 = timer();
            tObj4.StartDelay = tObj3.StartDelay + tDelayText + 1;
            tObj4.TimerFcn = @(~, ~) inputemu('key_normal', '\ENTER');
            
            % Select a polygon
            maskNumPoly = 6;
            funClickPoly = @(~, ~) Test_CompositeImg.click_polygon();
            tArrayPoly = Test_CompositeImg.select_shape(tObj4.StartDelay + ...
                tDelayText, maskNumPoly, funClickPoly, tDelayText, ...
                tDelayClick + 1);
            
            % Select an ellipse
            maskNumEllipse = 8;
            funClickEllipse = @(~, ~) Test_CompositeImg.click_drag_fig();
            tArrayEllipse = Test_CompositeImg.select_shape(...
                tArrayPoly(end).StartDelay + tDelayText, maskNumEllipse, ...
                funClickEllipse, tDelayText, tDelayClick);
            
            % Finish selecting masks
            tObj5 = timer();
            tObj5.StartDelay = tArrayEllipse(end).StartDelay + tDelayText;
            tObj5.TimerFcn = @(~, ~) inputemu('key_normal', '\ENTER');
            
            % Select the blood plasma channel
            tObj6 = timer();
            tObj6.StartDelay = tObj5.StartDelay + tDelayText + 1;
            tObj6.TimerFcn = @(~, ~) inputemu('key_normal', '\ENTER');
            
            % Create the array of timer objects
            tArray = [tObj1, tArrayRect, tObj2, tObj3, tObj4, ...
                tArrayPoly, tArrayEllipse, tObj5, tObj6];
            
        end
        
        % -------------------------------------------------------------- %
        
        function tArray = select_shape(varargin)
            
            % Parse optional arguments
            [startTime, maskNum, funClick, tDelayText, tDelayClick] = ...
                utils.parse_opt_args({0, 1, ...
                @(~, ~) Test_CompositeImg.click_drag_fig(), 0, 0}, ...
                varargin);
            
            % Select the type of mask
            tObj1 = timer();
            tObj1.StartDelay = startTime + tDelayText;
            tObj1.TimerFcn = @(~, ~) inputemu('key_normal', ...
                sprintf('%d\\ENTER', maskNum));
            
            % Choose the ROI
            tObj2 = timer();
            tObj2.StartDelay = tObj1.StartDelay + tDelayText;
            tObj2.TimerFcn = funClick;
            
            % Double click to select the ROI
            tObj3 = timer();
            tObj3.StartDelay = tObj2.StartDelay + tDelayClick;
            tObj3.TimerFcn = @(~, ~) Test_CompositeImg.select_roi();
            
            % Create the array of timer objects
            tArray = [tObj1, tObj2, tObj3];
            
            
        end
        
        % -------------------------------------------------------------- %
        
        function click_drag_fig()
            
            % Get the figure position 
            figPos = Test_CompositeImg.get_figpos();
            
            % Define the click locations
            xStart = figPos(1) + 0.4*figPos(3);
            yStart = figPos(2) + 0.6*figPos(4);
            xEnd = figPos(1) + 0.6*figPos(3);
            yEnd = figPos(2) + 0.4*figPos(4);
            
            % Package the commands into a cell array
            cmds = {...
                'left_down', [xStart, yStart]; % Click down at first pos
                'left_up', [xEnd, yEnd]}'; % Release the left mouse button
            
            % Run the commands
            tInterval = 0.25;
            inputemu(cmds, tInterval)
            
        end
        
        % -------------------------------------------------------------- %
        
        function click_polygon(varargin)
            
            % Get the figure position 
            figPos = Test_CompositeImg.get_figpos();
                
            % Define the click locations
            x1 = figPos(1) + 0.45*figPos(3);
            x2 = figPos(1) + 0.40*figPos(3);
            x3 = figPos(1) + 0.55*figPos(3);
            x4 = figPos(1) + 0.60*figPos(3);
            y1 = figPos(2) + 0.6*figPos(4);
            y2 = figPos(2) + 0.5*figPos(4);
            y3 = figPos(2) + 0.4*figPos(4);

            % Package the commands into a cell array
            cmds = {...
                'normal', [x1, y1];
                'normal', [x2, y2];
                'normal', [x1, y3];
                'normal', [x3, y3];
                'normal', [x4, y2];
                'normal', [x3, y1];
                'open', [x1, y1];
                }';
            
            % Run the commands
            tInterval = 0.25;
            inputemu(cmds, tInterval)
            
        end
        
        % -------------------------------------------------------------- %
        
        function select_roi()
            
            % Get the figure position 
            figPos = Test_CompositeImg.get_figpos();
            
            % Find the points
            xMiddle = figPos(1) + 0.5*figPos(3);
            yMiddle = figPos(2) + 0.5*figPos(4);
            
            % Run the commands
            inputemu('open', [xMiddle, yMiddle])
            
        end
        
        % -------------------------------------------------------------- %
        
        function figPos = get_figpos()
            
            figPos = nan(1, 4);
            if ~isempty(findall(0, 'Type', 'Figure'))
                
                hFig = gcf;
                figPos = get(hFig, 'position');
                
            end
            
        end
        
        % -------------------------------------------------------------- %
        
        function obj = CompositeImgObj()
            
            persistent objTemp
            if isempty(objTemp)
                objTemp = CompositeImg('test_compositeimg', ...
                    copy(Test_SCIM_Tif.LineScanVelSCIMObj), 'LineScanDiam', ...
                    {{true(size(Test_SCIM_Tif.LineScanVelSCIMObj.rawdata(:,:,1,1)))}});
            end
            obj = objTemp;
        
        end
        
    end
    
    % ================================================================== %
    
end
