classdef (Abstract) CalcDiameterLong < CalcDiameter
%CalcDiameterLong - Superclass for CalcDiameterLong classes
%
%   CalcDiameterLong is an abstract superclass that implements (or requires
%   implementation in its subclasses via abstract methods or properties)
%   most functionality related to CalcDiameterLong objects.  Typically
%   there is one concrete subclass of CalcDiameterLong for every
%   calculation algorithm, and it contains the algorithm-specific code that
%   is needed for the calculation.
%
%   CalcDiameterLong is a subclass of matlab.mixin.Copyable, which is
%   itself a subclass of handle, meaning that CalcDiameterLong objects are
%   actually references to the data contained in the object.  This allows
%   certain features that are only possible with handle objects, such as
%   events and certain GUI operations.  However, it is important to use the
%   copy method of matlab.mixin.Copyable to create a new, independent
%   object; otherwise changes to a CalcDiameterLong object used in one
%   place will also lead to changes in another (perhaps undesired) place.
%
% CalcDiameterLong public properties
%   config          - A scalar Config object
%   data            - A scalar DataDiameter object
%
% CalcDiameterLong public methods
%   CalcDiameterLong - CalcDiameterLong class constructor
%   copy            - Copy MATLAB array of handle objects
%   plot            - Plot a figure
%   process         - Run the processing
%
%   See also CalcDiameterFWHM, Calc, Config, DataDiameter, LineScanDiam,
%   FrameScan, ICalcDiameterLong

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
    
    methods
        
        function CalcDiamLongObj = CalcDiameterLong(varargin)
        %CalcDiameterLong - CalcDiameterLong class constructor
        %
        %   OBJ = CalcDiameterLong() prompts for all required information
        %   and creates a CalcDiameterLong object.
        %
        %   OBJ = CalcDiameterLong(CONFIG, DATA) uses the specified CONFIG
        %   and DATA objects to construct the CalcDiameterLong object. If
        %   any of the input arguments are empty, the constructor will
        %   prompt for any required information.  The input arguments must
        %   be objects which meet the requirements of the particular
        %   concrete subclass of CalcDiameterLong.
        %
        %   See also Config, DataDiameter
            
            % Call parent class constructor
            CalcDiamLongObj = CalcDiamLongObj@CalcDiameter(varargin{:});
            
        end
        
        % -------------------------------------------------------------- %
        
        varargout = plot(self, objPI, varargin)
        
        % -------------------------------------------------------------- %
        
        function self = process(self, objPI)
        %process - Run the processing
        %
        %   OBJ = process(OBJ, OBJ_PI) runs the processing on the
        %   CalcDiameterLong object OBJ using the CellScan object OBJ_PI.
        %
        %   See also LineScanDiam.process, FrameScan.process, LineScanDiam,
        %   FrameScan, ICalcDiameterLong
        
            % Check the number of input arguments
            narginchk(2, 2);
        
            % Check the ProcessedImg
            self.check_objPI(objPI);
        
            % Pull out some properties
            pixelSize = objPI.rawImg.metadata.pixelSize;
            t0 = objPI.rawImg.t0;
            doInvert = objPI.isDarkPlasma;
            
            % Extract diameter profile
            [diamProfile, lineRate] = objPI.get_diamProfile();
            
            % Adjust diamProfile as necessary
            [diamProfile, lineRate] = self.adjust_diamProfile(...
                diamProfile, lineRate);
            
            % Do the calculation
            [self, pixelWidth] = self.calc_diameter(diamProfile, ...
                lineRate, t0, doInvert);
            
            % Do the post-processing
            self = self.post_process_diameter(pixelWidth, pixelSize);
            
        end
        
    end
    
    % ================================================================== %
    
    methods (Access = protected)
        
        [diamProfile, lineRate] = adjust_diamProfile(self, ...
                diamProfile, lineRate)
            
    end
    
    % ================================================================== %
    
    methods (Abstract, Access = protected)
        
        varargout = plot_default(self, objPI, hdlGraphsTime, varargin)
        
        varargout = plot_diam_profile(self, objPI, hAx, varargin)
        
        varargout = plot_graphs(self, objPI, hAx, varargin)
        
        self = post_process_diameter(self, pixelWidth, pixelSize)
            
    end
    
    % ================================================================== %
    
end
