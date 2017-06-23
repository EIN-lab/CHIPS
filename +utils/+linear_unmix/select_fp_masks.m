function maskFPsBG = select_fp_masks(img, nFPs)
%select_fp_masks - Select masks for fluorophore and background regions
%
%   MASKS = select_fp_masks(IMG, N_FP) displays the multichannel image
%   and prompts to select N_FP regions, each one containing exclusively a
%   single fluorophore, as well as a mutual background region.  These
%   regions are returned as a logical mask, with dimensions RxCx(N_FP+1),
%   where R and C are the number of rows and columns in IMG.
%
%   See also utils.linear_unmix.linear_unmix, 
%   utils.linear_unmix.assemble_mixmat

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

% Check number of inputs.
narginchk(2, 2);

% Check the input image
utils.checks.object_class(img, {'numeric'}, 'image sequence')
utils.checks.greater_than(ndims(img), 2, 1, 'Number of image dimensions')
utils.checks.less_than(ndims(img), 4, 1, 'Number of image dimensions')
img = double(img);
[~, ~, nChs, ~] = size(img);

% Check the number of fluorophores
utils.checks.prfsi(nFPs, 'number of fluorophores');

% Check for the image processing toolbox
feature = 'Image_Toolbox';
className = 'LinearUnmix:SelectFPMasks';
utils.verify_license(feature, className);

%% Main part of the function

% Assemble a mean image to display all the channels
[img, cmaps] = utils.combine_img_chs(img);
II_mean = mean(img, 4);

% Initialize mask to cover selected regions
maskHide = false(size(II_mean));

% Select exclusive regions for each of the fluorophores
startPos = [5, 5];
for iFP = 1:nFPs

    % Hide the previously selected fluorophore regions
    II_mean(maskHide) = 0;

    % Select the region for the current fluorophore
    titleString = sprintf(['Draw a region containing ' ...
        'exclusively fluorophore %d'], iFP);
    hFig = figure;
    imagesc(II_mean); hold on
    hAx = gca;
    axis(hAx, 'image', 'off')
    title(titleString);
    
    % Label the channels
    nextPos = startPos;
    for jCh = 1:nChs
        hTxt = text(nextPos(1), nextPos(2), sprintf('Ch-%d', jCh), ...
            'HorizontalAlignment', 'left', 'VerticalAlignment', 'top');
        set(hTxt, 'Color', cmaps(end, :, jCh))
        lastExtent = get(hTxt, 'Extent');
        lastPos = get(hTxt, 'Position');
        nextPos = lastPos(1:2) + [startPos(1) + 1.1*lastExtent(3), 0];
    end
    hold off
    
    % Select the region for the current fluorophore
    hROI = imfreehand(gca, 'Closed', 1);
    maskFPsBG(:,:,iFP) = hROI.createMask();
    wait(hROI);
    close(hFig)

    % Prepare the selected mask
    maskHide = maskHide | repmat(maskFPsBG(:,:,iFP), [1, 1, 3]);

end     

% Select mutual background region
II_mean(maskHide) = 0;
hFig = figure;
imagesc(II_mean);
hAx = gca;
title('Choose a mutual background region');
axis(hAx, 'image', 'off')
hROI = imfreehand(gca, 'Closed', 1);
maskFPsBG(:,:,end+1) = hROI.createMask();
wait(hROI);
close(hFig);
    
end