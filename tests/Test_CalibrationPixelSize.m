classdef Test_CalibrationPixelSize < matlab.unittest.TestCase
    %TEST_CalibrationPixelSize Summary of this class goes here
    %   Detailed explanation goes here
    
    % ================================================================== %
    
    properties (Constant)
        fnCalObj = 'calibration_dummy.mat';
    end

    % ================================================================== %
    
    methods (Test)
        
        function testConstructor(self)
            
            % Variables to establish
            zoom = [1 2 3 4];
            pixelSize = [8 4 2 1];
            imgSize = 256;
            objective = '20x';
            date = '01/01/01';
            name = 'Testing Calibration';
            person = 'Someone';
            
            % Construct the object
            CalObj1 = CalibrationPixelSize(zoom, pixelSize, imgSize, ...
                objective, date, name, person);
            
            % Run the verifications
            self.verifyEqual(CalObj1.zoom, zoom(:), ...
                ['Calibation_PixelSize constructor failed to set zoom ' ...
                'correctly.']);
            self.verifyEqual(CalObj1.pixelSize, pixelSize(:), ...
                ['Calibation_PixelSize constructor failed to set ' ...
                'pixelSize correctly.']);
            self.verifyEqual(CalObj1.imgSize, imgSize, ...
                ['Calibation_PixelSize constructor failed to set ' ...
                'imgSize correctly.']);
            self.verifyEqual(CalObj1.objective, objective, ...
                ['Calibation_PixelSize constructor failed to set ' ...
                'objective correctly.']);
            self.verifyEqual(CalObj1.date, date, ['Calibation_PixelSize ' ...
                'constructor failed to set date correctly.']);
            self.verifyEqual(CalObj1.person, person, ...
                ['Calibation_PixelSize constructor failed to set person ' ...
                'correctly.']);
            
        end
        
        % -------------------------------------------------------------- %
        
        function testBadArgs(self)
            
            % Variables to establish
            zoom = [1 2 3 4];
            pixelSize = [8 4 2 1];
            
            % Run the verifications
            self.verifyError(@() CalibrationPixelSize([]), ...
                'CalibrationPixelSize:NoZoom');
            self.verifyError(@() CalibrationPixelSize(zoom, []), ...
                'CalibrationPixelSize:NoPixelSize');
            self.verifyError(@() CalibrationPixelSize(zoom, pixelSize, ...
                []), 'CalibrationPixelSize:NoImgSize');
            
        end
        
        % -------------------------------------------------------------- %
        
        function testCalcPixelSize(self)
            
            % Variables to establish
            zoom = 10;
            imgSize = 256;
            CalObj2 = Test_CalibrationPixelSize.CalObj;
            
            % Run the verifications
            pixelSize = CalObj2.calc_pixel_size(zoom, imgSize);
            self.verifyGreaterThan(pixelSize, 0, ['calc_pixel_size '...
                'produces a negative pixel size.'])
            
        end
        
        % -------------------------------------------------------------- %
        
        function testSaveLoad(self)
            
            % Create the object
            CalObj0 = Test_CalibrationPixelSize.CalObj;
            
            % Prepare the function handles
            fnSaveLoad = [CalObj0.name '.mat'];
            fSave = @(CalObj) save(fnSaveLoad, 'CalObj');
            fLoad = @() load(fnSaveLoad, 'CalObj');
            
            % Run the verifications
            self.verifyWarningFree(@() fSave(CalObj0));
            lastwarn('')
            str = fLoad();
            [lastMsg, ~] = lastwarn();
            self.verifyTrue(isempty(lastMsg))
            
            % Tidy up the variable
            delete(fnSaveLoad)
            
        end
        
        % -------------------------------------------------------------- %
        
        function testPlot(self)
            
             % Variables to establish
            CalObj5 = Test_CalibrationPixelSize.CalObj;
            
            % Run the verifications
            hFig = CalObj5.plot();
            self.verifyTrue(ishghandle(hFig), ['Plot does not produce ' ...
                'a valid graphics object handle.'])
            close(hFig)
            
        end
        
    end
    
    % ================================================================== %
    
    
    methods (Static)
        
        function tArray = select_calibration(varargin)
            
            % Parse optional arguments
            [startTime] = utils.parse_opt_args({0}, varargin);
            
            % Establish the timers
            waitSecs = 0.8;
            
            tObj1 = timer();
            tObj1.StartDelay = startTime + waitSecs;
            tObj1.TimerFcn = @(~, ~) ... % objective
                inputemu('key_normal', '20x\ENTER');
            
            tObj2 = timer();
            tObj2.StartDelay = tObj1.StartDelay + waitSecs;
            tObj2.TimerFcn = @(~, ~) ... % date
                inputemu('key_normal', '20-09-2012\ENTER');
            
            tObj3 = timer();
            tObj3.StartDelay = tObj2.StartDelay + waitSecs;
            tObj3.TimerFcn = @(~, ~) ... % person
                inputemu('key_normal', 'test person\ENTER');
            
            tObj4 = timer();
            tObj4.StartDelay = tObj3.StartDelay + waitSecs;
            tObj4.TimerFcn = @(~, ~) ... % name
                inputemu('key_normal', 'test-calibration\ENTER');
            
            tArray = [tObj1, tObj2, tObj3, tObj4];
            
        end
        
        % -------------------------------------------------------------- %
        
        function obj = CalObj()
            
            persistent objTemp
            if isempty(objTemp)
                objTemp = CalibrationPixelSize.load(...
                    Test_CalibrationPixelSize.fnCalObj);
            end
            obj = objTemp;
        
        end
        
    end
        
    % ================================================================== %
    
end

