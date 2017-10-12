%% LineScanDiam
% Analyse line scan images of vessel diameters

%% Usage
%   OBJ = LineScanDiam(NAME, RAWIMG, CONFIG, COLS, CH, ISDP)

%% Arguments
% * |NAME| is the name for this |LineScanDiam| object.
% * |RAWIMG| is the |RawImg| object that will be used to create the
% |LineScanDiam| object.
% * |CONFIG| contains the configuration parameters needed for the
% |calcDiameter| object.
% * |COLS| specifies the left and right columns that will form the edges of
% the |RawImg| data to use in the calculation.
% * |CH| specifies the channel to be used for calculating the diameter.
% * |ISDP| specifies whether the vessel lumen to analyse is bright (i.e.
% positively labelled) or dark (i.e. negatively labelled).
        
%% Details
% |LineScanDiam| objects are used to analyse the diameters from line scan
% images acquired by scanning perpendicular to the vessel axis.  Typically,
% the blood plasma will be labelled by a fluorescent marker, like a dextran
% conjugated fluorophore (e.g. FITC, as in the figure below).
%
% <<lsd_example_rawImg.png>>

%% See Also
% * <matlab:doc('LineScanDiam') |LineScanDiam| class documentation>
% * <matlab:doc('ConfigDiameterFWHM') |ConfigDiameterFWHM| class documentation>
% * <matlab:doc('CalcDiameterFWHM') |CalcDiameterFWHM| class documentation>
% * <matlab:doc('ImgGroup') |ImgGroup| class documentation>
% * <ig_ImgGroup.html |ImgGroup| quick start guide>

%% Examples
% The following examples require the sample images and other files, which
% can be downloaded manually, from the University of Zurich website
% (<http://www.pharma.uzh.ch/en/research/functionalimaging/CHIPS.html>), or
% automatically, by running the function |utils.download_example_imgs()|.
%
% <html><h3>Create a <tt>LineScanDiam</tt> object interactively</h3></html>
%
% The following example will illustrate the process of creating a
% |LineScanDiam| object interactively, starting with calling the
% constructor.
%
%   % Call the LineScanDiam constructor
%   lsd01 = LineScanDiam()
%
% Since no RawImg has been specified, the first stage is to select the type
% of RawImg to create.  Press three and then enter to select the SCIM_Tif.  
%
%  ----- What type of RawImg would you like to load? -----
%  
%    >> 1) BioFormats
%       2) RawImgDummy
%       3) SCIM_Tif
%  
%  Select a format: 3
%
% Then, use the interactive dialogue box to select the raw image file
% |linescandiam_scim.tif|, which should be located in the subfolder
% tests>res, within the CHIPS root directory.
%
% <<lsd_sel_rawImg.png>>
%
% Use the interactive dialogue box to select the dummy calibration 
% (|calibration_dummy.mat|):
%
% <<sel_cal.png>>
%
% The next stage is to define the 'meaning' of the image channels.  The
% first channel represents the blood plasma.  Press one and then enter to
% complete the selection.
%  
%  ----- What is shown on channel 2? -----
%  
%    >> 0) <blank>
%       1) blood_plasma
%       2) blood_rbcs
%  
%  Answer: 1
%
% The final stage is to select the left and right limits of the image to
% use for diameter calculations.  This can be useful to exclude the edges
% where there can be artefacts associated with other vessels or fluorescent
% areas.
%
% <<lsd_sel_edges.png>>
%
% We have now created a |LineScanDiam| object interactively.
%
%  lsd01 = 
% 
%    LineScanDiam with properties:
% 
%      calcDiameter: [1x1 CalcDiameterFWHM]
%      channelToUse: 2
%     colsToUseDiam: [8 114]
%          plotList: [1x1 struct]
%             state: 'unprocessed'
%              name: 'diamlinescan_scim'
%            rawImg: [1x1 SCIM_Tif]
%      isDarkPlasma: 0
%
% The process is almost exactly the same to create an array of
% |LineScanDiam| objects; when the software prompts you to select one or
% more raw images, simply select multiple images by using either the shift
% or control key.

%%
%
% <html><h3>Prepare a <tt>RawImg</tt> for use in these examples</h3></html>
%

% Prepare a rawImg for use in these examples
fnRawImg = fullfile(utils.CHIPS_rootdir, 'tests', 'res', ...
    'linescandiam_scim.tif');
channels = struct('blood_plasma', 1);
fnCalibration = fullfile(utils.CHIPS_rootdir, 'tests', 'res', ...
    'calibration_dummy.mat');
calibration = CalibrationPixelSize.load(fnCalibration);
rawImg = SCIM_Tif(fnRawImg, channels, calibration);

%%
%
% <html><h3>Create a <tt>LineScanDiam</tt> object without any interaction</h3></html>
%

% Create a LineScanDiam object without any interaction
nameLSD02 = 'test LSD 02';
configFWHM = ConfigDiameterFWHM();
colsToUse = [8 114];
lsd02 = LineScanDiam(nameLSD02, rawImg, configFWHM, colsToUse)

%%
%
% <html><h3>Create a <tt>LineScanDiam</tt> object with a custom config</h3></html>
%

% Create a LineScanDiam object with a custom config
configCustom = ConfigDiameterFWHM('maxRate', 10, 'lev50', 0.7);
lsd03 = LineScanDiam('test LSD 03', rawImg, configCustom, colsToUse);
confDiam = lsd03.calcDiameter.config

%%
%
% <html><h3>Create a <tt>LineScanDiam</tt> object array</h3></html>
%

% Create the RawImg array first 
rawImgArray(1:3) = copy(rawImg);
rawImgArray = copy(rawImgArray)
%%

% Then create a LineScanDiam object array
lsdArray = LineScanDiam('test LSD Array', rawImgArray, configCustom, ...
    colsToUse)

%%
%
% <html><h3>Process a scalar <tt>LineScanDiam</tt> object</h3></html>
%

% Process a scalar LineScanDiam object
lsd03 = lsd03.process()

%%
%
% <html><h3>Process a <tt>LineScanDiam</tt> object array (in parallel)</h3></html>
%

% Process a LineScanDiam object array (in parallel).
% This code requires the Parallel Computing Toolbox to run in parallel
useParallel = true;
lsdArray = lsdArray.process(useParallel);
lsdArray_state = {lsdArray.state}

%%
%
% <html><h3>Plot a figure showing the output</h3></html>
%

% Plot a figure showing the output
hFig03 = lsd03.plot();

%%
%
% <html><h3>Produce a GUI to optimise the parameters</h3></html>
%

% Produce a GUI to optimise the parameters
hFigOpt = lsd03.opt_config();

%%
%
% <html><h3>Output the data</h3></html>
%

% Output the data.  This requires write access to the working directory
fnCSV03 = lsd03.output_data('lsd03', 'overwrite', true);
fID03 = fopen(fnCSV03{1}, 'r');
fileContents03 = textscan(fID03, '%s');
fileContents03{1}{1:5}
fclose(fID03);
