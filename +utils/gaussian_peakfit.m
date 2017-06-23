function ppOpt = gaussian_peakfit(cc, lags, nPixelsToFit, varargin)
%gaussian_peakfit - Helper function for Gaussian peak fitting
%
%   This function is not intended to be called directly.

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

% Check the number of input arguments
narginchk(3, 4);

% Parse arguments
doPlot = utils.parse_opt_args({false}, varargin);

% Prepare some variables for the fit
nIdxsCorr = length(lags);

% Find an initial estimate guess for the peak x-corr
[~, idxMax] = max(cc);
idxMax = min([idxMax, nIdxsCorr]);

% Work out which of the indices we want to fit
idxsToFit = max([1, idxMax - nPixelsToFit]) : ...
    min([nIdxsCorr, idxMax + nPixelsToFit]);

% Perform the fitting
[sigma, mu, AA] = utils.mygaussfit(lags(idxsToFit), cc(idxsToFit));
ppOpt = [AA, mu, sqrt(2*sigma^2)];

% Figure for debugging
if doPlot
    funGauss = @(xx) AA .* exp( -(xx-mu).^2 ./ (2*sigma^2) );
    hold on
    plot(lags', cc)
    plot(lags(idxsToFit)', funGauss(lags(idxsToFit)'))
    plot(ones(1, 2)*ppOpt(2), [0, 1], 'k--')
    xlim([min(lags(idxsToFit)), max(lags(idxsToFit))])
    ylim([0, 1])
    hold off
end

end
