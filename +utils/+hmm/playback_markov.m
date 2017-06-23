function [fixeddata,countdata] = playback_markov(imagedata, ...
    offsets, edgebuffer, ch, fillBadData, inpaintIters, ...
    verbose, doPar)

%% Initialize

% Bad frame, fill missing data or replace
switch lower(fillBadData)

    case {'nan', 'inpaint'}
        
        valReplace = nan(1, class(imagedata));
        
    case 'zero'

        valReplace = zeroes(1, class(imagedata));
        
    otherwise
        
        warning('HMM:PlaybackMarkov:BadFillMethod', ['The method ' ...
                '"%s" to fill bad data is not recognised.  Using "nan" ' ...
                'instead.'], fillBadData)
        fillBadData = 'nan';
        [fixeddata,countdata] = utils.hmm.playback_markov(imagedata, ...
            offsets, edgebuffer, ch, fillBadData, inpaintIters, ...
            verbose, doPar);
        return 
            
end

hasInpaintIters = (nargin > 5) && ~isempty(inpaintIters);
if ~hasInpaintIters
    inpaintIters = 10;
end

%pick out the number of frames and size of images
[nFrames, Sy, Sx]=size(imagedata);

%dynamically set the dynamic range for playback by taking the 99.99% pixel
%removes outliers. can adjust downward for automated gain control
sortpix=imagedata(1:3,:,:);
sortpix=sortpix(:);
sortpix=sort(sortpix);
k=round(length(sortpix)*.9999);
maxpixel=sortpix(k); %#ok<NASGU>
minpixel=sortpix(1); %#ok<NASGU>

%initialize the data
countdata=int8(zeros(nFrames,Sy,Sx));
fixeddata=zeros(nFrames,Sy,Sx);

%% Offset annd Inpaint
if verbose
    strMsg = sprintf('Applying shifts to ch. %d', ch);
    if doPar
        fnPB = utils.progbarpar('msg', strMsg); 
    else
        fnPB = '';
        utils.progbar(0, 'msg', strMsg);
    end
else
    fnPB = '';
end
    
parfor iFrame = 1:nFrames

    %initialize a matrix just for this frame for simplicity
    correctimage = zeros(Sy,Sx);
    countimage = zeros(Sy,Sx);
    
    % Create an indexer
    % Pull out relevant part of ofssets matrix
    offsets_pf = offsets(:,((iFrame-1)*(Sy-2*edgebuffer)+1:iFrame*(Sy-...
        2*edgebuffer))); %#ok<PFBNS>
    
    % Evaluate values so that they are 'hidden' for parfor
    [correctimage, countimage] = utils.hmm.applyOffset(imagedata, ...
        iFrame, offsets_pf, edgebuffer, correctimage, countimage);

    %store the results into the data structure
    % Look for lines that are completelly missing
    indx_crop = sum(correctimage(edgebuffer+1:Sy-edgebuffer,:),2) == 0;
    % Extend indexer even to zero padding
    indx = [zeros(edgebuffer,1); indx_crop; zeros(edgebuffer,1)];
    % Replace those lines with nan, so that inpaint understands it
    correctimage(logical(indx),:) = valReplace;
    fixeddata(iFrame,:,:) = correctimage;
    countdata(iFrame,:,:)=countimage;
    
%     % Figures for debugging only
%     figure(3);
%     clf;
%     set(gcf,'Position',[50 314 560 420]);
%     %finds those pixels which were not sampled and sets their counts to
%     %infinity for display purposes
%     countimage(countimage==0)=Inf;
%     %display, normalizing for multiple samples
%     imagesc(correctimage./(countimage));
%     colormap(gray);
%     %set the dynamic range
%     caxis([minpixel maxpixel]);
%     %title it by frame number
%     title(num2str(iFrame));
% 
%     figure(4);
%     clf;
%     set(gcf,'Position',[50+560 314 560 420]);
%     imagesc(squeeze(imagedata(iFrame,:,:)));
%     colormap gray;
%     caxis([minpixel maxpixel]);
%     title(num2str(iFrame));
%     pause(.1);

    if verbose
        if doPar
            utils.progbarpar(fnPB, nFrames, 'msg', strMsg);
        else
            utils.progbar(1 - (iFrame-1)/nFrames, 'msg', strMsg, ...
                'doBackspace', 1);
        end 
    end
    
end

% Inpaint the NaNs if necessary
if strcmpi(fillBadData, 'inpaint')
    fixeddata = utils.inpaintn(fixeddata, inpaintIters);
end

% Close the progress bar
if doPar
    utils.progbarpar(fnPB, 0, 'msg', strMsg);
end
    
end
