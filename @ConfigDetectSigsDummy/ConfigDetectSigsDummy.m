classdef ConfigDetectSigsDummy < ConfigDetectSigs
%ConfigDetectSigsDummy - Parameters for dummy signal detection
%
%   The ConfigDetectSigsDummy class is a configuration class that contains
%   the parameters necessary for dummy signal detection.
%
%   ConfigDetectSigsDummy is a subclass of matlab.mixin.Copyable, which is
%   itself a subclass of handle, meaning that ConfigDetectSigsDummy objects
%   are actually references to the data contained in the object.  This
%   allows certain features that are only possible with handle objects,
%   such as events and certain GUI operations.  However, it is important to
%   use the copy method of matlab.mixin.Copyable to create a new,
%   independent object; otherwise changes to a ConfigDetectSigsDummy object
%   used in one place will also lead to changes in another (perhaps
%   undesired) place.
%   
% ConfigDetectSigsDummy public methods
%   ConfigDetectSigsDummy - ConfigDetectSigsDummy class constructor
%   copy            - Copy MATLAB array of handle objects
%   create_calc     - Return a Calc object containing the Config object
%   get_dims        - Return the dimensions needed for the opt_config GUI
%   opt_config      - Optimise parameters using a GUI
%
% ConfigDetectSigsDummy static methods
%   from_preset     - Create a ConfigDetectSigsDummy object from a preset
%
% ConfigDetectSigsDummy public events:
%   ProcessNow      - Notifies listeners to process an object
%
%   See also ConfigDetectSigsClsfy, ConfigDetectSigs, Config,
%   ConfigCellScan, CalcDetectSigsDummy, CellScan

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
        
        %classCalc - Constant, protected property containing the name of
        %   the associated Calc class
        classCalc = 'CalcDetectSigsDummy';
        
        optList = {};
        
    end
    
    % ================================================================== %
    
    methods
        
        function cdsdObj = ConfigDetectSigsDummy(varargin)
        %ConfigDetectSigsDummy - ConfigDetectSigsDummy class constructor
        %
        %   OBJ = ConfigDetectSigsDummy() creates a ConfigDetectSigsDummy
        %   object OBJ with default values for all properties.
        %
        %   OBJ = ConfigDetectSigsDummy(..., 'property', value, ...) or
        %   OBJ = ConfigDetectSigsDummy(..., propStruct, ...) 
        %
        %   This syntax specifies values for the properties, either in the
        %   form of attribute-value pairs, or structures (or objects) where
        %   the field (property) names correspond to properties in the
        %   ConfigDetectSigsDummy class. The argument parsing is done by
        %   the utility function parsepropval (link below), so please
        %   consult the documentation for this function for more details.
        %
        %   See also utils.parsepropval,
        %   ConfigDetectSigsDummy.from_preset, ConfigDetectSigsClsfy,
        %   ConfigDetectSigs, Config, ConfigCellScan, CalcDetectSigsDummy,
        %   CellScan
        
            % Call Config (i.e. parent class) constructor
            cdsdObj = cdsdObj@ConfigDetectSigs(varargin{:});
            
        end
        
    end
    
    % ================================================================== %
    
end
