classdef LineScanVel < StreakScan
%LineScanVel - Class to analyse line scan images of vessel velocities
%
%   The LineScanVel class analyses line scan images of vessel velocities
%   acquired by scanning along to the vessel axis.  Typically, the vessel
%   plasma will be labelled by a fluorescent marker, like a dextran
%   conjugated fluorophore (e.g. FITC), but the method also works with
%   labelled red blood cells (RBCs).
%
%   LineScanVel is a subclass of matlab.mixin.Copyable, which is itself a
%   subclass of handle, meaning that LineScanVel objects are actually
%   references to the data contained in the object.  This ensures memory is
%   used efficiently when LineScanVel objects are contained in other
%   objects (e.g. ImgGroup objects). However, LineScanVel objects can use
%   the copy method of matlab.mixin.Copyable to create new, independent
%   objects.
%
%   Please see the <a href="matlab:web(fullfile(utils.CHIPS_rootdir, 'doc', 'html', 'pi_LineScanVel.html'))">LineScanVel quick start guide</a> for additional
%   documentation and examples.
%
% LineScanVel public properties:
%   calcVelocity    - A scalar CalcVelocityStreaks object
%   colsToUseVel    - The columns from the raw image to use for velocity
%   isDarkStreaks   - Flag for whether the streaks are dark or bright
%   name            - The object name
%   plotList        - The list of plot options for each Calc
%   rawImg          - A scalar RawImgHelper object
%   state           - The object state
% 
% LineScanVel public methods:
%   LineScanVel     - LineScanVel class constructor
%   copy            - Copy MATLAB array of handle objects
%   get_config      - Return the Config from this LineScanVel object
%   opt_config      - Optimise the parameters in Config objects using a GUI
%   output_data     - Output the data
%   plot            - Plot a figure
%   process         - Process the elements of the LineScanVel object
%   split_into_windows - Split the raw image data into windows
%
% StreakScan static methods:
%   reqChannelAll   - The rawImg requires all of these channels
%   reqChannelAny   - The rawImg requires at least one of these channels
%
% LineScanVel public events:
%   NewRawImg       - Notifies listeners that the rawImg property was set
%
%   See also LineScanVel/LineScanVel, FrameScan, StreakScan, ProcessedImg,
%   matlab.mixin.Copyable, ICalcVelocityStreaks, IRawImg, RawImgHelper,
%   CalcVelocityStreaks

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
    
    properties (Constant)
        
        %plotList - The list of plot options for each Calc
        plotList = struct('calcVelocity', {{'default', 'graphs', ...
            'windows'}});
        
    end
    
    % ================================================================== %
    
    methods
        
        function LineScanVelObj = LineScanVel(varargin)
        %LineScanVel - LineScanVel class constructor
        %
        %   OBJ = LineScanVel() prompts for all required information and
        %   creates a LineScanVel object.
        %
        %   OBJ = LineScanVel(NAME, RAWIMG, CONFIG, ISDS, COLS) creates a
        %   LineScanVel object based on the specified NAME, RAWIMG,
        %   CONFIG, ISDS, and COLS.
        %
        %   Any of the arguments can be replaced by [] to prompt for the
        %   required information.
        %
        %   NAME must be a single row character array, and if it is empty
        %   the constructor will prompt to choose a name.
        %   RAWIMG must be a RawImgHelper object and can be of any
        %   dimension, but the resulting LineScanVel object will be size [1
        %   numel(RAWIMG)]. If RAWIMG is empty, the constructor will prompt
        %   to select/create a new one.
        %   CONFIG must be a scalar object derived from the Config class,
        %   and its create_calc() method must return an object derived from
        %   the CalcVelocityStreaks class.
        %   ISDS must be a scalar value that is convertible to a logical
        %   representing whether or not the streaks are dark (i.e.
        %   negatively labelled: ISDS = true) or bright (i.e. positively
        %   labelled: ISDS = false). [default = true]
        %   COLS must be a vector of length two containing integer values
        %   representing the first and last columns of RAWIMG to be used.
        %
        %   If RAWIMG is not scalar, the values for the other arguments are
        %   assumed to apply to all elements of RAWIMG.  This is true
        %   whether the arguments are specified explicitly, or implicitly
        %   (i.e. via interactive prompt).  To choose or specify individual
        %   values for the other arguments, either create the LineScanVel
        %   objects individually and combine into an array, or use the
        %   ImgGroup class.
        %
        %   Please see the <a href="matlab:web(fullfile(utils.CHIPS_rootdir, 'doc', 'html', 'pi_LineScanVel.html'))">LineScanVel quick start guide</a> for additional
        %   documentation and examples.
        %
        %   See also RawImg, RawImgHelper, IRawImg, StreakScan,
        %   ProcessedImg, matlab.mixin.Copyable, handle,
        %   CalcVelocityStreaks, CalcVelocityRadon, CalcVelocityLSPIV,
        %   ConfigVelocityRadon, ConfigVelocityLSPIV, ImgGroup
            
            % Parse arguments
            [name, rawImg, configVelIn, isDSIn, colsVelIn] = ...
                utils.parse_opt_args({'', [], [], [], [], []}, ...
                varargin);
            
            % Call StreakScan (i.e. parent class) constructor
            LineScanVelObj = LineScanVelObj@StreakScan(name, rawImg, ...
                configVelIn, isDSIn, colsVelIn);
            
            % Work out the current recursion depth
            if utils.is_deeper_than('LineScanVel.LineScanVel');
                return;
            end
            
        end
        
        % -------------------------------------------------------------- %
        
        function configOut = get_config(self)
        %get_config - Return the Config from this LineScanVel object
        %
        %   CONFIG = get_config(OBJ) returns the Config object associated
        %   with this LineScanVel object.  If the LineScanVel object is
        %   non-scalar, CONFIG will be an array of length numel(OBJ).
        %
        %   See also ConfigVelocityRadon, ConfigVelocityLSPIV, Config
        
            % Call the function one by one if we have an array
            if ~isscalar(self)
                configOut = arrayfun(@(xx) get_config(xx), self, ...
                    'UniformOutput', false);
                configOut = [configOut{:}];
                return
            end
            
            configOut = [self.calcVelocity.config];
            
        end
        
        % -------------------------------------------------------------- %
        
        [windows, time, yPos] = split_into_windows(self, windowTime, ...
            nOverlap)
        
    end
    
    % ================================================================== %
    
    methods (Access=protected)
        
        function process_sub(self, varargin)
            
            % Do the velocity processing
            self.process_velocity()
            
        end
        
        % -------------------------------------------------------------- %
        
        function process_velocity(self)
            
            % Reshape the raw image to remove frames (i.e. one long image)
            nFrames = size(self.rawImg.rawdata, 4);
            if nFrames > 1
                self.rawImg.to_long();
            end
            
            % Call the superclass method to do the rest
            self.process_velocity@StreakScan()
            
        end
        
        % -------------------------------------------------------------- %
        
        plot_frame(self, varargin)
        
    end
    
    % ================================================================== %
    
    methods (Static, Access = protected)
        
        function objOut = loadobj(structIn)
        %loadobj - Overload the loadobj method for LineScanVel objects
            
            % Create the basic object, which also attaches the listener
            objOut = LineScanVel(structIn.name_sub, structIn.rawImg, ...
                structIn.calcVelocity.config, structIn.isDarkStreaks, ...
                structIn.colsToUseVel);
            
            % Update the calcs to ensure any data is also loaded
            objOut.calcVelocity = structIn.calcVelocity;
            
            % Update the remaining properties
            if ~isempty(structIn.refImg)
                objOut.refImg = structIn.refImg;
            end
            
        end
        
    end
    
    % ================================================================== %
    
end

