function ch_calc(self, ff, chNums, varargin)
%ch_calc - Perform mathematical calculations on image channels
%
%   ch_calc(OBJ, F, CH_NUMS) calculates a new channel based on the function
%   F applied to the channel numbers specified by CH_NUMS, and merges it
%   into the existing image data.
%   F must be a function handle that accepts numel(CH_NUMS) image channels
%   as arguments and returns an array the size of one channel.
%   CH_NUMS must be a vector specifying the image channels to supply to the
%   function F, in the order that they should be supplied. For example:
%
%       ch_calc(OBJ, @(CH_A, CH_B) CH_A + CH_B, [3, 4]) adds channel 3 to
%           channel 4, and
%       ch_calc(OBJ, @(CH_A) CH_A.^2, 2) squares the elements of channel 2.
%
%   ch_calc(OBJ, F, CH_NUMS, CH_NAME) specifies the name of the new image
%   channel.  CH_NAME must be a single row character array specifying a
%   valid channel name (i.e. one that is known to the Metadata class).
%
%   ch_calc(OBJ, F, CH_NUMS, CH_NAME, NEW_CLASS) casts the image raw data
%   to class NEW_CLASS before evaluating the function.
%
%   IMPORTANT NOTE: Specifying an appropriate numerical class can be
%   critical to avoid numerical overflow or loss of precision if the raw
%   data is stored in an integer format.
%
%   Please see the <a href="matlab:web(fullfile(utils.CHIPS_rootdir, 'doc', 'html', 'id_pp_utilities.html'))">pre-processing utilities quick start guide</a> for 
%   additional documentation and examples.
%
%   See also RawImg.ch_calc_ratio, RawImg.ch_calc_sum, RawImg.split1,
%   RawImg.cat_data, Metadata.choose_channel

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
narginchk(3, 5);

% Call the function one by one if we have an array
if ~isscalar(self)
    arrayfun(@(xx) ch_calc(xx, ff, chNums, varargin{:}), self);
    return
end

% Parse optional arguments
[chName, newClass] = utils.parse_opt_args({'', ''}, varargin);

% Check that the function is a scalar function handle
utils.checks.scalar(ff, 'function');
utils.checks.object_class(ff, 'function_handle', 'function');

% Check that the chNums is a vector of integers, and that the numbers are
% all within the range of channels that we have
utils.checks.vector(chNums)
utils.checks.integer(chNums)
allowEq = true;
ME = utils.checks.less_than(max(chNums), self.metadata.nChannels, allowEq);
if ~isempty(ME)
    error('RawImg:ChCalc:NotEnoughChs', ['The list of channel numbers ' ...
        'contains values that are larger than the number of image ' ...
        'channels (%d)'], self.metadata.nChannels)
end

% Choose a channel name if one is not supplied, or check that the channel
% is of the correct format and known
if isempty(chName)
    strMenu = 'What is shown on the new channel?';
    chName = Metadata.choose_channel([], strMenu);
else
    utils.checks.single_row_char(chName, 'channel name');
    isValidCh = ismember(chName, Metadata.knownChannels);
    if ~isValidCh
        error('RawImg:ChCalc:UnknownCh', ['The channel name "%s" is ' ...
            'not recognised'], chName)
    end
end

% Check that the new class name is of the right format and valid
doCastClass = false;
if ~isempty(newClass)
    utils.checks.single_row_char(newClass, 'channel name');
    validClasses = {'double', 'single', 'int8', 'uint8', 'int16', ...
        'uint16', 'int32', 'uint32', 'int64', 'uint64'};
    isMember = ismember(newClass, validClasses);
    if ~isMember
        error('RawImg:ChCalc:BadNewClass', ['The newClass must be a ' ...
            'valid numeric class name (e.g. "double", "uint16")'])
    end
    doCastClass = true;
end

%%

% Prepare a list of channels to supply to the function
nChArgs = numel(chNums);
chList = cell(1, nChArgs);
for iChArg = 1:nChArgs
    if doCastClass
        chList{iChArg} = cast(self.rawdata(:,:,chNums(iChArg),:), newClass);
    else
        chList{iChArg} = self.rawdata(:,:,chNums(iChArg),:);
    end
end

% Evaluate the function
newCh = feval(ff, chList{:});

% Add the new data to the existing data
chsOld = self.metadata.nChannels;
if doCastClass
    self.rawdata = cast(self.rawdata, newClass);
end
self.rawdata = cat(3, self.rawdata, newCh);

% Create the new channels structure
chs = self.metadata.channels;
chs.(chName) = chsOld + 1;

% Update the metadata
acq = self.metadata.get_acq();
cal = self.metadata.calibration;
self.metadata = Metadata(size(self.rawdata), acq, chs, cal);

end
