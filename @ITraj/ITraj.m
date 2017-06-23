classdef (Abstract, Hidden, HandleCompatible) ITraj
%ITraj - Interface for classes that include trajectories

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
    
    properties (Hidden)
        %refImg - A reference RawImg object
        refImg
    end
    
    % ================================================================== %
    
    methods
        
        function self = set.refImg(self, refImg)
            
            % Check the refImg is a rawImg
            varName = 'refImg';
            utils.checks.object_class(refImg, 'RawImgHelper', varName);
            
            % Check that it's scalar
            utils.checks.scalar(refImg, varName);
            
            % Do the other checks
            classImg = class(self);
            reqChAll = {'position_x', 'position_y'};
            reqChAny = {};            
            utils.checks.rawImg(refImg, reqChAll, reqChAny, classImg);
            
            % Set the property
            self.refImg = refImg;
            
        end
        
    end
    
    % ================================================================== %
    
    methods (Abstract, Hidden)
    
        %calc_trajs - Calculate the trajectories
        [trajs, otherChs] = calc_trajs(self, varargin)
        
        %plot_trajs - Plot a figure of the trajectories
        varargout = plot_trajs(self, varargin)
        
    end
    
    % ================================================================== %
    
    methods (Static, Hidden)
        
        %calc_traj - Calculate a single trajectory
        [trajs, otherChs] = calc_traj(refImg, trajImg, varargin)
        
    end
    
    % ================================================================== %
    
    methods (Static, Access = protected)
        
        adjImgData = adj_traj_delay(delayTime, imgData, pixelTime, ...
            xChannel, yChannel)
        
        % -------------------------------------------------------------- %
        
        function trajVals = interp_traj(refCoord, trajCoord)

            maskValid = refCoord > 0;
            idxValid = find(maskValid);
            refCoordValid = refCoord(maskValid);

            trajVals = interp1(refCoordValid, idxValid, trajCoord, ...
                'spline', NaN);

        end
        
    end
    
    % ================================================================== %
    
end

