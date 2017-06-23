function [offsets, totprob] = markov(probMat, minShifts, lambda, ...
    refOffsets, gain, numLines, numFrames, frameRate, maxShift, doFull, ...
    verbose)
%markov - Calculate line-by-line offsets
%
%   See also utils.motion_correct, utils.hmm
%% Assing paramemeters
% Decide wether to do an abbreviated or full run
if doFull
    frames = 1:numFrames;
else
    frames = 1:20;
end

% How many frames per 30 seconds imaging
framesPer30sec = floor(frameRate * 30);

maxDx = maxShift(1);
maxDy = maxShift(2);

Nx = 2*maxDx+1;
Ny = 2*maxDy+1;

%% Build Matrix of Transitions
%this is going to be the matrix which keeps track of the transition which
%was the most probable way to get to a particular state from the previous
%state.. we will fill this matrix up, and the backtrack the most probable
%path as is the standard way of the veterbi algorithm.
savemax=zeros(Nx*Ny,length(frames)*(numLines),'int16');

%P is the probability vector which describes the maximal probability of
%being in a particular state at the current time step as we march forward
%we will start with a uniform distribution across offsets
P=ones(1,Nx*Ny);

if verbose && doFull
    strMsg = 'Running HMM';
    utils.progbar(0, 'msg', strMsg);
end

%% Precompute values for unique shifts:
% find unique shifts as rows
[unRows, ~, ~] = unique(minShifts, 'rows');

% array to save unique logs of trans probability
trans_prob_array = zeros(Nx*Ny,Nx*Ny,size(unRows,1));

for ii = 1 : size(unRows,1) % loop over unique shifts
    % get shifts in individual directions
    xPrime = unRows(ii,2); yPrime = unRows(ii,1);
    
    %creates the basic exponential model for the transistion probabilities,
    %this in terms of relative change in offset, normalizing appropriately
    %we make sure its big enough so that it covers all possible differences in
    %offsets
    [xx,yy]=meshgrid(-2*maxDx:2*maxDx,-2*maxDy:2*maxDy);
    % apply offset estimate
    xx = circshift(xx', xPrime)';
    yy = circshift(yy, yPrime);
    
    % rr adjusted according to eq. 11 in Chen, 2011
    rr = sqrt(xx.^2+yy.^2);  
    rel_trans_prob=exp(-(abs(rr)./lambda));
    rel_trans_prob=rel_trans_prob/(sum(sum(rel_trans_prob)));
    
    %now build up the entire transition probability matrix where you index a
    %pair of offsets as a single hashed value by making use of the reshape
    %function in matlab.  an offset pair will now be refered to a state.
    trans_prob=zeros(Nx*Ny,Nx*Ny);
    for iSx=-maxDx:maxDx
        for jSy=-maxDy:maxDy
            trans_prob((iSx+maxDx)*(maxDy*2+1)+jSy+maxDy+1,:) = ...
                reshape(rel_trans_prob((maxDy-jSy+1):(3*maxDy-jSy+1),...
                (maxDx-iSx+1):(3*maxDx-iSx+1)),Nx*Ny,1);
        end
    end
      
    %translate it into a log probability
    trans_prob=log(trans_prob);
    
    % store precomputed values for later use
    trans_prob_array(:,:,ii) = trans_prob;
        
end

%% Map new values to precomputed ones

%index which will march over lines considered
m=0;
%loop over all frames
for iFrame = frames
    
    %loop over all the lines considered in that frame
    for j=1+maxDy:numLines-maxDy
        m=m+1;    %increment our index for lines considered
        shift_m = minShifts(m,:,:); % get current shift
        % get mapping of current to precomuted
        [~, id] = ismember(shift_m,unRows,'rows');
        
        %pull out the relevant matrix of values
        PI=squeeze(probMat(m,:,:));
        PIvec=reshape(PI,Nx*Ny,1); %reshape them into a vector
        PIvec=PIvec/gain;
        
        % Run either the mex file (higher in the function preference order)
        % or the .m file (if no mex file is found)
        Pnew = utils.hmm.makepi(P, trans_prob_array(:,:,id));
    
        %calculate the most probable way to wind up in a given state, and
        %what the probability is.. save which path you took to get that
        %value, and update P.   
        % Additionaly store precomputed values
        [P, savemax(:,m)] = max(Pnew,[],2);  
             
        %add on the fits to the probabilities
        P=P'+PIvec';
        
%         % Figures for debugging only
%         figure; imagesc(reshape(P,Nx,Ny));
%         figure; imagesc(reshape(PIvec,Nx,Ny));
        
    end
    
    if verbose && doFull
        utils.progbar((iFrame/length(frames)), 'msg', strMsg, 'doBackspace', 1);
    end
    
end

%% Viterbi algorithm ~ backtracking of the most probable path

numlines=m;
%find the state that was the most probable ending point
%and what the total probablity was for this value of lambda
[totprob,mprob]=max(P);
%initialize the path of most probable states
thepath=zeros(1,numlines);
%for my interest i save the fits along the path
PIpath=zeros(1,numlines);
%calculate the total fit for this path without considering transition
%probabilities.
Ptot=0;
%march backward from the last line considered to the first
for k=numlines:-1:1
    %pull out the fits from the current line
    PI=squeeze(probMat(k,:,:));
    %turn it into a vector
    PIvec=reshape(PI,Nx*Ny,1);
    %what is the fit for the most probable state at this timepoint
    PIpath(k)=PIvec(mprob);
    %add that to the total fit
    Ptot=Ptot+PIvec(mprob);
    %save that point along the path
    thepath(k)=mprob;
    %remember what was the most probable way was to get to that state.. update mprob
    mprob=savemax(mprob,k);
end

%unhash the path in terms of state index into a pair of offsets
offsets(1,:)=mod(thepath,Ny);
offsets(1,offsets(1,:)==0)=Ny;
offsets(1,:)=offsets(1,:)-maxDy-1;
offsets(2,:)=((thepath-mod(thepath,Ny))/Ny)-maxDx;
%adjust for the alignments between reference frames
offsetfix=1:numlines;
offsetfix=floor(offsetfix/(numLines-2*maxDy));
offsetfix=floor(offsetfix/framesPer30sec)+1;

% Find out wether there will be a problem with rounding
isBad = ~mod(numFrames, framesPer30sec);

if isBad
    nRefs = numFrames/framesPer30sec;
    offsetfix(offsetfix > nRefs) = nRefs;
end

offsetfix=refOffsets(offsetfix,:)';
offsets=offsets-offsetfix;

% % Figure for debugging only
% figure
% plot(offsets');
% title(['\lambda' sprintf(' = %6.5f',lambda)]);
% xlabel('line number');
% ylabel('offset (relative pixels)');
% legend('Y-offset', 'X-offset')

end