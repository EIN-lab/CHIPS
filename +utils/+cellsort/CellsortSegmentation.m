function [ica_segments, ica_filtersbw, segmentlabel] = ...
    CellsortSegmentation(ica_filters, sigma, thresholdSeg, arealims, ...
    discardBorderROIs)
% [ica_segments, ica_filtersbw, segmentlabel, segcentroid] = 
% CellsortSegmentation(ica_filters, sigma, thresholdSeg, arealims, plotting)
%
%CellsortSegmentation
% Segment spatial filters derived by ICA
%
% Inputs:
%     ica_filters - X x Y x nIC matrix of ICA spatial filters
%     sigma - standard deviation of Gaussian smoothing kernel (pixels)
%     thresholdSeg - threshold for spatial filters (standard deviations)
%     arealims - 2-element vector specifying the minimum and maximum area
%     (in pixels) of segments to be retained; if only one element is
%     specified, use this as the minimum area
%     plotting - [0,1] whether or not to show filters
%
% Outputs:
%     ica_segments - segmented spatial filters
%     ica_filtersbw - X x Y x nIC matrix of ICA spatial filters,
%     thresholded to yield logical mask.
%     segmentabel - indices of the ICA filters from which each segment was
%                   derived
%     segcentroid - X,Y centroid, in pixels, of each segment
%
% Eran Mukamel, Axel Nimmerjahn and Mark Schnitzer, 2009
% Email: eran@post.harvard.edu, mschnitz@stanford.edu
%
%% Check inputs
% tic
% fprintf('-------------- CellsortSegmentation %s -------------- \n', date)

if (nargin<3)||isempty(thresholdSeg)
    thresholdSeg = 2;
end
if (nargin<4)||isempty(arealims)
    arealims = 200;
end
[nIC,numRows,numCols] = size(ica_filters);

%% Create binary and fractional mask
ica_filtersorig = ica_filters / abs(std(ica_filters(:)));
ica_filters = (ica_filters - mean(ica_filters(:)))/abs(std(ica_filters(:)));

if sigma>0
    % Smooth mixing filter with a Gaussian of s.d. sigma pixels
    smrange = max(5,3*sigma);
    [x,y] = meshgrid([-smrange:smrange]);

    smy = 1; smx = 1;
    ica_filtersfilt = exp(-((x/smx).^2 + (y/smy).^2)/(2*sigma^2));
    
    ica_filtersfilt = ica_filtersfilt/sum(ica_filtersfilt(:));
    ica_filtersbw = false(numRows,numCols,nIC);
    for ii = 1:size(ica_filters,1)
        ica_filtersuse = ica_filters(ii,:,:);
        ica_filtersuse = (ica_filtersuse - mean(ica_filtersuse(:)))/...
            abs(std(ica_filtersuse(:)));
        ica_filtersbw(:,:,ii) = (imfilter(ica_filtersuse, ...
            ica_filtersfilt, 'replicate', 'same') > thresholdSeg);
    end
else
    ica_filtersbw = (permute(ica_filters,[2,3,1]) > thresholdSeg);
end

% Discard ROIs touching the border, if necessary
if discardBorderROIs
    maskTouchesEdge = false(1, nIC);
    for iIC = 1:nIC
        tempMask = imclearborder(ica_filtersbw(:,:,iIC));
        maskTouchesEdge(iIC) = ~any(tempMask(:));
        ica_filtersbw(:,:,iIC) = tempMask;
    end
    ica_filtersbw(:,:,maskTouchesEdge) = [];
    ica_filtersorig(maskTouchesEdge,:,:) = [];
    nIC = nIC - sum(maskTouchesEdge);
end

%% Further segment connected components
ica_segments = [];
kk=0;
segmentlabel = [];
for ii = 1:nIC
    
    % Label contiguous components
    LL = bwlabel(ica_filtersbw(:,:,ii), 4);
    Lu = 1:max(LL(:));

    % Delete small components
    cc = struct2cell(regionprops(LL, 'area'));
    Larea = [cc{:}];
    Lcent = regionprops(LL, 'Centroid');
    
    
    if length(arealims)==2
        Lbig = Lu( (Larea >= arealims(1))&(Larea <= arealims(2)));
        Lsmall = Lu((Larea < arealims(1))|(Larea > arealims(2)));
    else
        Lbig = Lu(Larea >= arealims(1));
        Lsmall = Lu(Larea < arealims(1));
    end
    
    LL(ismember(LL,Lsmall)) = 0;   
        
    for jj = 1:length(Lbig)
        segmentlabel(jj+kk,:) = ii; % Not really sure what the 
    % authors intended here, just fill it up to avoid error in
    % CellScan.process
    end
    
    ica_filtersuse = squeeze(ica_filtersorig(ii,:,:));
    for jj = 1:length(Lbig)
        ica_segments(jj+kk,:,:) = ica_filtersuse .* ...
            ( 0*(LL==0) + (LL==Lbig(jj)) );  % Exclude background
    end
    
    kk = size(ica_segments,1);
    
end

% Handle the case where there are no ROIs
hasNoROIs = kk == 0;
if hasNoROIs
    ica_segments = zeros(size(ica_filtersbw(1,:,:)));
    segmentlabel = NaN;
end

end
