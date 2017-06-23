classdef Mock_Data < Data & IMock
    %MOCK_DATA Summary of this class goes here
    %   Detailed explanation goes here
    
    % ================================================================== %
    
    properties
        time
        raw1
        raw2
        processed1
        processed2
        mask1
        mask2
    end
    
    % ------------------------------------------------------------------ %
    
    properties (Constant, Access = protected)
        
        listRaw = {'time', 'raw1', 'raw2'};
        listProcessed = {'processed1','processed2'};
        listMask = {'mask1','mask2'};
        
        listPlotGood = {'raw1', 'processed1',}
        labelPlotGood = {'Raw 1 [unit]', 'Processed 1 [unit]'}
        listPlotDebug = {'raw1', 'raw2', 'processed1'};
        labelPlotDebug = {'Raw 1 [unit]', 'Raw 2 [unit]', ...
            'Processed 1 [unit]'}
        
        listMean = {};
        
        listOutput = {};
        nameDataClass = 'Mock Data';
        suffixDataClass = 'mock';
        
    end
    
    % ================================================================== %
    
    methods
    end
    
    % ================================================================== %
    
end

