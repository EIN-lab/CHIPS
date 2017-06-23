classdef (Abstract) CalcFindROIsFLIKA < CalcFindROIs
%CalcFindROIsFLIKA - Superclass for FLIKA-based ROI identification
%
%   The CalcFindROIsFLIKA class is a Calc class that implements the FLIKA
%   algorithm for ROI identification. For further information about FLIKA,
%   please refer to <a href="matlab:web('http://dx.doi.org/10.1016/j.ceca.2014.06.003', '-browser')">Ellefsen et al. (2014)</a>, Cell Calcium 56(3):147-156.
%
%   CalcFindROIsFLIKA is a subclass of matlab.mixin.Copyable, which is
%   itself a subclass of handle, meaning that CalcFindROIsFLIKA objects are
%   actually references to the data contained in the object.  This allows
%   certain features that are only possible with handle objects, such as
%   events and certain GUI operations.  However, it is important to use the
%   copy method of matlab.mixin.Copyable to create a new, independent
%   object; otherwise changes to a CalcFindROIsFLIKA object used in one
%   place will also lead to changes in another (perhaps undesired) place.
%
% CalcFindROIsFLIKA public properties
%   config          - A scalar ConfigFindROIsFLIKA object
%   data            - A scalar DataFindROIsFLIKA object
%
% CalcFindROIsFLIKA public methods
%   CalcFindROIsFLIKA - CalcFindROIsFLIKA class constructor
%   copy            - Copy MATLAB array of handle objects
%   get_roiMask     - Extract ROI mask
%   measure_ROIs    - Measure the ROI masks and return the traces
%   plot            - Plot a figure
%   process         - Run the processing
%
%   See also CalcFindROIsFLIKA_2D, CalcFindROIsFLIKA_2p5D,
%   CalcFindROIsFLIKA_3D, CalcFindROIs, Calc, ConfigFindROIsFLIKA,
%   DataFindROIsFLIKA, CellScan

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
    
    properties (Abstract, Constant, Access=protected)
        fracDetect
    end
    
    % ------------------------------------------------------------------ %
    
    properties (Constant, Access=protected)
        strMsg = 'Finding ROIs';
    end
    
    % ================================================================== %
    
    methods
        
        function CalcFindROIsFLIKAObj = CalcFindROIsFLIKA(varargin)
        %CalcFindROIsFLIKA - CalcFindROIsFLIKA class constructor
        %
        %   OBJ = CalcFindROIsFLIKA() prompts for all required information
        %   and creates a CalcFindROIsFLIKA object.
        %
        %   OBJ = CalcFindROIsFLIKA(CONFIG, DATA) uses the specified CONFIG
        %   and DATA objects to construct the CalcFindROIsFLIKA object. If
        %   any of the input arguments are empty, the constructor will
        %   prompt for any required information.  The input arguments must
        %   be objects which meet the requirements of the particular
        %   concrete subclass of CalcFindROIsFLIKA.
        %
        %   See also ConfigFindROIsFLIKA, DataFindROIsFLIKA
        
            % Parse arguments
            [configIn, dataIn] = utils.parse_opt_args({[], []}, varargin);
            
            % Call CalcFindROIs (i.e. parent class) constructor
            CalcFindROIsFLIKAObj = ...
                CalcFindROIsFLIKAObj@CalcFindROIs(configIn, dataIn);
            
        end
        
    end
    
    % ================================================================== %
    
    methods (Access = protected)
        
        self = find_ROIs(self, objPI)
        
        [self, puffBool] = detectPuffingPixels(self, normFiltSeq, frameRate)
        
        maskOut = dilate_erode(self, maskIn, pixelSize, frameRate)
        
        [pixelMask, puffMask, significantMask] = ROIsToMask(self)
        
        plot_imgs_sub(self, objPI, hAxes, varargin)
        
        % -------------------------------------------------------------- %
        
        function validConfig = get_validConfig(~)
            validConfig = {'ConfigFindROIsFLIKA'};
        end

    end
    
    % ================================================================== %
    
    methods (Abstract, Access = protected)
        
        [puffSignificantMask, roiMask, stats] = create_roiMask(self, ...
            dims, pixelIdxs, pixelSize, frameRate)
        
        self = add_data(self, puffSignificantMask, roiMask, ...
            stats, roiNames)
        
    end
    
    % ================================================================== %
    
end
