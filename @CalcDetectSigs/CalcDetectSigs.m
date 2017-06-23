classdef (Abstract) CalcDetectSigs < Calc
%CalcDetectSigs - Superclass for CalcDetectSigs classes
%
%   CalcDetectSigs is an abstract superclass that implements (or requires
%   implementation in its subclasses via abstract methods or properties)
%   most functionality related to CalcDetectSigs objects.  Typically there
%   is one concrete subclass of CalcDetectSigs for every calculation
%   algorithm, and it contains the algorithm-specific code that is needed
%   for the calculation.
%
%   CalcDetectSigs is a subclass of matlab.mixin.Copyable, which is itself
%   a subclass of handle, meaning that CalcDetectSigs objects are actually
%   references to the data contained in the object.  This allows certain
%   features that are only possible with handle objects, such as events and
%   certain GUI operations.  However, it is important to use the copy
%   method of matlab.mixin.Copyable to create a new, independent object;
%   otherwise changes to a CalcDetectSigs object used in one place will
%   also lead to changes in another (perhaps undesired) place.
%
% CalcDetectSigs public properties
%   config          - A scalar ConfigDetectSigs object
%   data            - A scalar DataDetectSigs object
%   nColsDetect     - The number of columns needed for plotting
%
% CalcDetectSigs public methods
%   CalcDetectSigs  - CalcDetectSigs class constructor
%   copy            - Copy MATLAB array of handle objects
%   plot            - Plot a figure
%   process         - Run the processing
%
%   See also CalcDetectSigsDummy, CalcDetectSigsClsfy, Calc,
%   ConfigDetectSigs, DataDetectSigs, CellScan

%   Copyright (C) 2017  Matthew J.P. Barrett, Kim David Ferrari et al.
%
%   This program is free software: you can redistribute it and/or modify
%   it under the terms of the GNU General Public License as published by
%   the Free Software Foundation, either version 3 of the License, or
%   (at your option) any later version.
% 
%   This program is distributed in the hope that it will be useful,
%   but WITHOUT ANY WARRANTY; without even the implied warranty of
%   MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
%   GNU General Public License for more details.
%   
%   You should have received a copy of the GNU General Public License 
%   along with this program.  If not, see <http://www.gnu.org/licenses/>.

    % ================================================================== %
    
    properties (Abstract, Constant)
        %nColsDetect - The number of columns needed for plotting
        nColsDetect
    end
    
    % ------------------------------------------------------------------ %
    
    properties (Constant, Access = protected)
        validPlotNames = {'annotations', 'classification', 'signals'};
        validProcessedImg = {'CellScan'};
    end
    
    % ================================================================== %
    
    methods
        
        function cdsObj = CalcDetectSigs(varargin)
        %CalcDetectSigs - CalcDetectSigs class constructor
        %
        %   OBJ = CalcDetectSigs() prompts for all required information and
        %   creates a CalcDetectSigs object.
        %
        %   OBJ = CalcDetectSigs(CONFIG, DATA) uses the specified CONFIG
        %   and DATA objects to construct the CalcDetectSigs object. If any
        %   of the input arguments are empty, the constructor will prompt
        %   for any required information.  The input arguments must be
        %   objects which meet the requirements of the particular concrete
        %   subclass of CalcDetectSigs.
        %
        %   See also ConfigDetectSigs, DataDetectSigs
        
            % Parse arguments
            [configIn, dataIn] = utils.parse_opt_args({[], []}, varargin);
            
            % Call Calc (i.e. parent class) constructor
            cdsObj = cdsObj@Calc(configIn, dataIn);
            
        end
        
        % -------------------------------------------------------------- %
        
         varargout = plot(self, objPI, varargin)
        
        % -------------------------------------------------------------- %
        
        function self = process(self, objPI)
        %process - Run the processing
        %
        %   OBJ = process(OBJ, OBJ_PI) runs the processing on the
        %   CalcDetectSigs object OBJ using the CellScan object OBJ_PI.
        %
        %   See also CellScan.process, CellScan
        
            % Check the number of input arguments
            narginchk(2, 2);
        
            % Check the ProcessedImg
            self.check_objPI(objPI);
            
            % Pull out any properties from the metadata that the calc
            % object will need
            frameRate = objPI.rawImg.metadata.frameRate;
            
            % Extract the traces
            tracesNorm = objPI.calcMeasureROIs.data.tracesNorm;
            roiNames = objPI.calcFindROIs.data.roiNames;
            
            % Do the calculation
            self = self.detect_sigs(tracesNorm, frameRate, roiNames);
            
        end
        
    end
    
    % ================================================================== %
    
    methods (Abstract, Access = protected)
        
        self = detect_sigs(self, traces, frameRate, roiNames)
        
        % -------------------------------------------------------------- %
        
        annotate_traces(self, objPI, hAxTraces, varargin)
        
        % -------------------------------------------------------------- %
        
        varargout = plot_clsfy(self, hAxes, varargin)
        
        % -------------------------------------------------------------- %
        
        varargout = plot_signals(self, objPI, varargin)
        
    end
    
    % ================================================================== %
    
end
