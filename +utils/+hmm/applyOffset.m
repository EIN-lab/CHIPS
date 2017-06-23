function [correctimage, countimage]=applyOffset(imagedata, iFrame, ...
    offsets_pf, edgebuffer, correctimage, countimage)

%pick out the number of frames and size of images
[~, Sy, Sx]=size(imagedata);

%loop over the lines we are considering placing
for jLine = 1:Sy-2*edgebuffer

    %pick out the line of the data we are placing
    lineextract=squeeze(imagedata(iFrame,jLine+edgebuffer,:));

    %pick out the line number where it is going
    linenumber=offsets_pf(1,jLine)+(jLine+edgebuffer);

    %pick out the relative shift in X within that line
    shift=offsets_pf(2,jLine);

    %need different bounds for shifts left and shifts right
    if shift<0    
        
        correctimage(linenumber,1:end+shift) = ...
            correctimage(linenumber,1:end+shift) + ...
            lineextract(1-shift:end)';

        countimage(linenumber,1:end+shift) = ...
            countimage(linenumber,1:end+shift) + ...
            ones(1,Sx+shift);

    else
        
        correctimage(linenumber,shift+1:end) = ...
            correctimage(linenumber,shift+1:end) + ...
            lineextract(1:end-shift)';

        countimage(linenumber,shift+1:end) = ...
            countimage(linenumber,shift+1:end) + ...
            ones(1,Sx-shift);

    end

end
