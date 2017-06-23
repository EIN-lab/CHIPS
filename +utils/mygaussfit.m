function [sigma, mu, AA] = mygaussfit(xx, yy)
%fit_gauss - Gaussian peak fitting helper function
%
%	[SIGMA, MU, A] = fit_gauss(X, Y) performs a fit to the function:
%       Y = A * exp( -(X - MU)^2 / (2*SIGMA^2) )
%
%   The fitting is done by a polyfit to the natural log of the data.

%	Copyright (c) 2007, Yohanan Sivan
%	Some modifications by Matthew J.P. Barrett, Kim David Ferrari et al.

% Check the number of input arguments
narginchk(2, 2);

% Check the input arguments
utils.checks.real_num(xx, 'X')
utils.checks.real_num(yy, 'Y')

% Do the fitting
pp = polyfit(xx(:), log(yy(:)), 2);
sigma = sqrt(-1/(2*pp(1)));
mu = pp(2)*sigma^2;
AA = exp(pp(3)+mu^2/(2*sigma^2));

end
