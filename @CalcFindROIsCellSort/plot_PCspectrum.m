function varargout = plot_PCspectrum(self, objPI, hAx, varargin)
% CellsortPlotPCspectrum(fn, CovEvals, PCuse)
%
% Plot the principal component (PC) spectrum and compare with the
% corresponding random-matrix noise floor
%
% Inputs:
%   imgSeq - input image sequence
%   CovEvals - eigenvalues of the covariance matrix
%   PCuse - [optional] - indices of PCs included in dimensionally reduced
%   data set
%
% Eran Mukamel, Axel Nimmerjahn and Mark Schnitzer, 2009
% Email: eran@post.harvard.edu, mschnitz@stanford.edu
%

%% Obtain data:
% input image sequence
imgSeq = squeeze(...
    objPI.rawImg.rawdata(:,:,objPI.channelToUse,:));
imgSeq = double(imgSeq);

badDataMask = ~isfinite(imgSeq);
nBadVals = sum(badDataMask(:));
doInpaint = (nBadVals > 0) && (self.config.inpaintIters > 0);
if doInpaint
    imgSeq = utils.inpaintn(imgSeq, self.config.inpaintIters);
end

% intermediate function outputs
CovEvals = self.CovEvals;
PCuse = self.PCuse;

%% Do the plotting
[numRows, numCols, numFrames] = size(imgSeq);
npix = numRows*numCols;

% Random matrix prediction (Sengupta & Mitra)
p1 = npix; % Number of pixels
q1 = numFrames; % Number of time frames
q = max(p1,q1);
p = min(p1,q1);
sigma = 1;
lmax = sigma*sqrt(p+q + 2*sqrt(p*q));
lmin = sigma*sqrt(p+q - 2*sqrt(p*q));
lambda = [lmin: (lmax-lmin)/100.0123423421: lmax];
rho = (1./(pi*lambda*(sigma^2))).*sqrt((lmax^2-lambda.^2).*(lambda.^2-lmin^2));
rho(isnan(rho)) = 0;
rhocdf = cumsum(rho)/sum(rho);
noiseigs = interp1(rhocdf, lambda, [p:-1:1]'/p, 'linear', 'extrap').^2 ;

% Normalize the PC spectrum
normrank = min(numFrames-1,length(CovEvals));
pca_norm = CovEvals*noiseigs(normrank) / (CovEvals(normrank)*noiseigs(1));

clf
% Left to implement: plotting on hAx
if isempty(hAx)
    hAx = axes();
    plot(pca_norm, 'o-', 'Color', [1,1,1]*0.3, 'MarkerFaceColor', [1,1,1]*0.3, 'LineWidth',2);
else
    plot(hAx, pca_norm, 'o-', 'Color', [1,1,1]*0.3, 'MarkerFaceColor', [1,1,1]*0.3, 'LineWidth',2);
end

hold(hAx, 'on')
plot(hAx, noiseigs / noiseigs(1), 'b-', 'LineWidth',2)
plot(hAx, 2*noiseigs / noiseigs(1), 'b--', 'LineWidth',2)
if ~isempty(PCuse)
    plot(hAx, PCuse, pca_norm(PCuse), 'rs', 'LineWidth',2)
end
hold(hAx, 'off')
formataxes
set(hAx,'XScale','log','YScale','log', 'Color','none')
xlabel(hAx, 'PC rank')
ylabel(hAx, 'Normalized variance')
axis tight
if isempty(PCuse)
    legend(hAx, 'Data variance','Noise floor','2 x Noise floor')
else
    legend(hAx, 'Data variance','Noise floor','2 x Noise floor','Retained PCs')
end

% fntitle = fn;
% fntitle(fn=='_') = ' ';
% title(fntitle)

% Pass the output argument, if requested
if nargout > 0
    varargout{1} = hAx;
end

function formataxes

set(gca,'FontSize',12,'FontWeight','bold','FontName','Helvetica','LineWidth',2,'TickLength',[1,1]*.02,'tickdir','out')
set(gcf,'Color','w','PaperPositionMode','auto')
