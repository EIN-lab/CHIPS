XSectScan
=======================================

Analyse cross section images of vessel diameters



Usage
----------------------------------------------------------

```matlab
OBJ = XSectScan(NAME, RAWIMG, CONFIG, CH, ISDP)
```


Arguments
----------------------------------------------------------

   + `NAME` is the name for this `LineScanVel` object.
   + `RAWIMG` is the `RawImg` object that will be used to create the `LineScanVel` object.
   + `CONFIG` contains the configuration parameters needed for the `calcDiameter` object.
   + `CH` specifies the channel to be used for calculating the diameter.
   + `ISDP` specifies whether the vessel lumen to analyse is bright (i.e. positively labelled) or dark (i.e. negatively labelled).



Details
----------------------------------------------------------

`XSectScan` objects are used to analyse the diameters of vessels using axial cross section images.  Typically, the vessel lumen will be labelled by a fluorescent marker, like a dextran conjugated fluorophore (e.g. FITC), but the method also works with a negatively labelled vessel lumen (e.g. everything but the vessel lumen is labelled).


![IMAGE](xss_example_rawImg.png)




See Also
----------------------------------------------------------

   + [`XSectScan` class documentation](matlab:doc('XSectScan'))
   + [`ConfigDiameterTiRS` class documentation](matlab:doc('ConfigDiameterTiRS'))
   + [`CalcDiameterTiRS` class documentation](matlab:doc('CalcDiameterTiRS'))
   + [`ImgGroup` class documentation](matlab:doc('ImgGroup'))
   + [`ImgGroup` quick start guide](./ig_ImgGroup.html)



Examples
----------------------------------------------------------

