function [traj, otherChs] = calc_traj(refImg, trajImg, varargin)
%calc_traj - Calculate a single trajectory

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

    % Check the number of arguments
    narginchk(2, inf);
    
    % Define allowed optional arguments and default values
    pNames = {...
        'LineMode'; ...
    };
    pValues  = {...
        'horizontal'; ...
        };
    dflts = cell2struct(pValues, pNames);

    % Parse any remaining input arguments
    params = utils.parsepropval(dflts, varargin{:});

    % Get rid of the last row of the images if necessary
    rowsToUseRef = 1:refImg.metadata.nLinesPerFrame;
    doDiscard = ~refImg.metadata.discardFlybackLine && ...
        refImg.metadata.nLinesPerFrame == ...
        refImg.metadata_original.acq.linesPerFrame;
    if doDiscard
        rowsToUseRef = rowsToUseRef(1:end-1);
    end

    rowsToUseTraj = 1:trajImg.metadata.nLinesPerFrame;
    if ~trajImg.metadata.discardFlybackLine
        rowsToUseTraj = rowsToUseTraj(1:end-1);
    end

    % Establish the x and y traj channels
    trajChNames = {'position_x', 'position_y'};

    hasTrajRef = all(isfield(refImg.metadata.channels, ...
        trajChNames));
    if hasTrajRef
        chX_Ref = refImg.metadata.channels.position_x;
        chY_Ref = refImg.metadata.channels.position_y;
    else
        error('RawImgHelper:CalcTraj:NoTrajRef', ['Cannot locate ' ...
            'any position channels in the reference image. '])
    end

    hasTrajTraj = all(isfield(trajImg.metadata.channels, ...
        trajChNames));
    if hasTrajTraj
        chX_Traj = trajImg.metadata.channels.position_x;
        chY_Traj = trajImg.metadata.channels.position_y;
    else
        error('RawImgHelper:CalcTraj:NoTrajTraj', ['Cannot locate ' ...
            'any position channels in the trajectory image. '])
    end
    
    % Extract out the data, removing the first frame (because of weirdness)
    imgDataRef = refImg.rawdata(rowsToUseRef,:,:,:);
    nFramesRef = size(imgDataRef, 4);
    if nFramesRef > 1
        imgDataRef = imgDataRef(:,:,:,2:end);
    end
    imgDataTraj = trajImg.rawdata(rowsToUseTraj,:,:,:);
    nFramesTraj = size(imgDataTraj, 4);
    if nFramesTraj > 1
        imgDataTraj = imgDataTraj(:,:,:,2:end);
    end

    % Adjust the image data (if necessary, desired)
    delayTime = 12; % us
%     delayTime = 0; % us
    
    doAdjust = delayTime > 0;
    if doAdjust

        pixelTimeRef = refImg.metadata.pixelTime;
        imgDataRef = ITraj.adj_traj_delay(delayTime, ...
            imgDataRef, pixelTimeRef, chX_Ref, chY_Ref);

        pixelTimeTraj = trajImg.metadata.pixelTime;
        imgDataTraj = ITraj.adj_traj_delay(delayTime, ...
            imgDataTraj, pixelTimeTraj, chX_Traj, chY_Traj);

    end

    % Calculate the average trajectories
    meanRef = mean(imgDataRef, 4);
    meanRefX = mean(meanRef(:,:,chX_Ref), 1);
    meanRefY = mean(meanRef(:,:,chY_Ref), 2);

    meanTraj = mean(imgDataTraj, 4);
    
    switch lower(params.LineMode)
        case 'horizontal'
            fMean = @(ch) mean(meanTraj(2:end,:,ch), 1);
        case 'vertical'
            fMean = @(ch) mean(meanTraj(:,:,ch), 2);
        case 'none'
            fMean = @(ch) meanTraj(:,:,ch)';
        otherwise
            error('ITraj:CalcTraj:UnknownLineMode', ['The LineMode ' ...
                '"%s" is not recognised.'], lower(params.LineMode))
    end
    meanTrajX = fMean(chX_Traj);
    meanTrajY = fMean(chY_Traj);
    meanTrajX = meanTrajX(:);
    meanTrajY = meanTrajY(:);
    
    % Identify the correction factors for the x and y trajectories
    fdXRef = sprintf('inputVoltageRange%d', chX_Ref);
    fdXTraj = sprintf('inputVoltageRange%d', chX_Traj);
    fdYRef = sprintf('inputVoltageRange%d', chY_Ref);
    fdYTraj = sprintf('inputVoltageRange%d', chY_Traj);
    factorX = refImg.metadata_original.acq.(fdXRef) / ...
        trajImg.metadata_original.acq.(fdXTraj);
    factorY = refImg.metadata_original.acq.(fdYRef) / ...
        trajImg.metadata_original.acq.(fdYTraj);
    
    % Correct the trajectories to account for different voltage ranges
    % between the reference and trajectory images, if necessary
    fCorrect = @(kk, factor) (kk - 2^15)./factor + 2^15;
    doCorrectX = factorX ~= 1;
    if doCorrectX
        meanTrajX = fCorrect(meanTrajX, factorX);
    end
    doCorrectY = factorY ~= 1;
    if doCorrectY
        meanTrajY = fCorrect(meanTrajY, factorY);
    end

    % Interpolate the trajectories to convert them to pixel terms
    traj(:, 1) = ITraj.interp_traj(meanRefX, meanTrajX);
    traj(:, 2) = ITraj.interp_traj(meanRefY, meanTrajY);
    
    otherChsList = find(~ismember(1:size(meanTraj, 3), [chX_Traj, chY_Traj]));
    for iCh = fliplr(otherChsList)
        tempMean = fMean(otherChsList(iCh));
        otherChs(:, iCh) = tempMean(:);%#ok<AGROW>
    end
    
end