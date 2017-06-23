function [diamProfile, lineRate] = adjust_diamProfile(self, ...
                diamProfile, lineRate)
     
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
           
% Don't bother doing anything if the lineRate is slow enough
if lineRate <= self.config.maxRate
    return
end

% Work out how many of the lines to average
nLinesToAvg = ceil(lineRate / self.config.maxRate);

% Work out how many total lines to use (because if we used all of them we 
% might occasionally get an error where there's a small number overhanging 
% at the end)
[nLines, nPixels] = size(diamProfile);
nLinesNew = floor(nLines / nLinesToAvg);

% Adjust the diameter profile and line rate
diamProfile = squeeze(mean(reshape(...
    diamProfile(1:nLinesToAvg*nLinesNew, :)', nPixels, ...
    nLinesToAvg, []), 2))';
lineRate = lineRate / nLinesToAvg;

end