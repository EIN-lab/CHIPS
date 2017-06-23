function dataInterp = interp_masked(self, dataRaw)
%interp_masked - Linearly interpolates data points that have been masked

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
    
nPoints = length(dataRaw);

maskDiffs = diff([0; any([self.mask], 2); 0]);
begPoints = find(maskDiffs == 1);
endPoints = find(maskDiffs == -1) - 1;

% Check if wrong number of beginning and end points
isWrongNPoints = length(begPoints) ~= length(endPoints);
if isWrongNPoints
    warning('Data:InterpMasked:WrongNPoints', 'Wrong number of points')
    return
end

% Pre-assign all the raw data to the interpolated data
dataInterp = dataRaw;

isFirstPoint = false;
isLastPoint = false;

for i = 1:length(begPoints)
    
    % Pull out the start/end indices that we're working
    x1 = begPoints(i) - 1;
    x2 = endPoints(i) + 1;
    
    % Check if the whole data vector is masked out
    isNoGoodData = x1 == 0 && x2 == nPoints;
    if isNoGoodData
        warning('Data:InterpMasked:NoGoodData', 'There is no good data')
        return
    end
    
    
    if x1 > 0
        
        y1 = dataRaw(x1);
        
    else
        
        % Adjust for the case where the first window is masked out
        isFirstPoint = true;
        x1 = 1;
        
        if x2 <= nPoints
            y1 = dataRaw(x2);
        else
            y1 = dataRaw(end);
        end;
        
    end
    
    if x2 < nPoints
        
        y2 = dataRaw(x2);
        
    else
        
        % Adjust for the case where the last window is masked out
        isLastPoint = true;
        x2 = nPoints;
        
        if x2 > 0
            y2 = dataRaw(x1);
        else
            y2 = dataRaw(1);
        end
        
    end
    
    % Work out which values to interpolate for
    if ~isFirstPoint && ~isLastPoint
        xx = x1 + 1 : x2 - 1;
    elseif isFirstPoint
        xx = x1;
    elseif isLastPoint
        xx = x2;
    end
    
    % Do the actual interpolation
    methodInterp = 'linear';
    dataInterp(xx) = interp1([x1 x2], [y1, y2], xx, methodInterp);
    
end

end