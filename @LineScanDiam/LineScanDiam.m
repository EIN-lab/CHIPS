classdef LineScanDiam < ProcessedImg & ICalcDiameterLong
%LineScanDiam - Class to analyse line scan images of vessel diameters
%
%   The LineScanDiam class analyses line scan images of vessel diameters
%   acquired by scanning perpendicular to the vessel axis.  Typically, the
%   vessel lumen will be labelled by a fluorescent marker, like a dextran
%   conjugated fluorophore (e.g. FITC).
%
%   LineScanDiam is a subclass of matlab.mixin.Copyable, which is itself a
%   subclass of handle, meaning that LineScanDiam objects are actually
%   references to the data contained in the object.  This ensures memory is
%   used efficiently when LineScanDiam objects are contained in other
%   objects (e.g. ImgGroup objects). However, LineScanDiam objects can use
%   the copy method of matlab.mixin.Copyable to create new, independent
%   objects.
%
%   Please see the <a href="matlab:web(fullfile(utils.CHIPS_rootdir, 'doc', 'html', 'pi_LineScanDiam.html'))">LineScanDiam quick start guide</a> for additional
%   documentation and examples.
%
% LineScanDiam public properties:
%   calcDiameter    - A scalar CalcDiameterLong object
%	channelToUse    - The numeric index of the channel to use
%   colsToUseDiam   - The columns from the raw image to use for diameter
%   isDarkPlasma    - Flag for whether the plasma is dark or bright
%   name            - The object name
%   plotList        - The list of plot options for each Calc
%   rawImg          - A scalar RawImgHelper object
%   state           - The object state 
% 
% LineScanDiam public methods:
%   LineScanDiam    - LineScanDiam class constructor
%   copy            - Copy MATLAB array of handle objects
%   get_config      - Return the Config from this LineScanDiam object
%   get_diamProfile - Get the profile needed to calculate diameter
%   opt_config      - Optimise the parameters in Config objects using a GUI
%   output_data     - Output the data
%   plot            - Plot a figure
%   process         - Process the elements of the LineScanDiam object
%
% LineScanDiam static methods:
%   reqChannelAll   - The rawImg requires all of these channels
%   reqChannelAny   - The rawImg requires at least one of these channels
%
% LineScanDiam public events:
%   NewRawImg       - Notifies listeners that the rawImg property was set
%
%   See also LineScanDiam/LineScanDiam, ProcessedImg,
%   matlab.mixin.Copyable, ICalcDiameterLong, IRawImg, RawImgHelper,
%   CalcDiameterLong

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
        
        %calcDiameter - A scalar CalcDiameterLong object
        %
        %   The calcDiameter must be a scalar object which is a subclass of
        %   CalcDiameterLong.
        %
        %   See also CalcDiameterLong, CalcDiameterFWHM
        calcDiameter
        
        %channelToUse - The numeric index of the channel to use
        %
        %   The numeric index of the channel to use for calculating 
        %   diameter values.
        %
        %   See also CalcDiameterLong, CalcDiameterFWHM,
        %   LineScanDiam/LineScanDiam
        channelToUse
        
        %colsToUseDiam - The columns from the raw image to use for diameter
        %
        %   The colsToUseDiam must be numeric vector of length two where
        %   the elements correspond to the first and last columns of the
        %   raw image to use in the diameter calculation.  This can be
        %   useful to avoid noisy or unnecesary regions of the line scan.
        colsToUseDiam
        
    end
    
    % ------------------------------------------------------------------ %
    
    properties (Constant)
        
        %plotList - The list of plot options for each Calc
        plotList = struct('calcDiameter', {{'default', ...
            'diam_profile', 'graphs'}});
        
    end
    
    % ------------------------------------------------------------------ %
    
    properties (Dependent, Access = protected)
        lineRate
    end
    
    % ================================================================== %
    
    methods
        
        function LineScanDiamObj = LineScanDiam(varargin)
        %LineScanDiam - LineScanDiam class constructor
        %
        %   OBJ = LineScanDiam() prompts for all required information
        %   and creates a LineScanDiam object.
        %
        %   OBJ = LineScanDiam(NAME, RAWIMG, CONFIG, COLS, CHANNEL, ISDP)
        %   creates a LineScanDiam object based on the specified NAME,
        %   RAWIMG, CONFIG, COLS, and CHANNEL, and ISDP.
        %
        %   Any of the arguments can be replaced by [] to prompt for the
        %   required information.
        %
        %   NAME must be a single row character array, and if it is empty
        %   the constructor will prompt to choose a name.
        %   RAWIMG must be a RawImgHelper object and can be of any
        %   dimension, but the resulting LineScanDiam object will be size
        %   [1 numel(RAWIMG)]. If RAWIMG is empty, the constructor will
        %   prompt to select/create a new one.
        %   CONFIG must be a scalar object derived from the Config class,
        %   and its create_calc() method must return an object derived from
        %   the CalcDiameterLong class.
        %   COLS must be a vector of length two containing integer values
        %   representing the first and last columns of RAWIMG to be used.
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
        %   values for the other arguments, either create the LineScanDiam
        %   objects individually and combine into an array, or use the
        %   ImgGroup class.
        %
        %   Please see the <a href="matlab:web(fullfile(utils.CHIPS_rootdir, 'doc', 'html', 'pi_LineScanDiam.html'))">LineScanDiam quick start guide</a> for additional
        %   documentation and examples.
        %
        %   See also RawImg, RawImgHelper, IRawImg, ProcessedImg,
        %   matlab.mixin.Copyable, handle, CalcDiameterLong,
        %   CalcDiameterFWHM, ConfigDiameterFWHM, ImgGroup
            
            % Parse arguments
            [name, rawImg, configDiamIn, colsToUseDiamIn, ...
             channelToUseIn, isDPin] = utils.parse_opt_args(...
                {'', [], [], [], [], [], false}, varargin);
            
            % Call RawImg (i.e. parent class) constructor
            LineScanDiamObj = LineScanDiamObj@ProcessedImg(...
                name, rawImg);
            
            % Work out the current recursion depth
            if utils.is_deeper_than('LineScanDiam.LineScanDiam');
                return;
            end
            
            % Choose which diameter calculation method
            if isempty(configDiamIn)
                calcObj = LineScanDiam.choose_calcDiameter();
            else
                calcObj = configDiamIn.create_calc();
            end
            for iElem = 1:numel(LineScanDiamObj)
                LineScanDiamObj(iElem).calcDiameter = copy(calcObj);
            end
            
            % Choose which channel to process
            if isempty(channelToUseIn)
                channelToUseIn = LineScanDiamObj.choose_channel();
            end
            [LineScanDiamObj(:).channelToUse] = deal(channelToUseIn);
            
            % Choose colsToUseDiam after the rest so we know which channel
            % to show in the image
            LineScanDiamObj.set_cols_diam(colsToUseDiamIn)
            
            % Set dark streaks
            if ~isempty(isDPin)
                [LineScanDiamObj(:).isDarkPlasma] = deal(isDPin);
            end
            
        end
        
        % -------------------------------------------------------------- %
        
        function configOut = get_config(self)
        %get_config - Return the Config from this LineScanDiam object
        %
        %   CONFIG = get_config(OBJ) returns the Config object associated
        %   with this LineScanDiam object.  If the LineScanDiam object is
        %   non-scalar, CONFIG will be an array of length numel(OBJ).
        %
        %   See also ConfigDiameterFWHM, Config
            
            configOut = [self.calcDiameter.config];
            
        end
        
        % -------------------------------------------------------------- %
        
        function [diamProfile, lineRate] = get_diamProfile(self)
        %get_diamProfile - Get the profile needed to calculate diameter
        %
        %   [PROFILE, LINE_RATE] = get_diamProfile(OBJ) returns the image
        %   profile needed to calculate diameter, along with the line rate
        %   of the profile [Hz].
        %
        %   See also CalcDiameterLong, ICalcDiameterLong
            
            colsToUse = self.colsToUseDiam(1) : self.colsToUseDiam(2);
            diamProfile = self.rawImg.rawdata(:, colsToUse, ...
                self.channelToUse);
            % Invert the image sequence if necessary
            if self.isDarkPlasma
                diamProfile = utils.nansuite.nanmax(diamProfile(:)) - ...
                    diamProfile;
            end
            lineRate = self.lineRate;
            
        end
        
        % -------------------------------------------------------------- %
        
        varargout = plot(self, varargin)
        
        % -------------------------------------------------------------- %
        
        function lineRate = get.lineRate(self)
            lineRate = [];
            if ~isempty(self.rawImg)
                lineRate = 1/(self.rawImg.metadata.lineTime*1E-3);
            end
        end
        
        % -------------------------------------------------------------- %
        
        function set.colsToUseDiam(self, colsToUseDiamIn)
            
            % Call the seperate function to run the checks
            imgDim = 2;
            varName = 'colsToUseDiam';
            imgSize = [];
            if ~isempty(self.rawImg)
                imgSize = size(self.rawImg.rawdata);
            end
            self.colsToUseDiam = utils.checks.check_crop_vals(imgSize, ...
                colsToUseDiamIn, imgDim, varName);
            
        end
        
        % -------------------------------------------------------------- %
        
        function set.calcDiameter(self, calcDiameter)
            
            % Check it's the right class
            className = 'CalcDiameterLong';
            varName = 'calcDiameter';
            utils.checks.object_class(calcDiameter, className, varName);
            
            % Check calcROIs is scalar
            utils.checks.scalar(calcDiameter, varName);
            
            % Set the property
            self.calcDiameter = calcDiameter;
            
        end
        
        % -------------------------------------------------------------- %
        
        function set.channelToUse(self, channelToUse)
            
            % Check the format
            utils.checks.prfsi(channelToUse, 'channelToUse');
            
            % Check that there are enough channels in the image
            if ~isempty(self.rawImg)
                nChs = self.rawImg.metadata.nChannels;
                utils.checks.less_than(channelToUse, nChs, true, ...
                    'channelToUse')
            end
            
            % Set the property
            self.channelToUse = channelToUse;
            
        end
        
    end
    
    % ================================================================== %
    
    methods (Access=protected)
        
        function choose_cols_diam(self)
        %choose_cols_diam - Interactively choose the colsToUseDiam
            
            % Work out how to display an image for choosing the columns
            imgData = mean(...
                self.rawImg.rawdata(:, :, self.channelToUse, :), 4);
            
            % Check that the aspect ratio is ok
            [nRows, nCols] = size(imgData);
            aspectRatio = nRows/nCols;
            arThresh = 10;
            if aspectRatio > arThresh
                warning('LineScanDiam:ChooseColsDiam:AspectRatio', ...
                    'The image will be averaged for easier cropping.')
                nOverlap = 1;
                windowLines = ceil(nRows/(nCols*arThresh));
                imgData = squeeze(mean(utils.split_into_windows(...
                    imgData, nOverlap, windowLines), 1))';
            end
            
            % Call the static function to choose the images
            isLR = true;
            strBoundary = 'DIAMETER';
            self.colsToUseDiam = utils.crop_rows_cols(imgData, isLR, ...
                strBoundary);
            
        end
        
        % -------------------------------------------------------------- %
        
        function process_diameter(self)
        %process_diameter - Process the calcDiameter
            
            % Reshape the raw image to remove frames (i.e. one long image)
            nFrames = size(self.rawImg.rawdata, 4);
            if nFrames > 1
                self.rawImg.to_long();
            end
            
            % Do the actual processing
            self.calcDiameter = self.calcDiameter.process(self);
            
        end
        
        % -------------------------------------------------------------- %
        
        function process_sub(self, varargin)
        %process_sub - Process each element of a LineScanDiam array
            
            % Do the diameter processing
            self.process_diameter()
            
        end
        
        % -------------------------------------------------------------- %
        
        function set_cols_diam(self, colsDiamIn)
        %set_cols_diam - Set the colsToUseDiam
            
            % Call the function one by one if we have an array
            if ~isscalar(self)
                for iObj = 1:numel(self)
                    
                    self(iObj).set_cols_diam(colsDiamIn)
                    
                    if iObj == 1
                        colsDiamIn = self(iObj).colsToUseDiam;
                    end
                    
                end
                return
            end
            
            if self.isComposite
                self.update_rawImg_props()
            else 
                
                % Choose the columns to use
                if isempty(colsDiamIn)
                    self.choose_cols_diam();
                else
                    self.colsToUseDiam = colsDiamIn;
                end
                
            end
            
        end
        
        % -------------------------------------------------------------- %
        
        function update_rawImg_props(self)
        %update_rawImg_props - Update properties when there is a new rawImg
            
            % Call the superclass method to do its bit
            self.update_rawImg_props@ProcessedImg()
            
            % Call the function one by one if we have an array
            if ~isscalar(self)
                arrayfun(@update_rawImg_props, self);
                return
            end
            
            % Update colsToUseDiam
            if self.isComposite
                wngState = warning('off', ...
                    'CheckCropVals:TooBigColsToUseDiam');
                self.colsToUseDiam = [1 inf];
                warning(wngState)
                [~, lastID] = lastwarn();
                if strcmp(lastID, 'CheckCropVals:TooBigColsToUseDiam')
                    lastwarn('')
                end
            else
                self.choose_cols_diam();
            end
            
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
            
            calcDiameter = CalcDiameterFWHM();
            
        end
        
        % -------------------------------------------------------------- %
        
        function objOut = loadobj(structIn)
        %loadobj - Overload the loadobj method for LineScanDiam objects
            
            % Add this field for the older versions where it didn't exist
            hasDP = isfield(structIn, 'isDarkPlasma');
            if ~hasDP
                structIn.isDarkPlasma = false;
            end
            
            % Create the basic object, which also attaches the listener
            objOut = LineScanDiam(structIn.name_sub, structIn.rawImg, ...
                structIn.calcDiameter.config, structIn.colsToUseDiam, ...
                structIn.channelToUse, structIn.isDarkPlasma);
            
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
