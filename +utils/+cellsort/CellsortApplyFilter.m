function cell_sig = CellsortApplyFilter(imgSeq, ica_segments, fLims, movm, subtractmean)
% cell_sig = CellsortApplyFilter(imgSeq, ica_segments, fLims, movm, subtractmean)
%
%CellsortApplyFilter
% Read in movie data and output signals corresponding to specified spatial
% filters
%
% Inputs:
%     imgSeq - Image stack, must be single-channel, squeezed to 3D.
%     ica_segments - nIC x X matrix of ICA spatial filters
%     fLims - optional two-element vector of frame limits to be read
%     movm - mean fluorescence image
%     subtractmean - boolean specifying whether or not to subtract the mean
%     fluorescence of each time frame
%
% Outputs:
%     cell_sig - cellular signals
%
% Eran Mukamel, Axel Nimmerjahn and Mark Schnitzer, 2009
% Email: eran@post.harvard.edu, mschnitz@stanford.edu
%

% Image dimensions
[numRows, numCols, numFrames] = size(imgSeq);

if (nargin<3)||isempty(fLims)
    nt = numFrames;
    fLims = [1,nt];
else
    nt = diff(fLims)+1;
end
if nargin<5
    subtractmean = 1;
end

if (nargin<4)||isempty(movm)
    movm = ones(numRows,numCols);
else
    movm = double(movm);
end
movm(movm==0) = 1; % Just in case there are black areas in the average image

cell_sig = zeros(size(ica_segments,1), nt);
ica_segments = reshape(ica_segments, [], numRows*numCols);

% Initialise a progress bar
isWorker = utils.is_on_worker();
if ~isWorker
    strMsg = 'Measuring ROIs';
    utils.progbar(0, 'msg', strMsg);
end

% fprintf('Loading %5g frames for %d ROIs.\n', nt, size(ica_segments,1))
iT = 0;
nT_max = 500;
while iT < nt
    
    ntcurr = min(nT_max, nt-iT);
    mov = zeros(numRows, numCols, ntcurr);
    
    for jj=1:ntcurr
        
        movcurr = imgSeq(:,:,jj+iT+fLims(1) - 1);
        mov(:,:,jj) = movcurr;
        
        % Update the progress bar
        if ~isWorker
            utils.progbar((iT + jj)/nt, 'msg', strMsg, 'doBackspace', true);
        end
        
    end
    
    mov = (mov ./ repmat(movm, [1,1,ntcurr])) - 1; % Normalize by background and subtract mean
    
    if subtractmean
        % Subtract the mean of each frame
        movtm = mean(mean(mov,1),2);
        mov = mov - repmat(movtm,[numRows,numCols,1]);
    end
    
    mov = reshape(mov, numRows*numCols, ntcurr);
    cell_sig(:, iT+[1:ntcurr]) = ica_segments*mov;
    
    iT=iT+ntcurr;
%     fprintf('Loaded %3.0f frames; ', k)
end
