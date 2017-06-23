function y = nanstd(x,flag,dim)
% FORMAT: Y = NANSTD(X,FLAG,DIM)
% 
%    Standard deviation ignoring NaNs
%
%    This function enhances the functionality of NANSTD as distributed in
%    the MATLAB Statistics Toolbox and is meant as a replacement (hence the
%    identical name).  
%
%    NANSTD(X) calculates the standard deviation along the first
%    non-singleton dimension of the N-D array X, ignoring NaNs.
%
%    NANSTD(X,0) normalizes by (N-1) where N is SIZE(X,DIM).  This make
%    NANSTD(X,0).^2 the best unbiased estimate of the variance if X is
%    a sample of a normal distribution. If omitted FLAG is set to zero.
%
%    NANSTD(X,1) normalizes by N and produces the square root of the
%    second moment of the sample about the mean.
%
%    NANSTD(X,FLAG,DIM) calculates the standard deviation along any
%    dimension of the N-D array X ignoring NaNs.
%
%    Similar replacements exist for NANMEAN, NANMEDIAN, NANMIN, NANMAX, and
%    NANSUM which are all part of the NaN-suite.
%
%    See also STD

% -------------------------------------------------------------------------
%    author:      Jan Gläscher
%    affiliation: Neuroimage Nord, University of Hamburg, Germany
%    email:       glaescher@uke.uni-hamburg.de
%    
%    $Revision: 1.1 $ $Date: 2004/07/15 22:42:15 $
%
%    Some modifications by Matthew J.P. Barrett, Kim David Ferrari et al.

if isempty(x)
	y = NaN;
	return
end

hasDim = (nargin > 2) && ~isempty(dim);
if ~hasDim
	dim = find(size(x)~=1, 1, 'first');
	if isempty(dim)
		dim = 1; 
	end	  
end

hasFlag = (nargin > 1) && ~isempty(flag);
if ~hasFlag
	flag = 0;
end


% Find NaNs in x and nanmean(x)
nans = isnan(x);
avg = utils.nansuite.nanmean(x,dim);

% create array indicating number of element 
% of x in dimension DIM (needed for subtraction of mean)
tile = ones(1,max(ndims(x),dim));
tile(dim) = size(x,dim);

% remove mean
x = x - repmat(avg,tile);

count = size(x,dim) - sum(nans,dim);

% Replace NaNs with zeros.
x(isnan(x)) = 0; 


% Protect against a  all NaNs in one dimension
i = find(count==0);

if flag == 0
	y = sqrt(sum(x.*x,dim)./max(count-1,1));
else
	y = sqrt(sum(x.*x,dim)./max(count,1));
end
y(i) = i + NaN;

% $Id: nanstd.m,v 1.1 2004/07/15 22:42:15 glaescher Exp glaescher $
