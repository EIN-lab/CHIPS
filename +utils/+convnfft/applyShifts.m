function imgSeq = applyShifts(imgSeq, sx, sy, fillBadData, inpaintIters)
%applyShifts - Apply calculated shifts to an image sequence
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
%   MERCHANTABILITY or FITNESS FOR A PARTICULAR P   URPOSE.  See the
%   GNU General Public License for more details.
%   
%   You should have received a copy of the GNU General Public License 
%   along with this program.  If not, see <http://www.gnu.org/licenses/>.

% Bad frame, fill missing data or replace
switch lower(fillBadData)

    case {'nan', 'median', 'inpaint'}
        
        funReplace = @nan;

    case 'zero'

        funReplace = @zeros;
        
    otherwise
        
        warning('ConvNFFT:ApplyShift:BadFillMethod', ['The method ' ...
                '"%s" to fill bad data is not recognised.  Using "nan" ' ...
                'instead.'], fillBadData)
        fillBadData = 'nan';
        imgSeq = utils.convnfft.applyShifts(imgSeq, sx, sy, fillBadData);
        return 
            
end

hasInpaintIters = (nargin > 4) && ~isempty(inpaintIters);
if ~hasInpaintIters
    inpaintIters = 5;
end

frames = size(imgSeq, 3);
for iFrame = 1:frames
    
    % Apply the shift to the current frame
    corrFrame = imgSeq(:, :, iFrame);
    
    dx = sx(iFrame);
    dy = sy(iFrame);
    
    % Shift and crop, so that the dimensions stay the same
    [ydim, xdim] = size(corrFrame);
    
    % Check for bad frame
    if ~isfinite(dx) || ~isfinite(dy)
        
        % Bad frame, fill missing data or replace
        switch lower(fillBadData)
            
            case {'nan', 'zero', 'inpaint'}
                
                corrFrame = funReplace(size(corrFrame), class(imgSeq));
                
            case 'median'
                
                % Calculate median of frames before and after bad frame
                % Find the last good frame
                goodX = isfinite(sx(1:iFrame));
                goodY = isfinite(sy(1:iFrame));
                goodFrames = goodX & goodY;
                frameBefore = find(goodFrames, 1, 'last');
                
                % Find the next good frame
                goodX = isfinite(sx(iFrame:end));
                goodY = isfinite(sy(iFrame:end));
                goodFrames = goodX & goodY;
                frameAfter = find(goodFrames, 1, 'first');
                
                if isempty(frameBefore) || isempty(frameAfter)
                    warning('ConvNFFT:ApplyShift:NoData', ['Can''t fill ' ...
                        'missing data using the median because there is ' ...
                        'no data on at least one side of the frame. ' ...
                        'Filling using NaNs instead. You may wish to try ' ...
                        'motion correction using the inpaint method.'])
                    corrFrame = nan(size(corrFrame));
                else
                    
                    % Concatenate the two frames and take median
                    missingData = cat(3, imgSeq(:,:,frameBefore), ...
                        imgSeq(:,:,frameAfter));
                    
                    corrFrame = median(missingData, 3);
                end
                
        end
        
        imgSeq(:,:,iFrame) = corrFrame;
        continue
        
    end
    
    % X-Shift
    if dx == 0
        % No shift
    elseif dx > 0
        corrFrame(:,end:-1:(end-abs(dx)+1))=[];
        replacement = funReplace(ydim, abs(dx), class(imgSeq));
        corrFrame = cat(2, replacement, corrFrame);
    elseif dx < 0
        corrFrame(:,1:abs(dx))=[];
        replacement = funReplace(ydim, abs(dx), class(imgSeq));
        corrFrame = cat(2, corrFrame, replacement);
    end
    
    % Y-Shift
    if dy == 0
        % No shift
    elseif dy > 0
        corrFrame(end:-1:(end-abs(dy)+1),:)=[];
        replacement = funReplace(abs(dy),xdim, class(imgSeq));
        corrFrame = cat(1, replacement, corrFrame);
    elseif dy < 0
        corrFrame(1:abs(dy),:)=[];
        replacement = funReplace(abs(dy),xdim, class(imgSeq));
        corrFrame = cat(1, corrFrame, replacement);
    end
    
    imgSeq(:,:,iFrame) = corrFrame;
    
end

% Inpaint the NaNs if necessary
if strcmpi(fillBadData, 'inpaint')
    imgSeq = utils.inpaintn(imgSeq, inpaintIters);
end

end
