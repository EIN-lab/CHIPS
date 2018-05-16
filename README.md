CHIPS
=====

CHIPS, or Cellular and Hemodynamic Image Processing Suite, is an open-source MATLAB toolbox designed to analyse functional images of cells and blood vessels, primarily from confocal or two-photon microscopy.  CHIPS is hosted at [GitHub](https://github.com/EIN-lab/CHIPS).

Getting Started
---------------

### Prerequisites

CHIPS has been tested on computers running Windows, macOS and several Linux distributions, using MATLAB versions from R2013a.  CHIPS is also expected to run in earlier MATLAB versions; however, this cannot be guaranteed since the unit testing framework did not exist prior to R2013a.  Every effort has been made to eliminate the use of additional MATLAB toolboxes, but it is impractical in certain cases.  In addition, while all algorithms work from R2013a, some function better in more recent versions.

### Installation

#### R2014b and Newer

For MATLAB versions from R2014b, CHIPS can be installed by downloading the latest self-contained toolbox file found on the GitHub repository [release page](https://github.com/EIN-lab/CHIPS/releases).  The toolbox can be installed by dragging and dropping into the Command Window, or double clicking the toolbox file from the Current Folder browser.  See [here](https://www.mathworks.com/help/matlab/matlab_env/get-add-ons.html#buytlxo-3) for more information on installing custom toolboxes.

#### R2014a and Older

MATLAB versions R2014a and earlier do not support custom toolbox files.  Therefore, to install CHIPS, download the source code (either *.zip or *.tar.gz) from the GitHub repository [release page](https://github.com/EIN-lab/CHIPS/releases), extract the source code to a folder, and then add that folder only, NOT including subfolders, to the MATLAB path.  For more information on adding folders to the MATLAB path, see [here](https://www.mathworks.com/help/matlab/matlab_env/add-remove-or-reorder-folders-on-the-search-path.html).

### Additional Steps

#### Bio-Formats

Users wishing to load images using the Bio-Formats library will also need to download the _bfmatlab_ toolbox, which includes the Bio-Formats Java bundle.  This can be done manually, from the Open Microscopy Environment [website](http://www.openmicroscopy.org/site/products/bio-formats), or automatically, by running the function `utils.install_bfmatlab()` (see also [here](../master/%2Butils/install_bfmatlab.m)), which is included with CHIPS.

#### Denoising

Users wishing to perform denoising using the `RawImg.denoise()` function will also need to download additional files from the _BM3D_ and _invansc_ packages.  This can be done manually, from the Tampere University of Technology website ([_BM3D_](http://www.cs.tut.fi/~foi/GCF-BM3D/) and [_invansc_](http://www.cs.tut.fi/~foi/invansc/)), or automatically, by running the function `utils.install_denoise()` (see also [here](../master/%2Butils/install_denoise.m)), which is included with CHIPS.

#### Images and files for examples and tests

The images and other files used in the examples can be downloaded manually, from the University of Zurich [website](http://www.pharma.uzh.ch/en/research/functionalimaging/CHIPS.html), or automatically, by running the function `utils.download_example_imgs()` (see also [here](https://github.com/EIN-lab/CHIPS/tree/master/%2Butils/download_example_imgs.m)), which is included with CHIPS.

Quick start guides and examples
-------------------------------

Find our quick start guides for many applications in the [Documentation](https://ein-lab.github.io/2p-img-analysis/doc/md/).

Getting Help
------------

Classes and functions in CHIPS include documentation that is accessible via the standard MATLAB `help` and `doc` functions.  For example:

```MATLAB
help BioFormats
doc LineScanVel
help RawImg.motion_correct
help utils.CHIPS_version
```

There are also examples, along with further documentation, available via the Help browswer.  To view them, open the Help browser (type `doc` in the Command Window). There should be a link to documentation for *CHIPS Toolbox* at the bottom right of the home page (bottom left in older versions of MATLAB) under Supplemental Software.

### Bug Reports and Further Assistance

Although we are unable to guarantee a response to all requests for assistance, please submit questions or bug reports via the GitHub repository [issues page](https://github.com/EIN-lab/CHIPS/issues).

Contributing
------------

Please see the [CONTRIBUTING.md](https://github.com/EIN-lab/CHIPS/tree/master/CONTRIBUTING.md) file for details.

License
-------

This project is licensed under the GNU General Public License. Please see the [LICENSE.txt](https://github.com/EIN-lab/CHIPS/tree/master/LICENSE.txt) file for details.

Although the GNU General Public License does not permit terms requiring users to cite the research paper where this software was originally published (see [here](https://www.gnu.org/licenses/gpl-faq.en.html#RequireCitation)), we request that any research making use of this software does cite the paper, as well as papers describing any algorithms used, in keeping with normal academic practice.  The function `utils.citation()`, which is included with CHIPS (see also [here](https://github.com/EIN-lab/CHIPS/tree/master/%2Butils/citation.m)), will output the citation details.

Authors
-------

CHIPS has been developed at the University of Zurich by:

- Matthew J.P. Barrett
- Kim David Ferrari
- Martin Holub
- Jillian L. Stobart
- Bruno Weber

Code of Conduct
-------

Please see the [CODE_OF_CONDUCT.md](https://github.com/EIN-lab/CHIPS/tree/master/CODE_OF_CONDUCT.md) file for details.

Acknowledgments
---------------

Please see the [ACKNOWLEDGEMENTS.txt](https://github.com/EIN-lab/CHIPS/tree/master/ACKNOWLEDGEMENTS.txt) file for details.
