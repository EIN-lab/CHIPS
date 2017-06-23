%% LineScanVel
% Analyse line scan images of vessel velocities

%% Usage
%   OBJ = LineScanVel(NAME, RAWIMG, CONFIG, ISDS, COLS)

%% Arguments
% * |NAME| is the name for this |LineScanVel| object.
% * |RAWIMG| is the |RawImg| object that will be used to create the
% |LineScanVel| object.
% * |CONFIG| contains the configuration parameters needed for the
% |calcVelocity| object.
% * |ISDS| specifies whether the streaks to analyse are dark (i.e.
% negatively labelled) or bright (i.e. positively labelled).
% * |COLS| specifies the left and right columns that will form the edges of
% the |RawImg| data to use in the calculation.
        
%% Details
% |LineScanVel| objects are used to analyse the velocity from line scan
% images acquired by scanning along to the vessel axis.  Typically, the
% blood plasma will be labelled by a fluorescent marker, like a dextran
% conjugated fluorophore (e.g. FITC, as in the figure below), but the
% method also works with labelled red blood cells (RBCs).
%
% <<lsv_example_rawImg.png>>

%% See Also
% * <matlab:doc('LineScanVel') |LineScanVel| class documentation>
% * <matlab:doc('ConfigVelocityRadon') |ConfigVelocityRadon| class documentation>
% * <matlab:doc('ConfigVelocityLSPIV') |ConfigVelocityLSPIV| class documentation>
% * <matlab:doc('CalcVelocityRadon') |CalcVelocityRadon| class documentation>
% * <matlab:doc('CalcVelocityLSPIV') |CalcVelocityLSPIV| class documentation>
% * <matlab:doc('ImgGroup') |ImgGroup| class documentation>
% * <ig_ImgGroup.html |ImgGroup| quick start guide>

%% Examples
% The following examples require the sample images and other files, which
% can be downloaded manually, from the University of Zurich website
% (<http://www.pharma.uzh.ch/en/research/functionalimaging/CHIPS.html>), or
% automatically, by running the function |utils.download_example_imgs()|.
%
% <html><h3>Create a <tt>LineScanVel</tt> object interactively</h3></html>
%
% The following example will illustrate the process of creating a
% |LineScanVel| object interactively, starting with calling the
% constructor.
%
%   % Call the LineScanVel constructor
%   lsv01 = LineScanVel()
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
% |linescanvel_scim.tif|, which should be located in the subfolder
% tests>res, within the CHIPS root directory.
%
% <<lsv_sel_rawImg.png>>
%
% A warning may appear about the pixel aspect ratio, but this is not
% relevant for |LineScanVel| images.
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
%  ----- What is shown on channel 1? -----
%  
%    >> 0) <blank>
%       1) blood_plasma
%       2) blood_rbcs
%  
%  Answer: 1
%
% The next stage is to specify which velocity calculation algorithm should
% be used. In this case we will choose the Radon transform method.  Press
% two and then enter to complete the selection
%
%  ----- What type of velocity calculation would you like to use? -----
%  
%    >> 1) CalcVelocityLSPIV
%       2) CalcVelocityRadon
%
%  Select a format: 2
%
% The final stage is to select the left and right limits of the image to
% use for velocity calculations.  This can be useful to exclude the edges
% where there can be artefacts associated with the scan mirrors changing
% speed and/or direction.
%
% <<lsv_sel_edges.png>>
%
% We have now created a |LineScanVel| object interactively.
%
%  lsv01 = 
% 
%    LineScanVel with properties:
% 
%          plotList: [1x1 struct]
%      calcVelocity: [1x1 CalcVelocityRadon]
%      colsToUseVel: [17 112]
%     isDarkStreaks: 1
%             state: 'unprocessed'
%              name: 'linescanvel_scim'
%            rawImg: [1x1 SCIM_Tif]
%
% The process is almost exactly the same to create an array of
% |LineScanVel| objects; when the software prompts you to select one or
% more raw images, simply select multiple images by using either the shift
% or control key.

%%
%
% <html><h3>Prepare a <tt>RawImg</tt> for use in these examples</h3></html>
%

% Prepare a rawImg for use in these examples
fnRawImg = fullfile(utils.CHIPS_rootdir, 'tests', 'res', ...
    'linescanvel_scim.tif');
channels = struct('blood_plasma', 1);
fnCalibration = fullfile(utils.CHIPS_rootdir, 'tests', 'res', ...
    'calibration_dummy.mat');
calibration = CalibrationPixelSize.load(fnCalibration);
rawImg = SCIM_Tif(fnRawImg, channels, calibration);

%%
%
% <html><h3>Create a <tt>LineScanVel</tt> object without any interaction</h3></html>
%

% Create a LineScanVel object without any interaction
nameLSV02 = 'test LSV 02';
configRadon = ConfigVelocityRadon();
isDarkStreaks = [];
colsToUse = [17 112];
lsv02 = LineScanVel(nameLSV02, rawImg, configRadon, ...
    isDarkStreaks, colsToUse)

%%
%
% <html><h3>Create a <tt>LineScanVel</tt> object array</h3></html>
%

% Create the RawImg array first 
rawImgArray(1:3) = copy(rawImg);
rawImgArray = copy(rawImgArray)
%%

% Then create a LineScanVel object array
lsvArray = LineScanVel('test LSV Array', rawImgArray, configRadon, ...
    isDarkStreaks, colsToUse)

%%
%
% <html><h3>Create a <tt>LineScanVel</tt> object with a custom config</h3></html>
%

% Create a LineScanVel object with a custom config
configLSPIV = ConfigVelocityLSPIV('shiftAmt', 8, 'windowTime', 100, ...
    'thresholdSNR', 1.5);
lsv03 = LineScanVel('test LSV 03', rawImg, configLSPIV, ...
    isDarkStreaks, colsToUse);
confVel = lsv03.calcVelocity.config

%%
%
% <html><h3>Process a scalar <tt>LineScanVel</tt> object</h3></html>
%

% Process a scalar LineScanVel object
lsv03 = lsv03.process();

%%
%
% <html><h3>Process a <tt>LineScanVel</tt> object array (in parallel)</h3></html>
%

% Process a LineScanVel object array (in parallel).
% This code requires the Parallel Computing Toolbox to run in parallel
useParallel = true;
lsvArray = lsvArray.process(useParallel);
lsvArray_state = {lsvArray.state}

%%
%
% <html><h3>Plot a figure showing the output</h3></html>
%

% Plot a figure showing the output
hFig03 = lsv03.plot();
set(hFig03, 'Position', [50, 50, 600, 700])

%%
%
% <html><h3>Produce a GUI to optimise the parameters</h3></html>
%

% Produce a GUI to optimise the Radon transform parameters
hFigOpt03 = lsv03.opt_config();

%%
%
% <html><h3>Output the data</h3></html>
%

% Output the data.  This requires write access to the working directory
fnCSV03 = lsv03.output_data('lsv03', 'overwrite', true);
fID03 = fopen(fnCSV03{1}, 'r');
fileContents03 = textscan(fID03, '%s');
fileContents03{1}{1:5}
fclose(fID03);
