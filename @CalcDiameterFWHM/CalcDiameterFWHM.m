classdef CalcDiameterFWHM < CalcDiameterLong
%CalcDiameterFWHM - Class to calculate diameter using the FWHM approach
%
%   The CalcDiameterFWHM class is Calc class that implements all basic
%   functionality related to calculating the diameter of images using the
%   full width at half maximum (FWHM) approach.
%
%   CalcDiameterFWHM is a subclass of matlab.mixin.Copyable, which is
%   itself a subclass of handle, meaning that CalcDiameterFWHM objects are
%   actually references to the data contained in the object.  This allows
%   certain features that are only possible with handle objects, such as
%   events and certain GUI operations.  However, it is important to use the
%   copy method of matlab.mixin.Copyable to create a new, independent
%   object; otherwise changes to a CalcDiameterFWHM object used in one
%   place will also lead to changes in another (perhaps undesired) place.
%
% CalcDiameterFWHM public properties
%   config          - A scalar ConfigDiameterFWHM object
%   data            - A scalar DataDiameterFWHM object
%
% CalcDiameterFWHM public methods
%   CalcDiameterFWHM - CalcDiameterFWHM class constructor
%   copy            - Copy MATLAB array of handle objects
%   plot            - Plot a figure
%   process         - Run the processing
%
%   See also CalcDiameterLong, Calc, ConfigDiameterFWHM, DataDiameterFWHM,
%   LineScanDiam, FrameScan, ICalcDiameterLong

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
    
    properties (Constant, Access = protected)
        validConfig = {'ConfigDiameterFWHM'};
        validData = {'DataDiameterFWHM'};
        validPlotNames = {'default', 'graphs', 'diam_profile'};
        validProcessedImg = {'LineScanDiam', 'FrameScan'}
    end
    
    % ================================================================== %
    
    methods
        
        function CalcDiameterFWHMObj = CalcDiameterFWHM(varargin)
        %CalcDiameterFWHM - CalcDiameterFWHM class constructor
        %
        %   OBJ = CalcDiameterFWHM() prompts for all required information
        %   and creates a CalcDiameterFWHM object.
        %
        %   OBJ = CalcDiameterFWHM(CONFIG, DATA) uses the specified CONFIG
        %   and DATA objects to construct the CalcDiameterFWHM object. If
        %   any of the input arguments are empty, the constructor will
        %   prompt for any required information.  The input arguments must
        %   be scalar ConfigDiameterFWHM and/or DataDiameterFWHM objects.
        %
        %   See also ConfigDiameterFWHM, DataDiameterFWHM
            
             % Call parent class constructor
            CalcDiameterFWHMObj = ...
                CalcDiameterFWHMObj@CalcDiameterLong(varargin{:});
            
        end
        
    end
    
    % ================================================================== %
        
    methods (Access = protected)
        
        varargout = plot_default(self, objPI, hdlGraphsTime, varargin)
        
        % -------------------------------------------------------------- %
        
        varargout = plot_graphs(self, objPI, hAx, varargin)
        
        % -------------------------------------------------------------- %
        
        varargout = plot_diam_profile(self, objPI, hAx, varargin)
        
        % -------------------------------------------------------------- %
        
        function [self, pixelWidth] = calc_diameter(self, diamProfile, ...
                lineRate, t0, doInvert)
            
            [self, pixelWidth] = self.calc_diameter_fwhm(diamProfile, ...
                lineRate, t0, doInvert);
            
        end
        
        % -------------------------------------------------------------- %
        
        [self, pixelWidth] = calc_diameter_fwhm(self, diamProfile, ...
            lineRate, t0, doInvert);
        
        % -------------------------------------------------------------- %
        
        self = post_process_diameter(self, pixelWidth, pixelSize)
        
    end
    
    % ================================================================== %
    
    methods (Static, Access = protected)
        
        function configObj = create_config()
            configObj = ConfigDiameterFWHM();
        end
        
        % -------------------------------------------------------------- %
        
        function dataObj = create_data()
            dataObj = DataDiameterFWHM();
        end
        
    end
    
    % ================================================================== %
    
end
