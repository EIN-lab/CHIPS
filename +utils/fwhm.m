function [fwhmOut, idxEdges] = fwhm(xx, varargin)
%fwhm - Calculate the full width at half maximum
%
%   FWHM = fwhm(X) calculates the full width at half maximum of X.  X must
%   be a vector containing only real numbers.
%
%   FWHM = fwhm(..., 'attribute', value) specifies one or more 
%   attribute/value pairs.  Valid attributes (case insensitive) are:
%
%       'doPlot' -> Whether to display a plot for debugging purposes. The
%                   doPlot must be a scalar value that can be converted to
%                   a logical. [default = false]
%
%       'lev50' ->	The normalised height level at which to calculate the
%                   FWHM.  The lev50 must be a finite scalar real number 
%                   between 0 and 1 (non-inclusive). [default = 0.5]
%
%       'method' ->	The method to use for one dimensional interpolation.
%                   The method must be a single row character array. See
%                   the help for interp1 (link below) for more info.
%                   [default = 'linear']
%
%       'nAround' -> The number of points around the edge to use in
%                   the interpolation. nAround must be a positive scalar
%                   integer. [default = 2]
%
%   [FWHM, IDX_EDGES] = fwhm(...) also returns the indices of the edges
%   that define the FWHM.
%
%   See also interp1

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
narginchk(1, inf);

% Check the 1d signal
utils.checks.real_num(xx, 'X');
utils.checks.vector(xx, 'X');

% Define allowed optional arguments and default values
pNames = {...
    'doPlot'; ...
    'lev50'; ...
    'method'; ...
    'nAround'; ...
    };
pValues  = {...
    false; ...
    0.5; ...
    'linear'; ...
    2; ...
    };
dflts = cell2struct(pValues, pNames);

% Parse function input arguments
params = utils.parsepropval(dflts, varargin{:});

% Check the parameters
utils.checks.scalar_logical_able(params.doPlot, 'doPlot');
utils.checks.prfs(params.lev50, 'lev50');
utils.checks.less_than(params.lev50, 1, false, 'lev50');
utils.checks.single_row_char(params.method, 'method')
utils.checks.prfsi(params.nAround, 'nAround')

% Setup default output arguments
idxEdges = nan(1, 2);
fwhmOut = NaN;

%% Main part of the function

% Normalise the signal over the range 0-1;
minX = utils.nansuite.nanmin(xx);
maxX = utils.nansuite.nanmax(xx);
rangeX = maxX - minX;
if abs(rangeX) > eps(0)
    xNorm = (xx - minX)./rangeX;
else
    warning('FWHM:ZeroRange', ['The maximum and minimum values are ' ...
        'identical, so the FWHM cannot be determined.'])
    return
end

% Create a binary signal of those pixels above the lev50
aboveHalf = xNorm >= params.lev50;
aboveIdx = find(aboveHalf == 1);

% Find the edges of these
idxEdgesRaw = [min(aboveIdx) max(aboveIdx)];
idxEdgesRaw = unique(idxEdgesRaw);
nEdges = length(idxEdgesRaw);

for iEdge = 1:nEdges
	
    % Select only a few points around the edge.
    minRange = max([1, idxEdgesRaw(iEdge) - (params.nAround)]);
    maxRange = min([idxEdgesRaw(iEdge) + params.nAround, length(xNorm)]);
    rangeVals = minRange:maxRange;
    
    % Remove non-unique values for the interpolation
    [~, m] = unique(xNorm(rangeVals));
    rangeVals = rangeVals(sort(m));
    
    % Use subpixel interpolation to determine the edge indices more
    % accurately
    idxEdges(iEdge) = interp1(xNorm(rangeVals), rangeVals, ...
        params.lev50, params.method);
    
end

if nEdges < 2
    warning('FWHM:NotEnoughEdges', ['The signal does not cross the ' ...
        'threshold more than once, so the FWHM cannot be determined'])
    return
end

% Calculate the FWHM using the subpixel edges
fwhmOut = idxEdges(2) - idxEdges(1);

% Plotting, for debugging
if params.doPlot
    figure, hold on
    xlabel('Pixel Number', 'FontSize', 14)
    ylabel('Normalised Pixel Intensity', 'FontSize', 14)
    plot(xNorm,'b-', 'LineWidth', 2)
    plot(idxEdges(1)*ones(1,2), [0 0.5], 'k--')
    plot(idxEdges(2)*ones(1,2), [0 0.5], 'k--')
    plot([idxEdges(1) idxEdges(2)], 0.5*ones(1,2), 'k--')
    text(idxEdges(1)+0.5*fwhmOut, 0.55, 'FWHM', ...
        'HorizontalAlignment', 'center')
    hold off
end

end
