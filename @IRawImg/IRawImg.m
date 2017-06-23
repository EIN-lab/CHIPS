classdef (Abstract) IRawImg < matlab.mixin.Copyable
%IRawImg - Interface for classes that include raw images
% 
%   The IRawImg class is an abstract superclass that implements (or
%   requires implementation in its subclasses via abstract methods or
%   properties) most functionality related to the rawImg property in other
%   classes. This approach allows reuse of the functionality in multiple
%   subclasses that do not otherwise share a common superclass.
%
%   IRawImg is a subclass of matlab.mixin.Copyable and implements a custom
%   copyElement method to ensure that the rawImg property (which is a
%   handle object) is itself copied when the copy method is run.
%
% IRawImg public properties:
%   rawImg          - A scalar RawImgHelper object
% 
% IRawImg does not provide any public methods.
%
% IRawImg static methods:
%   reqChannelAll   - The rawImg requires all of these channels
%   reqChannelAny   - The rawImg requires at least one of these channels
%
% IRawImg public events:
%   NewRawImg	- Notifies listeners that the rawImg property was set
%
%   See also ProcessedImg, CompositeImg, RawImgComposite, RawImgHelper,
%   matlab.mixin.Copyable, handle

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
        
        %rawImg - A scalar RawImgHelper object
        %
        %   The rawImg property of IRawImg must contain a scalar
        %   RawImgHelper object.  In addition, the RawImgHelper object must
        %   contain all of the channels returned by the static method
        %   reqChannelAll, and at least one of the properties returned by
        %   the static method reqChannelAny. These two methods are
        %   implemented in the concrete subclasses of IRawImg.
        %
        %   See also IRawImg.reqChannelAll, IRawImg.reqChannelAny
        rawImg
        
    end
    
    % ================================================================== %
    
    events
        
        %NewRawImg - Notifies listeners that the rawImg property was set
        %
        %   See also ED_NewRawImg
        NewRawImg
        
	end
    
    % ================================================================== %
    
    methods
        
        function set.rawImg(self, rawImg)
            
            % Find out if we're setting this value for the first time, or
            % if we're changing it
            wasEmpty = isempty(self.rawImg);
            
            % Check the rawImg
            self.check_rawImg(rawImg);
            
            % Set the property
            self.rawImg = rawImg;
            
            % Refresh the properties that need to change as a result of a
            % new rawImg objects.  Do this by notifying an event listener.
            eventDataObj = ED_NewRawImg(wasEmpty);
            notify(self, 'NewRawImg', eventDataObj);
            
        end
        
    end
    
    % ================================================================== %
    
    methods (Abstract, Access = protected)
        
        %update_rawImg_props - Abstract class method to ensure that all
        %   appropriate properties are updated when the rawImg property
        %   changes (e.g. when constructing an ImgGroup).
        update_rawImg_props(self)
        
    end
    
    % ================================================================== %
    
    methods (Access = protected)
        
        varargout = check_rawImg(self, rawImg)
        
        % -------------------------------------------------------------- %
        
        function cpObj = copyElement(obj)
        %copyElement - Customised copyElement class method to ensure that
        %   the rawImg property (a handle object) is recursively copied.
            
            % Make a shallow copy of the object
            cpObj = copyElement@matlab.mixin.Copyable(obj);
             
            % Make a deep copy of the rawImg object
            cpObj.rawImg = copy(obj.rawImg);
             
            % Attach a listener to update the properties when a new rawImg
            % is added to this object
            addlistener(cpObj, 'NewRawImg', @IRawImg.new_rawImg);
             
        end
        
        % -------------------------------------------------------------- %
        
        function update_name(self)
        %update_name - Class method to update the name of an IRawImg object
            
            canUpdate = ~isempty(self.rawImg) && ...
                ~isempty(self.rawImg.name);
            if canUpdate
                self.name = self.rawImg.name;
            end
            
        end
        
    end
        
    % ================================================================== %
    
    methods (Abstract, Static)
        
        %reqChannelAll - The rawImg requires all of these channels
        chList = reqChannelAll()
        
        %reqChannelAny - The rawImg requires at least one of these channels
        chList = reqChannelAny()
        
    end
    
    % ================================================================== %
    
    methods (Static, Access = protected)
        
        function new_rawImg(eventSrc, eventData)
        %new_rawImg - Static method to refresh the properties that need to
        %   change as a result of updating the rawImg property
        
            if ~eventData.wasEmpty
                eventSrc.update_rawImg_props();
            end
            
        end
        
    end
    
    % ================================================================== %
    
    methods (Abstract, Static, Access = protected)
        
        %loadobj - Overload loadobj for IRawImg objects
        objOut = loadobj(structIn)
        
    end
    
    % ================================================================== %
    
end

