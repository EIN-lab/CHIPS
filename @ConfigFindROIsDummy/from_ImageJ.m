function cfrdObj = from_ImageJ(varargin)
%from_ImageJ - Load ROIs from ImageJ ZIP-file
%
%   OBJ = from_ImageJ() prompts the user to select a ZIP-file
%   containing the ImageJ ROIs and will create a
%   ConfigFindROIsDummy object using the provided information. By
%   using <a href="matlab:help utils.create_ImgJ_mask">utils.create_ImgJ_mask</a> a ROI mask is drawn and ROI 
%   names specified in ImageJ are conserved.
%
%   OBJ = from_ImageJ(FILENAME) uses the supplied FILENAME to
%   create a ConfigFindROIsDummy object.
%
%   OBJ = from_ImageJ(FILENAME, XPIX, YPIX, SCALEFACTOR) specifies the
%   number of x and y pixels in the image that the mask was drawn on and a
%   scale factor for cases where ROIs were selected on images with a
%   different resolution.  E.g., if you drew the mask on a 512*512 pixel
%   image, but are analysing a 256x256 pixel image, the scale factor is
%   0.5.
%
%   See also utils.create_ImgJ_mask, utils.ReadImageJROI

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
    
    % Parse arguments
    [fnROIs, x_pix, y_pix, scaleFactor] = utils.parse_opt_args(...
        {'', [], [], []}, varargin);
    
    % Call the utility function to do most of the work
    [roiMask, roiNames] = utils.create_imgJ_mask(...
        fnROIs, x_pix, y_pix, scaleFactor);
    
	% Create the Config
    cfrdObj = ConfigFindROIsDummy('roiMask', roiMask, ...
        'roiNames', roiNames);

end
