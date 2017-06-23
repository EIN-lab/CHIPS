function varargout = verify_license(feature, className, varargin)
%verify_license - Verify that a particular licence is available
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
narginchk(2, 4);

% Parse arguments
[toolboxdir, verNum] = utils.parse_opt_args({[], []}, varargin);

flag = 1;

% Check that a licence exists
[status, errmsg] = license('checkout', feature);
if ~status
    flag = -1;
    warning([className ':NoToolbox'], ['Could not checkout a licence ' ...
        'for the feature "%s". The licence manager returned the ' ...
        'following warning:\n\n\t\n\nAny errors following this warning ' ...
        'may be related to the missing license.'], feature, errmsg)
end

% Optionally check that the version is correct
checkVersion = status && ~isempty(toolboxdir) && ~isempty(verNum);
if checkVersion
    isBadVersion = verLessThan(toolboxdir, verNum);
    if isBadVersion
        verDetails = ver(toolboxdir);
        warning([className ':BadToolbox'], ['The available version for ' ...
        'the "%s" (%s) is less than the recommended version (%s). Any ' ...
        'errors, warnings, or unusual performance may be related to ' ...
        'the older license.'], verDetails.Name, verDetails.Version, verNum)
        flag = 0;
    end
end

% Pass the arguments out if necessary
if nargout > 0
    varargout{1} = flag;
end
            
end
