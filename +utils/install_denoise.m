function install_denoise(varargin)
%install_denoise - Install the files required for denoising 
%
%   install_denoise() installs the files required for denoising from the
%   Tampere University of Technology website to the subdirectories BM3D and
%   invansc within the CHIPS root directory (as returned by
%   utils.CHIPS_rootdir).  For more information, please visit:
%
%       <a href="matlab:web('http://www.cs.tut.fi/~foi/GCF-BM3D/','-browser')">http://www.cs.tut.fi/~foi/GCF-BM3D/</a> (for BM3D), or
%       <a href="matlab:web('http://www.cs.tut.fi/~foi/invansc/','-browser')">http://www.cs.tut.fi/~foi/invansc/</a> (for invansc).
%
%   install_denoise(DIRBASE) uses the base directory DIRBASE instead of
%   utils.CHIPS_rootdir.
%
%   Please be aware that it is your responsibility to comply with the terms
%   and conditions of the package licences. 
%
%   See also utils.denoise, utils.denoise_VBM3D, utils.CHIPS_rootdir,
%   utils.install_zip

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
urlBM3D = 'http://www.cs.tut.fi/~foi/GCF-BM3D/BM3D.zip';
dirBM3D = 'BM3D';
miscBM3D = {'VBM3D.m', 'LEGAL_NOTICE.txt', 'README.txt'};
mexBM3D = {'bm3d_thr_video', 'bm3d_wiener_video'};
utils.install_zip(urlBM3D, dirBM3D, miscBM3D, mexBM3D, baseDir);

% Install the invansc files
urlInvansc = 'http://www.cs.tut.fi/~foi/invansc/invansc_v3.zip';
dirInvansc = 'invansc';
miscInvansc = {'Anscombe_forward.m', 'Anscombe_inverse_exact_unbiased.m', ...
    'Anscombe_vectors.mat', 'GenAnscombe_forward.m', ...
    'GenAnscombe_inverse_exact_unbiased.m', 'GenAnscombe_vectors.mat', ...
    'LEGAL_NOTICE.txt', 'ReadMe_Contents.txt'};
mexInvansc = {};
utils.install_zip(urlInvansc, dirInvansc, miscInvansc, mexInvansc, baseDir);
fprintf('\n')

warning('InstallDenoise:Licence', ['Please ensure you have read and ' ...
    'agreed to the terms of the licences for the denoising functions. ' ...
    'You can find a copy of the licences in the folders "BM3D" and ' ...
    '"invansc" in the CHIPS root directory, or at ' ...
    'http://www.cs.tut.fi/~foi/GCF-BM3D/legal_notice.html and ' ...
    'http://www.cs.tut.fi/~foi/invansc/legal_notice.html.'])

end
