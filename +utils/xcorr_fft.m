function cc = xcorr_fft(aa, bb)
%xcorr_fft - Calculates the xcorr of two vectors using the fft based method
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

% Ensure the inputs are shaped correctly
aa = aa(:);
bb = bb(:);

% Perform FFT on the inputs, with appropriate zero padding
nn = numel(aa);
nfft = 2^nextpow2(2*nn - 1); % assume aa and bb are the same length
aa_fft = fft(aa, nfft);
bb_fft = fft(bb, nfft);

% % Create a filter to reduce some cross correlation artefacts
% ww = 1./(sqrt(abs(aa_fft)).*sqrt(abs(bb_fft)));
% ww(isinf(ww)) = 0;

% Calculate the cross correlation, and remove the zero padding
cc = ifft(aa_fft.*conj(bb_fft));
% cc = ifft(aa_fft.*conj(bb_fft).*ww);
cc = [cc(end-nn+2:end) ; cc(1:nn)];

end
