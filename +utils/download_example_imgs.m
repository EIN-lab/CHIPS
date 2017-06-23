function download_example_imgs(varargin)
%download_example_imgs - Download the CHIPS example images
%
%   download_example_imgs() downloads the example images for CHIPS from the
%   University of Zurich website to the subdirectory tests/res within
%   the CHIPS root directory (as returned by utils.CHIPS_rootdir).  For
%   more information, please visit: 
%
%       <a href="matlab:web('http://www.pharma.uzh.ch/en/research/functionalimaging/CHIPS.html','-browser')">http://www.pharma.uzh.ch/en/research/functionalimaging/CHIPS.html</a>.
%
%   download_example_imgs(DIRBASE) uses the base directory DIRBASE instead
%   of utils.CHIPS_rootdir.
%
%   See also utils.CHIPS_rootdir, utils.install_zip

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

% Check the number of input arguments
narginchk(0, 1);

% Parse optional arguments
[baseDir] = utils.parse_opt_args({utils.CHIPS_rootdir}, varargin);

% Install the BM3D files
urlEg = ['http://www.pharma.uzh.ch/dam/' ...
    'jcr:c720632d-a79a-498d-8488-1c9f9ad1be33/CHIPS-example-images.zip'];
dirEg = ['tests' filesep 'res'];
utils.install_zip(urlEg, dirEg, {}, {}, baseDir);
fprintf('\n')

end
