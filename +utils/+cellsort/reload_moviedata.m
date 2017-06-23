function [mixedfilters] = reload_moviedata(npix1, mov, mixedsig, CovEvals)
        %-----------------------
        % Re-load movie data
        nPCs1 = size(mixedsig,1);

        Sinv = inv(diag(CovEvals.^(1/2)));

        movtm1 = mean(mov,1); % Average over space
        movuse = mov - ones(npix1,1) * movtm1;
        mixedfilters = reshape(movuse * mixedsig' * Sinv, npix1, nPCs1);
        
end