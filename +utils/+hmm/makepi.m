function [ Pnew ] = makepi( P,  trans_prob)
%makepi - Calculate probability matrix
%
%   This function serves as basis for the MEX-file makepi_mex. Use codegen
%   makepi.m to compile the mex file.
%
%   See also utils.hmm

% Checks for P
assert ( isa ( P, 'double') )
assert(all(size(P)<=[1 1681]));

% Checks for trans_prob
assert ( isa ( trans_prob, 'double') )
assert(all(size(trans_prob)<=[1681 1681]));

Prep=repmat(P,size(trans_prob,1),1);
%calculate the matrix of probabilities of being in one state at
%the previous time point and then transitioning to another
Pnew=Prep+trans_prob;

end

