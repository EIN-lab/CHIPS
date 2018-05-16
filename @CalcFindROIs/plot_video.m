function plot_video(self, objPI, varargin)

%   Copyright (C) 2017  Matthew J.P. Barrett, Kim David Ferrari et al.
%
%   This program is free software: you can redistribute it and/or modify
%   it under the terms of the GNU General Public License as published by
%   the Free Software Foundation, either version 3 of the License, or
%   (at your option) any later version.
% 
%   This program is distributed in the hope that it will be useful,
%   but WITHOUT ANY WARRANTY; without even the implied warranty of
%   MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
%   GNU General Public License for more details.
%   
%   You should have received a copy of the GNU General Public License 
%   along with this program.  If not, see <http://www.gnu.org/licenses/>.

% Setup the default axis scaling
tempRawData = objPI.rawImg.rawdata(:,:,objPI.channelToUse,:);
CAxis = [utils.nansuite.nanmin(tempRawData(:)), ...
    utils.nansuite.nanmax(tempRawData(:))];
clear tempRawData

% Initialise a progress bar
isParallel = utils.is_parallel();
isWorker = utils.is_on_worker();
if ~isWorker
    strMsg = 'Preparing image stack';
    if isParallel
        fnPB = utils.progbarpar('msg', strMsg);
    else
        fnPB = '';
        utils.progbar(0, 'msg', strMsg);
    end
end

% Prepare for the loop
refImg = objPI.get_refImg();
nFrames = objPI.rawImg.metadata.nFrames;
imgStack = (zeros([size(refImg), 3, nFrames]));

% Loop through and prepare the image frames
parfor iFrame = 1:nFrames

    % Prepare the image of the current frame
    imgFrame = self.plot_ROI_img(objPI, 'FilledROIs', false, ...
        'CAxis', CAxis, varargin{:}, 'FrameNum', iFrame); %#ok<PFBNS>

    % Add the current frame to the image stack
    imgStack(:,:,:,iFrame) = imgFrame;
    
    % Update the progress bar
    if ~isWorker
        if isParallel
            utils.progbarpar(fnPB, nFrames, 'msg', strMsg);
        else
            utils.progbar((nFrames - iFrame)/nFrames, ...
                'msg', strMsg, 'doBackspace', true);
        end
    end

end

% Close the progress bar
if ~isWorker && isParallel
    utils.progbarpar(fnPB, 0, 'msg', strMsg);
end

% Display the stack with the slider utility function
utils.stack_slider(imgStack);

end