The following examples require the sample images and other files, which can be downloaded manually, from the University of Zurich website ([http://www.pharma.uzh.ch/en/research/functionalimaging/CHIPS.html](http://www.pharma.uzh.ch/en/research/functionalimaging/CHIPS.html)), or automatically, by running the function `utils.download_example_imgs()`.

<h3>Create a <tt>XSectScan</tt> object interactively</h3>

The following example will illustrate the process of creating a `XSectScan` object interactively, starting with calling the constructor.

```matlab
% Call the XSectScan constructor
xss01 = XSectScan()
```
Since no RawImg has been specified, the first stage is to select the type of RawImg to create.  Press three and then enter to select the SCIM_Tif.


```text
----- What type of RawImg would you like to load? -----
```

```text
  >> 1) BioFormats
     2) RawImgDummy
     3) SCIM_Tif
```

```text
Select a format: 3
```
Then, use the interactive dialogue box to select the raw image file `xsectscan_scim.tif`, which should be located in the subfolder tests>res, within the CHIPS root directory.


![IMAGE](xss_sel_rawImg.png)


Use the interactive dialogue box to select the dummy calibration (`calibration_dummy.mat`):


![IMAGE](sel_cal.png)


The next stage is to define the 'meaning' of the image channels.  The first channel is not needed for now, and the second channel represents the blood plasma.  Press enter, followed by 1 and then enter, to complete the selection.


```text
----- What is shown on channel 1? -----
```

```text
  >> 0) <blank>
     1) blood_plasma
     2) blood_rbcs
```

```text
Answer:
```

```text
----- What is shown on channel 2? -----
```

```text
  >> 0) <blank>
     1) blood_plasma
     2) blood_rbcs
```

```text
Answer: 1
```
We have now created a `XSectScan` object interactively.


```text
xss01 =
```

```text
  XSectScan with properties:
```

```text
   calcDiameter: [1x1 CalcDiameterTiRS]
   channelToUse: 2
   isDarkPlasma: 0
       plotList: [1x1 struct]
          state: 'unprocessed'
           name: 'xsectscan_scim'
         rawImg: [1x1 SCIM_Tif]
```
The process is almost exactly the same to create an array of `XSectScan` objects; when the software prompts you to select one or more raw images, simply select multiple images by using either the shift or control key.

<h3>Prepare a <tt>RawImg</tt> for use in these examples</h3>

```matlab
% Prepare a rawImg for use in these examples
fnRawImg = fullfile(utils.CHIPS_rootdir, 'tests', 'res', ...
    'xsectscan_scim.tif');
channels = struct('blood_plasma', 2);
fnCalibration = fullfile(utils.CHIPS_rootdir, 'tests', 'res', ...
    'calibration_dummy.mat');
calibration = CalibrationPixelSize.load(fnCalibration);
rawImg = SCIM_Tif(fnRawImg, channels, calibration);
```

```text
Opening xsectscan_scim.tif: 100% [=================================]

```
<h3>Create a <tt>XSectScan</tt> object without any interaction</h3>

```matlab
% Create a XSectScan object without any interaction
nameXSS02 = 'test XSS 02';
configTiRS = ConfigDiameterTiRS();
xss02 = XSectScan(nameXSS02, rawImg, configTiRS)
```

```text
xss02 =
  XSectScan with properties:

    calcDiameter: [1×1 CalcDiameterTiRS]
    channelToUse: 2
    isDarkPlasma: 0
        plotList: [1×1 struct]
           state: 'unprocessed'
            name: 'test XSS 02'
          rawImg: [1×1 SCIM_Tif]

```
<h3>Create a <tt>XSectScan</tt> object with a custom config</h3>

```matlab
% Create a XSectScan object with a custom config
configCustom = ConfigDiameterTiRS('thresholdFWHM', 0.65, ...
    'thresholdInv', 0.35);
xss03 = XSectScan('test XSS 03', rawImg, configCustom);
confDiam = xss03.calcDiameter.config
```

```text
confDiam =
  ConfigDiameterTiRS with properties:

     connectivity: 8
    thresholdFWHM: 0.6500
     thresholdInv: 0.3500
     thresholdSTD: 3

```
<h3>Create a <tt>XSectScan</tt> object array</h3>

```matlab
% Create the RawImg array first
rawImgArray(1:3) = copy(rawImg);
rawImgArray = copy(rawImgArray)
```

```text
rawImgArray =
  1×3 SCIM_Tif array with properties:

    filename
    isDenoised
    isMotionCorrected
    metadata_original
    name
    rawdata
    t0
    metadata


```
```matlab
% Then create a XSectScan object array
xssArray = XSectScan('test XSS Array', rawImgArray, configCustom)
```

```text
Warning: All of the RawImg objects are assumed to have the same channel
structure. If this is not true, the processing will not work as expected; in
this case you will need to create the objects seperately.
xssArray =
  1×3 XSectScan array with properties:

    calcDiameter
    channelToUse
    isDarkPlasma
    plotList
    state
    name
    rawImg


```
<h3>Process a scalar <tt>XSectScan</tt> object</h3>

```matlab
% Process a scalar XSectScan object
xss03 = xss03.process()
```

```text
Calculating diameter: 100% [=======================================]
xss03 =
  XSectScan with properties:

    calcDiameter: [1×1 CalcDiameterTiRS]
    channelToUse: 2
    isDarkPlasma: 0
        plotList: [1×1 struct]
           state: 'processed'
            name: 'test XSS 03'
          rawImg: [1×1 SCIM_Tif]

```
<h3>Process a <tt>XSectScan</tt> object array (in parallel)</h3>

```matlab
% Process a XSectScan object array (in parallel).
% This code requires the Parallel Computing Toolbox to run in parallel
useParallel = true;
xssArray = xssArray.process(useParallel);
xssArray_state = {xssArray.state}
```

```text
Processing array: 100% [===========================================]
xssArray_state =
  1×3 cell array
    'processed'    'processed'    'processed'

```
<h3>Plot a figure showing the output</h3>

```matlab
% Plot a figure showing the output
hFig03 = xss03.plot();
set(hFig03, 'Position', [50, 50, 600, 600]);
```

![IMAGE](pi_XSectScan_01.png)
<h3>Produce a GUI to optimise the parameters</h3>

```matlab
% Produce a GUI to optimise the parameters
hFigOpt = xss03.opt_config();
```

![IMAGE](pi_XSectScan_02.png)
<h3>Output the data</h3>

```matlab
% Output the data.  This requires write access to the working directory
fnCSV03 = xss03.output_data('xss02', 'overwrite', true);
fID03 = fopen(fnCSV03{1}, 'r');
fileContents03 = textscan(fID03, '%s');
fileContents03{1}{1:5}
fclose(fID03);
```

```text
ans =
    'time,diameter,areaPixels,maskSTD,mask'
ans =
    '0.070,86.702,1476,FALSE,FALSE'
ans =
    '0.209,88.963,1554,FALSE,FALSE'
ans =
    '0.348,86.290,1462,FALSE,FALSE'
ans =
    '0.488,85.994,1452,FALSE,FALSE'

```

---
[Home](./index.html)
