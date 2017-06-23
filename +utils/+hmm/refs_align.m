function [stilloffsets] = refs_align(stillimages, maxoffset)
%takes a sequence of STILLIMAGES (numstils x N x N) and returns a matrix
%containing the relative offsets between these images in X and Y based upon
%the shift which gives the maximal cross correlational considered only over
%a range (MAXOFFSET) of offsets around zero offset
  
%pull out the number of still and the size of the image
  numstills=size(stillimages,1);
  
  M=size(stillimages,2);
  N=size(stillimages,3);
  
  %how many offsets are you going to consider
  Nx=(2*maxoffset)+1;
  Ny=(2*maxoffset)+1;
  
  %we are aligning them all to the first image, so the offset there is
  %zero,zero by definition
  stilloffsets(1,:)=[0 0];
  %it is the reference image
  refimage=squeeze(stillimages(1,:,:));
  
  %loop over all the other offsets
  for i=2:numstills
    
    %pick out the image we are aligning
    testimage=squeeze(stillimages(i,:,:));
    %initialize the correlation vector
    correlation=zeros(1,Nx*Ny);
    
    %loop over all shifts
    for shiftx=-maxoffset:maxoffset
      for shifty=-maxoffset:maxoffset
          
        %create a hashed index for this combination of x and y offset
        shifthash=((shiftx+maxoffset)*Nx) + (shifty+maxoffset+1);
        %disp(shifthash);
        
        %cut out the section of reference image for this offset
        refimage_cut=refimage(1+maxoffset:M-maxoffset,1+maxoffset:N- ...
                              maxoffset);
                          
        %cut out the section of test image for this offset
        testimage_cut=testimage(1+maxoffset+shifty:M-maxoffset+shifty,1+ ...
                               maxoffset+shiftx:N-maxoffset+shiftx);
                           
        %subtract out the mean from both
        refimage_cut=refimage_cut-mean(mean(refimage_cut));
        testimage_cut=testimage_cut-mean(mean(testimage_cut));
        
        %calculate the cross correlation and store it in the vector using
        %the hash as an index
        correlation(shifthash)=sum(sum(refimage_cut.*testimage_cut));
        
        %I considered using least square difference
        %correlation(shifthash)=mean(mean(abs(refimage_cut-testimage_cut)));
      end
    end
   
    
    %find the maximum correlation
    [~,minshift_hash]=max(correlation);
    
    %reverse the hash to get out the offsets
    minyshift=mod(minshift_hash,Nx);
    minxshift=((minshift_hash-minyshift)/Nx);
    minyshift=minyshift-maxoffset-1;
    minxshift=minxshift-maxoffset;
    %save the offsets
    stilloffsets(i,:)=[minyshift minxshift];
 
  end
  
  