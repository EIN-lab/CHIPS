function [mixedsig, CovEvals, percentvar] = cellsort_svd(covmat,...
        nPCs, nt, npix1)
    %-----------------------
    % Perform SVD

    [mixedsig, CovEvals] = eig(covmat);
    CovEvals = diag(CovEvals);
    [CovEvals, I] =  sort(CovEvals, 'descend');
    CovEvals = CovEvals(1:nPCs);
    mixedsig = mixedsig(:,I(1:nPCs));

    if nnz(CovEvals<=0)
%         nPCs = nPCs - nnz(CovEvals<=0);
%         fprintf(['Throwing out ',num2str(nnz(CovEvals<0)),...
%             ' negative eigenvalues; new # of PCs = ',num2str(nPCs),'. \n']);
        mixedsig = mixedsig(:,CovEvals>0);
        CovEvals = CovEvals(CovEvals>0);
    end

    mixedsig = mixedsig' * nt;
    CovEvals = CovEvals / npix1;
    
    covtrace1 = trace(covmat) / npix1;
    percentvar = 100*sum(CovEvals)/covtrace1;
%     fprintf([' First ',num2str(nPCs),' PCs contain ',...
%         num2str(percentvar,3),'%% of the variance.\n'])

end