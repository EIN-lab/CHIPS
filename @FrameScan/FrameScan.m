classdef FrameScan < StreakScan & ICalcDiameterLong
%FrameScan - Class to analyse frame scan images of vessel
%
%   The FrameScan class analyses frame scan images to calculate vessel
%   velocities and diameters.  Typically, the vessel plasma will be
%   labelled by a fluorescent marker, like a dextran conjugated fluorophore
%   (e.g. FITC), but the method also works with labelled red blood cells
%   (RBCs).
%
%   FrameScan is a subclass of matlab.mixin.Copyable, which is itself a
%   subclass of handle, meaning that FrameScan objects are actually
%   references to the data contained in the object.  This ensures memory is
%   used efficiently when FrameScan objects are contained in other
%   objects (e.g. ImgGroup objects). However, FrameScan objects can use
%   the copy method of matlab.mixin.Copyable to create new, independent
%   objects.
%
%   Please see the <a href="matlab:web(fullfile(utils.CHIPS_rootdir, 'doc', 'html', 'pi_FrameScan.html'))">FrameScan quick start guide</a> for additional documentation
%   and examples.
%
% FrameScan public properties:
%   calcDiameter    - A scalar CalcDiameterLong object
%   calcVelocity    - A scalar CalcVelocityStreaks object
%   colsToUseDiam   - The columns from the raw image to use for diameter
%   colsToUseVel    - The columns from the raw image to use for velocity
%   isDarkPlasma    - Flag for whether the plasma is dark or bright
%   isDarkStreaks   - Flag for whether the streaks are dark or bright
%   name            - The object name
%   plotList        - The list of plot options for each Calc
%   rawImg          - A scalar RawImgHelper object
%   rowsToUseVel    - The rows from the raw image to use for velocity
%   state           - The object state
% 
% FrameScan public methods:
%   FrameScan       - FrameScan class constructor
%   copy            - Copy MATLAB array of handle objects
%   get_config      - Return the Config from this FrameScan object
%   get_diamProfile - Get the profile needed to calculate diameter
%   opt_config      - Optimise the parameters in Config objects using a GUI
%   output_data     - Output the data
%   plot            - Plot a figure
%   process         - Process the elements of the FrameScan object
%   split_into_windows - Split the raw image data into windows
%
% FrameScan static methods:
%   reqChannelAll   - The rawImg requires all of these channels
%   reqChannelAny   - The rawImg requires at least one of these channels
%
% FrameScan public events:
%   NewRawImg       - Notifies listeners that the rawImg property was set
%
%   See also FrameScan/FrameScan, LineScanVel, StreakScan, ProcessedImg,
%   matlab.mixin.Copyable, ICalcDiameterLong, ICalcVelocityStreaks,
%   IRawImg, RawImgHelper, CalcDiameterLong, CalcVelocityStreaks

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
        
        %colsToUseDiam - The columns from the raw image to use for diameter
        %
        %   The colsToUseDiam must be numeric vector of length two where
        %   the elements correspond to the first and last columns of the
        %   raw image to use in the diameter calculation.  This can be
        %   useful to avoid noisy or unnecesary regions of the line scan.
        colsToUseDiam
        
        %rowsToUseVel - The rows from the raw image to use for velocity
        %
        %   The rowsToUseVel must be numeric vector of length two where the
        %   elements correspond to the first and last rows of the raw image
        %   to use in the velocity calculation.  This can be useful to
        %   avoid noisy or unnecesary regions of the rawImg.
        rowsToUseVel
        
    end
    
    % ------------------------------------------------------------------ %
    
    properties (Constant)
        
        %plotList - The list of plot options for each Calc
        plotList = struct('calcVelocity', {{'default', 'graphs', ...
                'windows'}}, ...
            'calcDiameter', {{'default'}});
        
    end
    
    % ------------------------------------------------------------------ %
    
    properties (Dependent, Access = protected)
        lineRate
    end
    
    % ================================================================== %
    
    methods
        
        function FrameScanObj = FrameScan(varargin)
        %FrameScan - FrameScan class constructor
        %
        %   OBJ = FrameScan() prompts for all required information and
        %   creates a FrameScan object.
        %
        %   OBJ = FrameScan(NAME, RAWIMG, CONFIG, ISDS, COLS_V, ...
        %       ROWS_V, COLS_D) creates a FrameScan object based on the
        %	specified NAME, RAWIMG, CONFIG, ISDS, COLS_V, ROWS_V, and 
        %   COLS_D.
        %
        %   Any of the arguments can be replaced by [] to prompt for the
        %   required information.
        %
        %   NAME must be a single row character array, and if it is empty
        %   the constructor will prompt to choose a name.
        %   RAWIMG must be a RawImgHelper object and can be of any
        %   dimension, but the resulting FrameScan object will be size [1
        %   numel(RAWIMG)]. If RAWIMG is empty, the constructor will prompt
        %   to select/create a new one.
        %   CONFIG must be a scalar object derived from the Config class,
        %   and its create_calc() method must return an object derived from
        %   the CalcVelocityStreaks class.
        %   ISDS must be a scalar value that is convertible to a logical
        %   representing whether or not the streaks are dark (i.e.
        %   negatively labelled: ISDS = true) or bright (i.e. negatively
        %   labelled: ISDS = false). [default = true]
        %   COLS_V must be a vector of length two containing integer values
        %   representing the first and last columns of RAWIMG to be used 
        %   for velocity calculations.
        %   ROWS_V must be a vector of length two containing integer values
        %   representing the first and last rows of RAWIMG to be used for
        %   velocity calculations.
        %   COLS_D must be a vector of length two containing integer values
        %   representing the first and last columns of RAWIMG to be used 
        %   for diameter calculations.
        %
        %   If RAWIMG is not scalar, the values for the other arguments are
        %   assumed to apply to all elements of RAWIMG.  This is true
        %   whether the arguments are specified explicitly, or implicitly
        %   (i.e. via interactive prompt).  To choose or specify individual
        %   values for the other arguments, either create the FrameScan
        %   objects individually and combine into an array, or use the
        %   ImgGroup class.
        %
        %   Please see the <a href="matlab:web(fullfile(utils.CHIPS_rootdir, 'doc', 'html', 'pi_FrameScan.html'))">FrameScan quick start guide</a> for additional
        %   documentation and examples.
        %
        %   See also RawImg, RawImgHelper, IRawImg, StreakScan,
        %   ProcessedImg, matlab.mixin.Copyable, handle,
        %   CalcVelocityStreaks, CalcVelocityRadon, CalcVelocityLSPIV,
        %   ConfigVelocityRadon, ConfigVelocityLSPIV, CalcDiameterLong,
        %   CalcDiameterFWHM, ConfigDiameterFWHM, ImgGroup
        
            % Parse arguments
            [name, rawImg, configFSIn, isDSIn, colsVelIn, ...
                rowsVelIn, colsDiamIn] = utils.parse_opt_args(...
                {'', [], [], [], [], [], []}, varargin);
            
            % Sort out the config
            configVelIn = [];
            configDiamIn = [];
            hasConfig = ~isempty(configFSIn);
            if hasConfig
                
                isGoodConfig = isa(configFSIn, 'ConfigFrameScan');
                if ~isGoodConfig
                    error('FrameScan:WrongClassConfig', ['The config '...
                        'must be of class "ConfigFrameScan", whereas ' ...
                        'the supplied config is of class "%s"'], ...
                        class(configFSIn))
                end
                
                if ~isscalar(configFSIn)
                    error('FrameScan:NonScalarConfig', ...
                        'The config must be a scalar.')
                end
                
                configVelIn = configFSIn.configVelocity;
                configDiamIn = configFSIn.configDiameter;
                
            end
            
            % Call StreakScan (i.e. parent class) constructor
            FrameScanObj = FrameScanObj@StreakScan(name, rawImg, ...
                configVelIn, isDSIn, colsVelIn);
            
            % Work out the current recursion depth
            if utils.is_deeper_than('FrameScan.FrameScan');
                return;
            end
            
            % Choose which rows to use for velocity and cols for diameter
            FrameScanObj.set_cols_rows(rowsVelIn, colsDiamIn);
            
            % Choose which velocity calculation method
            if isempty(configDiamIn)
                calcObj = FrameScan.choose_calcDiameter();
            else
                calcObj = configDiamIn.create_calc();
            end
            for iElem = 1:numel(FrameScanObj)
                FrameScanObj(iElem).calcDiameter = copy(calcObj);
            end
            
        end
        
        % -------------------------------------------------------------- %
        
        function configOut = get_config(self)
        %get_config - Return the Config from this FrameScan object
        %
        %   CONFIG = get_config(OBJ) returns the ConfigFrameScan object
        %   associated with this FrameScan object.  If the FrameScan
        %   object is non-scalar, CONFIG will be an array of length
        %   numel(OBJ).
        %
        %   See also ConfigFrameScan, Config
        
            % Call the function one by one if we have an array
            if ~isscalar(self)
                configOut = arrayfun(@(xx) get_config(xx), self, ...
                    'UniformOutput', false);
                configOut = [configOut{:}];
                return
            end
        
            configOut = ConfigFrameScan(self.calcVelocity.config, ...
                self.calcDiameter.config);
            
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
            
            colsToUse = self.colsToUseDiam(1):self.colsToUseDiam(2);
            channelToUse = self.rawImg.metadata.channels.blood_plasma;
            diamProfile = permute(sum(...
                self.rawImg.rawdata(:, colsToUse, channelToUse, ...
                :),2), [4 1 2 3]);
            % Invert the image sequence if necessary
            if self.isDarkPlasma
                diamProfile = utils.nansuite.nanmax(diamProfile(:)) - ...
                    diamProfile;
            end
            lineRate = self.lineRate;
            
        end
        
        % -------------------------------------------------------------- %
        
        [windows, time, yPos] = split_into_windows(self, windowTime, ...
            nOverlap)
        
        % -------------------------------------------------------------- %
        
        function lineRate = get.lineRate(self)
            lineRate = [];
            if ~isempty(self.rawImg)
                lineRate = self.rawImg.metadata.frameRate;
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
        
        function set.rowsToUseVel(self, rowsToUseVelIn)
            
            % Call the seperate function to run the checks
            imgDim = 1;
            varName = 'rowsToUseVel';
            imgSize = [];
            if ~isempty(self.rawImg)
                imgSize = size(self.rawImg.rawdata);
            end
            self.rowsToUseVel = utils.checks.check_crop_vals(imgSize, ...
                rowsToUseVelIn, imgDim, varName);
            
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
        
    end
    
    % ================================================================== %
    
    methods (Access = protected)
        
        function process_sub(self, varargin)
            
            % Parse arguments
            defFlag = {'calcVelocity', 'calcDiameter'};
            flag = utils.parse_opt_args({defFlag}, varargin);
            if ischar(flag)
                flag = {flag};
            end
            
            % Do the velocity processing
            doVelocity = ismember('calcVelocity', flag);
            if doVelocity
                self.process_velocity()
            end

            % Do the diameter processing
            doDiameter = ismember('calcDiameter', flag);
            if doDiameter
                self.process_diameter()
            end
            
        end
        
        % -------------------------------------------------------------- %
        
        function update_rawImg_props(self)
            
            % Call the superclass method
            update_rawImg_props@StreakScan(self)
            
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
            else
                self.choose_rows_vel();
                self.choose_cols_diam();
            end
            
        end
        
        % -------------------------------------------------------------- %
        
        plot_frame(self, varargin)
        
        % -------------------------------------------------------------- %
        
        function process_diameter(self)
            
            % Do the actual properties
            self.calcDiameter = self.calcDiameter.process(self);
            
        end
        
        % -------------------------------------------------------------- %
        
        function set_cols_rows(self, rowsVelIn, colsDiamIn)
            
            % Call the function one by one if we have an array
            if ~isscalar(self)
                for iObj = 1:numel(self)
                    
                    self(iObj).set_cols_rows(rowsVelIn, colsDiamIn)
                    
                    if iObj == 1
                        rowsVelIn = self(iObj).rowsToUseVel;
                        colsDiamIn = self(iObj).colsToUseDiam;
                    end
                    
                end
                return
            end
            
            if self.isComposite
                self.update_rawImg_props()
            else 
                
                % Choose rowsToUseVelIn
                if isempty(rowsVelIn)
                    self.choose_rows_vel();
                else
                    self.rowsToUseVel = rowsVelIn;
                end
                
                % Choose colsToUseDiam
                if isempty(colsDiamIn)
                    self.choose_cols_diam();
                else
                    self.colsToUseDiam = colsDiamIn;
                end
                
            end
            
        end
        
        % -------------------------------------------------------------- %
            
        function choose_cols_diam(self)
            
            % Work out how to display an image for choosing the columns
            imgChannel = self.channelStreak;
            imgData = mean(self.rawImg.rawdata(:, :, imgChannel, :), 4);
            
            function sizeImgData = plot_imgData(strFigTitle)
                
                sizeImgData = size(imgData);
                imagesc(imgData);
                hold on
                axis tight, axis image, axis off
                colormap('gray')
                title(strFigTitle)
                plot(self.colsToUseVel(1)*[1, 1], self.rowsToUseVel, 'b--')
                plot(self.colsToUseVel(2)*[1, 1], self.rowsToUseVel, 'b--')
                plot(self.colsToUseVel, self.rowsToUseVel(1)*[1, 1], 'b--')
                plot(self.colsToUseVel, self.rowsToUseVel(2)*[1, 1], 'b--')
                hold off
                
            end
            
            % Call the static function to choose the images
            isLR = true;
            strBoundary = 'DIAMETER';
            self.colsToUseDiam = utils.crop_rows_cols(@plot_imgData, isLR, ...
                strBoundary);
            
        end
        
        % -------------------------------------------------------------- %
        
        function choose_rows_vel(self)
            
            % Work out how to display an image for choosing the columns
            imgChannel = self.channelStreak;
            imgData = mean(self.rawImg.rawdata(:, :, imgChannel, :), 4);
            rowsForLines = [1 size(imgData, 1)];
            
            function sizeImgData = plot_imgData(strFigTitle)
                
                sizeImgData = size(imgData);
                imagesc(imgData);
                hold on
                axis tight, axis image
                colormap('gray')
                title(strFigTitle)
                plot(self.colsToUseVel(1)*[1, 1], rowsForLines, 'b--')
                plot(self.colsToUseVel(2)*[1, 1], rowsForLines, 'b--')
                hold off
                
            end
            
            % Call the static function to choose the images
            isLR = false;
            self.rowsToUseVel = utils.crop_rows_cols(@plot_imgData, isLR);
            
        end
        
        % -------------------------------------------------------------- %
        
        varargout = plot_main(self, varargin)
        
    end
    
    % ================================================================== %
    
    methods (Static, Access = protected)
        
        function calcDiameter = choose_calcDiameter()
            
            calcDiameter = CalcDiameterFWHM();
            
%             classParent = 'CalcDiameter';
%             strType = 'diameter calculation';
%             calcDiameter = utils.choose_subclass(classParent, strType);
            
        end
        
        % -------------------------------------------------------------- %
        
        function objOut = loadobj(structIn)
        %loadobj - Overload the loadobj method for FrameScan objects
        
            % Create the basic object, which also attaches the listener
            configFS = ConfigFrameScan(structIn.calcVelocity.config, ...
                structIn.calcDiameter.config);
            objOut = FrameScan(structIn.name_sub, structIn.rawImg, ...
                configFS, structIn.isDarkStreaks, structIn.colsToUseVel, ...
                structIn.rowsToUseVel, structIn.colsToUseDiam);
            
            % Update the calcs to ensure any data is also loaded
            objOut.calcVelocity = structIn.calcVelocity;
            objOut.calcDiameter = structIn.calcDiameter;
            
            % Update the remaining properties
            if ~isempty(structIn.refImg)
                objOut.refImg = structIn.refImg;
            end
            
        end
        
    end
    
    % ================================================================== %
    
end

