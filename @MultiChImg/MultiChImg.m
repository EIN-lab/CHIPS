classdef MultiChImg < CompositeImg
%MultiChImg - Class to contain images from an multi-channel raw image
%
%   The MultiChImg class implements most functionality related to groups of
%   ProcessedImg objects that are derived from the same RawImg object,
%   which should contain multiple channels. This allows efficient use of
%   memory, since the same RawImg object does not need to be duplicated to
%   analyse different parts of it.
%
%   The MultiChImg class is a specialisation of CompositeImg for
%   convenience, in that only 'channel' type masks can be created
%   interactively.  However, there are no additional restrictions or checks
%   on masks that are supplied.
%
%   As an alternative to creating a MultiChImg, it is also possible to
%   split a RawImg object into it's component channels using the
%   RawImg.split1 method.
%
% MultiChImg public properties:
%   children    - A cell array containing the Processable child objects
%   imgTypes    - The unique child object image types
%   masks       - The masks used to create the child object RawImg
%   name        - The object name
%   nChildren   - The number of children in the object
%   rawImg      - A scalar RawImgHelper object
%   state       - The object state
% 
% MultiChImg public methods:
%   MultiChImg  - MultiChImg class constructor
%   add         - Add children to the object
%   copy        - Copy MATLAB array of handle objects
%   get_config  - Return the Configs from this object
%   opt_config  - Optimise the parameters in Config objects using a GUI
%   output_data - Output the data
%   plot        - Plot a figure for each child object
%   process     - Process the child objects
%
% MultiChImg static methods:
%   from_files  - Create a MultiChImg object from a list of files
%   reqChannelAll - The rawImg requires all of these channels
%   reqChannelAny - The rawImg requires at least one of these channels
%
% MultiChImg public events:
%   NewRawImg	- Notifies listeners that the rawImg property was set
%
%   See also RawImg.split1, RawImgComposite, Processable, CompositeImg,
%   ImgGroup, IRawImg, matlab.mixin.Copyable, handle

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
        
        function MultiChImgObj = MultiChImg(varargin)
        %MultiChImg - MultiChImg class constructor
        %
        %   OBJ = MultiChImg() prompts for any required information and
        %   creates a MultiChImg object.
        %
        %   OBJ = MultiChImg(ARG1, ARG2, ...) prompts for any required
        %   information to create a MultiChImg object, then passes the
        %   arguments ARG1, ARG2, ... to the MultiChImg.add function to
        %   add to the MultiChImg object. See the link below for further
        %   documentation.
        %
        %   ARG1 = MultiChImg(NAME, ...) specifies a name for the
        %   MultiChImg object.  NAME must be a single row character array,
        %   or a cell array containging a single row character array.
        %
        %   See also MultiChImg.add, CompositeImg, ImgGroup, Processable
            
            % Call ImgGroup (i.e. parent class) constructor
            MultiChImgObj = MultiChImgObj@CompositeImg(varargin{:});
            
        end
        
    end
    
    % ================================================================== %
    
    methods (Access = protected)
        
        function mask = choose_mask(self, imgType)
        %choose_mask - Protected class method to choose an individual mask.
        %   In this case the masks are restricted to channels.
            
            % Call the superclass method, restricting it to column ROIs
            maskType = 'channels';
            mask = self.choose_mask@CompositeImg(imgType, maskType);
            
        end
        
    end
    
    % ================================================================== %
    
    methods (Static)
        
        MultiChImgObj = from_files(varargin)
        
    end
    
    % ================================================================== %
    
    methods (Static, Access = protected)
        
        function objOut = loadobj(structIn)
        %loadobj - Overload the loadobj method for MultiChImg objects
            
            % Create the basic object, which also attaches the listener
            objOut = MultiChImg(structIn.name_sub, structIn.rawImg);
            
            % Update the children.  We do it here because CompositeImg/add
            % does not currently accept ProcessedImg arguments
            objOut.children = structIn.children;
            
            % Update the remaining properties
            if ~isempty(structIn.refImg)
                objOut.refImg = structIn.refImg;
            end
            
        end
        
    end
    
    % ================================================================== %
    
end

