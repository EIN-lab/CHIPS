classdef Test_BioFormats < matlab.unittest.TestCase
    %TEST_BIOFORMATS Summary of this class goes here
    %   Detailed explanation goes here
    
    properties (Constant)
        fnBFOMETIFF = 'cellscan_ome_tiff.ome.tif';
        skipImport = true;
    end
    
    % ================================================================== %
    
    methods (Test)
        
        function testConstructor(self)
            
            % Create the object
            BF2 = BioFormats(Test_BioFormats.fnBFOMETIFF, ...
                Test_Metadata.channelsAC, ...
                Test_CalibrationPixelSize.CalObj);
            
            % Run the verifications
            self.verifyEqual(BF2.filename, ...
                Test_BioFormats.fnBFOMETIFF, ['BioFormats Constructor ' ...
                'failed to correctly set filename.']);
            self.verifyNotEmpty(BF2.name, ['BioFormats Constructor ' ...
                'failed to set name.']);
            self.verifyNotEmpty(BF2.rawdata, ['BioFormats constructor ' ...
                'method failed to set rawdata.']);
            self.verifyNotEmpty(BF2.metadata, ['BioFormats ' ...
                'constructor method failed to set metadata.']);
            
        end
                
    end
    
    % ================================================================== %
    
    methods (Static)
        
        function tArray = select_ome_tif(varargin)
            
            % Parse optional arguments
            defFN = Test_BioFormats.fnBFOMETIFF;
            defChannels = 5;
            [startTime, fileNameStart, channels] = utils.parse_opt_args(...
                {0, defFN, defChannels}, varargin);
            
            % Create a timer to interact with the file select gui
            tObj1 = Test_RawImg.select_file(startTime, fileNameStart);
            
            % Create a timer to enter the channel selection process
            tArray = Test_Metadata.select_channels(...
                tObj1.StartDelay + 3, channels);
            
            % Establish a timer that turns back on the warning
            wngState = warning('off', 'BioFormats:ParseOME:BadZoom');
            tObjX = timer();
            tObjX.StartDelay = tArray(end).StartDelay;
            tObjX.TimerFcn = @(~, ~) warning(wngState);
            
            % Create the array of timer objects
            tArray = [tObj1, tArray, tObjX];
            
        end
        
        % -------------------------------------------------------------- %
        
        function obj = BFOMETIFFObj()
            
            persistent objTemp
            if isempty(objTemp)
                objTemp = Test_BioFormats.get_BFOMETIFFObj_sub;
            end
            obj = objTemp;
        
        end
        
        % -------------------------------------------------------------- %
        
        function BFOMETIFFObj_sub = get_BFOMETIFFObj_sub(~)
            try
                BFOMETIFFObj_sub = BioFormats(...
                    Test_BioFormats.fnBFOMETIFF, ...
                    Test_Metadata.channelsR, ...
                    Test_CalibrationPixelSize.CalObj);
            catch ME
                if strcmp(ME.identifier, 'BioFormats:LibNotFound')
                    warning(ME.identifier, ME.message)
                    BFOMETIFFObj_sub = [];
                else
                    rethrow(ME)
                end
            end
        end
        
    end
    
    % ================================================================== %
    
end
