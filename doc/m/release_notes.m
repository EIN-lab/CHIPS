%% Release Notes

%% 
% <html><h2>v1.0.4 - First Public Release</h2></html>
%
% *Known Issues*
%
% * Bio-Formats in MATLAB R2013a: The current Bio-Formats Java library is
% not compatible with the Java version included with MATLAB R2013a.  Please
% refer to the <system_requirements.html system requirements> page for the
% workaround.
% * 5D images: CHIPS does not currently support images with multiple slices
% in both space and time.  In other words, CHIPS supports z-stack images,
% or repeated time series images (i.e. movies), but not a mix of both.
% * Non-square pixels: CHIPS is not currently designed to process images
% with unequal pixel aspect ratios (i.e. non-square pixels).
% * |repmat| with objects: There can be some unexpected behaviour in older
% MATLAB versions when using the function |repmat| with certain CHIPS
% classes.  For example, in R2013a, |scimArray = repmat(SCIM_TIF(), 1, 3)|
% does not behave as expected, but the alternative |scimArray(1:3) =
% SCIM_TIF()| does.
% * Tests: There are several compatability issues when running the tests.
% Please contact the developers for more information.