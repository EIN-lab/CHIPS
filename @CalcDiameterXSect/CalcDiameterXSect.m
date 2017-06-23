classdef (Abstract) CalcDiameterXSect < CalcDiameter
%CalcDiameterXSect - Superclass for CalcDiameterXSect classes
%
%   CalcDiameterXSect is an abstract superclass that implements (or
%   requires implementation in its subclasses via abstract methods or
%   properties) most functionality related to CalcDiameterXSect objects.
%   Typically there is one concrete subclass of CalcDiameterXSect for every
%   calculation algorithm, and it contains the algorithm-specific code that
%   is needed for the calculation.
%
%   CalcDiameterXSect is a subclass of matlab.mixin.Copyable, which is
%   itself a subclass of handle, meaning that CalcDiameterXSect objects are
%   actually references to the data contained in the object.  This allows
%   certain features that are only possible with handle objects, such as
%   events and certain GUI operations.  However, it is important to use the
%   copy method of matlab.mixin.Copyable to create a new, independent
%   object; otherwise changes to a CalcDiameterXSect object used in one
%   place will also lead to changes in another (perhaps undesired) place.
%
% CalcDiameterXSect public properties
%   config          - A scalar Config object
%   data            - A scalar DataDiameter object
%
% CalcDiameterXSect public methods
%   CalcDiameterXSect - CalcDiameterXSect class constructor
%   copy            - Copy MATLAB array of handle objects
%   plot            - Plot a figure
%   process         - Run the processing
%
%   See also CalcDiameterTiRS, Calc, Config, DataDiameter, XSectScan

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
        
        function CalcDiamXSectObj = CalcDiameterXSect(varargin)
        %CalcDiameterXSect - CalcDiameterXSect class constructor
        %
        %   OBJ = CalcDiameterXSect() prompts for all required information
        %   and creates a CalcDiameterXSect object.
        %
        %   OBJ = CalcDiameterXSect(CONFIG, DATA) uses the specified CONFIG
        %   and DATA objects to construct the CalcDiameterXSect object. If
        %   any of the input arguments are empty, the constructor will
        %   prompt for any required information.  The input arguments must
        %   be objects which meet the requirements of the particular
        %   concrete subclass of CalcDiameterXSect.
        %
        %   See also Config, DataDiameter
            
            % Call parent class constructor
            CalcDiamXSectObj = CalcDiamXSectObj@CalcDiameter(varargin{:});
            
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
            
            % Check for the image processing toolbox
            feature = 'Image_Toolbox';
            className = 'CalcDiameterTiRS';
            utils.verify_license(feature, className);
            
            % Check the ProcessedImg
            self.check_objPI(objPI);
            
            % Prepare the image sequence
            imgSeq = squeeze(...
                objPI.rawImg.rawdata(:,:,objPI.channelToUse,:));
            
            % Pull out some properties
            pixelSize = objPI.rawImg.metadata.pixelSize;
            frameRate = objPI.rawImg.metadata.frameRate;
            doInvert = objPI.isDarkPlasma;
            t0 = objPI.rawImg.t0;
            
            % Do the calculation
            self = self.calc_diameter(imgSeq, frameRate, doInvert, t0);
            
            % Do the post-processing
            self = self.post_process_diameter(pixelSize);
            
        end
        
    end
    
    % ================================================================== %
    
    methods (Abstract, Access = protected)
        
        varargout = plot_default(self, objPI, hAx, varargin)
        
        self = post_process_diameter(self, pixelSize)
        
    end
    
    % ================================================================== %
    
end
