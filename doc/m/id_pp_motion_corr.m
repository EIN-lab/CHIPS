%% Motion Correction
% Motion correction is designed to correct for motion artefacts in the raw
% images that often result from movement of the sample.  This may occur
% through microscope drift or movement of the sample (e.g. animal) itself.

%% See Also
% * <matlab:doc('utils.motion_correct') Motion correction utility function documentation>
% * <./id_ri.html |RawImg| quick start guide>

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
    'cellscan_scim.tif');
channels = struct('Ca_Cyto_Astro', 1);
fnCalibration = fullfile(utils.CHIPS_rootdir, 'tests', 'res', ...
    'calibration_dummy.mat');
calibration = CalibrationPixelSize.load(fnCalibration);
rawImg = SCIM_Tif(fnRawImg, channels, calibration);

%%
%
% <html><h3>Motion correct a scalar <tt>RawImg</tt> object</h3></html>
%

% Make a copy of the RawImg object so we can reuse the original later
ri001 = copy(rawImg);

% Motion correct a scalar RawImg object, showing a plot as output
ri001.motion_correct('doPlot', true);

%%
%
% <html><h3>Motion correct using custom parameters</h3></html>
%

% Motion correct using custom parameters
ri002 = copy(rawImg);
ri002.motion_correct('minCorr', 0.843, 'doPlot', true);

%%
%
% <html><h3>Motion correct a <tt>RawImg</tt> object array (in parallel)</h3></html>
%

% Create a RawImg array
riArray(1:3) = copy(rawImg);
riArray = copy(riArray);

% Motion correct a RawImg object array (in parallel)
% This code requires the Parallel Computing Toolbox to run in parallel
riArray = riArray.motion_correct('useParallel', true);
isMC_array = [riArray(:).isMotionCorrected]

%%
%
% <./index.html Home>