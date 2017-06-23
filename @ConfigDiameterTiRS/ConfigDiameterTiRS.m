classdef ConfigDiameterTiRS < Config
%ConfigDiameterTiRS - Parameters for TiRS-based diameter calculation
%
%   The ConfigDiameterTiRS class is a configuration class that contains the
%   parameters necessary for calculating diameters based on the
%   thresholding in Radon space (TiRS) algorithm. For more information on
%   the TiRS algorithm, please refer to the documentation of
%   CalcDiameterTiRS, or <a href="matlab:web('http://dx.doi.org/doi:10.1038/jcbfm.2014.67', '-browser')">Gao and Drew (2014)</a>, J Cereb Blood Flow Metab
%   34(7):1180-1187.
%
% ConfigDiameterTiRS public properties
%   connectivity    - Connectivity to identify connected components
%   thresholdFWHM	- Threshold to calculate the FWHM in Radon space
%   thresholdInv	- Threshold to calculate the final vessel lumen area
%   thresholdSTD    - The std dev multiple at which to exclude data
%   
% ConfigDiameterTiRS public methods
%   ConfigDiameterTiRS - ConfigDiameterTiRS class constructor
%   copy            - Copy MATLAB array of handle objects
%   create_calc     - Return a Calc object containing the Config object
%   get_dims        - Return the dimensions needed for the opt_config GUI
%   opt_config      - Optimise parameters using a GUI
%
% ConfigDiameterTiRS static methods
%   from_preset     - Create a ConfigDiameterTiRS object from a preset
%
% ConfigDetectSigsDummy public events:
%   ProcessNow      - Notifies listeners to process an object
%
%   See also Config, CalcDiameterTiRS, XSectScan
    
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
    
    properties
        
        %connectivity - Connectivity to identify connected components
        %
        %   A scalar number specifying the connectivity value to use when
        %   separating the final image mask into connected components.
        %   (The largest component is assumed to be the vessel lumen.)
        %   [default = 8]
        %
        %   See also bwconncomp
        connectivity = 8;
        
        %thresholdFWHM - Threshold to calculate the FWHM in Radon space
        %
        %   A scalar number between 0 and 1 representing the normalised
        %   intensity of the Radon transform image at a given angle that
        %   should be used to calculate the area of the vessel lumen.
        %   Higher values for thresholdFWHM lead to smaller diameters, and
        %   vice versa. [default = 0.35];
        %
        %   See also utils.fwhm
        thresholdFWHM = 0.35;
        
        %thresholdInv - Threshold to calculate the final vessel lumen area
        %
        %   A scalar number between 0 and 1 representing the normalised
        %   intensity of the inverted, thresholded Radon transform image to
        %   calculate the final area of the vessel lumen. Higher values for
        %   thresholdFWHM lead to smaller diameters, and vice versa.
        %   [default = 0.2];
        thresholdInv = 0.2;
        
        %thresholdSTD - The std dev multiple at which to exclude data
        %
        %   A scalar number representing the number of standard deviations
        %   away from the median at which the diameter data will be
        %   considered 'bad' and flagged. [default = 3]
        %
        %   See also DataDiameter.maskSTD
        thresholdSTD = 3;
        
    end
    
    % ------------------------------------------------------------------ %
    
    properties (Constant, Access = protected)
        
        classCalc = 'CalcDiameterTiRS';
        
        optList = {...
            'TiRS', {'connectivity', 'thresholdFWHM', 'thresholdInv'}; ...
            'Postprocessing', {'thresholdSTD'}};
        
    end
    
    % ================================================================== %
    
    methods
        
        function ConfigDiamTiRSObj = ConfigDiameterTiRS(varargin)
        %ConfigDiameterTiRS - ConfigDiameterTiRS class constructor
        %
        %   OBJ = ConfigDiameterTiRS() creates a Config object OBJ with
        %   default values for all properties.
        %
        %   OBJ = ConfigDiameterTiRS(..., 'property', value, ...) or
        %   OBJ = ConfigDiameterTiRS(..., propStruct, ...) 
        %
        %   This syntax specifies values for the properties, either in the
        %   form of attribute-value pairs, or structures (or objects) where
        %   the field (property) names correspond to properties in the
        %   ConfigDiameterTiRS class. The argument parsing is done by
        %   the utility function parsepropval (link below), so please
        %   consult the documentation for this function for further
        %   details.
        %
        %   See also ConfigDiameterTiRS.from_preset, utils.parsepropval,
        %   Config
        
            % Call parent class constructor
            ConfigDiamTiRSObj = ConfigDiamTiRSObj@Config(varargin{:});
            
        end
        
        % -------------------------------------------------------------- %
        
        function self = set.connectivity(self, val)
            isValid = ismember(val, [4 8]);
            if ~isValid
                error('ConfigDiameterTiRS:BadConnectivity', ['The ' ...
                    'value for connectivity must be either 4 or 8'])
            end
            self.connectivity = val;
        end
        
        % -------------------------------------------------------------- %
        
        function self = set.thresholdFWHM(self, val)
            utils.checks.prfs(val, 'thresholdFWHM')
            utils.checks.less_than(val, [], [], 'thresholdFWHM')
            self.thresholdFWHM = val;
        end
        
        % -------------------------------------------------------------- %
        
        function self = set.thresholdInv(self, val)
            utils.checks.prfs(val, 'thresholdInv')
            utils.checks.less_than(val, [], [], 'thresholdInv')
            self.thresholdInv = val;
        end
        
        % -------------------------------------------------------------- %
        
        function self = set.thresholdSTD(self, val)
            utils.checks.prfs(val, 'thresholdSTD')
            self.thresholdSTD = val;
        end
            
    end
    
    % ================================================================== %
    
end
