classdef CalcFindROIsFLIKA_2p5D < CalcFindROIsFLIKA
%CalcFindROIsFLIKA_2p5D - Class for FLIKA-based ROI identification (2.5D)
%
%   The CalcFindROIsFLIKA_2p5D class is a Calc class that implements the
%   2.5D FLIKA algorithm for ROI identification. In the 2.5D case, ROIs are
%   identified in the original 3D mask generated by FLIKA, and then each
%   ROI is collapsed down to a 2D mask. For further information about FLIKA,
%   please refer to <a href="matlab:web('http://dx.doi.org/10.1016/j.ceca.2014.06.003', '-browser')">Ellefsen et al. (2014)</a>, Cell Calcium 56(3):147-156.
%
%   CalcFindROIsFLIKA_2p5D is a subclass of matlab.mixin.Copyable, which is
%   itself a subclass of handle, meaning that CalcFindROIsFLIKA_2p5D
%   objects are actually references to the data contained in the object.
%   This allows certain features that are only possible with handle
%   objects, such as events and certain GUI operations.  However, it is
%   important to use the copy method of matlab.mixin.Copyable to create a
%   new, independent object; otherwise changes to a CalcFindROIsFLIKA_2p5D
%   object used in one place will also lead to changes in another (perhaps
%   undesired) place.
%
% CalcFindROIsFLIKA_2p5D public properties
%   config          - A scalar ConfigFindROIsFLIKA_2p5D object
%   data            - A scalar DataFindROIsFLIKA_2p5D object
%
% CalcFindROIsFLIKA_2p5D public methods
%   CalcFindROIsFLIKA_2p5D - CalcFindROIsFLIKA_2p5D class constructor
%   copy            - Copy MATLAB array of handle objects
%   get_roiMask     - Extract ROI mask
%   measure_ROIs    - Measure the ROI masks and return the traces
%   plot            - Plot a figure
%   process         - Run the processing
%
%   See also CalcFindROIsFLIKA_2D, CalcFindROIsFLIKA_3D, CalcFindROIsFLIKA,
%   CalcFindROIs, Calc, ConfigFindROIsFLIKA_2p5D, DataFindROIsFLIKA_2p5D,
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
        is3D = false;        
    end
    
    % ------------------------------------------------------------------ %
    
    properties (Constant, Access = protected)
        
        fracDetect = 0.5;
        
        %validConfig - Constant, protected property containing the name of
        %   the associated Config class
        validConfig = {'ConfigFindROIsFLIKA_2p5D'};
        
        %validConfig - Constant, protected property containing the name of
        %   the associated Config class
        validData = {'DataFindROIsFLIKA_2p5D'};
        
    end
    
    % ================================================================== %
    
    methods
        
        function CalcFLIKA_2p5DObj = CalcFindROIsFLIKA_2p5D(varargin)
        %CalcFindROIsFLIKA_2p5D - CalcFindROIsFLIKA_2p5D class constructor
        %
        %   OBJ = CalcFindROIsFLIKA_2p5D() prompts for all required
        %   information and creates a CalcFindROIsFLIKA_2p5D object.
        %
        %   OBJ = CalcFindROIsFLIKA_2p5D(CONFIG, DATA) uses the specified
        %   CONFIG and DATA objects to construct the CalcFindROIsFLIKA_2p5D
        %   object. If any of the input arguments are empty, the
        %   constructor will prompt for any required information. The input
        %   arguments must be scalar ConfigFindROIsFLIKA_2p5D and/or
        %   DataFindROIsFLIKA_2p5D objects.
        %
        %   See also ConfigFindROIsFLIKA_2p5D, DataFindROIsFLIKA_2p5D
        
            % Parse arguments
            [configIn, dataIn] = utils.parse_opt_args({[], []}, varargin);
            
            % Call CalcFindROIs (i.e. parent class) constructor
            CalcFLIKA_2p5DObj = ...
                CalcFLIKA_2p5DObj@CalcFindROIsFLIKA(configIn, dataIn);
            
        end
        
    end
    
    % ================================================================== %
    
    methods (Access = protected)
        
        function [puffSignificantMask, roiMask, stats] = ...
                create_roiMask(self, dims, pixelIdxs, pixelSize, frameRate)
            
            % Create stage 3 mask
            puffSignificantMask = false(dims);
            puffSignificantMask(vertcat(pixelIdxs{:})) = true;
            
            % Discard ROIs touching the border, if neccessary
            if self.config.discardBorderROIs        
                maskTemp = imclearborder(puffSignificantMask);
            else
                maskTemp = puffSignificantMask;
            end
            
            % Create the roiMask
            cc_3D = bwconncomp(maskTemp);

            % Loop through the individual ROIs
            isWorker = utils.is_on_worker();
            nROIs = cc_3D.NumObjects;
            for iROI = nROIs:-1:1

                % Create a dummy 3D mask with the appropriate pixels
                dummyImg = false(cc_3D.ImageSize);
                dummyImg(cc_3D.PixelIdxList{iROI}) = true;
                
                % Calculate some stats from the 3D dummy image
                statsTemp3D = regionprops(dummyImg);
                centroid{iROI} = statsTemp3D.Centroid;
                duration(iROI) = statsTemp3D.BoundingBox(end)./frameRate;
                volume(iROI) = statsTemp3D.Area.*(pixelSize.^2)./frameRate;

                % Collapse the mask for this ROI to 2D
                roiMask(:,:,iROI) = sum(dummyImg, 3) > 0;
                
                % Update the progress bar
                if ~isWorker
                    fracNow = self.fracDetect + (1 - self.fracDetect) * ...
                        (nROIs - iROI + 1) / nROIs;
                    utils.progbar(fracNow, 'msg', self.strMsg, ...
                        'doBackspace', true);
                end
                
            end
            
            hasNoROIs = nROIs < 1;
            if hasNoROIs
                
                % Create some dummy arguments
                roiMask = false(cc_3D.ImageSize(1:2));
                stats.Area = NaN;
                stats.Centroid = [NaN, NaN, NaN];
                stats.Duration = NaN;
                stats.PixelIdxList = {NaN};
                stats.Volume = NaN;
                
                % Update the progress bar
                if ~isWorker
                    utils.progbar(1, 'msg', self.strMsg, ...
                        'doBackspace', true);
                end
                
            else
                
                % Get some statistics about the ROIs
                stats = CalcFindROIs.get_ROI_stats(roiMask, pixelSize);

                % Filter out rois that are too small
                maskSize = ([stats.Area] < self.config.minROIArea) | ...
                    ([stats.Area] > self.config.maxROIArea) | ...
                    (duration < self.config.minROITime);
                
                % Filter out the bad ROIs and transpose the cells
                maskFilter = maskSize;
                
                % Special case, where all ROIs are bad
                if all(maskFilter)
                    roiMask = false(cc_3D.ImageSize(1:2));
                    stats = struct();
                    stats.Area = NaN;
                    stats.Centroid = [NaN, NaN, NaN];
                    stats.Duration = NaN;
                    stats.PixelIdxList = {NaN};
                    stats.Volume = NaN;
                else
                    roiMask(:,:,maskFilter) = [];
                    stats(maskFilter) = [];
                    [stats.Centroid] = deal(centroid{~maskFilter});
                    duration = num2cell(duration(~maskFilter));
                    [stats.Duration] = deal(duration{:});
                    volume = num2cell(volume(~maskFilter));
                    [stats.Volume] = deal(volume{:});
                end
                
            end

        end
        
        % -------------------------------------------------------------- %
        
        function self = add_data(self, puffSignificantMask, roiMask, ...
                stats, roiNames)
            
            % Store processed data
            centroids = reshape([stats(:).Centroid], 3, [])';
            self.data = self.data.add_processed_data([stats.Area], ...
                centroids(:,3), centroids(:,1), centroids(:,2), [stats.Duration], ...
                puffSignificantMask, {stats(:).PixelIdxList}', ...
                roiMask, roiNames, [stats.Volume]);
            
        end

    end
    
    % ================================================================== %
    
    methods (Static, Access = protected)
        
        function configObj = create_config()
        %create_config - Creates an object of the associated Config class
        
            configObj = ConfigFindROIsFLIKA_2p5D();
        
        end
        
        % -------------------------------------------------------------- %
        
        function dataObj = create_data()
        %create_data - Creates an object of the associated Data class
            
            dataObj = DataFindROIsFLIKA_2p5D();
        
        end
        
    end
    
    % ================================================================== %
    
end
