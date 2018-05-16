function varargout = plot_ICAtraces(self, objPI, hAx, varargin)
% CellsortICAplot(mode, ica_filters, ica_sig, f0, tlims, dt, ratebin,
%                  plottype, ICuse, spt, spc)
%
% Display the results of ICA analysis in the form of paired spatial filters
% and signal time courses. This function implements only fraction of
% original functionality. For full implementation, refer to
% CalcDetectSigsCellSort.plot_ICAsigs.
%
% Inputs:
%     mode - 'series' shows each spatial filter separately
%     ica_filters - nIC x X x Y array of ICA spatial filters
%     ica_sig - nIC x T matrix of ICA temporal signals
%     f0 - mean fluorescence image
%     tlims - 2-element vector specifying the range of times to be displayed
%     dt - time step corresponding to individual movie time frames
%     plottype - type of spike plot to use:
%         plottype = 1: plot cellular signals
%     ICuse - vector of indices of cells to be plotted
%
% Eran Mukamel, Axel Nimmerjahn and Mark Schnitzer, 2009
% Email: eran@post.harvard.edu, mschnitz@stanford.edu

%% Check input arguments

% prepare colomap
colord=[0         0    1.0000
    0    0.4000         0
    1.0000         0         0
    0    0.7500    0.7500
    0.7500         0    0.7500
    0.8, 0.5, 0
    0         0    0.5
    0         0.85      0];

% Ask the Calc class for necessary data
ica_filters = self.data.icFilters;
ica_sig = self.data.icTraces;
dt = 1 / objPI.rawImg.metadata.frameRate;
f0 = self.data.tAverage;
tlims = [self.data.time(1) self.data.time(end)];
ICuse = [];

% Reorder columns to keep consistency with original algorithm
ica_filters = permute(ica_filters, [3, 1, 2]);
ica_sig = permute(ica_sig, [2, 1]);

% ---------------------------------------------------------------------%
% These should be obtained via the new CalcDetectSigsCellSort
mode = 'series';
plottype = 1 ;
% DetectSigs should have different plottype than FindROIs as the latter may
% also use this function but rather for debugging
% ---------------------------------------------------------------------%

% Check the arguments
nIC = size(ica_sig,1);
if isempty(tlims)
    tlims = [0, size(ica_sig,2)*dt]; % seconds
end
if isempty(plottype)
    plottype = 1;
end
if isempty(ICuse) || length(ICuse) > nIC
    ICuse = [1:nIC];
end
if size(ICuse,2) == 1
    ICuse = ICuse';
end


% Reshape the filters
[numRows,numCols] = size(f0);
if size(ica_filters,1)==nIC
    ica_filters = reshape(ica_filters,nIC,numRows,numCols);
elseif size(ica_filters,2)==nIC
    ica_filters = reshape(ica_filters,nIC,numRows,numCols);
end

% ---------------------------------------------------------------------%
% Left to be implemented, if necessary
% Check Axes
if isempty(hAx)
    % Create them if necessary
    hAx = axes();
else
    % Otherwise check that it's a scalar axes
    utils.checks.hghandle(hAx, 'axes', 'hAx');
    utils.checks.scalar(hAx, 'hAx')
end
ax = hAx;
% ---------------------------------------------------------------------%

