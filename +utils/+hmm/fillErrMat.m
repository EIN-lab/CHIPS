function [errMat, subCoords] = fillErrMat( iFrame, ...
    chSeq, refImg, maxDy, maxDx, Ny, Nx, numLines)
%fillErrMat - helper function conforming to parfor
%   This function calculates absolute error of all possible considered ...
%vertical and horizontal shifts

totLines = (numLines - 2*maxDy);
subCoords = zeros(totLines, Nx);
errMat = zeros(totLines, Ny, Nx);

for jLine = 1+maxDy:numLines-maxDy

    % Pull out the line we are placing
    currLine = squeeze(chSeq(iFrame, jLine, :));

    for shift=-maxDx:maxDx
        %pick out the size of the image
        [N, M] =size(refImg); % Allow images that are not square!

        %what is the topline and the bottomline considered
        topline=max(1,jLine-maxDy);
        bottomline=min(N,jLine+maxDy);
        %this check is a remenant of older versions which allowed lines to be
        %placed that were near the edges of the image.
        %topline and bottomline should always be j-maxdy and j+maxdy respectively
        %now..

        %pick out the section of currLine which we will be considering
        %edge pixels are not considered so that the same number of pixels are
        %fit for each offset
        start=1+maxDx;
        ending=M-maxDx;
        F=currLine(start:ending);

        %pick out the range of pixels in X out of the reference image which we will
        %be considering for this particular fit.
        start2=1+maxDx+shift;
        ending2=M-maxDx+shift;

        %pick out that section of the reference image which we will be aligning
        %to for this particular X offset.. we do all Y offsets considered
        %simultaneously in this implementation
        G=refImg(topline:bottomline,start2:ending2);

        %repeat the line we are fitting for all the possible Y offsets
        F=repmat(F',size(G,1),1);

        %calculate the fit in terms of a log probability for each pixel in the
        %calculation
        try
            % See eq. 7 in Chen, 2011, probably eq. 5
            temp = (1/length(start:ending)).*abs(F-G);
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
        errMat(jLine-maxDy, :,  shift+maxDx+1) = sum(temp,2);
        % Save location of current error
        subCoords(jLine-maxDy, shift+maxDx+1) = shift;
        
    end
end
