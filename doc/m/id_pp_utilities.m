%% Other Preprocessing Utilities
% A number of other preprocessing utilities are included in the CHIPS
% toolbox.  For example, it is possible to calculate a new channel using
% information from other channels (e.g. for FRET ratiometric sensors),
% to split images up into multiple smaller images, and to concatenate
% images together.

%% See Also
% * <matlab:doc('RawImg.ch_calc') |ch_calc| method documentation>
% * <matlab:doc('RawImg.split1') |split1| method documentation>
% * <matlab:doc('RawImg.cat_data') |cat_data| function documentation>
% * <id_ri.html |RawImg| quick start guide>

%% Examples
% The following examples require the sample images and other files, which
% can be downloaded manually, from the University of Zurich website
% (<http://www.pharma.uzh.ch/en/research/functionalimaging/CHIPS.html>), or
% automatically, by running the function |utils.download_example_imgs()|.
%
% <html><h3>Prepare a <tt>RawImg</tt> for use in these examples</h3></html>
%

% Prepare a rawImg for use in these examples
fnRawImg = fullfile(utils.CHIPS_rootdir, 'tests', 'res', ...
    'xsectscan_scim.tif');
channels = struct('cellular_signal', 1, 'blood_plasma', 2);
fnCalibration = fullfile(utils.CHIPS_rootdir, 'tests', 'res', ...
    'calibration_dummy.mat');
calibration = CalibrationPixelSize.load(fnCalibration);
rawImg = SCIM_Tif(fnRawImg, channels, calibration);

%%
%
% <html><h3>Calculate a ratio channel</h3></html>
%

% Make a copy of the RawImg object so we can reuse the original later
ri001 = copy(rawImg);
nChs_pre = ri001.metadata.nChannels

% Calculate a ratio channel (i.e. ch3 = ch1 ./ ch2)
chNums = [1, 2];
chName = 'cellular_signal';
ri001.ch_calc_ratio(chNums, chName);
nChs_post = ri001.metadata.nChannels

%%
%
% <html><h3>Split the image into separate channels</h3></html>
%

% Split the image into separate channels
ri002 = copy(rawImg);
dim = 3;
dimDist = [1, 1];
[ri002_ch1, ri002_ch2] = ri002.split1(dim, dimDist);
ch1_name = ri002_ch1.metadata.get_ch_name(1)
ch2_name = ri002_ch2.metadata.get_ch_name(1)

%%
%
% <html><h3>Concatenate multiple images together</h3></html>
%

% Concatenate multiple images together (including recursively)
nFrames_pre = rawImg.metadata.nFrames
dim = 4;
riArray(1:3) = copy(rawImg);
ri003 = RawImg.cat_data(dim, copy(rawImg), riArray, copy(rawImg));
nFrames_post = ri003.metadata.nFrames
