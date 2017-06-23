classdef CalcDiameterTiRS < CalcDiameterXSect
%CalcDiameterTiRS - Class to calculate diameter using the TiRS approach
%
%   The CalcDiameterTiRS class is Calc class that implements all basic
%   functionality related to calculating the diameter of images using the
%   thresholding in Radon space (TiRS) algorithm. For further information
%   on the TiRS algorithm, please refer to <a href="matlab:web('http://dx.doi.org/doi:10.1038/jcbfm.2014.67', '-browser')">Gao and Drew (2014)</a>, J Cereb
%   Blood Flow Metab 34(7):1180-1187.
%
%   CalcDiameterTiRS is a subclass of matlab.mixin.Copyable, which is
%   itself a subclass of handle, meaning that CalcDiameterTiRS objects are
%   actually references to the data contained in the object.  This allows
%   certain features that are only possible with handle objects, such as
%   events and certain GUI operations.  However, it is important to use the
%   copy method of matlab.mixin.Copyable to create a new, independent
%   object; otherwise changes to a CalcDiameterTiRS object used in one
%   place will also lead to changes in another (perhaps undesired) place.
%
% CalcDiameterTiRS public properties
%   config          - A scalar ConfigDiameterTiRS object
%   data            - A scalar DataDiameterTiRS object
%
% CalcDiameterTiRS public methods
%   CalcDiameterTiRS - CalcDiameterTiRS class constructor
%   copy            - Copy MATLAB array of handle objects
%   plot            - Plot a figure
%   process         - Run the processing
%
%   See also CalcDiameterXSect, Calc, ConfigDiameterTiRS, DataDiameterTiRS,
%   XSectScan

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
        validConfig = {'ConfigDiameterTiRS'};
        validData = {'DataDiameterTiRS'};
        validPlotNames = {'default'};
        validProcessedImg = {'XSectScan'};
    end
    
    % ================================================================== %
    
    methods
        
        function CalcDiamTiRSObj = CalcDiameterTiRS(varargin)
        %CalcDiameterTiRS - CalcDiameterTiRS class constructor
        %
        %   OBJ = CalcDiameterTiRS() prompts for all required information
        %   and creates a CalcDiameterTiRS object.
        %
        %   OBJ = CalcDiameterTiRS(CONFIG, DATA) uses the specified CONFIG
        %   and DATA objects to construct the CalcDiameterTiRS object. If
        %   any of the input arguments are empty, the constructor will
        %   prompt for any required information.  The input arguments must
        %   be scalar ConfigDiameterTiRS and/or DataDiameterTiRS objects.
        %
        %   See also ConfigDiameterTiRS, DataDiameterTiRS
            
            % Call parent class constructor
            CalcDiamTiRSObj = ...
                CalcDiamTiRSObj@CalcDiameterXSect(varargin{:});
            
        end
        
    end
    
    % ================================================================== %
    
    methods (Access = protected)
        
        self = calc_diameter(self, imgSeq, frameRate, doInvert, t0)
        
        % -------------------------------------------------------------- %
        
        self = post_process_diameter(self, pixelSize)
        
        % -------------------------------------------------------------- %
        
        varargout = plot_default(self, objPI, hAx, varargin)
        
    end
    
    % ================================================================== %
    
    methods (Static, Access = protected)
        
        function configObj = create_config()
            configObj = ConfigDiameterTiRS();
        end
        
        % -------------------------------------------------------------- %
        
        function dataObj = create_data()
            dataObj = DataDiameterTiRS();
        end
        
    end
    
    % ================================================================== %
    
end
