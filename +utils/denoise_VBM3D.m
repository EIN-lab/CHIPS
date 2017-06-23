function [chSeq_dn] = denoise_VBM3D(chSeq, paramsIn)
%denoise_VBM3D - Denoise an image sequence using the VBM3D approach
%
%   This function is not intended to be called directly.

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
    narginchk(2, 2);

    % Check the path for these directories, and add if necessary
    utils.checkaddpath('invansc')
    utils.checkaddpath('BM3D')

    % Pull out the input image class, then convert to double precision
    inClass = class(chSeq);
    chSeq = squeeze(chSeq);
    if ~isa(chSeq, 'double')
        chSeq = double(chSeq);
    end

    % Apply forward Variance Stabilizing Transformation
    SD = std(chSeq(:));
    try
        chSeq_dn = GenAnscombe_forward(chSeq, SD);
    catch ME
        check_denoise_err(ME)
    end

    % Assure that the image falls into [0, 1] range
    [chSeq_dn, rangeVST] = utils.normalise_sig(chSeq_dn);
    
    % Model assumes unit variance after VST transform; 	
    SD_VST = 1;
    % Rescale to account for normalization
    SD_VST = SD_VST / (rangeVST(2) - rangeVST(1));
    
%     % This shouldn't be necessary, but may be more robust
%     SD_VST = std(chSeq_denoised(:));

    % Defensively programming the rng state because inside VBM3D it uses
    % legacy syntax which might screw things up elsewhere.
    rngState = rng();

    % Turn off unneeded warnings for now
    [lastMsgPre, lastIDPre] = lastwarn();
    wngIDOff = 'MATLAB:RandStream:ActivatingLegacyGenerators';
    wngState = warning('off', wngIDOff);

    % Denoise via BlockMatching Algorithm for sequences
    % sigma in scale [0,255] is expected
    NFrames = 0;
    PrintInfo = 0;
    try
        [~, chSeq_dn] = VBM3D(chSeq_dn, SD_VST*255, NFrames, PrintInfo, ...
            chSeq_dn, paramsIn.profile);
    catch ME
        check_denoise_err(ME)
    end
    
    % Restore the warnings and random state
    rng('default')
    rng(rngState);
    warning(wngState)
    utils.clear_unwanted_wngs(wngIDOff, lastMsgPre, lastIDPre)
    
    % Rescale to original scale
    chSeq_dn = chSeq_dn * (rangeVST(2) - rangeVST(1)) + rangeVST(1);

    % Apply inverse transformation
    try
        chSeq_dn = GenAnscombe_inverse_exact_unbiased(chSeq_dn, SD);
    catch ME
        check_denoise_err(ME)
    end
    
    % Cast the output to the appropriate class
    chSeq_dn = cast(chSeq_dn, inClass);
    
end

% ----------------------------------------------------------------------- %

function check_denoise_err(ME)

% Setup a list of known errors that occur when files are missing
knownErrs = {'MATLAB:load:couldNotReadFile', 'MATLAB:UndefinedFunction'};

% Prepare a list of required functions etc
fcnList = {...
    'VBM3D.m', 'BM3D'; ...
    ['bm3d_thr_video.' mexext], 'BM3D';
    ['bm3d_wiener_video.' mexext]', 'BM3D';
    'Anscombe_forward.m', 'invansc';
    'Anscombe_inverse_exact_unbiased.m', 'invansc';
    'Anscombe_vectors.mat', 'invansc';
    'GenAnscombe_forward.m', 'invansc';
    'GenAnscombe_inverse_exact_unbiased.m', 'invansc';
    'GenAnscombe_vectors.mat', 'invansc'};
fcnList = fcnList';
strFcn = sprintf('\t%s (%s)\n', fcnList{:});

% Check if the error that occurred was one of them, and if so throw and
% appropriate error
if ismember(ME.identifier, knownErrs)
    error('BioFormats:LibNotFound', ['One or more of the required ' ...
        'denoising functions was not found on the path. Please download ', ...
        'them from http://www.cs.tut.fi/~foi/GCF-BM3D/ and/or ', ...
        'http://www.cs.tut.fi/~foi/invansc/, install them, and add them to ' ...
        'your MATLAB path before using the denoising functions.\n\n' ...
        'Alternatively, you may use the utility function ' ...
        '"utils.install_denoise()" to do this automatically.\n\n' ...
        'Note, if installing manually, only the following files are '...
        'required, with the parent package indicated in parentheses.' ...
        '\n\n%s'], strFcn(1:end-1));
else
    rethrow(ME)
end

end
