classdef DataVelocityRadon < DataVelocityStreaks
%DataVelocityRadon - Data from Radon based velocity calculations
%
%   The DataVelocityRadon class is a data class that is designed to
%   contain all the basic data output from CalcVelocityRadon.
%
% DataVelocityRadon public properties inherited from Data:
%   mask            - A mask combining all of the other masks
%   means           - A helper structure containing means of the data
%   nPlotsGood      - The number of plots in non-debug mode        
%   nPlotsDebug     - The number of plots in debug mode
%   state           - The current state
%   stdevs          - A helper structure containing stdevs of the data
%
% DataVelocityRadon public properties
%   estSNR          - An estimate of the SNR of the velocity calculation
%   flux            - A time series of the RBC flux [cells/s]
%   linearDensity   - A time series of the RBC linear density [mm/mm]
%   lineDensity     - A time series of the RBC linear density [cells/mm]
%   maskSNR         - Points below the SNR threshold
%   maskSTD         - Points outside the std range
%   rbcSpacingD     - The distance spacing between individual cells [um]
%   rbcSpacingT     - The time spacing between individual cells [ms]
%   theta           - A time series of the RBC streak angle [degrees]
%   thetaRangeMid   - The midpoint of the streak angle range [degrees]
%   time            - The time series vector [s]
%   velocity        - A time series vector of the RBC velocity [mm/s]
%   yPosition       - The y position at which the velocity was calculated
%
% DataVelocityRadon public methods:
%   add_raw_data    - Add raw data to the Data object
%   add_processed_data - Add processed data to the Data object
%   add_mask_data   - Add mask data to the Data object
%   plot            - Plot a single graph from the Data object
%   plot_graphs     - Plot multiple graphs from the Data object
%   output_data     - Output the data
%
%   See also DataVelocityLSPIV, DataVelocityStreaks, DataVelocity, Data,
%   CalcVelocityRadon, LineScanVel, FrameScan

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
        
        %flux - A time series of the RBC flux [cells/s]
        %
        %   See also DataVelocityRadon.velocity,
        %   DataVelocityRadon.lineDensity
        flux
        
        %linearDensity - A time series of the RBC linear density [mm/mm]
        %
        %   See also DataVelocityRadon.lineDensity
        linearDensity
        
        %lineDensity - A time series of the RBC line density [cells/mm]
        %
        %   See also DataVelocityRadon.velocity, DataVelocityRadon.flux, 
        %   DataVelocityRadon.linearDensity
        lineDensity
        
        %rbcSpacingD - The distance spacing between individual cells [um]
        %
        %   See also DataVelocityRadon.rbcSpacingT
        rbcSpacingD
        
        %rbcSpacingT - The time spacing between individual cells [ms]
        %
        %   See also DataVelocityRadon.rbcSpacingD
        rbcSpacingT
        
        %theta - A time series of the RBC streak angle [degrees]
        %
        %   See also DataVelocityRadon.velocity
        theta
        
        %thetaRangeMid - The midpoint of the streak angle range [degrees]
        %
        %   See also DataVelocityRadon.theta
        thetaRangeMid
        
    end
    
    % ------------------------------------------------------------------ %
    
    properties (Constant, Access = protected)
        
        listRaw = {'time', 'theta', 'flux', 'linearDensity', ...
            'rbcSpacingT', 'yPosition', 'estSNR', 'thetaRangeMid'};
        listProcessed = {'velocity', 'lineDensity', 'rbcSpacingD'};
        listMask = {'maskSNR', 'maskSTD'};
        
        listPlotDebug = {'velocity', 'flux', 'lineDensity', 'theta', ...
            'estSNR'};
        labelPlotDebug = {'Velocity [mm/s]', 'RBC Flux [cells/s]', ...
            'Line Density [cells/mm]', 'Streak Angle [deg]', ...
            'Estimated SNR [a.u.]'};
        
        listPlotGood = {'velocity', 'flux', 'lineDensity'};
        labelPlotGood = {'Velocity [mm/s]', 'RBC Flux [cells/s]', ...
            'Line Density [cells/mm]'};
        
        listMean = {'velocity', 'flux', 'lineDensity', 'linearDensity', ...
            'yPosition', 'theta', 'estSNR'};
        
        listOutput = {'time', 'velocity', 'flux', 'lineDensity', ...
            'linearDensity', 'yPosition', 'theta', 'estSNR', 'maskSNR', ...
            'maskSTD', 'mask'};
        nameDataClass = 'Velocity (Radon)';
        suffixDataClass = 'velocityRadon';
        
    end
    
    % ================================================================== %
    
    methods
        
        function self = set.linearDensity(self, val)
            utils.checks.real_num(val, 'linearDensity')
            utils.checks.vector(val, 'linearDensity')
            self.linearDensity = val;
        end
        
        % -------------------------------------------------------------- %
        
        function self = set.lineDensity(self, val)
            utils.checks.real_num(val, 'lineDensity')
            utils.checks.vector(val, 'lineDensity')
            self.lineDensity = val;
        end
        
        % -------------------------------------------------------------- %
        
        function self = set.rbcSpacingD(self, val)
            utils.checks.cell_array(val, 'rbcSpacingD')
            utils.checks.vector(val, 'rbcSpacingD')
            self.rbcSpacingD = val;
        end
        
        % -------------------------------------------------------------- %
        
        function self = set.rbcSpacingT(self, val)
            utils.checks.cell_array(val, 'rbcSpacingT')
            utils.checks.vector(val, 'rbcSpacingT')
            self.rbcSpacingT = val;
        end
        
        % -------------------------------------------------------------- %
        
        function self = set.theta(self, val)
            utils.checks.rfv(val, 'theta')
            self.theta = val;
        end
        
        % -------------------------------------------------------------- %
        
        function self = set.flux(self, val)
            utils.checks.rfv(val, 'flux')
            self.flux = val;
        end
        
        % -------------------------------------------------------------- %
        
        function self = set.thetaRangeMid(self, val)
            utils.checks.rfv(val, 'thetaRangeMid')
            self.thetaRangeMid = val;
        end
        
    end
    
    % ================================================================== %
    
end
