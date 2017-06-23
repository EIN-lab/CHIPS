classdef Test_CalcMeasureROIs < matlab.unittest.TestCase
    %Test_CalcMeasureROIs Summary of this class goes here
    %   Detailed explanation goes here
    
    % ================================================================== %
    
    properties
    end

    % ================================================================== %
    
    methods
    end
    
    % ================================================================== %
    
    methods (Static)
        
        function objCMR = processing_tests(self, objCMR, objCFR, isMC)
            
            % Get the CellScan object and extract the CFR arguments
            if isMC
                csObj = Test_CellScan.get_csObj_MC();
            else
                csObj = copy(Test_CellScan.CellScanObj);
            end
            csObj.calcFindROIs = objCFR;
            
            % Process the object
            objCMR = objCMR.process(csObj);
            
            % Test that it's processed
            self.verifyEqual(objCMR.data.state, 'processed', ['The ' ...
                'process method does not appear to process the object.'])
            
            % Plot the traces figure
            hFig = figure();
            hAxes = objCMR.plot(csObj, 'traces');
            
            % Test that the plotting works
            self.verifyTrue(all(ishghandle(hAxes)), ['The traces plot ' ...
                'does not produce a valid axes handle.'])
            close(hFig)
            
        end
        
        % -------------------------------------------------------------- %
        
        function objCMR = get_classCMR_args(classCMR, classCFR, isMC)
            
            % Only do the processing the first time it's asked for
            persistent objCMR_temp className_temp
            
            % Create a list of options and work out which one we're doing
            classCMR_options = utils.find_subclasses('CalcMeasureROIs');
            idxCMR = find(strcmp(classCMR_options, classCMR));
            classCFR_options = utils.find_subclasses('CalcFindROIs');
            idxCFR = find(strcmp(classCFR_options, classCFR));
            idxMC = isMC + 1;
            
            % Create the necessary variables, if needed
            isBlank = isempty(className_temp);
            if isBlank
                nCMR = numel(classCMR_options);
                nCFR = numel(classCFR_options);
                objCMR_temp = cell(nCMR, nCFR, 2);
                className_temp = cell(nCMR, nCFR, 2);
            end
            
            % Check if the particlar class has changed or been processed
            hasChanged = ~strcmp(classCMR, ...
                className_temp{idxCMR, idxCFR, idxMC});
            hasEmpty = isempty(objCMR_temp{idxCMR, idxCFR, idxMC});
            doProcess = hasChanged && hasEmpty;
            if doProcess
                
                % Get the CalcFindROIs arguments
                objCFR = Test_CalcFindROIs.get_classCFR_args(classCFR);
                
                % Create an object from the classname, and process it
                fConstructor = str2func(classCMR);
                objCMR_temp{idxCMR, idxCFR, idxMC} = fConstructor();
                
                % Process the object
                if isMC
                    csObj = copy(Test_CellScan.get_csObj_MC());
                else
                    csObj = copy(Test_CellScan.CellScanObj);
                end
                csObj.calcFindROIs = objCFR;
                objCMR_temp{idxCMR, idxCFR, idxMC} = ...
                    objCMR_temp{idxCMR, idxCFR, idxMC}.process(csObj);
                
                % Assign the data to persistent variables
                className_temp{idxCMR, idxCFR, idxMC} = ...
                    class(objCMR_temp{idxCMR, idxCFR, idxMC});
                
            end
            
            % Assign the output variables
            objCMR = objCMR_temp{idxCMR, idxCFR, idxMC};
            
        end
        
        % -------------------------------------------------------------- %
        
        function objCMR = get_empty_CMR()
            
            % Prepare an empty set of ROIs
            csObj = copy(Test_CellScan.CellScanObj);
            csObj.calcFindROIs = Test_CalcFindROIs.get_empty_CFR();
            
            % Prepare an empty set of traces etc
            objCMR = CalcMeasureROIsDummy();
            wngState = warning('off', 'CalcMeasureROIs:MeasureROIs:NoROIs');
            objCMR = objCMR.process(csObj);
            warning(wngState)
            
        end
        
    end
    
    % ================================================================== %
    
end