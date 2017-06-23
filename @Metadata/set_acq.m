function self = set_acq(self, acq)
%set_acq - Protected class method to set the acquisition properties

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

    % Check that acq is a scalar structure
    utils.checks.object_class(acq, 'struct', 'acq');
    utils.checks.scalar(acq, 'acq structure');
    
    % ------------------------------------------------------------------ %

    % Check we have the lineTime
    hasLineTime = isfield(acq, 'lineTime') && ~isempty(acq.lineTime);
    if hasLineTime
        self.lineTime = acq.lineTime;
    end
    
    % ------------------------------------------------------------------ %
    
    % Check if we have the pixel time
    hasPixelTime = isfield(acq, 'pixelTime') && ~isempty(acq.pixelTime);
    if hasPixelTime
        
        % Set the pixelTime, or issue a warning if there was an error
        try
            self.pixelTime = acq.pixelTime;
        catch ME
            warning(ME.identifier, ME.message)
        end
            
    end
    
    % ------------------------------------------------------------------ %
    
    % Check if we have the pulseDuration
    hasPulseDuration = isfield(acq, 'pulseDuration') && ...
        ~isempty(acq.pulseDuration);
    if hasPulseDuration
        
        % Set the pulseDuration, or issue a warning if there was an error
        try
            self.pulseDuration = acq.pulseDuration;
        catch ME
            warning(ME.identifier, ME.message)
        end
            
    end
    
    % ------------------------------------------------------------------ %
    
    % Check if we have the pulsePeriod
    hasPulsePeriod = isfield(acq, 'pulsePeriod') && ...
        ~isempty(acq.pulsePeriod);
    if hasPulsePeriod
        
        % Set the pulseDuration, or issue a warning if there was an error
        try
            self.pulsePeriod = acq.pulsePeriod;
        catch ME
            warning(ME.identifier, ME.message)
        end
            
    end
    
    % ------------------------------------------------------------------ %
    
    % Check we have the zoom
    hasZoom = isfield(acq, 'zoom') && ~isempty(acq.zoom);
    if hasZoom
        self.zoom = acq.zoom;
    end
    
    % ------------------------------------------------------------------ %
    
    % Check we have the isBiDi, and that it is a scalar logical value
    hasIsBidi = isfield(acq, 'isBiDi') && ~isempty(acq.isBiDi);
    if hasIsBidi
        self.isBiDi = acq.isBiDi;
    end
    
    % ------------------------------------------------------------------ %
    
    % Check if we have discardFlybackLine
    hasFlyback = isfield(acq, 'discardFlybackLine') && ...
        ~isempty(acq.discardFlybackLine);
    if hasFlyback
        
        % Set the pulseDuration, or issue a warning if there was an error
        try
            self.discardFlybackLine = acq.discardFlybackLine;
        catch ME
            warning(ME.identifier, ME.message)
        end

    end
    
    % ------------------------------------------------------------------ %
    
    % Check if we have nFastPoints
    hasFastpoints = isfield(acq, 'nFastPoints') && ...
        ~isempty(acq.nFastPoints);
    if hasFastpoints
        
        % Set the nFastPoints, or issue a warning if there was an error
        try
            self.nFastPoints = acq.nFastPoints;
        catch ME
            warning(ME.identifier, ME.message)
        end

    end
    
    % ------------------------------------------------------------------ %
    
    % Check if we have nLinesPerFrameOrig
    hasOrigLines = isfield(acq, 'nLinesPerFrameOrig') && ...
        ~isempty(acq.nLinesPerFrameOrig);
    if hasOrigLines
        
        % Set the nLinesPerFrameOrig, or issue a warning if there was an
        % error
        try
            self.nLinesPerFrameOrig = acq.nLinesPerFrameOrig;
        catch ME
            warning(ME.identifier, ME.message)
        end

    end
    
    % ------------------------------------------------------------------ %
    
    % Check if we have nPixelsPerLineOrig
    hasOrigPixels = isfield(acq, 'nPixelsPerLineOrig') && ...
        ~isempty(acq.nPixelsPerLineOrig);
    if hasOrigPixels
        
        % Set the nPixelsPerLineOrig, or issue a warning if there was an
        % error
        try
            self.nPixelsPerLineOrig = acq.nPixelsPerLineOrig;
        catch ME
            warning(ME.identifier, ME.message)
        end

    end

end