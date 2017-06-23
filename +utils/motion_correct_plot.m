function motion_correct_plot(sx, sy, dims, refImg)
%motion_correct_plot - Plot a figure illustrating the motion correction
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
narginchk(4, 4);

ydim = dims(1);
xdim = dims(2);
nFrames = dims(3);
x1 = 1:xdim;
y1 = 1:ydim;

isLine = ~(numel(sx) == nFrames);
if isLine
    nLines = numel(sx)/nFrames;
end

subplot(5,5,[2:5 7:10 12:15 17:20])
imagesc(x1,y1,refImg); hold on
colormap('gray')
title('Reference Image');
axis image, axis off

for iFrame = 1:nFrames

    % Skip any bad frames
    isBadFrame = isnan(sx(iFrame)) || isnan(sy(iFrame));
    if isBadFrame
        continue
    end
    
    if ~isLine
        x2 = sx(iFrame) + (1:xdim);
        y2 = sy(iFrame) + (1:ydim);
        x = intersect(x1,x2);
        y = intersect(y1,y2);
        plot(x([1 end end 1 1])+[-1 1 1 -1 -1]/2,...
            y([1 1 end end 1])+[-1 -1 1 1 -1]/2,...
            'w','LineWidth',1);
    end

end

% Work out the maximum shift to define the axis limits
maxShift = 1.1*max(abs([sx, sy]));

% Plot the x shifts
xx = 1:length(sx);

subplot(5,5,[1 6 11 16]), hold on
if isLine
    sx = reshape(sx, nLines, nFrames);
    sx_mean = utils.nansuite.nanmean(sx);
    sx_std = utils.nansuite.nanstd(sx);
    xxNaN = any(isnan(sx), 1);
    utils.boundedline.boundedline(sx_mean, 1:nFrames, sx_std, ...
        'orientation', 'horiz');
else
    xxNaN = isnan(sx);
    plot(sx, xx, 'b.-', 'LineWidth', 2);
end
plot(zeros(1, sum(xxNaN)), xx(xxNaN), 'rx')
xlabel('X Shift')
ylabel('Frame Number')
if maxShift > 0
    xlim([-maxShift, maxShift])
end
ylim([0.5, nFrames+0.5])

% Plot the y shifts
yy = 1:length(sy);

subplot(5,5,22:25), hold on
if isLine
    sy = reshape(sy, nLines, nFrames);
    sy_mean = utils.nansuite.nanmean(sy);
    sy_std = utils.nansuite.nanstd(sy);
    yyNaN = any(isnan(sy), 1);
    utils.boundedline.boundedline(1:nFrames, sy_mean, sy_std);
else
    yyNaN = isnan(sy);
    plot(yy, sy, 'b.-', 'LineWidth', 2);
end
plot(yy(yyNaN), zeros(1, sum(yyNaN)), 'rx')
xlabel('Frame number')
ylabel('Y Shift')
xlim([0.5, nFrames+0.5])
if maxShift > 0
    ylim([-maxShift, maxShift])
end

hasBadFrames = (sum(yyNaN) + sum(xxNaN)) > 0;
if hasBadFrames
    if isLine
        strBad = 'Contains Bad Lines';
    else
        strBad = 'Bad Frames';
    end
    legend(strBad, 'Location', 'Best')
    legend('boxoff')
end

end