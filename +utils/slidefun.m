function R = slidefun (FUN, W, V, windowmode, varargin) 
% SLIDEFUN - apply function to a moving window over a vector
%
%   R = SLIDEFUN(FUN, W, V) evaluates the function FUN to a moving window
%   of W consecutive elements of the vector V. The function FUN is
%   specified by a function handle or a function name and should return a
%   scalar for a vector input. W specifies the size of the window and
%   should be a positive integer. At the two edges of the vector less than
%   W elements will be used. R will have the same size as V, but V is
%   always treated as vector (as V(:)).
%
%   Effectively SLIDEFUN applies the function FUN to a moving window of
%   consecutive elemens V(x0:(x0+W)) using FEVAL, and returns the result in
%   R(x).
%
%   The window [x0:(x0+W)] is positioned relative to the current point x in V. 
%   R = SLIDEFUN(FUN, W, V, WINDOWMODE) denotes the type of windowing being
%   used. WINDOWMODE can be (the first letters of) one the following:
%       - 'central', or '' (default): the window is centered around each point,
%          so that x0 equals x - floor(W/2);
%       - 'backward': window is using W points before the current point, so
%          that x0 equals x-W+1
%       - 'forward': window is using W points following the current point,
%          so that x0 equals x
%
%  R = SLIDEFUN(FUN,W,V,WINDOWMODE, P1,P2,...) provides for aditional
%  parameters which are passed to the function FUN. 
%   
%   Example 1) Sliding max filter - return the maximum of every three
%   consecutive elements:
%      V =  [1  2  3  9  4  2  1  1  5  6] ;
%      R = slidefun(@max, 3, V)
%      % -> [2  3  9  9  9  4  2  5  6  6]
%      % So R(i) = max(R(i-1:i+1)) ;
%      % and R(1) = max(V(1:2))
%
%   Example 2) Sum every four consecutive elements
%      V =  [1  2  3  4  3  2  1] ;
%      R = slidefun('sum',4, V) 
%      % -> [3  6 10 12 12 10  6]
%      % So R(i) = sum(R(i-2:i+1)) ;
%      %    R(1) = sum([1 2]) ; 
%      %    R(2) = sum([1 2 3]) ;
%   
%   Example 3) Range of every three consecutive elements
%      myfun = inline('max(x) - min(x)','x') ; % (Matlab R13)
%      V =  [1  4  3  3  3  2  9  8] ;
%      R = slidefun(myfun,3, V) 
%      % -> [3  3  1  0  1  7  7  1]
%
%   Example 4) Mimick cumsum
%      V = 1:10 ;
%      R = slidefun(@sum, numel(V), V, 'backward') 
%      isequal(R,cumsum(V))
%
%   Example 5) Inverse cumprod ignoring zeros
%      V = [1:3 0 5:8] ;
%      myfun = inline('prod(x(x~=0))','x') ;
%      R = slidefun(myfun, numel(V), V, 'forward') 
%
%   Example 6) Replace values when they are outliers given their enighbours
%      V =   [1  1  2  3  8  4  5  4  4  6  5  7  8  9] ; % 5th value (10) is an outlier
%      N = 2 ; % window of 2*2+1  = 5 elements, central element has index N+1
%      isoutlier = slidefun(@(V,N) abs(V(N)-mean(V)) > 1.5*std(V), 2*N+1, V, [] ,N+1) 
%      % ->  [0  0  0  0  1  0  0  0  0  0  0  0  0]
%      V(isoutlier) = NaN
%
%   Note that for some specific functions (e.g., MEAN) filter can do the
%   same job faster. See FEVAL for more information about passing
%   functions.
%
%   See also FEVAL, INLINE, FILTER, BOOTSTRP
%   and Function handles, Anonymous functions.

% Written and tested in Matlab R2014a
% version 4.1 (feb 2015)
% (c) Jos van der Geest
% email: jos@jasen.nl

% History
% 1.0 (sep 2006). This file was inspired by a post on CSSM in sep 2006.
% 2.0 (oct 2006). Use for-loop instead of large matrices
% 3.0 (oct 2006). Added windowmode option (after File 9428 by John
%                 D'Errico)
% 4.0 (sep 2008). Can now handle (anonymous) function handles properly.
% 4.1 (feb 2015). Treat V as a vector, always & fix narginchk

% check input arguments,expected
% <function name>, <window size>, <vector>, <windowmode>, <optional arguments ...>
narginchk(3,Inf) ;

if nargin==3 || isempty(windowmode),
    windowmode = 'central' ;
end

% based on code by John D'Errico
if ~ischar(windowmode),
    error('WindowMode should be a character array') ;
else
    validmodes = {'central','backward','forward'} ;
    windowmode = strmatch(lower(windowmode), validmodes) ; %#ok
    if isempty(windowmode),
        error('Invalid window mode') ;
    end
end
% windowmode will 1, 2, or 3

if (numel(W) ~= 1) || (fix(W) ~= W) || (W < 1),
    error('Window size W must be a positive integer scalar.') ;
end

nV = numel(V) ;

if isa(FUN,'function_handle')
    FUNstr = func2str(FUN);
end

if nV==0,
    % trivial case
    R = V ;
    return
end

% make V a vector
szV = size(V) ;
V = V(:) ; 

% can the function be applied succesfully?
try
    R = feval(FUN,V(1:min(W,nV)),varargin{:}) ;
    % feval did ok. Now check for scalar output
    if numel(R) ~= 1,
        error('Function "%s" does not return a scalar output for a vector input.', FUNstr) ;
    end
    
catch
    % Rewrite the error, likely to be caused by feval
    % For instance, function expects more arguments, ...    
    ERR = lasterror ;
    if numel(varargin)>0,
        ERR.message = sprintf('%s\r(This could be caused by the additional arguments given to %s).',ERR.message, upper(mfilename)) ;
    end
    rethrow(ERR) ;
end % try-catch

% where is the first relative element
switch windowmode 
    case 1 % central
        x0 = -floor(W/2) ;
    case 2 % backward
        x0 = -(W-1) ;
    case 3 % forward
        x0 = 0 ;
end
x1 = x0+W-1 ; % last relative element
x = x0:x1 ; % window vector (has W elements)

R = R(ones(size(V))) ; % pre-allocation !!

% The engine: seperation in three sections is faster than using a single
% loop with calls to min and max. 

% 1. leading elements
iend = min(-x0,nV-x1) ; % what is the last leading element, note that this might not exist
for i=1:iend,
    R(i) = feval(FUN,V(1:i+x1),varargin{:}) ;
end

% 2. main portion of V, start were section 1 finished
for i=(iend+1):(nV-x1),
    R(i) = feval(FUN,V(x+i),varargin{:}) ;
end

% 3. trailing elements, start were section 2 finished
for i=(i+1):nV,
    R(i) = feval(FUN,V((i+x0):nV),varargin{:}) ;
end

% Almost done. Just reshape back into the right size
R = reshape(R, szV) ;