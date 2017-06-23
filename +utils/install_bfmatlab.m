function install_bfmatlab(varargin)
%install_bfmatlab - Install the files required for Bio-Formats
%
%   install_bfmatlab() installs the files required for Bio-Formats from the
%   Open Microscopy Environment website to the subdirectory bfmatlab within
%   the CHIPS root directory (as returned by utils.CHIPS_rootdir).  For
%   more information, please visit:
%
%       <a href="matlab:web('http://www.openmicroscopy.org/site/products/bio-formats','-browser')">http://www.openmicroscopy.org/site/products/bio-formats</a>.
%
%   install_bfmatlab(DIRBASE) uses the base directory DIRBASE instead of
%   utils.CHIPS_rootdir.
%
%   Please be aware that it is your responsibility to comply with the terms
%   and conditions of the Bio-Formats licence.
%
%   See also BioFormats, utils.CHIPS_rootdir, utils.install_zip

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
urlBF = ['http://downloads.openmicroscopy.org/bio-formats/5.3.4/' ...
    'artifacts/bfmatlab.zip'];
dirBF = 'bfmatlab';
utils.install_zip(urlBF, dirBF, {}, {}, baseDir);
fprintf('\n')

warning('InstallBfmatlab:Licence', ['Please ensure you have read and ' ...
    'agreed to the terms of the licence for the Bio-Formats library. ' ...
    'You can find a copy of the licence at ' ...
    'http://www.openmicroscopy.org/site/about/licensing-attribution.'])

end
