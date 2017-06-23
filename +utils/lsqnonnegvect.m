function [x,resnorm,resid,exitflag,output,lambda] = lsqnonnegvect(C,d, options, varargin)
    %LSQNONNEGVECT Partly vectorized linear least squares with nonnegativity constraints based on
	%   MATLAB function lsqnonneg.
	%   
    %   X = LSQNONNEGVECT(C,d) returns the matrix X, of which the kth column minimizes
	%   NORM(d(:,k)-C*X(:,k)) subject to X >= 0. C and d must be real. Each column of d corresponds
	%   to a distinct linear least squares problem
	%
	%   X = LSQNONNEGVECT(C,d,OPTIONS) minimizes with the default optimization
	%   parameters replaced by values in the structure OPTIONS, an argument
	%   created with the OPTIMSET function.  See OPTIMSET for details. Used
	%   options are Display and TolX. (A default tolerance TolX of
	%   10*MAX(SIZE(C))*NORM(C,1)*EPS is used.)
	%
	%   X = LSQNONNEGVECT(PROBLEM) finds the minimum for PROBLEM. PROBLEM is a
	%   structure with the matrix 'C' in PROBLEM.C, the vector 'd' in
	%   PROBLEM.d, the options structure in PROBLEM.options, and solver name
	%   'lsqnonneg' in PROBLEM.solver. The structure PROBLEM must have all the
	%   fields.
	%
	%   [X,RESNORM] = LSQNONNEGVECT(...) also returns the value of the squared 2-norm of
	%   the residual: norm(d-C*X)^2.
	%
	%   [X,RESNORM,RESIDUAL] = LSQNONNEGVECT(...) also returns the value of the
	%   residual: d-C*X.
	%
	%   [X,RESNORM,RESIDUAL,EXITFLAG] = LSQNONNEGVECT(...) returns an EXITFLAG that
	%   describes the exit condition of LSQNONNEGVECT. Possible values of EXITFLAG and
	%   the corresponding exit conditions are
	%
	%    1  LSQNONNEGVECT converged with a solution X.
	%    0  Iteration count was exceeded. Increasing the tolerance
	%       (OPTIONS.TolX) may lead to a solution.
	%
	%   [X,RESNORM,RESIDUAL,EXITFLAG,OUTPUT] = LSQNONNEGVECT(...) returns a structure
	%   OUTPUT with the number of steps taken in OUTPUT.iterations, the type of
	%   algorithm used in OUTPUT.algorithm, and the exit message in OUTPUT.message.
	%
	%   [X,RESNORM,RESIDUAL,EXITFLAG,OUTPUT,LAMBDA] = LSQNONNEGVECT(...) returns
	%   the dual vector LAMBDA  where LAMBDA(i) <= 0 when X(i) is (approximately) 0
	%   and LAMBDA(i) is (approximately) 0 when X(i) > 0.
	%
	%   See also LSQNONNEG.
	
	%   version 1.0, 2014-08-06
	%   version 1.1, 2016-09-13 : Fixed a bug to avoid calling Punique with empty matrix (inner
	%                             loop)
	
	%   Adapted by David Provencher (Université de Sherbrooke, d.provencher@usherbrooke.ca)
	%   from the following version of Matlab's lsqnonneg function :
	%   $Revision: 1.15.4.14 $  $Date: 2009/11/16 22:27:07 $
	
	% Reference:
	%  Lawson and Hanson, "Solving Least Squares Problems", Prentice-Hall, 1974.
	
	% Check if more inputs have been passed. In that case error.
	if nargin > 4
		error('MATLAB:lsqnonneg:TooManyInputs', ...
			'Too many input arguments.');
	end
	
	defaultopt = struct('Display','notify','TolX','10*eps*norm(C,1)*length(C)');
	% If just 'defaults' passed in, return the default options in X
	if nargin == 1 && nargout <= 1 && isequal(C,'defaults')
		x = defaultopt;
		return
	end
	
	% Detect problem structure input
	if nargin == 1
		if isa(C,'struct')
			[C,d,options] = separateOptimStruct(C);
		else % Single input and non-structure.
			error('MATLAB:lsqnonneg:InputArg', ...
				['The input should be either a structure with valid ',...
				'fields or at least two arguments to LSQNONNEGVECT.']);
		end
	end
	
	if nargin == 0
		error('MATLAB:lsqnonneg:NotEnoughInputs','LSQNONNEGVECT requires at least two input arguments.');
	end
	
	if ~isreal(C) || ~isreal(d),
		error('MATLAB:lsqnonneg:ComplexCorD', 'C and d must be real.');
	end
	
	% Check for non-double inputs
	if ~isa(C,'double') || ~isa(d,'double')
		error('MATLAB:lsqnonneg:NonDoubleInput', ...
			'LSQNONNEGVECT only accepts inputs of data type double.')
	end
	
	if nargin > 2
		% Check for deprecated syntax
		options = deprecateX0(options,nargin,varargin{:});
	else
		% No options passed, set to empty
		options = [];
	end
	
	printtype = optimget(options,'Display',defaultopt,'fast');
	tol = optimget(options,'TolX',defaultopt,'fast');
	
	% In case the defaults were gathered from calling: optimset('lsqnonneg'):
	if ischar(tol)
		if strcmpi(tol,'10*eps*norm(c,1)*length(c)')
			tol = 10*eps*norm(C,1)*length(C);
		else
			error('MATLAB:lsqnonneg:OptTolXNotPosScalar',...
				'Option ''TolX'' must be an positive scalar if not the default.')
		end
	end
	
	switch printtype
		case {'notify','notify-detailed'}
			verbosity = 1;
		case {'none','off'}
			verbosity = 0;
		case {'innerIter','innerIter-detailed'}
			warning('MATLAB:lsqnonneg:InvalidDisplayValueIter', ...
				'''innerIter'' value not valid for ''Display'' parameter for LSQNONNEGVECT.')
			verbosity = 3;
		case {'final','final-detailed'}
			verbosity = 2;
		otherwise
			error('MATLAB:lsqnonneg:InvalidOptParamDisplay',...
				'Bad value for options parameter: ''Display''.');
	end
	
	nModel = size(C,2);
	nData = size(d,2);
	% Initialize vector of nModel zeros and Infs (to be used later)
	nZeros = zeros(nModel,nData);
	
	% initilaize flag to indicate variables for which optimization is complete
	outerOptimDone = false(1,nData);
	dataVect = 1:nData;
	
	% Initialize set of non-active columns to null
	P = false(nModel,nData);
	% Initialize set of active columns to all and the initial point to zeros
	Z = true(nModel,nData);
	x = nZeros;
	
	resid = d - C*x;
	w = C'*resid;
	
	% Set up iteration criterion
	outerIter = 0;
	innerIter = 0;
	
	itmax = 3*nModel;
	exitflag = 1;
	
	% Data vectors with only zero or negative values do not need to be fitted
	zeroFitMask = sum(abs(w),1) <= tol;
	dataVectLeft = dataVect(~zeroFitMask);
	nDataLeft = numel(dataVectLeft);
	
	% Outer loop to put variables into set to hold positive coefficients
	while nDataLeft > 0 % any(~outerOptimDone)
		outerIter = outerIter + 1;
		
		% Reset intermediate solution z
		z = zeros(nModel,nDataLeft);
		
		% Create wz, a Lagrange multiplier vector of variables in the zero set.
		% wz must have the same size as w to preserve the correct indices, so
		% set multipliers to -Inf for variables outside of the zero set.
		wz = -Inf*ones(nModel, nDataLeft);
		wz(Z(:,dataVectLeft)) = w(Z(:,dataVectLeft));
		
		% Find variable for which optimisation is not done with largest Lagrange
		% multiplier for each data vector
		[~,t] = max(wz);
		
		% Faster version of sub2ind(size(wz), t(~outerOptimDone), dataVect(~outerOptimDone));
		ind = t + (dataVectLeft-1)*nModel;
		
		% Move variable t from zero set to positive set
		P(ind) = true;
		Z(ind) = false;
		
		% Compute intermediate solution using only variables in positive set	
		Punique = uniqueCols(P(:,dataVectLeft));
		for k = 1:size(Punique,2)
			modelInd = Punique(:,k);
			colInd = find( all(bsxfun(@eq,P(:,dataVectLeft), modelInd), 1));
			globalInd = dataVectLeft(colInd);
			z(modelInd,colInd) = C(:,modelInd)\d(:,globalInd);
		end

		innerOptimDone = outerOptimDone;
		
		% inner loop to remove elements from the positive set which no longer
		% belong
		while any(z(P(:,dataVectLeft)) <= tol)
			innerIter = innerIter + 1;
			if innerIter > itmax
				msg = sprintf(['Exiting: Iteration count is exceeded, exiting LSQNONNEGVECT.', ...
					'\n','Try raising the tolerance (OPTIONS.TolX).']);
				if verbosity
					disp(msg)
				end
				exitflag = 0;
				output.iterations = outerIter;
				output.message = msg;
				output.algorithm = 'active-set';
				resnorm = sum(resid.*resid);
				x = z;
				lambda = w;
				return
			end
			% Find indices where intermediate solution z is approximately negative
			Q = (z <= tol) & P(:,dataVectLeft);
			
			% This is equivalent to the lsqnonneg line alpha = min(x(Q)./(x(Q) - z(Q))) 
			% since Q here can have multiple columns
			% Although a bit obscure, it can be 100-1000x faster than doing it in a loop
			[~,indx] = find(Q);
			alpha = NaN*ones(1,nDataLeft);
			ind = unique(indx);
			ind2 = dataVectLeft(ind);
			alpha(ind) = min(x(:,ind2).*Q(:,ind) ./ (x(:,ind2).*Q(:,ind) - z(:,ind).*Q(:,ind)), [],1);

			ind = isnan(alpha);
			innerOptimDone(dataVectLeft(ind)) = true;
			x(:,dataVectLeft(ind)) = z(:,ind);
			x(:,dataVectLeft(~ind)) = x(:,dataVectLeft(~ind)) + bsxfun(@times, (z(:,~ind) - x(:,dataVectLeft(~ind))), alpha(~ind));
			
			dataVectLeft = dataVectLeft(~ind);
			nDataLeft = length(dataVectLeft);
			
			% Reset Z and P given intermediate values of x
			Z(:,dataVectLeft) = ((abs(x(:,dataVectLeft)) < tol) & P(:,dataVectLeft)) | Z(:,dataVectLeft);
			P(:,dataVectLeft) = ~Z(:,dataVectLeft);
			z = zeros(nModel,nDataLeft);
			
			% Re-solve for z in unfinished optimizations. Skip if all ind were NaN (in that case,
			% all alpha are NaN too)
			if ~isempty(dataVectLeft) 
				Punique = uniqueCols(P(:,dataVectLeft));
				
				for k = 1:size(Punique,2)
					modelInd = Punique(:,k);
					colInd = find( all(bsxfun(@eq,P(:,dataVectLeft), modelInd), 1));
					globalInd = dataVectLeft(colInd);
					z(modelInd,colInd) = C(:,modelInd)\d(:,globalInd);
				end
			end
		end
		x(:,dataVectLeft) = z(:,1:nDataLeft);
		
		% Slow
		dataVectLeft = dataVect(~outerOptimDone);
		nDataLeft = length(dataVectLeft);
		
		resid = d(:,dataVectLeft) - C*x(:,dataVectLeft);
		w = C'*resid;
		
		doneFlag = false(1,nDataLeft);
		doneFlag(~any(Z(:,dataVectLeft),1) | ~any(w.*Z(:,dataVectLeft) > tol, 1)) = true;
		
		outerOptimDone(dataVectLeft) = doneFlag;
		
		% Remove values in w which are no longer necessary
		w = w(:,~doneFlag);
		dataVectLeft = dataVectLeft(~doneFlag);
		nDataLeft = length(dataVectLeft);
		innerIter = 0;
	end
	% Recompute residual using all data vectors
	resid = d - C*x;
	resnorm = sum(resid.^2);
	lambda = C'*resid;
	
	output.iterations = outerIter;
	output.algorithm = 'active-set';
	msg = 'Optimization terminated.';
	if verbosity > 1
		disp(msg)
	end
	output.message = msg;
end
%--------------------------------------------------------------------------
function options = deprecateX0(options,numInputs,varargin)
	% Code to check if user has passed in x0. If so, ignore it and warn of its
	% deprecation. Also check whether the options have been passed in either
	% the 3rd or 4th input.
	x0DeprecationStr = xlate(['Ignoring input argument X0. The input for X0 will be ', ...
		'removed in a future release. See the help for valid syntax.']);
	x0DeprecationID = 'MATLAB:lsqnonneg:ignoringX0';
	if numInputs == 4
		% 4 inputs given; the 3rd (variable name "options") will be interpreted
		% as x0, and the 4th as options
		if ~isempty(options)
			% x0 is non-empty
			warning(x0DeprecationID,x0DeprecationStr);
		end
		% Take the 4th argument as the options
		options = varargin{1};
	elseif numInputs == 3
		% Check if a non-empty or non-struct has been passed in for options
		% If so, assume that it's an attempt to pass x0
		if ~isstruct(options) && ~isempty(options)
			warning(x0DeprecationID,x0DeprecationStr);
			% No options passed, set to empty
			options = [];
		end
	end
end
%--------------------------------------------------------------------------
% Find unique columns of a matrix
function uniqueCols = uniqueCols(A)
	[srtX, srtIdx] = sortrows(A');
	dX = diff(srtX, 1, 1);
	unqIdx = [true; any(dX, 2)];

	uniqueCols = A(:,srtIdx(unqIdx));
end
