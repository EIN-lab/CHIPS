function varargout = get_diamProfile(~, objPI, varargin)
%get_diamProfile - Get the profile needed to process linescans
%
%   [PROFILE, LINE_RATE] = get_diamProfile(OBJ) returns the image
%   profile needed to calculate diameter, along with the line rate
%   of the profile [Hz].
%
%   See also CalcDiameterLong, ICalcDiameterLong

% Setup the default parameter names and values
pNames = {
    'mode'; ...
    };
pValues = {
    'default'; ...
    };
dflts = cell2struct(pValues, pNames);
params = utils.parse_params(dflts, varargin{:});

channelToUse = objPI.channelToUse;
dims = size(objPI.rawImg.rawdata);

% Two modes:
% 'full' will return a 1-by-nFrames*nLinesPerFrame image
% 'average' will return a 1-by-nFrames image and average nLinesPerFrame for
% each frame
switch lower(params.mode)
    case 'full'
        diamProfile = reshape(permute(objPI.rawImg.rawdata(:, :, ...
            channelToUse,:), [1 4 2 3]), [dims(1)*dims(4), dims(2)]);
        diamProfile = permute(diamProfile, [3, 2, 1]);
        lineRate = 1/(objPI.rawImg.metadata.lineTime*1E-3);
        
    case {'average', 'default'}
        diamProfile = permute(mean(objPI.rawImg.rawdata(:, :, channelToUse, ...
            :),1), [1 2 4 3]);
        lineRate = (1/(objPI.rawImg.metadata.lineTime*1E-3))/dims(1);
        
    otherwise
        error('ClacFindROIsFLIKA:get_diamProfile:UnknownMode', ...
            ['Mode ''%s'' unknown. Known modes are ''average'' and ', ...
            '''full''.'], mode)
end

varargout{1} = diamProfile;
varargout{2} = lineRate;

end