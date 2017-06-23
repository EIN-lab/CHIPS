classdef Test_CalcVelocityStreaks_params < matlab.unittest.TestCase
    %Test_CalcVelocityStreaks Summary of this class goes here
    %   Detailed explanation goes here
    
    % ================================================================== %
    
    properties (TestParameter)
        classCVS = utils.find_subclasses('CalcVelocityStreaks');
        classVS = utils.find_subclasses('ICalcVelocityStreaks');
    end

    % ================================================================== %
    
    methods (Test)
        
        function testNoArgs(self, classCVS)
            
            % Create an object from the classname
            fConstructor = str2func(classCVS);
            objCVS = fConstructor();
            
            % Run the verification
            self.verifyClass(objCVS, classCVS);
            
        end
        
        % -------------------------------------------------------------- %
        
        function testProcess(self, classCVS, classVS)
            
            % Create a copy to avoid any problems
            ssObj = copy(Test_StreakScan.get_ssObj(classVS));
            
            % Create an object from the classname
            fConstructor = str2func(classCVS);
            objCVS = fConstructor();
            objCVS.config.windowTime = 40; % adjust this to avoid warnings
            
            % Process the object
            wngState = warning('off', 'GetWindow:ExtendWindow');
            objCVS = objCVS.process(ssObj);
            
            % Test that it's processed
            self.verifyEqual(objCVS.data.state, 'processed', ['The ' ...
                'process method does not appear to process the object.'])
            
            % Test the graphs plot
            hFig = figure();
            hAxes = objCVS.plot(ssObj, 'graphs');
            if ~isempty(hAxes)
                self.verifyTrue(ishghandle(hFig), ['The graphs plot ' ...
                    'does not produce a valid graphics object handle.'])
            end
            close(hFig)
            
            % Test the windows plot
            hFig = figure();
            hAxes = objCVS.plot(ssObj, 'windows');
            if ~isempty(hAxes)
                self.verifyTrue(ishghandle(hFig), ['The windows plot ' ...
                    'does not produce a valid graphics object handle.'])
            end
            close(hFig)
            warning(wngState)
            
            % Test the output
            fnOutput = [classCVS '_' class(ssObj) '.csv'];
            dirCheck = 'CalcVelocityStreaks';
            Test_ProcessedImg.check_output_data(self, objCVS.data, ...
                fnOutput, dirCheck);
            
        end
        
        % -------------------------------------------------------------- %
        
        function testT0(self, classCVS)
            
            % Create an object from the classname
            fConstructor = str2func(classCVS);
            objCVS = fConstructor();
            classSSL = 'LineScanVel';
            ssObj = copy(Test_StreakScan.get_ssObj(classSSL));
            t0 = 5;
            
            % Process the object, with the correct time offset
            ssObj.rawImg.t0 = t0;
            objCVS = objCVS.process(ssObj);
            
            % Test that it's processed
            tF1 = 0.5*1E-3*objCVS.config.windowTime - t0;
            self.verifyEqual(objCVS.data.time(1), tF1, 'RelTol', 0.01, ...
                'The process method does not respect the RawImg t0.')
            
        end
        
    end
    
    % ================================================================== %
    
end
