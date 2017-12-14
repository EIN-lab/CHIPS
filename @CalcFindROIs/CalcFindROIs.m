classdef (Abstract) CalcFindROIs < Calc & IMeasureROIs
%CalcFindROIs - Superclass for CalcFindROIs classes
%
%   CalcFindROIs is an abstract superclass that implements (or requires
%   implementation in its subclasses via abstract methods or properties)
%   most functionality related to CalcFindROIs objects.  Typically there is
%   one concrete subclass of CalcFindROIs for every calculation algorithm,
%   and it contains the algorithm-specific code that is needed for the
%   calculation.
%
%   CalcFindROIs is a subclass of matlab.mixin.Copyable, which is itself a
%   subclass of handle, meaning that CalcFindROIs objects are actually
%   references to the data contained in the object.  This allows certain
%   features that are only possible with handle objects, such as events and
%   certain GUI operations.  However, it is important to use the copy
%   method of matlab.mixin.Copyable to create a new, independent object;
%   otherwise changes to a CalcFindROIs object used in one place will also
%   lead to changes in another (perhaps undesired) place.
%
% CalcFindROIs public properties
%   config          - A scalar ConfigFindROIs object
%   data            - A scalar DataFindROIs object
%
% CalcFindROIs public methods
%   CalcFindROIs    - CalcFindROIs class constructor
%   copy            - Copy MATLAB array of handle objects
%   get_roiMask     - Extract ROI mask
%   measure_ROIs    - Measure the ROI masks and return the traces
%   plot            - Plot a figure
%   process         - Run the processing
%
%   See also CalcFindROIsDummy, CalcFindROIsFLIKA, CalcFindROIsFLIKA_2D,
%   CalcFindROIsFLIKA_2p5D, CalcFindROIsFLIKA_3D, Calc, ConfigFindROIs,
%   DataFindROIs, CellScan

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
    
    properties (Abstract, Access = protected)
        %is3D - Whether or not the ROI mask is 3D
        is3D
        
        %isLS - Whether or not the RawImg is a linescan
        isLS
    end
    
    % ------------------------------------------------------------------ %
    
    properties (Constant, Access = protected)
        validPlotNames = {'images', 'rois', 'video', 'pc_filters', ...
            'pc_spectrum', 'ica_traces'};
        validProcessedImg = {'CellScan'};
    end
    
    % ================================================================== %
    
    methods
        
        function CalcFindROIsObj = CalcFindROIs(varargin)
        %CalcFindROIs - CalcFindROIs class constructor
        %
        %   OBJ = CalcFindROIs() prompts for all required information and
        %   creates a CalcFindROIs object.
        %
        %   OBJ = CalcFindROIs(CONFIG, DATA) uses the specified CONFIG
        %   and DATA objects to construct the CalcFindROIs object. If any
        %   of the input arguments are empty, the constructor will prompt
        %   for any required information.  The input arguments must be
        %   objects which meet the requirements of the particular concrete
        %   subclass of CalcFindROIs.
        %
        %   See also ConfigFindROIs, DataFindROIs
        
            % Parse arguments
            [configIn, dataIn] = utils.parse_opt_args({[], []}, varargin);
            
            % Call Calc (i.e. parent class) constructor
            CalcFindROIsObj = CalcFindROIsObj@Calc(configIn, dataIn);
            
        end
        
        % -------------------------------------------------------------- %
        
        function [isLS, varargout] = get_LS(self, ~, varargin)
        %get_LS - Get the linescan
        
            isLS = self.isLS;
            varargout(:) = {[]};

        end
        
        % -------------------------------------------------------------- %
        
        function roiMask = get_roiMask(self)
        %get_roiMask - Extract ROI mask
        %
        %   MASK = get_roiMask(OBJ) extracts the ROI mask from the
        %   CalcFindROIs object's associated data class.
        %
        %   See also DataFindROIs.roiMask
        
            % Extract ROI mask from data
            roiMask = self.data.roiMask;
            
        end
        
        % -------------------------------------------------------------- %
        
        varargout = plot(self, objPI, varargin)
        
        % -------------------------------------------------------------- %
        
        function self = process(self, objPI)
        %process - Run the processing
        %
        %   OBJ = process(OBJ, OBJ_PI) runs the processing on the
        %   CalcFindROIs object OBJ using the CellScan object OBJ_PI.
        %
        %   See also CellScan.process, CellScan
        
            % Check the number of input arguments
            narginchk(2, 2);
        
            % Check the ProcessedImg
            self.check_objPI(objPI);
            
            % Do the calculation
            self = self.find_ROIs(objPI);
            
        end
        
        % -------------------------------------------------------------- %
        
        [traces, tracesExist] = measure_ROIs(self, objPI)
        
    end
    
    % ================================================================== %
    
    methods (Access = protected)
        
        varargout = get_diamProfile(self, objPI, varargin)
                       
        % -------------------------------------------------------------- %
        
        varargout = plot_imgs(self, objPI, hAxes, varargin)
                       
        % -------------------------------------------------------------- %
        
        varargout = plot_ROIs(self, objPI, hAxes, varargin)
        
        % -------------------------------------------------------------- %
        
        function varargout = plot_ICAsigs(~, ~, ~)
            warning('CalcFindROIs:PlotICASigs:NoICAs', ...
                'This plot does not produce any output for this class')
            if nargout > 0
                varargout{1} = [];
            end
        end
        
        % -------------------------------------------------------------- %
        
        function varargout = plot_pcs(~, ~, ~)
            warning('CalcFindROIs:PlotPCFilters:NoPCs', ...
                'This plot does not produce any output for this class')
            if nargout > 0
                varargout{1} = [];
            end
        end
        
        % -------------------------------------------------------------- %
        
        function varargout = plot_PCspectrum(~, ~, ~)
            warning('CalcFindROIs:PlotPCSpectrum:NoPCs', ...
                'This plot does not produce any output for this class')
            if nargout > 0
                varargout{1} = [];
            end
        end
        
        % -------------------------------------------------------------- %
        
        [roiImg, nROIs] = plot_ROI_layers(self, roiMask, varargin)
        
        % -------------------------------------------------------------- %
        
        [combinedImg, nROIs, barLabel] = plot_ROI_img(self, objPI, ...
            varargin)
        
        % -------------------------------------------------------------- %
        
        plot_video(self, objPI, varargin)
        
    end
    
    % ================================================================== %
    
    methods (Abstract, Access = protected)
        
        %find_rois - An abstract, protected method to implement the ROI
        %   segmentation algorithm
        self = find_ROIs(self, objPI)
        
        % -------------------------------------------------------------- %
        
        plot_imgs_sub(self, objPI, hAxes, varargin)
        
    end
    
    % ================================================================== %
    
    methods (Static, Access = protected)
        
        stats = get_ROI_stats(roiMask, pixelSize)
        
        % -------------------------------------------------------------- %
        
        trace = measure_ROI(imgSeq, xIdx, yIdx, propagateNaNs)
        
    end
    
    % ================================================================== %
    
end
