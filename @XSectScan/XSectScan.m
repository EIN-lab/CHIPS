classdef XSectScan < ProcessedImg
%XSectScan - Class to analyse diameter from vessel cross section images
%
%   The XSectScan class analyses the diameter of vessels using axial cross
%   section images. Typically, the vessel lumen will be labelled by a
%   fluorescent marker, like a dextran conjugated fluorophore (e.g. FITC),
%   but the method also works with a negatively labelled vessel lumen (e.g.
%   everything but the vessel lumen is labelled).
%
%   XSectScan is a subclass of matlab.mixin.Copyable, which is itself a
%   subclass of handle, meaning that XSectScan objects are actually
%   references to the data contained in the object.  This ensures memory is
%   used efficiently when XSectScan objects are contained in other objects
%   (e.g. ImgGroup objects). However, XSectScan objects can use the copy
%   method of matlab.mixin.Copyable to create new, independent objects.
%
%   Please see the <a href="matlab:web(fullfile(utils.CHIPS_rootdir, 'doc', 'html', 'pi_XSectScan.html'))">XSectScan quick start guide</a> for additional documentation
%   and examples.
%
% XSectScan public properties:
%   calcDiameter    - A scalar CalcDiameterXSect object
%	channelToUse    - The numeric index of the channel to use
%   isDarkPlasma    - Flag for whether the plasma is dark or bright
%   name            - The object name
%   plotList        - The list of plot options for each Calc
%   rawImg          - A scalar RawImgHelper object
%   state           - The object state
% 
% XSectScan public methods:
%   XSectScan       - XSectScan class constructor
%   copy            - Copy MATLAB array of handle objects
%   get_config      - Return the Config from this XSectScan object
%   opt_config      - Optimise the parameters in Config objects using a GUI
%   output_data     - Output the data
%   plot            - Plot a figure
%   process         - Process the elements of the XSectScan object
%
% XSectScan static methods:
%   reqChannelAll   - The rawImg requires all of these channels
%   reqChannelAny   - The rawImg requires at least one of these channels
%
% XSectScan public events:
%   NewRawImg       - Notifies listeners that the rawImg property was set
%
%   See also XSectScan/XSectScan, ProcessedImg, matlab.mixin.Copyable,
%   IRawImg, RawImgHelper, CalcDiameterXSect

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
        
        %calcDiameter - A scalar CalcDiameterXSect object
        %
        %   The calcDiameter must be a scalar object which is a subclass of
        %   CalcDiameterXSect.
        %
        %   See also CalcDiameterXSect, CalcDiameterTiRS
        calcDiameter
        
        %channelToUse - The numeric index of the channel to use
        %
        %   The numeric index of the channel to use for calculating 
        %   diameter values.
        %
        %   See also CalcDiameterXSect, CalcDiameterTiRS, 
        %   XSectScan/XSectScan
        channelToUse
        
        %isDarkPlasma - Flag for whether the plasma is dark or bright
        %
        %   The isDarkPlasma property represents whether the plasma/vessel
        %   lumen is positively labelled (e.g. by a fluorophore) or
        %   negatively labelled (e.g. all other parts of the image are
        %   positively labelled). isDarkPlasma must be a scalar value
        %   convertible to a logical. [default = false]
        isDarkPlasma = false;
        
    end
    
    % ------------------------------------------------------------------ %
    
    properties (Constant)
        
        %plotList - The list of plot options for each Calc
        plotList = struct('calcDiameter', {{'default'}});
        
    end
    
    % ------------------------------------------------------------------ %
    
    properties (Transient, Access = protected)
        
        %lhCalcDiameter - A listener handle for lhCalcDiameter ProcessNow
        lhCalcDiameter
        
    end
    
    % ================================================================== %
    
    methods
        
        function XSectScanObj = XSectScan(varargin)
        %XSectScan - XSectScan class constructor
        %
        %   OBJ = XSectScan() prompts for all required information
        %   and creates a XSectScan object.
        %
        %   OBJ = XSectScan(NAME, RAWIMG, CONFIG, CHANNEL, ISDP) creates a
        %   XSectScan object based on the specified NAME, RAWIMG,
        %   CONFIG, CHANNEL, and ISDP.
        %
        %   Any of the arguments can be replaced by [] to prompt for the
        %   required information.
        %
        %   NAME must be a single row character array, and if it is empty
        %   the constructor will prompt to choose a name.
        %   RAWIMG must be a RawImgHelper object and can be of any
        %   dimension, but the resulting XSectScan object will be size
        %   [1 numel(RAWIMG)]. If RAWIMG is empty, the constructor will
        %   prompt to select/create a new one.
        %   CONFIG must be a scalar object derived from the Config class,
        %   and its create_calc() method must return an object derived from
        %   the CalcDiameterXSect class.
        %   CHANNEL must be an integer scalar representing the index of the
        %   channel to be used for calculating the diameter.
        %   ISDP must be a scalar value that is convertible to a logical
        %   representing whether or not the plasma is dark (i.e. negatively
        %   labelled: ISDP = true) or bright (i.e. positively labelled:
        %   ISDP = false). [default = false]
        %
        %   If RAWIMG is not scalar, the values for the other arguments are
        %   assumed to apply to all elements of RAWIMG.  This is true
        %   whether the arguments are specified explicitly, or implicitly
        %   (i.e. via interactive prompt).  To choose or specify individual
        %   values for the other arguments, either create the XSectScan
        %   objects individually and combine into an array, or use the
        %   ImgGroup class.
        %
        %   Please see the <a href="matlab:web(fullfile(utils.CHIPS_rootdir, 'doc', 'html', 'pi_XSectScan.html'))">XSectScan quick start guide</a> for additional
        %   documentation and examples.
        %
        %   See also RawImg, RawImgHelper, IRawImg, ProcessedImg,
        %   matlab.mixin.Copyable, handle, CalcDiameterXSect,
        %   CalcDiameterTiRS, ConfigDiameterTiRS, ImgGroup
            
            
            % Parse arguments
            [name, rawImg, configDiamIn, channelToUseIn, isDPin] = ...
                utils.parse_opt_args({'', [], [], [], false}, varargin);
            
            % Call RawImg (i.e. parent class) constructor
            XSectScanObj = XSectScanObj@ProcessedImg(name, rawImg);
            
            % Work out the current recursion depth
            if utils.is_deeper_than('XSectScan.XSectScan');
                return;
            end
            
            % Choose which diameter calculation method
            if isempty(configDiamIn)
                calcObj = XSectScan.choose_calcDiameter();
            else
                calcObj = configDiamIn.create_calc();
            end
            for iElem = 1:numel(XSectScanObj)
                XSectScanObj(iElem).calcDiameter = copy(calcObj);
            end
            
            % Choose which channel to process
            if isempty(channelToUseIn)
                channelToUseIn = XSectScanObj.choose_channel();
            end
            [XSectScanObj(:).channelToUse] = deal(channelToUseIn);
            
            % Set dark streaks
            if ~isempty(isDPin)
                [XSectScanObj(:).isDarkPlasma] = deal(isDPin);
            end
            
        end
        
        % -------------------------------------------------------------- %
        
        function configOut = get_config(self)
        %get_config - Return the Config from this XSectScan object
        %
        %   CONFIG = get_config(OBJ) returns the Config object associated
        %   with this XSectScan object.  If the XSectScan object is
        %   non-scalar, CONFIG will be an array of length numel(OBJ).
        %
        %   See also ConfigDiameterTiRS, Config
        
            % Call the function one by one if we have an array
            if ~isscalar(self)
                configOut = arrayfun(@(xx) get_config(xx), self, ...
                    'UniformOutput', false);
                configOut = [configOut{:}];
                return
            end
            
            configOut = self.calcDiameter.config;
            
        end
        
        % -------------------------------------------------------------- %
        
        varargout = plot(self, varargin)
        
        % -------------------------------------------------------------- %
        
        function set.calcDiameter(self, calcDiameter)
            
            % Check it's the right class
            className = 'CalcDiameterXSect';
            varName = 'calcDiameter';
            utils.checks.object_class(calcDiameter, className, varName);
            
            % Check calcROIs is scalar
            utils.checks.scalar(calcDiameter, varName);
            
            % Set the property
            self.calcDiameter = calcDiameter;
            
            % Attach a listener to process the object when the user
            % requests this (via the Config.opt_config GUI.  Make sure we
            % delete any old listeners, because otherwise the callback
            % might get executed many times.
            if ~isempty(self.lhCalcDiameter) %#ok<MCSUP>
                delete(self.lhCalcDiameter) %#ok<MCSUP>
            end
            self.lhCalcDiameter = addlistener(...
                self.calcDiameter.config, 'ProcessNow', ...
                @ProcessedImg.process_now); %#ok<MCSUP>
            
        end
        
        % -------------------------------------------------------------- %
        
        function set.isDarkPlasma(self, isDarkPlasma)
            
            % Check isDarkPlasma is boolean
            utils.checks.logical_able(isDarkPlasma, 'isDarkPlasma');
            
            % Check isDarkPlasma is scalar
            utils.checks.scalar(isDarkPlasma, 'isDarkPlasma');
            
            % Set the property
            self.isDarkPlasma = isDarkPlasma;
            
        end
        
    end
    
    % ================================================================== %
    
    methods (Access = protected)
        
        function process_sub(self, varargin)
        %process_sub - Process each element of a XSectScan array
            
            % Do the velocity processing
            self.process_diameter()
            
        end
        
        % -------------------------------------------------------------- %
        
        function process_diameter(self)
        %process_diameter - Process the calcDiameter
            
            % Do the actual calculation
            self.calcDiameter = self.calcDiameter.process(self);
            
        end
        
        % -------------------------------------------------------------- %
        
        function update_rawImg_props(self)
        %update_rawImg_props - Update properties when there is a new rawImg
            
            % Call the superclass method to do it's bit
            self.update_rawImg_props@ProcessedImg()
            
            % Call the function one by one if we have an array
            if ~isscalar(self)
                arrayfun(@update_rawImg_props, self);
                return
            end
            
            % Don't need to do anything for this yet
            
        end
        
    end
    
    % ================================================================== %
    
    methods (Static)
        
        function chList = reqChannelAll()
        %reqChannelAll - The rawImg requires all of these channels
            chList = {};
        end
        
        % -------------------------------------------------------------- %
        
        function chList = reqChannelAny()
        %reqChannelAny - The rawImg requires at least one of these channels
            chList = {'blood_plasma', 'blood_rbcs'};
        end
        
    end
    
    % ================================================================== %
    
    methods (Static, Access = protected)
        
        function calcDiameter = choose_calcDiameter()
        %choose_calcDiameter - Choose a calcDiameter
            
            calcDiameter = CalcDiameterTiRS();
            
        end
        
        % -------------------------------------------------------------- %
        
        function objOut = loadobj(structIn)
        %loadobj - Overload the loadobj method for XSectScan objects
            
            % Create the basic object, which also attaches the listener
            objOut = XSectScan(structIn.name_sub, structIn.rawImg, ...
                structIn.calcDiameter.config, structIn.channelToUse, ...
                structIn.isDarkPlasma);
            
            % Update the calcs to ensure any data is also loaded
            objOut.calcDiameter = structIn.calcDiameter;
            
            % Update the remaining properties
            if ~isempty(structIn.refImg)
                objOut.refImg = structIn.refImg;
            end
            
        end
        
    end
    
    % ================================================================== %
    
end
