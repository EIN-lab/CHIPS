function [covmat, mov, movm, movtm, nLines_dsamp, nCols_dsamp] = ...
    create_cov(imgSeq, numLines, nPxlPerLine, useframes, nt, dsamp, isT)

    % Load movie data to compute the covariance matrix
    npix = numLines*nPxlPerLine;

    % Downsampling
    if length(dsamp)==1
        dsamp_time = dsamp(1);
        dsamp_space = 1;
    else
        dsamp_time = dsamp(1);
        dsamp_space = dsamp(2); % Spatial downsample
    end

    if (dsamp_space==1)
        mov = double(imgSeq(:,:,useframes));
        nLines_dsamp = numLines;
        nCols_dsamp = nPxlPerLine;
    else
        szImg = (1/dsamp_space) .* size(imgSeq(:,:,1));
        npix = prod(szImg);
        mov = utils.resize_img(imgSeq, szImg);
        mov = mov(:,:,useframes);
    end
    mov = reshape(mov, npix, nt);

    % DFoF normalization of each pixel
    movm = mean(mov,2); % Average over time
    movmzero = (movm==0); % Avoid dividing by zero
    movm(movmzero) = 1;
    mov = mov ./ (movm * ones(1,nt)) - 1; % Compute Delta F/F
    mov(movmzero, :) = 0;

    if dsamp_time>1
        mov = filter(ones(dsamp_time,1)/dsamp_time, 1, mov, [], 2);
        mov = mov(:, 1 : dsamp_time : end);
    end
    
    % Average over space
    movtm = mean(mov,1); 
    
    if isT
        
        % Create the temporal covariance matrix
        covmat = (mov'*mov)/npix - movtm'*movtm;
        
    else
        
        % Create the spatial covariance matrix, rescaling to agree temporal
        mov = mov - ones(size(mov,1),1)*movtm; 
        covmat = (mov*mov')/size(mov,1);
        
    end
    
end
