function tf = is_on_worker()
%is_on_worker - Is the current execution occurring on a parallel worker
%
%   TF = is_on_worker() returns a binary flag specifying whether the
%   current execution is taking place on a parallel pool worker.
%
%   See also getCurrentTask, gcp, parpool

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
narginchk(0, 0);

try
    tf = ~isempty(getCurrentTask());
catch err
    if ~strcmp(err.identifier, 'MATLAB:UndefinedFunction')
        rethrow(err);
    end
    tf = false;
end
    
end