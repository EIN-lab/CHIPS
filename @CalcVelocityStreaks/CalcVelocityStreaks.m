classdef (Abstract) CalcVelocityStreaks < CalcVelocity
%CalcVelocityStreaks - Superclass for CalcVelocityStreaks classes
%
%   CalcVelocityStreaks is an abstract superclass that implements (or
%   requires implementation in its subclasses via abstract methods or
%   properties) most functionality related to calculating the velocity of
%   images based on the streaks formed by moving red blood cells (RBCs).
%   Typically there is one concrete subclass of CalcVelocityStreaks for
%   every calculation algorithm, and it contains the algorithm-specific
%   code that is needed for the calculation.
%
%   CalcVelocityStreaks is a subclass of matlab.mixin.Copyable, which is
%   itself a subclass of handle, meaning that CalcVelocityStreaks objects
%   are actually references to the data contained in the object.  This
%   allows certain features that are only possible with handle objects,
%   such as events and certain GUI operations.  However, it is important to
%   use the copy method of matlab.mixin.Copyable to create a new,
%   independent object; otherwise changes to a CalcVelocityStreaks object
%   used in one place will also lead to changes in another (perhaps
%   undesired) place.
%
% CalcVelocityStreaks public properties
%   config          - A scalar Config object
%   data            - A scalar DataVelocityStreaks object
%
% CalcVelocityStreaks public methods
%   CalcVelocityStreaks - CalcVelocityStreaks class constructor
%   copy            - Copy MATLAB array of handle objects
%   plot            - Plot a figure
%   process         - Run the processing
%
%   See also CalcVelocityLSPIV, CalcVelocityRadon, CalcVelocity, Calc,
%   Config, DataVelocityStreaks, LineScanVel, FrameScan,
%   StreakScan, ICalcVelocityStreaks

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
    
    properties (Constant, Access = protected)
        validPlotNames = {'graphs', 'windows'};
        validProcessedImg = {'LineScanVel', 'FrameScan'};
    end
    
    % ================================================================== %
    
    methods
        
        function CalcVelocityStreaksObj = CalcVelocityStreaks(varargin)
        %CalcVelocityStreaks - CalcVelocityStreaks class constructor
        %
        %   OBJ = CalcVelocityStreaks() prompts for all required
        %   information and creates a CalcVelocityStreaks object.
        %
        %   OBJ = CalcVelocityStreaks(CONFIG, DATA) uses the specified
        %   CONFIG and DATA objects to construct the CalcVelocityStreaks
        %   object. If any of the input arguments are empty, the
        %   constructor will prompt for any required information.  The
        %   input arguments must be objects which meet the requirements of
        %   the particular concrete subclass of CalcVelocityStreaks.
        %
        %   See also Config, DataVelocityStreaks
            
            % Parse arguments
            [configIn, dataIn] = utils.parse_opt_args({[], []}, varargin);
            
            % Call CalcVelocity (i.e. parent class) constructor
            CalcVelocityStreaksObj = CalcVelocityStreaksObj@CalcVelocity(...
                configIn, dataIn);
            
        end
        
        % -------------------------------------------------------------- %
        
        varargout = plot(self, objPI, varargin)
        
    end
    
    % ================================================================== %
    
    methods (Access = protected)
        
        function hAx = plot_graphs(self, ~, hAx, varargin)
            
            % Setup the default parameter names and values
            pNames = {
                'isDebug'
                };
            pValues = {
                true
                };
            dflts = cell2struct(pValues, pNames);
            params = utils.parse_params(dflts, varargin{:});
            
            % Check handle, making a new one if necessary
            if isempty(hAx)
                
                % Work out the initial number of rows 
                if params.isDebug
                    nGraphs = self.data.nPlotsDebug;
                else
                    nGraphs = self.data.nPlotsGood;
                end

                for iGraph = nGraphs:-1:1
                    hAx(iGraph) = subplot(nGraphs, 1, iGraph);
                end
                
            else
                % Otherwise check that it's a scalar axes
                utils.checks.hghandle(hAx, 'axes', 'hAx');
            end
            
            self.data.plot_graphs(hAx, 'time', [], ...
                'debug', params.isDebug)
            xlabel(hAx(end), 'Time [s]')
            if params.isDebug
                axes(hAx(end)), hold on
                plot(get(hAx(end), 'xlim'), ...
                    ones(1,2)*self.config.thresholdSNR, 'k-')
                hold off
                ylim(hAx(end), [0 inf])
            end

        end

    end
    
    % ================================================================== %
    
    methods (Abstract, Access = protected)
        
        hAx = plot_windows(self, objPI, hAx, varargin)
        
    end
    
    % ================================================================== %
    
end
