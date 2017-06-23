function varargout = exclude_frames(self, badFrames, varargin)
%exclude_frames - Excludes the specified frame(s) from the image
%
%   exclude_frames(OBJ) excludes the first frame.
%
%   exclude_frames(OBJ, BADFRAMES) excludes BADFRAMES.
%
%   exclude_frames(..., 'attribute', value) specifies one or more
%   attribute/value pairs.  Valid attributes (case insensitive) are:
%
%       method ->   String indicating method to use. options are 'nan' and
%                   'inpaint'. [default = 'nan']
%
%       inpaintIters -> The number of iterations to perform when
%                   inpainting. [default = 5]
%
%   See also utils.inpaintn

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

% Define the allowed optional arguments and default values, and create
% a default parameters structure
pnames = {'method', 'inpaintIters'};
dflts  = {'nan', 5};
params = cell2struct(dflts, pnames, 2);

% Parse function input arguments
paramsIn = utils.parsepropval(params, varargin{:});

% Check the badFrames
if nargin > 1
    utils.checks.positive(badFrames, 'badFrames');
    utils.checks.finite(badFrames, 'badFrames');
    utils.checks.real_num(badFrames, 'badFrames');
    utils.checks.integer(badFrames, 'badFrames');
    utils.checks.single_row(badFrames, 'badFrames');
else
    badFrames = 1;
end

% Check the method
utils.checks.single_row_char(params.method, 'method');

% Check the inpaintIters
utils.checks.prfsi(params.inpaintIters, 'inpaintIters');

% Check if function is called on array
if ~isscalar(self)

    % Work out number of objects
    lnObj = length(self);

    % Process each of the objects
    for iObj = 1:lnObj
        self(iObj).exclude_frames(paramsIn);
    end

    return

else

    % Check frames exist
    if any(badFrames) > self.metadata.nFrames
        error('RawImg:ExcludeFrames:BadFrameNum', ['You ', ...
            'want to exclude frames %s, but the image only has %s', ...
            ' frames.'], ...
            num2str(badFrames), ...
            num2str(self.metadata.nFrames))
    end

    % Convert to double
    self.rawdata = double(self.rawdata);

   % Which method to use
    switch lower(paramsIn.method)

        case {'nan', 'inpaint'}

            % Replace specified frames with NaN
            self.rawdata(:,:,:,badFrames) = nan;

        otherwise

            warning('RawImg:ExcludeFrames:BadFillMethod', ['The method ' ...
                '"%s" to fill bad data is not recognised.  Using "nan" ' ...
                'instead.'], paramsIn.method)
            self.rawdata(:,:,:,badFrames) = nan;

    end

    % Inpaint the NaNs if necessary
    if strcmpi(paramsIn.method, 'inpaint')

        hasInpaintIters = ~isempty(paramsIn.inpaintIters);
        if ~hasInpaintIters
            paramsIn.inpaintIters = 5;
        end

        for iCh = 1:self.metadata.nChannels
            corrSeq = squeeze(self.rawdata(:,:,iCh,:));
            corrSeq = utils.inpaintn(corrSeq, paramsIn.inpaintIters);
            self.rawdata(:,:,iCh,:) = corrSeq;
        end
    end

    % Pass the output argument, if necessary
    if nargout > 0
        varargout{1} = self;
    end

end

end
