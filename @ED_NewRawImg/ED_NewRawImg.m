classdef (ConstructOnLoad) ED_NewRawImg < event.EventData
%ED_NewRawImg - Event Data for IRawImg.NewRawImg event
%
% ED_NewRawImg public properties:
%   wasEmpty	- Whether or not the rawImg property was previously empty
%
% ED_NewRawImg public methods:
%   ED_NewRawImg - ED_NewRawImg class constructor
%
%   See also event.EventData, IRawImg.rawImg, IRawImg.NewRawImg, IRawImg
    
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
        
        %wasEmpty - Whether or not the rawImg property was previously empty
        wasEmpty = true;
        
    end
    
    % ================================================================== %
    
	methods
        
        function eventData = ED_NewRawImg(value)
        %ED_NewRawImg - ED_NewRawImg class constructor
        %
        %   OBJ = ED_NewRawImg(WAS_EMPTY) creates an ED_NewRawImg object
        %   with the specified value for WAS_EMPTY.  WAS_EMPTY must be
        %   a scalar logical.
            eventData.wasEmpty = value;
        end
        
    end
    
    % ================================================================== %
end
