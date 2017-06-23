classdef (ConstructOnLoad) ED_ProcessNow < event.EventData
%ED_ProcessNow - Event Data for Config.ProcessNow event
%
% ED_ProcessNow public properties:
%   objPI           - The ProcessedImg object to be processed
%   calcName        - The Calc, within the ProcessedImg, to be processed
%
% ED_ProcessNow public methods:
%   ED_ProcessNow   - ED_ProcessNow class constructor
%
%   See also event.EventData, ProcessedImg.process, Config.ProcessNow,
%   ProcessedImg, Config
    
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
        
        %objPI - The ProcessedImg object to be processed
        objPI = [];
        
        %calcName - The Calc, within the ProcessedImg, to be processed
        calcName = '';
        
    end
    
    % ================================================================== %
    
	methods
        
        function eventData = ED_ProcessNow(objPI, calcName)
        %ED_ProcessNow - ED_ProcessNow class constructor
        %
        %   OBJ = ED_ProcessNow(OBJ_PI, CALCNAME) creates an ED_ProcessNow
        %   object with the specified values for OBJ_PI and calcName.
        %   OBJ_PI must be a scalar ProcessedImg object, and CALCNAME must
        %   be a single row character array corresponding to a valid calc
        %   property within OBJ_PI.
            eventData.objPI = objPI;
            eventData.calcName = calcName;
        end
        
    end
    
    % ================================================================== %
    
end
