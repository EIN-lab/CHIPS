function probMat = create_PI_markov(lineextract,refimage,maxdx,maxdy,j)
%PI=create_PI_markov(lineextract,refimage,maxdx,maxdy,j)
%take a reference image (REFIMAGE), a line of data to fit (LINEEXTRACT),
%maximum offsets to consider MAXDX, MAXDY, and the expected location of
%that line in y (J) (expected location in x is assumed to at zero offset.

%pick out the size of the image
N=size(refimage,1);

%initialize the probabilities to zero
probMat=zeros(2*maxdy+1,2*maxdx+1);

%what is the topline and the bottomline considered
%this check is a remenant of older versions which allowed lines to be
%placed that were near the edges of the image.
%topline and bottomline should always be j-maxdy and j+maxdy respectively
%now..
topline=max(1,j-maxdy);
bottomline=min(N,j+maxdy);

%loop over all considered x shifts
for shift=-maxdx:maxdx

    %pick out the section of lineextract which we will be considering
    %edge pixels are not considered so that the same number of pixels are
    %fit for each offset
    start=1+maxdx;
    ending=N-maxdx;
    F=lineextract(start:ending);

    %pick out the range of pixels in X out of the reference image which we will
    %be considering for this particular fit.
    start2=1+maxdx+shift;
    ending2=N-maxdx+shift;
    
    %pick out that section of the reference image which we will be aligning
    %to for this particular X offset.. we do all Y offsets considered
    %simultaneously in this implementation
    G=refimage(topline:bottomline,start2:ending2);
    
    %repeat the line we are fitting for all the possible Y offsets
    F=repmat(F',size(G,1),1);
    
    %calculate the fit in terms of a log probability for each pixel in the
    %calculation
    try
        % See eq. 7 in Chen, 2011
        temp=F.*reallog(G)-G;
    catch ME
        if (strcmp(ME.identifier,'MATLAB:reallog:complexResult'))
            msg = 'Likely reason is you provided a bad reference image.';
            causeException = MException(...
                'motion_correction:hmm:ComplexResult',msg);
            ME = addCause(ME,causeException);
        end
        rethrow(ME)
        
    end
    %sum over all the pixels in the line to get the total probability
    % for this X offset over all Y offset considered.
    %stick into the PI matrix in the appropriate spot
    probMat(topline-j+maxdy+1:bottomline-j+maxdy+1,shift+maxdx+1)=sum(temp,2);
end