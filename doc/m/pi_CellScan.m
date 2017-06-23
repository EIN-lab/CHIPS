%% CellScan
% Analyse cellular signals

%% Usage
%   OBJ = CellScan(NAME, RAWIMG, CONFIG, CHANNEL)

%% Arguments
% * |NAME| is the name for this |CellScan| object.
% * |RAWIMG| is the |RawImg| object that will be used to create the
% |CellScan| object.
% * |CONFIG| contains the configuration parameters needed for the
% |calcFindROIs|, |calcMeasureROIs| and |calcDetectSigs| objects.
% * |CHANNEL| is the channel number to use for analysis.
        
%% Details
% |CellScan| objects are used to analyse dynamic fluorescence signals of
% cellular origin (i.e. calcium dyes and genetic sensors, metabolite
% sensors, etc.)
%
% <<cs_example_rawImg.png>>

%% See Also
% * <matlab:doc('CellScan') |CellScan| class documentation>
% * <matlab:doc('ConfigCellScan') |ConfigCellScan| class documentation>
% * <matlab:doc('ConfigFindROIsDummy') |ConfigFindROIsDummy| class documentation>
% * <matlab:doc('ConfigFindROIsFLIKA') |ConfigFindROIsFLIKA| class documentation>
% * <matlab:doc('ConfigFindROIsFLIKA_2D') |ConfigFindROIsFLIKA_2D| class documentation>
% * <matlab:doc('ConfigFindROIsFLIKA_2p5D') |ConfigFindROIsFLIKA_2p5D| class documentation>
% * <matlab:doc('ConfigFindROIsFLIKA_3D') |ConfigFindROIsFLIKA_3D| class documentation>
% * <matlab:doc('ConfigMeasureROIsDummy') |ConfigMeasureROIsDummy| class documentation>
% * <matlab:doc('ConfigDetectSigsDummy') |ConfigDetectSigsDummy| class documentation>
% * <matlab:doc('ConfigDetectSigsClsfy') |ConfigDetectSigsClsfy| class documentation>
% * <matlab:doc('CalcFindROIsDummy') |CalcFindROIsDummy| class documentation>
% * <matlab:doc('CalcFindROIsFLIKA') |CalcFindROIsFLIKA| class documentation>
% * <matlab:doc('CalcFindROIsFLIKA_2D') |CalcFindROIsFLIKA_2D| class documentation>
% * <matlab:doc('CalcFindROIsFLIKA_2p5D') |CalcFindROIsFLIKA_2p5D| class documentation>
% * <matlab:doc('CalcFindROIsFLIKA_3D') |CalcFindROIsFLIKA_3D| class documentation>
% * <matlab:doc('CalcMeasureROIsDummy') |CalcMeasureROIsDummy| class documentation>
% * <matlab:doc('CalcDetectSigsDummy') |CalcDetectSigsDummy| class documentation>
% * <matlab:doc('CalcDetectSigsClsfy') |CalcDetectSigsClsfy| class documentation>
% * <matlab:doc('ImgGroup') |ImgGroup| class documentation>
% * <ig_ImgGroup.html |ImgGroup| quick start guide>

%% Examples
% The following examples require the sample images and other files, which
% can be downloaded manually, from the University of Zurich website
% (<http://www.pharma.uzh.ch/en/research/functionalimaging/CHIPS.html>), or
% automatically, by running the function |utils.download_example_imgs()|.
%
% <html><h3>Create a <tt>CellScan</tt> object interactively</h3></html>
%
% The following example will illustrate the process of creating a
% |CellScan| object interactively, starting with calling the
% constructor.
%
%   % Call the CellScan constructor
%   cs01 = CellScan()
%
% Since no RawImg has been specified, the first stage is to select the type
% of RawImg to create.  Press 2 and then enter to select the SCIM_Tif.  
%
%  ----- What type of RawImg would you like to load? -----
%  
%    >> 1) BioFormats
%       2) SCIM_Tif
%  
%  Select a format: 2
%
% Then, use the interactive dialogue box to select the raw image file
% |cellscan_scim.tif|, which should be located in the subfolder
% tests>res, within the CHIPS root directory.
%
% <<cs_sel_rawImg.png>>
%
% Use the interactive dialogue box to select the dummy calibration 
% (|calibration_dummy.mat|):
%
% <<sel_cal.png>>
%
% The next stage is to define the 'meaning' of the image channel(s).  The
% channel represents a cytosolic calcium sensor in astroytes. Press 1 and
% then enter to complete the selection.
%
%  ----- What is shown on channel 1? -----
%  
%    >> 0) <blank>
%       1) Ca_Cyto_Astro
%       2) Ca_Memb_Astro
%       3) Ca_Neuron
%       4) cellular_signal
%       5) FRET_ratio
%  
%  Answer: 1
%  
% Since |CellScan| objects require a method for ROI identification, a
% method for ROI measurement, and a method for signal detection, we have to
% specify our choice.
%
% CellScan defaults to a whole frame analysis (i.e. one ROI covers the
% whole frame). We'd like to use 3D FLIKA instead, because we want to
% identify ROIs based on activity. Press 6 and then enter to complete the
% selection.
%
%  ----- Which ROI detection method would you like to use? -----
%  
%    >> 1) whole frame
%       2) load ImageJ ROIs
%       3) load mask from .tif or .mat file
%       4) 2D FLIKA (automatic ROI selection)
%       5) 2.5D FLIKA (automatic ROI selection)
%       6) 3D FLIKA (automatic ROI selection)
%       7) CellSort (automatic ROI selection)
%
%  Select a detection method, please: 6
%
% The next stage is to specify the ROI measuring method. CellScan uses
% simple baseline calculation as the default. Press enter to complete the
% selection.
%
%  ----- Which ROI measuring method would you like to use? -----
%  
%    >> 1) simple baseline normalised
%
%  Select a measuring method, please:
%
% The last stage is to specify the signal detection method. We want to
% classify signals based on shape and to do some basic measurements like
% amplitude, etc. Press 2 and then enter to complete the selection.
%
% ----- Which signal detection method would you like to use? -----
%  
%    >> 1) no signal detection
%       2) detect + classify signals
%  
% Select a detection method, please: 2
%
% We have now created a CellScan object interactively.
%
%  cs01 = 
% 
%    CellScan with properties:
% 
%        calcFindROIs: [1x1 CalcFindROIsFLIKA_3D]
%     calcMeasureROIs: [1x1 CalcMeasureROIsDummy]
%      calcDetectSigs: [1x1 CalcDetectSigsClsfy]
%        channelToUse: 1
%            plotList: [1x1 struct]
%               state: 'unprocessed'
%                name: 'cellscan_scim'
%              rawImg: [1x1 SCIM_Tif]
% 
% The process is almost exactly the same to create an array of |CellScan|
% objects; when the software prompts you to select one or more raw images,
% simply select multiple images by using either the shift or control key.

