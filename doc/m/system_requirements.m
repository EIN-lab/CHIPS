%% System Requirements
%
% CHIPS has been tested on computers running Windows, macOS and several
% Linux distributions, using MATLAB versions R2013a and newer.  CHIPS is
% also expected to run in earlier MATLAB versions; however, this cannot be
% guaranteed since the unit testing framework did not exist prior to
% R2013a.  Every effort has been made to eliminate the use of additional
% MATLAB toolboxes, but it is impractical in certain cases.  In addition,
% while all algorithms work in versions from R2013a, some function better
% in more recent versions.

%% 
% <html><h2>Bio-Formats in MATLAB R2013a</h2></html>
%
% The current Bio-Formats Java library is not compatible with the Java
% version included with MATLAB R2013a (Java 6).  However, there is a
% workaround:
%
% # Download and install the Java Runtime Environment (JRE) version 7 or 8
% from the Oracle
% <http://www.oracle.com/technetwork/java/archive-139210.html website>.
% Make sure to choose the correct JRE version for your platform (i.e. the
% correct operating system and the correct 32/64 bit architecture).  Note:
% it is not necessary to install the complete Java Development Kit, only
% the runtime environment.
% # Follow the instructions on the MathWorks website so that your MATLAB
% installation uses the newly-downloaded JRE.  The instructions are
% slightly different for
% <https://www.mathworks.com/matlabcentral/answers/130359-how-do-i-change-the-java-virtual-machine-jvm-that-matlab-is-using-on-windows
% Windows>,
% <https://www.mathworks.com/matlabcentral/answers/103056-how-do-i-change-the-java-virtual-machine-jvm-that-matlab-is-using-for-mac-os
% macOS> and
% <https://uk.mathworks.com/matlabcentral/answers/130360-how-do-i-change-the-java-virtual-machine-jvm-that-matlab-is-using-for-linux
% Linux>.