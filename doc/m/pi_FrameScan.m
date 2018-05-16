%% FrameScan
% Analyse frame scan images of vessels

%% Usage
%   OBJ = FrameScan(NAME, RAWIMG, CONFIG, ISDS, COLS_V, ROWS_V, COLS_D)

%% Arguments
% * |NAME| is the name for this |FrameScan| object.
% * |RAWIMG| is the |RawImg| object that will be used to create the
% |FrameScan| object.
% * |CONFIG| contains the configuration parameters needed for the
% |calcVelocity| and |calcDiameter| object.
% * |ISDS| specifies whether the streaks to analyse are dark (i.e.
% negatively labelled) or bright (i.e. positively labelled).
% * |COLS_V| specifies the left and right columns that will form the edges
% of the |RawImg| data to use in the velocity calculation.
% * |ROWS_V| specifies the top and bottom rows that will form the edges of
% the |RawImg| data to use in the velocity calculation.
% * |COLS_D| specifies the left and right columns that will form the edges
% of the |RawImg| data to use in the diameter calculation.
        
%% Details
% |FrameScan| objects are used to analyse both the velocities and diameters
% from frame scan images of blood vessels.  Typically, the blood plasma
% will be labelled by a fluorescent marker, like a dextran conjugated
% fluorophore (e.g. FITC, as in the figure below), but the method also
% works with labelled red blood cells (RBCs).
%
% <<fs_example_rawImg.png>>

%% See Also
% * <matlab:doc('FrameScan') |FrameScan| class documentation>
% * <matlab:doc('ConfigFrameScan') |ConfigFrameScan| class documentation>
% * <matlab:doc('ConfigVelocityRadon') |ConfigVelocityRadon| class documentation>
% * <matlab:doc('ConfigVelocityLSPIV') |ConfigVelocityLSPIV| class documentation>
% * <matlab:doc('ConfigDiameterFWHM') |ConfigDiameterFWHM| class documentation>
% * <matlab:doc('CalcVelocityRadon') |CalcVelocityRadon| class documentation>
% * <matlab:doc('CalcVelocityLSPIV') |CalcVelocityLSPIV| class documentation>
% * <matlab:doc('CalcDiameterFWHM') |CalcDiameterFWHM| class documentation>
% * <matlab:doc('ImgGroup') |ImgGroup| class documentation>
% * <./ig_ImgGroup.html |ImgGroup| quick start guide>

%% Examples
% The following examples require the sample images and other files, which
% can be downloaded manually, from the University of Zurich website
% (<http://www.pharma.uzh.ch/en/research/functionalimaging/CHIPS.html>), or
% automatically, by running the function |utils.download_example_imgs()|.
%
% <html><h3>Create a <tt>FrameScan</tt> object interactively</h3></html>
%
% The following example will illustrate the process of creating a
% |FrameScan| object interactively, starting with calling the constructor.
%
%   % Call the FrameScan constructor
%   fs01 = FrameScan()
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
% A warning may appear about the pixel aspect ratio, but this is not
% relevant for |FrameScan| images.
%
% Then, use the interactive dialogue box to select the raw image file
% |framescan_scim.tif|, which should be located in the subfolder
% tests>res, within the CHIPS root directory.
%
% <<fs_sel_rawImg.png>>
%
% Use the interactive dialogue box to select the dummy calibration 
% (|calibration_dummy.mat|):
%
% <<sel_cal.png>>
%
% The next stage is to define the 'meaning' of the image channels.  The
% first channel represents the blood plasma. Press one and then enter to
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
% two and then enter to complete the selection.
%
%  ----- What type of velocity calculation would you like to use? -----
%  
%    >> 1) CalcVelocityLSPIV
%       2) CalcVelocityRadon
%
%  Select a format: 2
%
% The next stage is to select the limits of the image to use for velocity
% calculations.  Selecting left and right limits can be useful to exclude
% the edges where there can be artefacts associated with the scan mirrors
% changing speed and/or direction.  Selecting top and bottom limits ensures
% that the velocity is only calculated inside the vessel.
%
% <<fs_sel_edges_lr_v.png>>
%
% <<fs_sel_edges_tb_v.png>>
%
% The final stage is to select the left and right limits of the image to
% use for diameter calculations.  This can be useful to exclude the edges
% where there can be artefacts associated with other vessels or fluorescent
% areas.
%
% <<fs_sel_edges_lr_d.png>>
%
% We have now created a |FrameScan| object interactively.
%
%  fs01 = 
% 
%    FrameScan with properties:
% 
%      calcDiameter: [1x1 CalcDiameterFWHM]
%     colsToUseDiam: [21 110]
%      rowsToUseVel: [27 94]
%          plotList: [1x1 struct]
%      calcVelocity: [1x1 CalcVelocityRadon]
%      colsToUseVel: [20 112]
%     isDarkStreaks: 1
%             state: 'unprocessed'
%              name: 'framescan_scim'
%            rawImg: [1x1 SCIM_Tif]
%      isDarkPlasma: 0
%
% The process is almost exactly the same to create an array of |FrameScan|
% objects; when the software prompts you to select one or more raw images,
% simply select multiple images by using either the shift or control key.

