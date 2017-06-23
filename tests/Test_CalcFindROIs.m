classdef Test_CalcFindROIs < matlab.unittest.TestCase
    %Test_CalcFindROIs Summary of this class goes here
    %   Detailed explanation goes here
    
    % ================================================================== %
    
    properties
    end

    % ================================================================== %
    
    methods
    end
    
    % ================================================================== %
    
    methods (Static)
        
        function objCFR = processing_tests(vrfy, objCFR, isMC)
            
            % Get the CellScan object
            if isMC
                csObj = copy(Test_CellScan.get_csObj_MC());
            else
                csObj = copy(Test_CellScan.CellScanObj);
            end
            
            % Process the object
            objCFR = objCFR.process(csObj);
            
            % Test that it's processed
            vrfy.verifyEqual(objCFR.data.state, 'processed', ['The ' ...
                'process method does not appear to process the object.'])
            
            % Plot the rois figure
            hFig = figure();
            hAxes = objCFR.plot(csObj, 'rois');
            
            % Test that the plotting works
            vrfy.verifyTrue(ishghandle(hAxes), ['The ROIs plot does ' ...
                'not produce a valid axes handle.'])
            close(hFig)
            
            % Plot the images figure
            hFig = figure();
            hAxes = objCFR.plot(csObj, 'images');
            
            % Test that the plotting works
            vrfy.verifyTrue(all(ishghandle(hAxes)), ['The images plot ' ...
                'does not produce a valid axes handle.'])
            close(hFig)
            
        end
        
        % -------------------------------------------------------------- %
        
        function measure_NoROIs_tests(vrfy, objCFR)
            
            % Check that the measuring works as expected for empty ROIs
            csObj = copy(Test_CellScan.CellScanObj);
            [traces, tracesExist] = objCFR.measure_ROIs(csObj);
            vrfy.verifyEqual(traces, 0)
            vrfy.verifyFalse(tracesExist)
            
        end
        
        % -------------------------------------------------------------- %
        
        function objCFR = get_classCFR_args(classCFR)
            
            % Only do the processing the first time it's asked for
            persistent objCFR_temp className_temp
            
            % Create a list of options and work out which one we're doing
            classCFR_options = utils.find_subclasses('CalcFindROIs');
            idxCFR = find(strcmp(classCFR_options, classCFR));
            
            % Create the necessary variables, if needed
            isBlank = isempty(className_temp);
            if isBlank
                nClasses = numel(classCFR_options);
                objCFR_temp = cell(1, nClasses);
                className_temp = cell(1, nClasses);
            end
            
            % Check if the particlar class has changed or been processed
            hasChanged = ~strcmp(classCFR, className_temp{idxCFR});
            hasEmpty = isempty(objCFR_temp{idxCFR});
            doProcess = hasChanged && hasEmpty;
            if doProcess
                
                % Create an object from the classname, and process it
                fConstructor = str2func(classCFR);
                objCFR_temp{idxCFR} = fConstructor();
                
                % Do some magic to change the config
                classConfig = class(objCFR_temp{idxCFR}.config);
                fConfigPreset = str2func([classConfig '.from_preset']);
                try
                    objCFR_temp{idxCFR}.config = fConfigPreset('ca_cyto_astro');
                catch
                end
                
                % Process the object
                objCFR_temp{idxCFR} = objCFR_temp{idxCFR}.process(...
                    Test_CellScan.CellScanObj);
                className_temp{idxCFR} = class(objCFR_temp{idxCFR});
                
            end
            
            % Assign the output variables
            objCFR = objCFR_temp{idxCFR};
            
        end
        
        % -------------------------------------------------------------- %
        
        function objCFR = get_empty_CFR()
            
            % Prepare an empty set of ROIs
            is3D = false;
            roiMask = false(size(Test_CellScan.refImg));
            roiNames = utils.create_ROI_names(roiMask, is3D);
            confObj = ConfigFindROIsDummy(...
                'roiMask', roiMask, 'roiNames', roiNames);
            objCFR = confObj.create_calc();
            objCFR = objCFR.process(Test_CellScan.CellScanObj);
            
        end
        
    end
    
    % ================================================================== %
    
end