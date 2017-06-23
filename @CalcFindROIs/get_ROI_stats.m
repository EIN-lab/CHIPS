function stats = get_ROI_stats(roiMask, pixelSize)
%get_ROI_stats - Extract descriptive statistics about ROIs

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

    % Properties we care about
    props = {'Area', 'Centroid', 'PixelIdxList'};
    empty = repmat({{}}, 1, numel(props));
    args = [props; empty];
    stats = struct(args{:});

    % Extract statistics on per frame basis
    nMasks = size(roiMask,3);
    for iFr = 1:nMasks
        
        % Look for connected components (should be just one for every frame)
        cc = bwconncomp(roiMask(:, :, iFr));

        % label cc - should give a binary image
        % 0- background; 1- ROI
        mafr_lab = labelmatrix(cc);

        % ask matlab function to give you statistics
        stats = [stats; regionprops(mafr_lab, props)];
        
    end
    
    % Rescale to absolute units
    if ~isempty(stats)
        area = num2cell([stats.Area] .* power(pixelSize, 2));
        [stats.Area] = deal(area{:});
    end
    
end