%%
%
% <html><h3>Prepare a <tt>RawImg</tt> for use in these examples</h3></html>
%

% Prepare a rawImg for use in these examples
fnRawImg = fullfile(utils.CHIPS_rootdir, 'tests', 'res', ...
    'framescan_scim.tif');
channels = struct('blood_plasma', 1);
fnCalibration = fullfile(utils.CHIPS_rootdir, 'tests', 'res', ...
    'calibration_dummy.mat');
calibration = CalibrationPixelSize.load(fnCalibration);
rawImg = SCIM_Tif(fnRawImg, channels, calibration);

%%
%
% <html><h3>Create a <tt>FrameScan</tt> object without any interaction</h3></html>
%

% Create a FrameScan object without any interaction
nameFS02 = 'test FS 02';
configFS = ConfigFrameScan(ConfigVelocityLSPIV(), ConfigDiameterFWHM);
isDarkStreaks = [];
colsToUseVel = [20 112];
rowsToUseVel = [27 94];
colsToUseDiam = [21 110];
fs02 = FrameScan(nameFS02, rawImg, configFS, isDarkStreaks, ...
    colsToUseVel, rowsToUseVel, colsToUseDiam)

%%
%
% <html><h3>Create a <tt>FrameScan</tt> object with a custom config</h3></html>
%

% Create a FrameScan object with a custom config
configCustom = ConfigFrameScan(...
    ConfigVelocityRadon('windowTime', 30, 'nOverlap', 6), ...
    ConfigDiameterFWHM('maxRate', 10, 'lev50', 0.6));
fs03 = FrameScan('test FS 03', rawImg, configCustom, ...
    isDarkStreaks, colsToUseVel, rowsToUseVel, colsToUseDiam);
confDiam = fs03.calcDiameter.config
confVel = fs03.calcVelocity.config

%%
%
% <html><h3>Create a <tt>FrameScan</tt> object array</h3></html>
%

% Create the RawImg array first 
rawImgArray(1:3) = copy(rawImg);
rawImgArray = copy(rawImgArray)
%%

% Then create the FrameScan object array
fsArray = FrameScan('test FS Array', rawImgArray, configCustom, ...
    isDarkStreaks, colsToUseVel, rowsToUseVel, colsToUseDiam)

%%
%
% <html><h3>Process a scalar <tt>FrameScan</tt> object</h3></html>
%

% Process a scalar FrameScan object
fs03 = fs03.process()

%%
%
% <html><h3>Process a <tt>FrameScan</tt> object array (in parallel)</h3></html>
%

% Process a FrameScan object array (in parallel).
% This code requires the Parallel Computing Toolbox to run in parallel
useParallel = true;
fsArray = fsArray.process(useParallel);
fsArray_state = {fsArray.state}

%%
%
% <html><h3>Plot a figure showing the output</h3></html>
%

% Plot a figure showing the output
hFig03 = fs03.plot();
set(hFig03, 'Position', [50, 50, 800, 1000])

%%
%
% <html><h3>Produce a GUI to optimise the parameters</h3></html>
%

% Produce a GUI to optimise the parameters
hFigOpt = fs03.opt_config();

%%
%
% <html><h3>Output the data</h3></html>
%

% Output the data.  This requires write access to the working directory
fnCSV03 = fs03.output_data('fs03', 'overwrite', true);
%%

% First, the diameter data
fID03_diameter = fopen(fnCSV03{1}, 'r');
fileContents03d = textscan(fID03_diameter, '%s');
fileContents03d{1}{1:5}
fclose(fID03_diameter);
%%

% Then, the velocity data
fID03_velocity = fopen(fnCSV03{2}, 'r');
fileContents03v = textscan(fID03_velocity, '%s');
fileContents03v{1}{1:5}
fclose(fID03_velocity);

%%
%
% <./index.html Home>