classdef (Abstract) RawImgHelper < matlab.mixin.Copyable & ITraj
%RawImgHelper - Superclass for all raw image classes
%
%   The RawImgHelper class is an abstract superclass that implements (or
%   requires implementation in its subclasses via abstract methods or
%   properties) most functionality related to RawImg objects.
%
%   RawImgHelper is a subclass of matlab.mixin.Copyable, which is itself a
%   subset of handle, meaning that RawImgHelper objects are actually
%   references to the data contained in the object.  This ensures memory is
%   used efficiently when RawImgHelper objects are contained in other
%   objects (e.g. ProcessedImg objects). However, RawImgHelper objects can
%   use the copy method of matlab.mixin.Copyable to create new, independent
%   objects.
%
% RawImgHelper public properties:
%   metadata    - The image metadata
%   name        - The object name
%   rawdata     - The raw image data
%   t0          - The image time that should be treated as t=0 [s]
% 
% RawImgHelper public methods:
%   check_ch    - Check that the appropriate channels are present
%   copy        - Copy MATLAB array of handle objects
%   get_ch_name - Get channel names from channel numbers
%   has_ch      - Determine if particular channels are present
%   to_long     - Convert the images to long format
%
%   See also RawImg, RawImgComposite, Metadata, matlab.mixin.Copyable,
%   handle, IRawImg

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
        
        %metadata - The image metadata
        %
        %   The metadata property contains all required metadata about the
        %   image, in a scalar object of class Metadata.
        %
        %   See also Metadata
        metadata
        
    end
    
    % ------------------------------------------------------------------ %
    
    properties (Abstract, Dependent)
        
        %name - The object name
        name
        
        %rawdata - The raw image data
        rawdata
        
        %t0 - The image time that should be treated as t=0 [s]
        t0
        
    end
    
    % ================================================================== %
    
    methods
        
        varargout = check_ch(self, channels, checkType, varargin)
        
        % -------------------------------------------------------------- %
        
        chName = get_ch_name(self, chNum)
        
        % -------------------------------------------------------------- %
        
        tf = has_ch(self, channels)
        
        % -------------------------------------------------------------- %
        
        function set.metadata(self, metadata)
            
            % Check everything is ok
            metadata = self.check_metadata(metadata);
            
            % Assign metadataX
            self.metadata = metadata;
            
        end
        
    end
    
    % ================================================================== %
    
    methods (Hidden) 
        
        [trajs, otherChs] = calc_trajs(self, varargin)
        
        % -------------------------------------------------------------- %
        
        varargout = plot_trajs(self, varargin)
        
    end
    
    % ================================================================== %
    
    methods (Abstract)
        
        %to_long - Convert the images to long format
        to_long(self)
        
    end
    
    % ================================================================== %
    
    methods (Access = protected)
        
        function metadata = check_metadata(~, metadata)
            
            % Check metadata is a Metadata object
            varName = 'metadata';
            className = 'Metadata';
            utils.checks.object_class(metadata, className, varName);
            
            % Check metadata is scalar
            utils.checks.scalar(metadata, varName);
            
        end
        
    end
    
    % ================================================================== %
    
end
