function y = nanmean(x,dim,ignoreinf)
% FORMAT: Y = NANMEAN(X,DIM,IGNORE_INF)
% 
%    Average or mean value ignoring NaNs
%
%    This function enhances the functionality of NANMEAN as distributed in
%    the MATLAB Statistics Toolbox and is meant as a replacement (hence the
%    identical name).  
%
%    NANMEAN(X,DIM) calculates the mean along any dimension of the N-D
%    array X ignoring NaNs.  If DIM is omitted NANMEAN averages along the
%    first non-singleton dimension of X.
%
%	 NANMEAN(X,DIM,IGNORE_INF) is a binary flag specifying whether to
%	 ignore Inf values as well as NaNs. If IGNORE_INF is omitted NANMEAN
%	 does not ignore Inf values.
%
%    Similar replacements exist for NANSTD, NANMEDIAN, NANMIN, NANMAX, and
%    NANSUM which are all part of the NaN-suite.
%
%    See also MEAN

% -------------------------------------------------------------------------
%    author:      Jan Gläscher
%    affiliation: Neuroimage Nord, University of Hamburg, Germany
%    email:       glaescher@uke.uni-hamburg.de
%    
%    $Revision: 1.1 $ $Date: 2004/07/15 22:42:13 $
%
%    Some modifications by Matthew J.P. Barrett, Kim David Ferrari et al.

if isempty(x)
	y = NaN;
	return
end

if nargin < 2 || isempty(dim)
	dim = min(find(size(x)~=1));
	if isempty(dim)
		dim = 1;
	end
end

if nargin < 3 || isempty(ignoreinf)
    ignoreinf = false;
end

% Replace NaNs (and perhaps Infs with zeros.
if ~ignoreinf
    nans = isnan(x);
else
    nans = ~isfinite(x);
end
x(nans) = 0; 

% denominator
count = size(x,dim) - sum(nans,dim);

% Protect against a  all NaNs in one dimension
i = find(count==0);
count(i) = ones(size(i));

y = sum(x,dim)./count;
y(i) = i + NaN;



% $Id: nanmean.m,v 1.1 2004/07/15 22:42:13 glaescher Exp glaescher $
