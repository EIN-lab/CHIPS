function [ PCuse ] = defaultPCs(~, mixedfilters, FOV)
%defaultPCs - Select PCs to analyze automatically
%   defaultPCs selects range of PCs to be used for further analysis
%   automatically. The bounds of cropped interval are determined by amount
%   of structural information in the PCs and expected number of relevant
%   entities in given field of view.

% The upper bound is based on expected number of signals that tend to
% appear in certain size of FOV.  Later, we may want to apply denoising and
% than automatically try to determine the number of entities in the image
FOV_area = FOV(1) * FOV(2); % in um^2
cellArea = 1000; % um2: very approximate estimate but in the right ballpark
numSigs = ceil(FOV_area / cellArea);

% There may be several PCs right at the beginning that actually dont carry
% any information on structure, rather only on noise.  We want to throw
% these away, but for now we don't have a reliable way to do this
% automatically, so we can just start from the beginning.  Using the SNR of
% the filters may be one approach.

% Choose the number of PCs to look at, making sure we don't use more than
% we have available!
nFilters = size(mixedfilters, 3);
PCuse = 1 : min([numSigs, nFilters]);

end

