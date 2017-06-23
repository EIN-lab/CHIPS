function [ica_sig, ica_filters, ica_A, numiter] = CellsortICA(mixedsig, ...
    mixedfilters, CovEvals, PCuse, mu, nIC, ica_A_guess, termTol, maxrounds, ...
    strMsg)
% [ica_sig, ica_filters, ica_A, numiter] = 
% CellsortICA(mixedsig, mixedfilters, CovEvals, PCuse, mu, nIC,...
% ica_A_guess, termTol, maxrounds)
%
%CELLSORT
% Perform ICA with a standard set of parameters, including skewness as the
% objective function
%
% Inputs:
%   mixedsig - N x T matrix of N temporal signal mixtures sampled at T
%   points.
%   mixedfilters - X x Y x N array of N spatial signal mixtures sampled at
%   X x Y spatial points.
%   CovEvals - eigenvalues of the covariance matrix
%   PCuse - vector of indices of the components to be included. If empty,
%   use all the components. length = N
%   mu - parameter (between 0 and 1) specifying weight of temporal
%   information in spatio-temporal ICA
%   nIC - number of ICs to derive
%   ica_A_guess - nPCuse x nIC matrix as initial guess to ICA algorithm.
%   Alternatively ica_A_guess is a random seed that sets the state of
%   random number generator (rng).
%   termTol - termination tolerance; fractional change in output at which
%   to end iteration of the fixed point algorithm.
%   maxrounds - maximum number of rounds of iterations
%
% Outputs:
%     ica_sig - nIC x T matrix of ICA temporal signals
%     ica_filters - nIC x X x Y array of ICA spatial filters
%     ica_A - nIC x N orthogonal unmixing matrix to convert the input to 
%               output signals
%     numiter - number of rounds of iteration before termination
%
% Routine is based on the fastICA package (Hugo Gävert, Jarmo Hurri, ...
%                               Jaakko Särelä, and Aapo Hyvärinen,...
%                               http://www.cis.hut.fi/projects/ica/fastica)
%
% Eran Mukamel, Axel Nimmerjahn and Mark Schnitzer, 2009
% Email: eran@post.harvard.edu, mschnitz@stanford.edu
%
% fprintf('-------------- CellsortICA %s -------------- \n', date)

%% Check input data
if (nargin<4) || isempty(PCuse)
    PCuse = 1:size(mixedsig,1);
end
if (nargin<6) || isempty(nIC)
    nIC = length(PCuse);
end
if (nargin<7) || isempty(ica_A_guess)
    % Guessing randomly makes it impossible to reproduce results
    ica_A_guess = randn(length(PCuse), nIC);
end
if (nargin<8) || isempty(termTol)
    termTol = 1e-6;
end
if (nargin<9) || isempty(maxrounds)
    maxrounds = 100;
end
if isempty(mu)||(mu>1)||(mu<0)
    error('Spatio-temporal parameter, mu, must be between 0 and 1.')
end

% Check that ica_A_guess is the right size
if size(ica_A_guess,1)~= length(PCuse) || size(ica_A_guess,2)~=nIC
    error('Initial guess for ica_A is the wrong size.')
end
if nIC>length(PCuse)
    error('Cannot estimate more ICs than the number of PCs.')
end

% ----------------------------------------------------------------------%    
%% Do the ICA
[numRows, numCols,~] = size(mixedfilters);
npix = numRows*numCols;

% Select PCs
if mu > 0 || ~isempty(mixedsig)
    mixedsig = mixedsig(PCuse,:);
end
if mu < 1 || ~isempty(mixedfilters)
    mixedfilters = reshape(mixedfilters(:,:,PCuse),npix,length(PCuse));
end
CovEvals = CovEvals(PCuse);

% Center the data by removing the mean of each PC
mixedmean = mean(mixedsig,2);
mixedsig = mixedsig - mixedmean * ones(1, size(mixedsig,2));

% Create concatenated data for spatio-temporal ICA
nx = size(mixedfilters,1);
if mu == 1
    % Pure temporal ICA
    sig_use = mixedsig;
elseif mu == 0
    % Pure spatial ICA
    sig_use = mixedfilters';
else
    % Spatial-temporal ICA
    sig_use = [(1-mu)*mixedfilters', mu*mixedsig];
    % This normalization ensures that, if both mixedfilters and mixedsig
    % have unit covariance, then so will sig_use
    sig_use = sig_use / sqrt(1-2*mu+2*mu^2); 
end

% Perform ICA
[ica_A, numiter] = fpica_standardica(sig_use, ica_A_guess, termTol, ...
    maxrounds, strMsg);

% Sort ICs according to skewness of the temporal component
ica_W = ica_A';

ica_sig = ica_W * mixedsig;
 % This is the matrix of the generators of the ICs
ica_filters = reshape((mixedfilters*diag(CovEvals.^(-1/2))*ica_A)', nIC, nx); 
ica_filters = ica_filters / npix^2;

icskew = utils.skewness(ica_sig');
[~, ICord] = sort(icskew, 'descend');
ica_A = ica_A(:,ICord);
ica_sig = ica_sig(ICord,:);
ica_filters = ica_filters(ICord,:);
ica_filters = reshape(ica_filters, nIC, numRows, numCols);

end

% Note that with these definitions of ica_filters and ica_sig, we can decompose
% the sphered and original movie data matrices as:
%     mov_sphere ~ mixedfilters * mixedsig = ica_filters * ica_sig = (mixedfilters*ica_A') * (ica_A*mixedsig),
%     mov ~ mixedfilters * pca_D * mixedsig.
% This gives:
%     ica_filters = mixedfilters * ica_A' = mov * mixedsig' * inv(diag(pca_D.^(1/2)) * ica_A'
%     ica_sig = ica_A * mixedsig = ica_A * inv(diag(pca_D.^(1/2))) * mixedfilters' * mov

function [BB, iternum] = fpica_standardica(XX, ica_A_guess, ...
        termTol, maxrounds, strMsg)

    numSamples = size(XX,2);

    BB = ica_A_guess;
    BOld = zeros(size(BB));

    iternum = 0;
    minAbsCos = 0;

    errvec = zeros(maxrounds,1);

    isWorker = utils.is_on_worker();

    while (iternum < maxrounds) && ((1 - minAbsCos)>termTol)

        iternum = iternum + 1;

        % Symmetric orthogonalization.
        BB = (XX * ((XX' * BB) .^ 2)) / numSamples;
        BB = BB * real(inv(BB' * BB)^(1/2));

        % Test for termination condition.
        minAbsCos = min(abs(diag(BB' * BOld)));

        BOld = BB;
        errvec(iternum) = (1 - minAbsCos);

        if ~isWorker
            utils.progbar((iternum/maxrounds) * 1/5 + 2/5, ...
                'msg', strMsg, 'doBackspace', true);
        end

    end

    % Give a warning if the algorithm doesn't converge
    if iternum >= maxrounds
        warning('CellSortICA:FPICA:NoConvergence', ['Failed to ', ...
            'converge; terminating after %d rounds, current ' ...
            'change in estimate %3.3g.\n'], iternum, 1-minAbsCos)
    end

end

