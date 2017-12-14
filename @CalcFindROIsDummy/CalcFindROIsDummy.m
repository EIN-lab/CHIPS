classdef CalcFindROIsDummy < CalcFindROIs
%CalcFindROIsDummy - Class for dummy ROI identification
%
%   The CalcFindROIsDummy class is a Calc class that performs dummy ROI
%   finding.  That is, it simply 'finds' previously identified ROIs, or
%   uses the whole frame as a ROI.
%
%   CalcFindROIsDummy is a subclass of matlab.mixin.Copyable, which is
%   itself a subclass of handle, meaning that CalcFindROIsDummy objects are
%   actually references to the data contained in the object.  This allows
%   certain features that are only possible with handle objects, such as
%   events and certain GUI operations.  However, it is important to use the
%   copy method of matlab.mixin.Copyable to create a new, independent
%   object; otherwise changes to a CalcFindROIsDummy object used in one
%   place will also lead to changes in another (perhaps undesired) place.
%
% CalcFindROIsDummy public properties
%   config          - A scalar ConfigFindROIsDummy object
%   data            - A scalar DataFindROIsDummy object
%
% CalcFindROIsDummy public methods
%   CalcFindROIsDummy - CalcFindROIsDummy class constructor
%   copy            - Copy MATLAB array of handle objects
%   get_roiMask     - Extract ROI mask
%   measure_ROIs    - Measure the ROI masks and return the traces
%   plot            - Plot a figure
%   process         - Run the processing
%
%   See also CalcFindROIs, Calc, ConfigFindROIsDummy, DataFindROIsDummy,
%   CellScan

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
    
    properties (Access = protected)
        %is3D - Whether or not the ROI mask is 3D
        is3D
        
        %isLS - Whether or not the RawImg is a linescan
        isLS
    end
    
    % ------------------------------------------------------------------ %
    
    properties (Constant, Access = protected)
        
        %validConfig - Constant, protected property containing the name of
        %   the associated Config class
        validConfig = {'ConfigFindROIsDummy'};
        
        %validData - Constant, protected property containing the name of
        %   the associated Data class
        validData = {'DataFindROIsDummy'};
    end
    
    % ================================================================== %
    
    methods
        
        function CalcFindROIsDummyObj = CalcFindROIsDummy(varargin)
        %CalcFindROIsDummy - CalcFindROIsDummy class constructor
        %
        %   OBJ = CalcFindROIsDummy() prompts for all required information
        %   and creates a CalcFindROIsDummy object.
        %
        %   OBJ = CalcFindROIsDummy(CONFIG, DATA) uses the specified CONFIG
        %   and DATA objects to construct the CalcFindROIsDummy object. If
        %   any of the input arguments are empty, the constructor will
        %   prompt for any required information. The input arguments must
        %   be scalar ConfigFindROIsDummy and/or DataFindROIsDummy objects.
        %
        %   See also ConfigFindROIsDummy, DataFindROIsDummy
        
            % Parse arguments
            [configIn, dataIn] = utils.parse_opt_args({[], []}, varargin);
            
            % Call CalcFindROIs (i.e. parent class) constructor
            CalcFindROIsDummyObj = ...
                CalcFindROIsDummyObj@CalcFindROIs(configIn, dataIn);
            
        end
        
        % --------------------------------------------------------------- %
        
        function [isLS, varargout] = get_LS(self, objPI, varargin)
        %get_LS - Get the linescan
        
            isLS = self.isLS;
            varargout{:} = {[]};
            
            if isLS
                [imgSeq, lineRate] = self.get_diamProfile(objPI, ...
                    varargin{:});
                
                if nargout > 1
                    varargout{1} = imgSeq;
                end
                if nargout > 2
                    varargout{2} = lineRate;
                end
            end
        end
                    
    end
    
    % ================================================================== %
    
    methods (Access = protected)
        
        function self = find_ROIs(self, objPI)
        %find_ROIs - Basic ROI identification
        %
        %   OBJ = find_ROIs(OBJ, IMG) requires passing a CalcFindROIsDummy
        %   object (OBJ) and the image sequence (IMG). find_rois finds the
        %   ROIs based on the information provided in the associated Config
        %   object.
        %
        %   See also ConfigFindROIsDummy, ConfigFindROIsDummy.from_mask,
        %   ConfigFindROIsDummy.from_ImageJ
        
            % Initialise a progress bar
            isWorker = utils.is_on_worker();
            if ~isWorker
                strMsg = 'Finding ROIs';
                utils.progbar(0, 'msg', strMsg);
            end
            
            % Extract the metadata
            pixelSize = objPI.rawImg.metadata.pixelSize;
            imgSeq = squeeze(...
                objPI.rawImg.rawdata(:,:,objPI.channelToUse,:));
        
            % Work out if we want to analyse the whole frame 
            doWholeFrame = isscalar(self.config.roiMask) && ...
                self.config.roiMask;
            if doWholeFrame
                
                % If so, create a completely filled mask
                [nRows, nCols] = size(imgSeq(:,:,1));
                roiMask = true(nRows, nCols);
                roiNames = {'wholeFrame'};
                
            else
                
                % Otherwise use the mask in the config
                roiMask = self.config.roiMask;
                roiNames = self.config.roiNames;
                
            end
            
            % Work out if this is a 3D mask or not
            self.is3D = size(imgSeq, 3) == size(roiMask, 3);
            
            % Work out if this is a linescan mask or not
            self.isLS = size(roiMask, 1) == 1;
            
            % Give the ROIs some names if they don't already have any
            if isempty(roiNames) || isempty(roiNames{:})
                roiNames = utils.create_ROI_names(roiMask, self.is3D);
            end
            
            % Calculate some statistics on the ROIs
            stats = CalcFindROIs.get_ROI_stats(roiMask, pixelSize);
            
            % Update the progress bar
            if ~isWorker
                utils.progbar(1, 'msg', strMsg, 'doBackspace', true);
            end

            % Add the completed mask
            centroids = reshape([stats(:).Centroid], 2, [])';
            self.data = self.data.add_processed_data([stats(:).Area]', ...
                centroids(:,1), centroids(:,2), ...
                {stats(:).PixelIdxList}', roiMask, roiNames);
            
        end
        
        % -------------------------------------------------------------- %
        
        function plot_imgs_sub(self, objPI, hAxes, varargin)
            
            % Disable unused axes
            axis(hAxes([1,3]), 'off')
            
            % Call the superclass method to plot the ROIs
            self.plot(objPI, hAxes(2), 'rois', varargin{:});
            
        end

    end
    
    % ================================================================== %
    
    methods (Static, Access = protected)
        
        function configObj = create_config()
        %create_config - Creates an object of the associated Config class
        
            configObj = ConfigFindROIsDummy();
            
        end
        
        % -------------------------------------------------------------- %
        
        function dataObj = create_data()
        %create_data - Creates an object of the associated Data class
        
            dataObj = DataFindROIsDummy();
            
        end
        
    end
    
    % ================================================================== %
    
end
