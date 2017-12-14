function roiMask = select_LS_ROI(imgSeq, varargin)

% Setup for the loop
rowsForLines = [1 size(imgSeq, 1)];
isLR = true;
doSort = false;
colsROIRaw = [];
roiMask = false(1, size(imgSeq, 2));
% Create a nested function to do the subplotting
    function sizeimgSeq = plot_imgSeq(strFigTitle, ...
            iROI, colsROIsRaw)
        
        sizeimgSeq = size(imgSeq);
        imagesc(imgSeq);
        hold on
        axis tight, axis image
        colormap('gray')
        title(strFigTitle)
        for jROI = 1:iROI-1
            plot(colsROIsRaw(jROI, 1)*[1, 1], rowsForLines, 'b--')
            plot(colsROIsRaw(jROI, 2)*[1, 1], rowsForLines, 'b--')
        end
        hold off
        
    end

% Loop through and choose the ROI boundaries
iROI = 0;
done = false;
while ~done
    
    iROI = iROI + 1;
    
    % Setup the function handle to do the plotting etc
    fPlot = @(strFigTitle) plot_imgSeq(strFigTitle, ...
        iROI, colsROIRaw);
    
    % Call the static function to choose the images
    strTitle = sprintf('ROI %d', iROI);
    out = utils.crop_rows_cols(fPlot, ...
        isLR, strTitle, doSort);
    if ~isempty(out)
        colsROIRaw(iROI, :) = out;
    else
        done = true;
    end
    
end

for i = 1:iROI-1
    roiMask(1, colsROIRaw(i,1):colsROIRaw(i,2)) = true;
end

end