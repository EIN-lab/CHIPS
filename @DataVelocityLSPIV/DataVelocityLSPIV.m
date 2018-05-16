classdef DataVelocityLSPIV < DataVelocityStreaks
%DataVelocityLSPIV - Data from LSPIV-based velocity calculation
%
%   The DataVelocityLSPIV class is a data class that is designed to
%   contain all the basic data output from CalcVelocityLSPIV.
%
% DataVelocityLSPIV public properties inherited from Data:
%   mask            - A mask combining all of the other masks
%   means           - A helper structure containing means of the data
%   nPlotsGood      - The number of plots in non-debug mode        
%   nPlotsDebug     - The number of plots in debug mode
%   state           - The current state
%   stdevs          - A helper structure containing stdevs of the data
%
% DataVelocityLSPIV public properties
%   estSNR          - An estimate of the SNR of the velocity calculation
%   maskSNR         - Points below the SNR threshold
%   maskSTD         - Points outside the std range
%   pixelShift      - The number of pixels the RBCs have shifted
%   time            - The time series vector [s]
%   velocity        - A time series vector of the RBC velocity [mm/s]
%   xCorr           - The cross correlation curve for every time point
%   yPosition       - The y position at which the velocity was calculated
%
% DataVelocityLSPIV public methods:
%   add_raw_data    - Add raw data to the Data object
%   add_processed_data - Add processed data to the Data object
%   add_mask_data   - Add mask data to the Data object
%   plot            - Plot a single graph from the Data object
%   plot_graphs     - Plot multiple graphs from the Data object
%   output_data     - Output the data
%
%   See also DataVelocityRadon, DataVelocityStreaks, DataVelocity, Data,
%   CalcVelocityLSPIV, LineScanVel, FrameScan

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
        
        %pixelShift - The number of pixels the RBCs have shifted
        %
        %   See also DataVelocityLSPIV.xCorr
        pixelShift
        
        %xCorr - The cross correlation curve for every time point
        %
        %   See also DataVelocityLSPIV.pixelShift
        xCorr
        
    end
    
    % ------------------------------------------------------------------ %
    
    properties (Constant, Access = protected)
        
        listRaw = {'time', 'yPosition', 'xCorr', 'pixelShift', 'estSNR'};
        listProcessed = {'velocity'};
        listMask = {'maskSNR', 'maskSTD'};
        
        listPlotDebug = {'velocity', 'pixelShift', 'estSNR'};
        labelPlotDebug = {'Velocity [mm/s]', 'Pixel Shift [pixels]', ...
            'Estimated SNR [a.u.]'};
        
        listPlotGood = {'velocity'};
        labelPlotGood = {'Velocity [mm/s]'};
        
        listMean = {'velocity', 'yPosition', 'pixelShift', 'estSNR'};
        
        listOutput = {'time', 'velocity', 'yPosition', 'pixelShift', ...
            'estSNR', 'maskSNR', 'maskSTD', 'mask'};
        nameDataClass = 'Velocity (LS-PIV)';
        suffixDataClass = 'velocityLSPIV';
        
    end
    
    % ================================================================== %
    
    methods
        
        function plot_graphs(self, varargin)
            
            % Define the allowed optional arguments and default values, and create a
            % default parameters structure
            pnames = {'average', 'blArgs', 'debug', 'interp', ...
                'inverse', 'plotArgs', 'plotFun', 'yLabels'};
            dflts  = {false, {'alpha'}, true, [], false, {}, @plot, []};
            defParams = cell2struct(dflts, pnames, 2);
            
            % Parse arguments (ignoring warning about any extra ones)
            wngState = warning('off', 'ParseOptArgs:TooManyInputs');

            % Check axis handle is the correct class, create one if it doesn't exist,
            % and work out where the rest of the arguments are
            hAxes = [];
            hasAxes = (nargin > 1) && all(ishghandle(varargin{1})) && ...
                all(strcmp(get(varargin{1}, 'type'), 'axes'));
            if hasAxes

                % Check we have enough arguments in this case
                narginchk(3, inf)

                % Pull out the axis
                hAxes = varargin{1};

                % Extract the rest of the arguments
                [xDataIn, yVarListIn] = utils.parse_opt_args({[], []}, ...
                    varargin(2:end));
                params = utils.parsepropval(defParams, varargin{4:end});

            else

                % Extract the rest of the arguments
                [xDataIn, yVarListIn] = utils.parse_opt_args({[], []}, ...
                    varargin(:));
                params = utils.parsepropval(defParams, varargin{3:end});

            end

            % Restore the warning state
            warning(wngState)
            
            % Work out if we need to do anything
            doSomething = params.debug && ~params.inverse && ...
                strcmp(xDataIn, 'time') && isempty(yVarListIn) && ...
                isempty(params.yLabels) && ...
                isequal(params.plotFun, defParams.plotFun);
            
            % If we don't, call the superclass method without modification
            if ~doSomething
                self.plot_graphs@DataVelocityStreaks(varargin{:});
                return
            end
            
            % Otherwise, create list of vars
            xData = 'time';
            yVarList = self.listPlotDebug;
            nAxes = length(yVarList);
            maskPixelShift = strcmp('pixelShift', yVarList);
            yLabelList = self.labelPlotDebug;
            
            % Create axis handles, if necessary
            if isempty(hAxes)
                for iAx = nAxes:-1:1
                    hAxes(iAx) = subplot(nAxes, 1, iAx);
                end
            end
            
            % Call superclass to plot most of the vars
            self.plot_graphs@DataVelocityStreaks(hAxes(~maskPixelShift), ...
                xData, yVarList(~maskPixelShift), 'yLabel', ...
                yLabelList(~maskPixelShift));
            
            % Plot the xcorr image
            nPixels = size(self.xCorr, 2);
            maxPixelShift = round(nPixels / 2) - 1;
            idxsCorr = maxPixelShift:-1:-maxPixelShift;
            imagesc(self.time, idxsCorr, self.xCorr', ...
                'Parent', hAxes(maskPixelShift))
            set(hAxes(maskPixelShift), 'YDir','normal')
            
            % Prepare a parameters structure for plot
            paramsPlot = rmfield(params, {'inverse', 'yLabels'});
            
            % Plot the pixelShift line
            hold on
            axes(hAxes(maskPixelShift))
            self.plot(hAxes(maskPixelShift), xData, 'pixelShift', ...
                paramsPlot)
            ylabel(hAxes(maskPixelShift), yLabelList(maskPixelShift))
            hold off
            
            % Restore the y axis for the xcorr image
            axis(hAxes(maskPixelShift), 'tight')
%             set(hAxes(maskPixelShift), 'YLim', 'normal')
            
        end
        
        % -------------------------------------------------------------- %
        
        function self = set.xCorr(self, val)
            utils.checks.real_num(val, 'xCorr')
            utils.checks.finite(val, 'xCorr')
            self.xCorr = val;
        end
        
        % -------------------------------------------------------------- %
        
        function self = set.pixelShift(self, val)
            utils.checks.rfv(val, 'pixelShift')
            self.pixelShift = val;
        end
        
    end
    
    % ================================================================== %
    
end
