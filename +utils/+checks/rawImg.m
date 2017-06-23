function varargout = rawImg(rawImg, varargin)
%rawImg - Check that the value is an appropriate rawImg
%
%   rawImg(val) checks that val is a scalar object of the class
%   RawImgHelper.  If it is, nothing else happens; if it is not, the
%   function throws an exception from the calling function.
%
%   rawImg(val, reqChAll, reqChAny) checks that the val contains all of the
%   channels in reqChAll, and at least one of the channels in reqChAny.
%   Both reqChAll and reqChAny must be either single row char arrays, cell
%   arrays containing single row char arrays, or empty.
%
%   rawImg(val, reqChAll, reqChAll, 'ObjName') includes 'ObjName' in the
%   exception message
%
%   ME = rawImg(...) returns the MException object instead of throwing it
%   internally.  If no exception is created, ME will be an empty array.
%   This can be useful for combining multiple checks while still throwing
%   the exception from the original calling function.
%
%   See also IRawImg, RawImg.check_ch, error, MException,
%   MException.throwAsCaller

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

% Check the number of arguments in
narginchk(1, 4)

% Parse arguments
[reqChannelAll, reqChannelAny, classPI] = ...
    utils.parse_opt_args({'', '', ''}, varargin);

% Initialise the output argument
varargout{1} = [];

% Work out if we want to return any exception or throw it internally
doReturnME = nargout > 0;

%% Check the refImg is a rawImg

varName = 'rawImg';
ME = utils.checks.object_class(rawImg, 'RawImgHelper', varName);
if ~isempty(ME)
    if doReturnME
        varargout{1} = ME;
        return
    else
        throwAsCaller(ME)
    end
end

%% Check that it's scalar

ME = utils.checks.scalar(rawImg, varName);
if ~isempty(ME)
    if doReturnME
        varargout{1} = ME;
        return
    else
        throwAsCaller(ME)
    end
end

%% Check we have all of the "all required" channels

if ~isempty(reqChannelAll)
    ME = rawImg.check_ch(reqChannelAll, 'all', classPI);
    if ~isempty(ME)
        if doReturnME
            varargout{1} = ME;
            return
        else
            throwAsCaller(ME)
        end
    end
end

%% Check we have at least one of the "any required" channels

if ~isempty(reqChannelAny)
    ME = rawImg.check_ch(reqChannelAny, 'any', classPI);
    if ~isempty(ME)
        if doReturnME
            varargout{1} = ME;
            return
        else
            throwAsCaller(ME)
        end
    end
end

end
