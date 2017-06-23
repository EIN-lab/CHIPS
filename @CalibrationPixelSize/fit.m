function self = fit(self)
%fit - Fit the funRaw to the supplied data

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
%   along with this program.  If not, see <http://www.gnu.org/licenses/>

    % Check for the optimization toolbox
    feature = 'Optimization_Toolbox';
    className = 'CalibrationPixelSize';
    utils.verify_license(feature, className);

    % Set up the optimisation problem
    funObj = @(params) self.funRaw(self.zoom, params) - self.pixelSize;
    params0 = [1, mean(self.pixelSize)];
    lb = [0 0];
    ub = [10, 2*min(self.pixelSize)];
    options = optimset('Display', 'off');

    % Determine the optimal values for the parameters
    self.paramsOpt = lsqnonlin(funObj, params0, lb, ub, options);

    % Create the optimal parameterised function for use later
    self.funFitted = @(zoom) self.funRaw(zoom, self.paramsOpt);

end