%%
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
% <html><h3>Create a <tt>CellScan</tt> object without any interaction</h3></html>
%

% Create a CellScan object without any interaction
nameCS02 = 'test CS 02';
configFind = ConfigFindROIsFLIKA_3D();
configMeasure = ConfigMeasureROIsDummy();
configDetect = ConfigDetectSigsDummy();
configCS = ConfigCellScan(configFind, configMeasure, configDetect);
channelToUse = 1;
cs02 = CellScan(nameCS02, rawImg, configCS, channelToUse)

%%
%
% <html><h3>Create a <tt>CellScan</tt> object array</h3></html>
%

% Create a CellScan object array
rawImgArray(1:3) = copy(rawImg);
rawImgArray = copy(rawImgArray);
csArray = CellScan('test CS Array', rawImgArray, configCS, channelToUse)

%%
%
% <html><h3>Create a <tt>CellScan</tt> object with a custom config</h3></html>
%

% Create a CellScan object with a custom config
configFindCustom = ConfigFindROIsFLIKA_2D('baselineFrames', 30, ...
    'freqPassBand', 0.15, 'sigmaXY', 4, 'dilateXY', 1, ...
    'thresholdPuff', 10, 'minRiseTime', 2, 'maxRiseTime', 10, ...
    'minROIArea', 36);
configMeasureCustom = ConfigMeasureROIsDummy('baselineFrames', 30);
configDetectCustom = ConfigDetectSigsClsfy('baselineFrames', 30, ...
    'thresholdSP', 9, 'lpWindowTime', 6, 'spPassBandMin', 0.015, ...
    'spPassBandMax', 0.6, 'spFilterOrder', 10);
configCSCustom = ConfigCellScan(configFindCustom, configMeasureCustom, ...
    configDetectCustom);
cs03 = CellScan('test CS 03', rawImg, configCSCustom, channelToUse);
confFind = cs03.calcFindROIs.config
confMeasure = cs03.calcMeasureROIs.config
confDetect = cs03.calcDetectSigs.config

%%
%
% <html><h3>Process a scalar <tt>CellScan</tt> object</h3></html>
%

% Process a scalar CellScan object
cs03 = cs03.process()

%%
%
% <html><h3>Process a <tt>CellScan</tt> object array (in parallel)</h3></html>
%

% Process a CellScan object array (in parallel)
% This code requires the Parallel Computing Toolbox to run in parallel
useParallel = true;
csArray = csArray.process(useParallel);
csArray_state = {csArray.state}

%%
%
% <html><h3>Plot a figure showing an overview of identified ROIs</h3></html>
%

% Plot a figure showing an overview of identified ROIs
hFig03 = cs03.plot();
set(hFig03, 'Units', 'pixels', 'Position', [50, 50, 1100, 750]);

%%
%
% <html><h3>Produce a GUI to optimise the parameters</h3></html>
%

% Produce a GUI to optimise the parameters
hFigOpt = cs03.opt_config();

%%
%
% <html><h3>Output the data</h3></html>
%

% Output the data.  This requires write access to the working directory.
fnCS03 = cs03.output_data('cs03', 'overwrite', true);
%%

% First, the findROIs data
fID03_find = fopen(fnCS03{1}, 'r');
fileContents03f = textscan(fID03_find, '%s');
fileContents03f{1}{1:5}
fclose(fID03_find);
%%

% Then, the measureROIs data
fID03_measure = fopen(fnCS03{2}, 'r');
fileContents03m = textscan(fID03_measure, '%s');
fileContents03m{1}{1:5}
fclose(fID03_measure);
%%

% Finally, the detectSigs data
fID03_detect = fopen(fnCS03{3}, 'r');
fileContents03d = textscan(fID03_detect, '%s');
fileContents03d{1}{1:5}
fclose(fID03_detect);