%% Do the plotting
switch mode
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    case {'series'}
        colmax = 20; % Maximum # of ICs in one column
        ncols = ceil(length(ICuse)/colmax);
        nrows = ceil(length(ICuse)/ncols);

        if size(ica_filters(:,:,1))==size(f0(:,:,1))
            ica_filters = permute(ica_filters,[3,1,2]);
        end

        subplot(1,3*ncols,[2:3])
        tlims(2) = min(tlims(2),size(ica_sig,2)*dt);
        tlims(1) = max(tlims(1),0);

        clf
        f_pos = get(gcf,'Position');
        f_pos(4) = max([f_pos(4),500,50*nrows]);
        f_pos(3) = max(400*ncols,0.9*f_pos(4));

        colormap(hot)
        colord=get(gca,'ColorOrder');
        ll=0;
        filtax = [];
        if ~isempty(ica_filters)
            for k=0:ncols-1
                jj=3*k;
                nrows_curr = min(nrows,length(ICuse)-k*nrows);
                for j=1:nrows_curr
                    filtax= [filtax,subplot(nrows_curr + (plottype==4),3*ncols, jj+1)];
                    jj=jj+3*ncols;
                    ll=ll+1;
                    imagesc(squeeze(ica_filters(ICuse(ll),:,:)))
                    axis image tight off
                end
            end
        end

        %ax = [];
        for j=0:ncols-1
            ax(j+1)=subplot(1,3*ncols,3*j+[2:3]);
            ICuseuse = ICuse([1+j*nrows:min(length(ICuse),(j+1)*nrows)]);
            if plottype<=2
                complot(ica_sig, ICuseuse, dt)
            end
            formataxes
            formataxes
            xlabel('Time (s)')
            xlim(tlims)
            yl = ylim;
            drawnow
        end
        set(gcf,'Color','w','PaperPositionMode','auto')

        %%%%
        % Resize plots to appropriate size
        if (plottype<4)&(length(ICuse)>=3)
            bigpos = get(ax(1),'Position');
            aheight = 0.9*bigpos(4)/nrows;
            for k=1:length(filtax)
                axpos = get(filtax(k),'Position');
                axpos(3) = aheight;
                axpos(4) = aheight;
                set(filtax(k),'Position',axpos)
            end

            set(gcf,'Units','normalized')
            fpos = get(gcf,'Position');
            for j=1:ncols
                axpos = get(ax(j),'OuterPosition');
                filtpos = get(filtax(1+(j-1)*nrows),'Position');
                axpos(1) = filtpos(1) + filtpos(3)*1.1;
                set(ax(j),'OuterPosition',axpos,'ActivePositionProperty','outerposition')
                axpos = get(ax(j),'Position');
            end
            set(gcf,'Resize','on','Units','characters')
        end

        for j=1:ncols
            ax = [ax,axes('Position',get(ax(j),'Position'),'XAxisLocation','top','Color','none')];
            if plottype==4
                xt = get(ax4(end),'XTick');
            else
                xt = get(ax(j),'XTick');
            end
            xlim(tlims)
            formataxes
            set(gca,'YTick',[],'XTick',xt,'XTickLabel',num2str(xt'/dt, '%15.0f'))
            xlabel('Frame number')
            axes(ax(j))
            box on
        end
        linkaxes(ax,'xy')

end

%% Output
% Return the axes handle if asked for
if nargout > 0
    varargout{1} = ax;
end

%% Helper functions
%%%%%%%%%%%%%%%%%%%%%
function complot(sig, ICuse, dt)

for i = 1:length(ICuse)
    zsig(i, :) = zScore(sig(ICuse(i),:));
end

alpha = mean(max(zsig')-min(zsig'));
if islogical(zsig)
    alpha = 1.5*alpha;
end

zsig2 = zsig;
for i = 1:size(ICuse,2)
    zsig2(i,:) = zsig(i,:) - alpha*(i-1)*ones(size(zsig(1,:)));
end

tvec = [1:size(zsig,2)]*dt;
if islogical(zsig)
    plot(tvec, zsig2','LineWidth',1)
else
    plot(tvec, zsig2','LineWidth',1)
end
axis tight

set(gca,'YTick',(-size(zsig,1)+1)*alpha:alpha:0);
set(gca,'YTicklabel',fliplr(ICuse));


function formataxes

set(gca,'FontSize',12,'FontWeight','bold','FontName','Helvetica','LineWidth',2,'TickLength',[1,1]*.02,'tickdir','out')
set(gcf,'Color','w','PaperPositionMode','auto')

function fout = gaussblur(fin, smpix)
%
% Blur an image with a Gaussian kernel of s.d. smpix
%

if ndims(fin)==2
    [x,y] = meshgrid([-ceil(3*smpix):ceil(3*smpix)]);
    smfilt = exp(-(x.^2+y.^2)/(2*smpix^2));
    smfilt = smfilt/sum(smfilt(:));

    fout = imfilter(fin, smfilt, 'replicate', 'same');
else
    [x,y] = meshgrid([-ceil(smpix):ceil(smpix)]);
    smfilt = exp(-(x.^2+y.^2)/(2*smpix^2));
    smfilt = smfilt/sum(smfilt(:));

    fout = imfilter(fin, smfilt, 'replicate', 'same');
end

function z = zScore(x)
    % Compute X's mean and sd, and standardize it
    % look for first non-singleton dimension
    dim = find(size(x) ~= 1, 1);
    if isempty(dim), dim = 1; end
    
    mu = mean(x, dim);
    sigma = std(x,0,dim);
    sigma(sigma==0) = 1;
    z = bsxfun(@minus,x, mu);
    z = bsxfun(@rdivide, z, sigma);