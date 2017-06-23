function gain = find_gain(chSeq, streak, verbose)
%find_gain - Calculate gain of the optical system
%
%   [offsets, refImgs] = find_gain(CHSEQ, STREAK, VERBOSE) takes a movie
%   CHSEQ and calculates the GAIN of the optical systemon  which the movie
%   was recorded by looking at the relationship between the standard
%   deviation and the mean of those pixels. This only works if there is no
%   movement, so this function looks for the "stillest" section of frames
%   (STREAK frames long).  "Stillest" is judged by having the smallest mean
%   absolute difference between frames. VERBOSE specifies wether or not to
%   show a progress bar.
%
%       verbose ->  Whether to display status bars and more elaborate plots 
%                   for debugging purposes. The verbose must be a scalar  
%                   value that can be converted to a logical. 
%                   [default = false]
%
%   See also utils.hmm

% Show status bar, if needed
if verbose
    utils.progbar(0.0, 'msg', 'Auto Calculating Gain');
end

% Values lower than ~25 lead to numerical instability
streak = max(streak, 25);

% Pull out the number of frames
numFrames = size(chSeq,1);

% Calculate the mean absolute difference between frames
diffvector = mean(mean(abs(diff(chSeq)), 2), 3);

% Initialize the vector which stores the mean absolute difference between
% frames for all possible streaks
diffavg = zeros(1, length(diffvector) - streak);

% Calculate mean absolute difference per streak
for iFrame = 1:numFrames-streak-1
    
    % Update status bar, if needed
    if verbose
        utils.progbar(iFrame/(numFrames-streak-1), 'msg', ...
            'Auto Calculating Gain', 'doBackspace', 1);
    end
    
    diffavg(iFrame) = mean(diffvector(iFrame:iFrame+streak));
end

% Find the best streak
[~, minFrame] = min(diffavg);

% Cut out the data across that streak
streakSeq = chSeq(minFrame:minFrame+streak,:,:);

% Find the mean of every pixel across that streak and linearize
means = mean(streakSeq);
means=double(means(:));

% Calculate the stds of every pixel across that streak and linearize
stds = std(streakSeq);
stds = double(stds(:));

% Check for the optimization toolbox
feature = 'Optimization_Toolbox';
className = 'HMM:FindGain';
utils.verify_license(feature, className);

% Set up the optimisation problem
funObj = @(aa) aa.*means.^0.5 - stds;
aa0 = mean(stds ./ (means.^0.5));
lb = [];
ub = [];
options = optimset('Display', 'off');

% Determine the optimal values for the parameters
aaOpt = lsqnonlin(funObj, aa0, lb, ub, options);

gain = aaOpt.^2;

% Make sure progbar maxes (because the for loop is very fast)
if verbose
    utils.progbar(1, 'msg', ...
        'Auto Calculating Gain', 'doBackspace', 1);
end

end