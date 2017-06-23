function [header,Aout,cmap] = scim_openTif(varargin)
%% function [header,Aout,cmap] = scim_openTif(varargin)
% Opens a ScanImage TIF file, extracting its header information and, if specified, stores some/all of image contents as output array Aout if specified. 
% By default, Aout, if specified for output, is of size MxNxCxK,where C spans the channel indices, and K the slice/frame indices.
% Function behavior can be controlled via flags, which are strings specified as arguments, in any order. 
% Some flags (e.g. 'flat', 'cell', 'rgb') modify the format of Aout.
% Other flags (e.g. 'show' and 'write') cause display or file outputs
%
% NOTE: IF 1) no flag causing display or file output is supplied AND 2) second output argument (Aout) is not assigned to output variable
%       THEN image file is not actually read -- only  header information is extracted
%
%% SYNTAX
%   scim_openTif()
%   scim_openTif(filename)
%   header = scim_openTif(...)
%   [header,Aout] = scim_openTif(...)
%   [header,Aout,cmap] = scim_openTif(...)
%   [...] = scim_openTif(...,flag1,flag2,flag2Arg,flag3,flag4,...)
%       filename: Name of TIF file, with or without '.tif' extension. If omitted, a dialog is launched to allow interactive selection.
%       flagN/flagNArg: Flags (string-valued) and/or flag/value pairs, in any order, specifying options to use in opening specified file
%
%       header: Structure comprising information stored by ScanImage into TIF header
%       Aout: MxNxCxK array, with images of size MxN for each of C colors and K slices or frames. Default type is uint16.
%       cmap: Cell array containing 2-element arrays of [lowPixVal highPixVal] for each channel. With flag of type 'fourChan/Cell' or 'allChan/Cell',
%             there are entries for all possible channels. Otherwise, number of entries equals number of saved & selected channels.
%
% NOTE: IF 1) no flag causing display or file output is supplied AND 2) second output argument (Aout) is not assigned to output variable
%       THEN image file is not actually read -- only only header information is extracted
%
%% FLAGS (case-insensitive)
%   NO ARGUMENTS
%       'show': Display the image(s) read by this function call. This option suppresses output to the workspace.
%               For multi-slice data, a maximum projection image is shown. For multi-frame data, a movie is shown.
%       'showMIP': Same as 'show', but forces display of maximum projection image regardless of whether multi-frame or multi-slice data.
%       'showMovie': Same as 'show', but forces display of movie regardless of whether multi-frame or multi-slice data.
%       'flat': Forces output to be 3-dimensional array of size MxNx(#Frames*#Slices*#Channels), i.e. channels are interleaved rather than separated
%       'cell': Outputs data as cell array of 3-dimensional arrays of size MxNx(#Frames*#Slices), i.e. each channel in a cell element. 
%       'RGB': Forces output to have MxNx3xK form so as to form Matlab RGB image data, even if less than 3 channels are present/selected.
%                   Data is normalized to overall maximum value (across stacks/frames/channels), unless 'useLUT' is specified.
%                   By default, channel 2/1/3 are assigned to R/G/B and channel 4 to gray. See 'colorOrder' flag description for more info.
%       'useLUT': This flag applies with 'show' and/or 'RGB' options. It specifies that LUT values from file (if any) should be employed when scaling the image data (with 'RGB' flag) and when displaying image (with 'show' flag).
%
%    (Infrequently used):
%       'fourCell(s)' or 'allCell(s)': Same as 'cell' but cell array is forced to have 4 elements even if less than 4 channels are saved/selected. Unsaved/selected channels are stored as empty array.
%       'fourChan(s)' or 'allChan(s)': Forces output to be of size MxNx4xK, even if less than 4 channels are used/selected. Unused/unselected channels will be filled with 0. Incompatible with 'flat' and 'rgb' modes.
%
%
%   WITH ARGUMENTS
%       'channel' or 'channels': Argument specifies subset of channel(s) to extract. Ex: 1,[1 3], 2:4. 
%       'slice' or 'slices': Argument specifies subset of slices present to extract. Use 'inf' to specify all slices above highest specified value. Ex: 1:30, [50 inf], [1:9 11:19 21 inf]
%       'frame' or 'frames': Argument specifies subset of frames present to extract. Use 'inf' to specify all frames above highest specified value. Ex: 1:30, [50 inf], [1:9 11:19 21 inf]
%
%       'write':    Specifies that processed data (i.e. channel/slice/frame extraction, truecolor creation, etc, if any) should be written to file. This option suppresses output to the workspace.
%                   Argument is a string. When empty or 'auto', the output filename is the input filename; '_RGB' is appended if RGB option is used; '_selChans','_selSlices', and/or '_selFrames' are also appended if chans/slices/frames are selected
%                   Otherwise, argument specifies string to append to input filename to create the output filename. An intervening underscore ('_') is employed.
%
%       'writeMIP': Specifies that multi-slice/frame data should be written to a single-image maximum projection file. This option suppreses output to the workspace.
%                   Argument is a string. When empty or 'auto', output filename is the input filename, with '_MIP' appended; '_RGB' is also appended if RGB option is used; '_selChans','_selSlices', and/or '_selFrames' are also appended if chans/slices/frames are selected
%                   Otherwise, argument specifies user-defined string to append to input filename to create the output filename, following an underscore ('_') character.
%
%       'writeAVI': Specifies that multi-slice/frame data should be written to an AVI movie file. This option suppreses output to the workspace.
%                   Argument is a string. When empty or 'auto', output filename is the input filename, with '.avi' extentsion; '_RGB' is appended if RGB option is used; '_selChans','_selSlices', and/or '_selFrames' are also appended if chans/slices/frames are selected
%                   When 'short', additional information about channel/slice/frame extraction (if any) is suppressed. I.e., the output filename is identical to input filename, but for '.avi' extension.
%                   Otherwise, argument specifies string to append to input filename to create the output filename. An intervening underscore ('_') is employed.
%
%       'aspect':   Argument specifies size of image as written & shown (but not output). Specified as 2-D array([outputPixelsPerLine outputLinesPerFrame]) or scalar([outputSize])
%                   When argument is scalar, shown/written image has square aspect ratio. If value is 0,1, or inf, the larger of the image data's pixelsPerLine or linesPerFrame is used. Otherwise, value specifies both outputPixelsPerLine and outputLines.
%                   When argument is empty or omitted, the shown/written image pixelsPerLine and linesPerFrame match that of the input image data-- i.e. the input data's aspect ratio is preserved.
%                   When flag is omitted, data is shown with image size auto-adjusted to produce a square aspect ratio for cases where shown data is a single image (e.g. MIP). Otherwise, data is shown/written/output with input data size.
%                   NOTE: Image Processing toolbox is presently required to adjust the output size for writing or showing data as a movie. However, it is not required for showing resized data as a single image (e.g. a MIP).
%
%       'colorOrder': Applies in 'RGB' mode only. Argument is 1x4 array specifying color assignment for each channel number. 
%                     Values 1,2,3 correspond to red, green, and blue. Value 4 is interpreted as gray, i.e. intensity is spread through R/G/B.
%                     Default value is [2 1 3 4]. Entry for unused or unselected channels can be 'nan', but will be ignored in any event.
%
%% NOTES
%   This function replaces the genericOpenTif() function supplied with ScanImage 3.0 and earlier
%   Legacy function provided 3-dimensional array output consistent with using 'flat' flag
%   Legacy function provided option 'splitIntoCellArray' consistent with using 'cell' flag
%       
%   At this time, files can only have multiple frames OR slices, but not both
%
%   Flags 'fourChan(s)' and 'fourCell(s)' pertain to current status where ScanImage supports exactly up to 4 channels
%
%   TODO: Add cancel to waitbar (and make sure it actually appears) while writing, in case very long write was inadvertently requested
%   TODO: Make option to use more precise conversion to uint8 based on conversion to double type -- can use this when memory permits
%   TODO: Add option to turn off/on compression for movies -- Cinepak vs None is a significant time vs. filesize tradeoff. Alternatively -- use new VideoWriter object for newer Matlab versions.
%
%% CHANGES
%   VI111609A: Employ the storedLinesPerFrame value when determining the stored image dimensions -- Vijay Iyer 11/16/09
%   VI020910A: Remove insistence on having 'expected' number of frames, as this cannot be anticipated in next trigger mode. Eventually, could add check back in for cases identified where number of frames can be anticipated. -- Vijay Iyer 2/9/10
%   VI120910A: Allocate correct number of output arguments; dont' assign to base workspace anymore; eliminate 'header' flag, can auto-detect whether to read file based on flags and output arguments  -- Vijay Iyer 12/9/10
%   VI121010A: Fix off-by-one errors in default colormap used by convertToUnit8()/makeMovie(); also, explicitly prevent values greater than (cmapLength-1), which can arise due to roudning -- Vijay Iyer 12/10/10
%   VI121010B: Use Compression='none' for all AVI creation at moment; the default Indeo encoding previously used cannot be read by Windows media player anymore in XPSP3 and beyond, as of Windows security update 954157 -- Vijay Iyer 12/10/10
%   VI040511A: BUGFIX - Index was incorrectly computed, affecting cases where savedChannels skips some values -- Vijay Iyer 4/5/11
%   VI071211A: Changes to allow either SI3 or SI4 files to be read by this function -- Vijay Iyer 7/12/11
%   VI071311A: Use TIFF object to read file, rather than imread(), as it's much faster -- Vijay Iyer 7/13/11
%
%% CREDITS
%   Created 4/16/09, by Vijay Iyer
%
%% ****************************************************************

%	Some modifications by Matthew J.P. Barrett, Kim David Ferrari et al.

% Import the utils.scim package so the parseHeader function works
import utils.scim.*

% Check for the image processing toolbox
feature = 'Image_Toolbox';
className = 'SCIM:SCIMOpenTif';
utils.verify_license(feature, className);

%% Constants/Inits
maxNumChans = 4;
reducedChans = false;
reducedSlices = false;
redicedFrames = false;

error(nargoutchk(0,3,nargout,'struct')); %VI120910A

resizeWarning = false;

%% Parse input arguments
flagNames = {'flat' 'show' 'showmovie' 'showmip' 'cell' 'rgb' 'uselut' 'channel' 'channels' 'slice' 'slices' 'frame' 'frames' 'colororder' 'fourcell' 'fourchan' 'fourcells' 'fourchans' 'allcell' 'allcells' 'allchan' 'allchans'}; %VI120910A
argFlags = {'channel' 'channels' 'slice' 'slices' 'frame' 'frames' 'channelorder' 'type' 'write' 'writemip' 'writeavi' 'writempeg' 'aspect'};
forceOutputFlags  = {'show' 'showmovie' 'showmip' 'write' 'writemip' 'writeavi' 'writempeg'};

flagIndices = find(cellfun(@(x)ischar(x) && (ismember(lower(x),flagNames) || ismember(lower(x),argFlags)),varargin));
flags = cellfun(@lower,varargin(flagIndices),'UniformOutput',false);
if isempty(flags)
    flags = {};
end

forceOutput = ~isempty(intersect(flags,forceOutputFlags)); %VI120910A

%% Determine input file
if isempty(find(flagIndices==1)) && nargin>=1 && ischar(varargin{1})
    fileName = varargin{1};
else
    fileName = '';
end

if isempty(fileName)
    [f, p] = uigetfile({'*.tif;*.tiff'},'Select Image File');
    if f == 0
        return;
    end
    fileName = fullfile(p,f); 
end

[filePath,fileStem,fileExt] = fileparts(fileName);
fileNameWExt = [fileStem, fileExt];

%% Read TIFF file; extract # frames & image header
if ~exist(fileName,'file')
    error('''%s'' is not a recognized flag or filename. Aborting.',fileName);
end

warning('off','MATLAB:tifflib:TIFFReadDirectory:libraryWarning');
hTif = Tiff(fileName);

headerString  = hTif.getTag('ImageDescription');

numImages = 1;
while ~hTif.lastDirectory()
    numImages = numImages + 1;
    hTif.nextDirectory();
end
hTif.setDirectory(1);

if strncmp('state',headerString,5) 
    fileVersion = 3;
    header = parseHeader(headerString);
else
    fileVersion = 4;
    header = most.util.assignments2StructOrObj(headerString);            
end

%Extracts header info required by scim_openTif()
hdr = extractHeaderData(header,fileVersion);

%Extract frame tag info, if available (SI4 only)
frameTagStr = 'Frame Tag';
if strncmpi(headerString,frameTagStr,length(frameTagStr))
    header.frameTags = extractFrameTags(hTif,numImages);    
end

%VI120910A: Detect/handle header-only operation (don't read data)
if nargout <=1 && ~forceOutput 
    return;
end

%% Read image meta-data
savedChans = hdr.savedChans;
numChans = length(savedChans);
numPixels = hdr.numPixels;
numLines = hdr.numLines;
numSlices = hdr.numSlices;
numFrames = hdr.numFrames;

if numSlices > 1 && numFrames > 1 && header.acq.numAvgFramesSave ~= numFrames
    error('Cannot interpret multiple frames and slices simultaneously at this time');
end

%%%VI020910A: Removed (for now)%%%%%%
% if numImages < numChans * numFrames * numSlices
%     fprintf(2,'WARNING(%s): Number of images in file is less than expected. Perhaps acquisition was aborted in middle.',mfilename());
% end
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

if numFrames > 1
    numFrames = floor(numImages/numChans);
elseif numSlices > 1
    numSlices = floor(numImages/numChans);
end

if ~numFrames || ~numSlices
    error('Acquisition did not complete a single frame or slice. Aborting.');
end
   

acqLUT = hdr.acqLUT;

%% Process Flags

%Determine slices & frames to extract
if numSlices > 1  
    selection = selectImages({'slice' 'slices'},numSlices);
    selectionStr = 'Slice';
    numTotal = numSlices;
elseif numFrames > 1
    selection = selectImages({'frame' 'frames'},numFrames);
    selectionStr = 'Frame';
    numTotal = numFrames;
else
    selection = 1;
    selectionStr = '';
    numTotal = 1;
end
numSelections = length(selection);

    function selection = selectImages(selectionFlags, numItems)
        if any(ismember(selectionFlags,flags))
            selection = getArg(selectionFlags);
            %Handle 'inf' specifier in slice array
            if find(isinf(selection))
                selection(isinf(selection)) = [];
                if max(selection) < numItems
                    selection = [selection (max(selection)+1):numItems];
                end
            end
            if max(selection) > numItems
                error('Slice or frame values specified are not found in file');
            end
        else
            selection = 1:numItems;
        end
    end

%Determine channels to extract
if any(ismember({'channel' 'channels'},flags))
    selChans = getArg({'channel' 'channels'});
    
    if ~isempty(setdiff(selChans,savedChans))
        selChans(find(setdiff(selChans,savedChans))) = [];
        warning('Some specified channels to extract not detected in file and, hence, ignored');
        if isempty(selChans)
            warning('No saved channels are specified to extract. Aborting.');
            return;
        end
    end
    reducedChans = length(selChans) < length(savedChans); %Determine if # channels was reduced by         
else
    selChans = savedChans;
end

%Determine other flag-determined values
forceFlat = ismember('flat',flags);
forceRGB = ismember('rgb',flags);
forceFour= any(ismember({'fourchan' 'fourchans' 'allchan' 'allchans'},flags));
forceCell = any(ismember({'cell' 'fourcell' 'fourcells' 'allcell' 'allcells'},flags));

useLUT = ismember('uselut',flags);

%Handle any contradictions
if length(find([forceFour forceFlat forceRGB forceCell])) > 1 
    error('Flag specifications are inconsistent. Aborting.');
end

if length(find(ismember({'write' 'writeavi' 'writemip'},flags))) > 1 
    error('Multiple ''write'' flag types are not permitted. Aborting.');
end

%Determine color order array, a 1x4 array specifying idx each channel # is targeted to (regardless of whether it was saved)
if ismember('colororder',flags) 
    if ~forceRGB
        warning('The flag ''colorOrder'' only applies if ''rgb'' flag is also specified. Ignored.');
    else
        colorOrder = getArg('colorOrder');
        %TODO: Validation
    end
else 
    colorOrder = [2 1 3 4];
end

%Use LUT data, if present
if isempty(acqLUT)
    if useLUT
        warning('File did not store LUT values during acquisition. ''useLUT'' flag ignored.');
    end
    useLUT = false;
end

%% Preallocate image data
switch hTif.getTag('SampleFormat')
    case 1
        imageDataType = 'uint16';
    case 2
        imageDataType = 'int16';
    otherwise
        assert('Unrecognized or unsupported SampleFormat tag found');
end

if forceFlat
    Aout = zeros(numLines,numPixels,length(selChans)*numSelections,imageDataType);
elseif forceFour
    Aout = zeros(numLines,numPixels,4,numSelections,imageDataType);
elseif forceRGB
    Aout = zeros(numLines,numPixels,3,numSelections,imageDataType);
elseif forceCell
    Aout = cell(1,maxNumChans);
    for i=1:length(savedChans)
        if ismember(savedChans(i),selChans)
            Aout{savedChans(i)} = zeros(numLines,numPixels,numSelections,imageDataType);
        end
    end
else
    Aout = zeros(numLines,numPixels,length(selChans),numSelections,imageDataType);
end

% Prepare some waitbar-related variables
isWorker = utils.is_on_worker();
h = [];

%% Read image data
warnState = warning('query','all');
try
    
    % Initialise a progress bar
    strMsg = ['Opening ' fileNameWExt];
    if ~isWorker
        utils.progbar(0, 'msg', strMsg);
    end
    
    count = 0; %Initialize counter required for flat case
       
    for i=1:length(selection)

        for j = 1:length(savedChans)
            %idx = numChans * (selection(i) - 1) + savedChans(j);  %VI040511A: Removed
            idx = numChans * (selection(i) - 1) + j; %VI040511A

            if forceFlat
                if ismember(savedChans(j), selChans)
                    count = count + 1;
                    
                    hTif.setDirectory(idx);
                    Aout(:,:,count) = hTif.read();
               end
            elseif forceFour
                if ismember(savedChans(j),selChans)                    
                    hTif.setDirectory(idx);
                    Aout(:,:,savedChans(j),i) = hTif.read();
               end
            elseif forceRGB
                if ismember(savedChans(j),selChans)
                    colorIdx = colorOrder(savedChans(j));
                    if colorIdx < 4                        
                        hTif.setDirectory(idx);
                        Aout(:,:,colorIdx,i) = Aout(:,:,colorIdx,i) + scaleImage(hTif.read(),savedChans(j));
                    else
                        hTif.setDirectory(idx);
                        grayImage = scaleImage(hTif.read(),savedChans(j));
                        
                        for k = 1:3
                            Aout(:,:,k,i) = Aout(:,:,k, i) + grayImage;
                        end
                    end
                end
            elseif forceCell
                if ismember(savedChans(j),selChans)
                    hTif.setDirectory(idx);                    
                    Aout{savedChans(j)}(:,:,i) = hTif.read();
                end
            else
                if ismember(savedChans(j), selChans)
                    hTif.setDirectory(idx);
                    Aout(:,:,j,i) = hTif.read();
                end
            end
        end
        
        % Update the progress bar
        if ~isWorker
            [~, lastID] = lastwarn();
            isSuppressedWarning = strcmp(lastID, ...
                'MATLAB:imagesci:tiffmexutils:libtiffWarning');
            if isSuppressedWarning
                lastwarn('');
            end
            utils.progbar(i/length(selection), 'msg', strMsg, 'doBackspace', true);
        end
        
    end
    
    warning(warnState);
catch
    if ishandle(hTif)
        hTif.close();
    end
    warning(warnState);
    rethrow(lasterror);
end

%% Image read post-processing (pre-show)

%Handle data normalization for RGB case
if forceRGB   
    %Normalize against global max (this way, brightness changes with depth/time are observable)
    if ~useLUT
        Aout = Aout * (intmax(imageDataType)/max(Aout(:))); %this allows renormalization, without ever converting to double
        %NOTE: At a glance, this could run into rounding issues with some data where value may exceed 1.0; may need fix akin to VI121010A -- Vijay Iyer 12/10/10
    end
end

%% Determine data resizing parameters

%Determine default aspect ratio for showing and outputting/writing data
[showNumPixels, showNumLines] = deal(max(numPixels,numLines)); %show data square, by default
[outNumPixels, outNumLines] = deal(numPixels, numLines); 

%Determine output size change, if any
if ismember('aspect',flags)
    outSize = getArg('aspect');
    if ~isnumeric(outSize) || ndims(outSize) > 2 || numel(outSize) > 2
        fprintf(2,'The argument to flag ''aspect'' must be a scalar or 2-element numeric array. Flag ignored.');               
    elseif isempty(outSize)
        %do nothing - output size matches input size
    elseif isscalar(outSize)
        if any(outSize == [0 1 inf])
            [outNumPixels outNumLines] = deal(max(numPixels,numLines));
        else
            [outNumPixels outNumLines] = deal(outSize);
        end
    else
        [outNumPixels outNumLines] = deal(outSize(1),outSize(2));
    end
    
    %Show data the same way it's output, when 'aspect' flag is used
    [showNumPixels showNumLines] = deal(outNumPixels, outNumLines);
end


%% Show image, if specified
% It might have been better to force a common format (i.e. cell) to unify show methodology, and then convert to final output format

if any(ismember({'show' 'showmovie' 'showmip'},flags))

    %Determine manner to show the data
    if numSelections == 1
        if ismember('showavi',flags)
            warning('Data only contains one frame/slice. Cannot show movie.');
            target = '';
        end
        target = 'image';
    elseif ismember('showmip',flags) || (ismember('show',flags) && numSlices > 1)
        target = 'mip';
    elseif ismember('showmovie',flags) || (ismember('show',flags) && numFrames > 1)
        target = 'movie';
    end

    %Show the data 
    switch target
        case {'image' 'mip'}
            if numSelections > 1
                maxProjStr = ' Max Projection';
            else
                maxProjStr = '';
            end

            if forceRGB
                showImage(makeMIP(Aout),[fileStem fileExt maxProjStr],[]);
            else
                for i=1:length(selChans)
                    titleString = [fileStem fileExt maxProjStr ' (Channel ' num2str(selChans(i)) ')'];
                    showImage(makeMIP(extractChannelData(Aout, selChans(i))), titleString, selChans(i));
                end
            end
        case 'movie'           
            if forceRGB
                showMovie(Aout);
            else                
                for i=1:length(selChans)
                    showMovie(extractChannelData(convert2Uint8(Aout),selChans(i)),selChans(i));
                end
            end
    end
end

%% Image read post-processing (post-show)
%Cell array output case
if forceCell
    if ~any(ismember({'fourcell' 'fourcell' 'allcell' 'allcells'},flags))
        Aout(cellfun(@isempty,Aout)) = [];
    end
end    

%% Write image data, if specified
if any(ismember({'write' 'writeavi' 'writemip' 'writempeg'},flags))
    
    %Determine filename clause to write, if applicable
    writeFlag = intersect({'write' 'writeavi' 'writemip' 'writempeg'},flags);
    if ~isempty(writeFlag)
        writeFileClause = getArg(writeFlag);
        if isempty(writeFileClause)
            writeFileClause = 'auto';
        end
    end
    
    %Determine if there's been any processing/reduction
    [imageReductionStr, chanReductionStr, dataReductionStr] = deal('');
    imagesReduced = any(ismember({'frame' 'frames' 'slice' 'slices'},flags)); %Ideally would further check that flag argument actually did something, but this is pretty good
    channelsReduced = any(ismember({'channel' 'channels'},flags));
    dataProcessed = imagesReduced || channelsReduced || ismember('rgb',flags);
    if imagesReduced
        [dataReductionStr,imageReductionStr] = deal('_selection');
    end
    if channelsReduced
        [dataReductionStr,channelReductionStr] = deal('_selection');
    end
        
    %Determine type of file(s) to write
    if numSelections == 1 || ismember('write',flags)
        if any(ismember({'writeavi' 'writemip' 'writempeg'},flags)) %numSelections = 1 cannot coexist with writeavi/writemip                  
            warning('Data only contains one frame/slice. Cannot write MIP or AVI file.');
            target = '';            
        elseif dataProcessed
            target = 'image';
        else
            warning('No specification to process/alter data in any manner is made. Cannot write to file.');
            target = '';        
        end
    elseif ismember('writemip',flags) %|| (ismember('write',flags) && numSlices > 1)
        target = 'mip';
    elseif ismember('writeavi',flags) %|| (ismember('write',flags) && numFrames > 1)
        target = 'avi';
    elseif ismember('writempeg',flags)
        target = 'mpg';
    end
    
    %Write the file(s)
    switch target
        case ''
            % Do nothing
        case 'image'
            ext = '.tif';
            if forceFlat                
                imwrite(resizeImage(Aout),determineOutFileName('selection',ext),'Description',headerString);
            elseif forceRGB
                imwrite(resizeImage(Aout),determineOutFileName(['rgb' channelReductionStr],ext),'Description',headerString);
            else
                for i=1:length(selChans)
                    outFileName = determineOutFileName(['chan' num2str(selChans(i)) imageReductionStr],ext);
                    proceed = 'Yes';
                    if exist(outFileName,'file')
                        proceed = questdlg('File already exists. Overwrite?','File Already Exists','Yes','No','No');
                        delete(outFileName);
                    end
                    if strcmpi(proceed,'Yes')
                        streaming =  exist('scim_tifStream','file'); %Use faster file-writing, if available
                        if streaming
                            tifStream = scim_tifStream(outFileName, size(Aout,2), size(Aout,1), headerString);
                            for j=1:numSelections
                                appendFrame(tifStream,resizeImage(extractChannelData(Aout, selChans(i), j)));
                            end
                            close(tifStream);
                        else                                                                         
                            for j=1:numSelections
                                imwrite(resizeImage(extractChannelData(Aout, selChans(i),j)), outFileName,'Description',headerString,'WriteMode','append','Compression','none'); %Compression doesn't appear to work with multi-frame TIFF
                            end
                        end
                    else
                        warning('Aborting file write operations');
                        break;
                    end               
                end               
            end
        case 'mip'
            ext = '.tif';
            if forceRGB
                imwrite(resizeImage(makeMIP(Aout)),determineOutFileName(['mip_rgb' dataReductionStr] ,ext),'Description',headerString);
            else
                
                if ~isWorker
                    strMsg = 'Writing output image';
                    utils.progbar(0, 'msg', strMsg);
                end
                
                try
                    for i=1:length(selChans)
                        
                        imwrite(resizeImage(makeMIP(extractChannelData(Aout, selChans(i)))), determineOutFileName(['chan' num2str(selChans(i)) '_mip' imageReductionStr],ext),'Description',headerString,'Compression','none'); %could probably use compression here safely
                        
                        % Update the progress bar
                        if ~isWorker
                            utils.progbar(i/length(selChans), ...
                                'msg', strMsg, 'doBackspace', true);
                        end
                        
                    end           
                catch
                    rethrow(lasterror);
                end
            end            
        case 'avi'
            ext = '.avi';
            
            %%%VI121010B%%%
            if ispc 
                if forceRGB
                    compression = 'none'; %RLE not available for truecolor; could use Cinepak, but it takes a very long time
                else
                    compression = 'none'; 
                    %Could use RLE, but in some cases this has artifacts -- even though this should be lossless 
                    %Could use Cinepak, but this takes a long time
                    %Indeo doesn't run on XPSP3 forward
                    %MSVC looks quite lousy
                end                    
            else
                compression = 'none'; %No compression options available for Unix/Mac and for truecolor
            end
            %%%%%%%%%%%%%%%
            
            if forceRGB
                [M,fps] = makeMovie(Aout,true);
                movie2avi(M,determineOutFileName(['rgb' dataReductionStr], ext),'fps',fps,'Compression',compression);                        
            else
                for i=1:length(selChans)
                    [M,fps] = makeMovie(extractChannelData(Aout,selChans(i)),true);
                    movie2avi(M,determineOutFileName(['chan' num2str(selChans(i)) imageReductionStr], ext),'fps',fps,'Compression',compression);
                end
            end                    
        case 'mpg'
            ext = '.mpg';
            
            % construct movie object from our data
            if forceRGB
                [M,fps] = makeMovie(Aout,true);
                movie2mpg(M,determineOutFileName(['rgb' dataReductionStr], ext),fps); 
            else
                for i=1:length(selChans)
                    [M,fps] = makeMovie(extractChannelData(Aout,selChans(i)),true);
                    movie2mpg(M,determineOutFileName(['chan' num2str(selChans(i)) imageReductionStr], ext),fps);
                end
            end
    end
    
end



%% Process output arguments   

if nargout >= 3
    cmap = acqLUT;
    if ~isempty(acqLUT) %Screens out case where LUT values not stored
        if ~forceFour && ~any(ismember({'fourcell' 'fourcells' 'allcell' 'allcells'},flags));
            %Remove unsaved and unselected channels
            for i=1:maxNumChans
                if ~ismember(i,selChans)
                    cmap(i) = [];
                end
            end
        end
    end
end


%% GENERAL HELPERS

    function arg = getArg(flag)
        [tf,loc] = ismember(flag,flags); %Use this approach, instead of intersect, to allow detection of flag duplication
        if length(find(tf)) > 1
            error(['Flag ''' flag ''' appears more than once, which is not allowed']);
        else %Extract location of specified flag amongst flags
            loc(~loc) = [];
        end
        flagIndex = flagIndices(loc);
        if length(varargin) <= flagIndex
            arg = [];
            return;
        else
            arg = varargin{flagIndex+1};
            if ischar(arg) && ismember(lower(arg),flags) %Handle case where argument was omitted, and next argument is a flag
                arg = [];
            end
        end
    end

    %Image scaling required for RGB case
    function currImage = scaleImage(currImage,chanIdx)
        if useLUT
            [minVal maxVal] = deal(acqLUT{chanIdx}(1),acqLUT{chanIdx}(2));  
            switch imageDataType
                case 'uint16'                    
                    currImage = uint16(double(intmax('uint16')) * (double(currImage) - minVal)./(maxVal - minVal));
                case 'int16'
                    currImage = int16(double(intmax('int16')) * (double(currImage) - minVal)./(maxVal - minVal));
                otherwise
                    assert(false);
            end

        end               
    end

    %Create movie frames and determine frameRate
    function [M,frameRate] = makeMovie(A,forAVI,forShow)
        
        cmapLength = double(intmax('uint8')) + 1; %VI121010B %VI121010A
        %%%VI121010B: Removed -- No longer ever using Indeo compression%%%
        %         if nargin < 2 || ~forAVI || ~ispc
        %             cmapLength = double(intmax('uint8')) + 1; %VI121010A
        %         else
        %             cmapLength = 236; %For Indeo compression, the default for Windows
        %         end
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        
        if nargin < 3
            forShow = false;
        end
        
        %Determine whether to resize to show dimensions
        forceShowDims = forShow && forceShowResize();

        %Create the movie frames
        for selCount=1:numSelections
            if forceFlat || forceCell %MxNx1xK cases
                frameData = resizeImage(convert2Uint8(A(:,:,selCount),cmapLength),forceShowDims);               
            else
                frameData = resizeImage(convert2Uint8(A(:,:,:,selCount),cmapLength),forceShowDims);
            end
            M(selCount) = im2frame(frameData,gray(cmapLength));
        end       
        
        %Determine rate at which to show movie
        defFrameRate = 12; %Matlab's default value
        movieTimeLimit = 10;
        if numSelections / defFrameRate > movieTimeLimit
            frameRate = numSelections / movieTimeLimit;
        else
            frameRate = defFrameRate;
        end     

    end

    function movie2mpg(M,filename,fps)
        videoWriter = VideoWriter(filename,'Motion JPEG AVI');
        
        if nargin > 2 && ~isempty(fps)
            videoWriter.FrameRate = fps;
        end
        
        videoWriter.open();
        
        % DEQ20101230 - this would be easier: videoWriter.writeVideo(M),
        % but it can cause memory allocation issues (due to the inefficient
        % uint8 -> float -> uint8 conversions in VideoWriter.writeVideo())
        for frame=M
            if length(size(frame.cdata)) == 2 % writing individual channels
                videoWriter.writeVideo(frame); 
            elseif length(size(frame.cdata)) == 3 % writing merged RGB
                videoWriter.writeVideo(frame.cdata);
            end
        end
        
        videoWriter.close();
    end

    function x = convert2Uint8(x,cmapLength)
        if isa(x,'uint8')
            return;
        end
        if nargin < 2
            cmapLength = double(intmax('uint8')) + 1; %VI121010A
        end
        
        %Do conversion to uint8 /without/ converting to double first -- saves memory, but more rounding artifacts
        x = uint8(x/(max(x(:))/cmapLength)) - 1; %VI121010A  %Without rounding artifacts, this would yield values from 0:(cmapLength-1)
        x(x > (cmapLength-1)) = (cmapLength - 1); %VI121010A: Ensure that value never exceeds (cmapLength-1), which can occur because (max(x(:))/cmapLength) is rounded in above computation
    end        

    %Determines whether data is compelled to be resized for show operations. If not compelled, default behaviour occurs.
    function tf = forceShowResize()
        tf = ismember('aspect',flags) && any([showNumPixels,showNumLines] == [numPixels,numLines]);                              
    end


    function M = showMovie(A,selChan)
        
        %implay is a decent tool, so we defer to it if present. Downsides: it's a pain to load up; also doesn't respect the figure name (so we don't bother trying to name it sensibly)
        if exist('implay','file') && ~forceShowResize()
            M = implay(convert2Uint8(A));
            return;
        end           
        
        %Create movie
        [M, frameRate] = makeMovie(A);
        clear A; %No longer needed
          
        movieTime = numSelections / frameRate;
        
        if forceRGB
            titleString = [fileStem fileExt ' Movie'];
        else            
            titleString = [fileStem fileExt ' Movie (Channel ' num2str(selChan) ')'];
        end
        
        %Make figure, sized to fit image
        hf = figure('Menubar','none','Name',titleString, 'NumberTitle','off');
        pixPosn = getpixelposition(hf);
        pixPosn = [pixPosn(1)-(size(M(1).cdata,2)-pixPosn(3)) pixPosn(2)-(size(M(1).cdata,1)-pixPosn(4)) size(M(1).cdata,2) size(M(1).cdata,1)];
        %[pixPosn(3) pixPosn(4)] = deal(size(A,2), size(A,1));
        setpixelposition(hf,pixPosn);
        
        %Add toolbar with play button
        ht = uitoolbar(hf);        
        iconData = imread(fullfile(matlabroot(),'toolbox','matlab','icons','greenarrowicon.gif'));
        iconData = double(iconData)/max(double(iconData(:)));
        iconData = repmat(iconData,[1 1 3]);
        %iconData(:,:,1) = zeros(size(iconData(:,:,1)));
        %iconData(:,:,3) = zeros(size(iconData(:,:,1)));
        hPlay = uipushtool(ht,'CData',iconData, 'ClickedCallback',@playMovie);
        
        playMovie(hPlay);

        function playMovie(src,event)
            set(src,'Enable','off');
            ht = timer('StartDelay',1.2*movieTime,'TimerFcn',@(timerObj,event)set(src,'Enable','on'));           
            start(ht);
            movie(hf,M,1,frameRate);
        end
        
    end



    function I = makeMIP(A)
        if numSelections == 1
            I = A;
            return;
        end
        
        %Create array of same type
        if forceFlat || forceCell
            I = repmat(A(:,:,1),[1 1]);
        else %this handles normal, RGB, and 4 channel cases 
            I = repmat(A(:,:,:,1),[1 1]);
        end
            
        for selCount = 1:numSelections %A MIP can be created, regardless if multi-frame or multi-slice
            if forceFlat || forceCell
                I = max(A(:,:,selCount),I);
            else
                I = max(A(:,:,:,selCount),I);
            end
        end
    end
    
    function showImage(A,titleString,chanIdx)
        if useLUT
            cLim = acqLUT{chanIdx};
        else 
            cLim = [];
        end
        if exist('imshow','file') %Image processing toolbox exists       

            if verLessThan('matlab','7.8') || any([showNumPixels showNumLines] ~= [outNumPixels outNumLines])
                %Use imshow() because imtool() is too clunky prior to 2009a
                %Use imshow() if there's a non-square aspect ratio, unless 'aspect' flag forces output/show sizes to match
                if forceRGB
                    h = imshow(A,'XData',1:showNumPixels,'YData',1:showNumLines,'InitialMagnification','fit','Border','tight'); %Data is already directly scaled
                else
                    h = imshow(A,cLim,'XData',1:showNumPixels,'YData',1:showNumLines,'InitialMagnification','fit','Border','tight'); %Display data with colormap scaled to LUT, if present; otherwise, scale colormap to min & max of data
                end
                set(ancestor(h,'figure'),'Name',titleString,'NumberTitle','off');
            else  %imtool() is handy starting in 2009a, though not spectacular
                if forceRGB
                    h = imtool(A,'InitialMagnification','fit');
                else
                    h = imtool(A,cLim,'InitialMagnification','fit');
                end
                set(h,'Name',titleString);
            end
        else
            hf = figure('Name',titleString,'NumberTitle','off');
            %%%Handle the 'Border'='tight' stuff manually
            %dataAspectRatio = size(A,2)/size(A,1);
            dataAspectRatio = showNumPixels/showNumLines;
            posn = get(hf,'Position');
            posn(3) = posn(4) * dataAspectRatio;
            set(hf,'Position',posn);
            %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
            colormap('gray');
            if useLUT
                h = image(A,'XData',1:showNumPixels,'YData',1:showNumLines);
                set(gca,'CLim',cLim);
            else
                imagesc(A,'XData',1:showNumPixels,'YData',1:showNumLines);
            end
            set(gca,'Position',[0 0 1 1],'Visible','off');                                   
        end
    end

    function Atemp = extractChannelData(Aout,selChan,selFrame)
        %selChan and selFrame (optional) specify a specific channel and frame to extract
        if nargin == 2
            selFrame = 0;
        end            
        if forceFlat
            if selFrame
                idx = (selFrame - 1) * length(selChan) + selChan;
                Atemp = Aout(:,:,idx);
            else
                Atemp = Aout(:,:,selChan:(length(selChan)):end);
            end
        elseif forceCell
            if selFrame
                Atemp = Aout{selChan}(:,:,selFrame);
            else
                Atemp = Aout{selChan};
            end
        else
            if selFrame
                Atemp = Aout(:,:,selChan,selFrame);
            else                
                Atemp = Aout(:,:,selChan,:);
            end
            
        end        
    end   

    %Resize image to outNumPixels/outNumLines, or to showNumPixels/showNumLines if forced
    function imageData = resizeImage(imageData,forceShowDims)
        
        if nargin < 2            
            forceShowDims = false;
        end        
        
        if any([outNumPixels outNumLines] ~= [numPixels numLines]) || (any([showNumPixels showNumLines] ~= [numPixels numLines]) && forceShowDims)
            if exist('imresize','file')
                
                if forceShowDims
                    [newNumLines, newNumPixels] = deal(showNumLines, showNumPixels);
                    method = 'nearest'; %Fastest interpolation for quick shows
                else 
                    [newNumLines, newNumPixels] = deal(outNumLines, outNumPixels);
                    method = 'bilinear'; %Better (but not best) for writing data
                end
                imageData = imresize(imageData,[newNumLines newNumPixels],'Colormap','original','Method',method);

            elseif ~resizeWarning 
                fprintf(2,'WARNING(%s): Resizing of image data was attempted, but Image Processing toolbox not found.',mfilename()); 
                resizeWarning = true; %Don't warn repeatedly
            end
        end               
    end

    
    function outFileName = determineOutFileName(defaultClause,extension)
        if strcmpi(writeFileClause,'auto')
            outFileName = [filePath filesep() fileStem '_' defaultClause extension];
        else
            outFileName = [filePath filesep() fileStem '_' writeFileClause extension];
        end
    end  

    function s = extractHeaderData(header,fileVersion)
       
        if fileVersion == 3
            localHdr = header;
            
            s.savedChans = [];
            for i=1:maxNumChans
                if isfield(localHdr.acq,['savingChannel' num2str(i)])
                    if localHdr.acq.(['savingChannel' num2str(i)]) && localHdr.acq.(['acquiringChannel' num2str(i)])
                        s.savedChans = [s.savedChans i];
                    end
                end
            end
            
            s.numPixels = localHdr.acq.pixelsPerLine;
            s.numLines = localHdr.acq.linesPerFrame;
            
            if isfield(localHdr.acq,'slowDimDiscardFlybackLine') && localHdr.acq.slowDimDiscardFlybackLine
                s.numLines = s.numLines - 1;
            end
            
            s.numSlices = localHdr.acq.numberOfZSlices;
            
            if localHdr.acq.averaging <= 1
                s.numFrames = localHdr.acq.numberOfFrames;
            else
                s.numFrames = 1;
            end
            
            if  ~isfield(localHdr.internal,'lowPixelValue1')
                s.acqLUT = {};
            else
                s.acqLUT = cell(1,maxNumChans);
                for i=1:length(s.acqLUT)
                    s.acqLUT{i} = [localHdr.internal.(['lowPixelValue' num2str(i)]) localHdr.internal.(['highPixelValue' num2str(i)])];
                end
            end            
            
        elseif fileVersion == 4
            if isfield(header,'SI4App')
                localHdr = header.SI4App;
            else
                localHdr = header.SI4;
            end
            
            s.savedChans = localHdr.channelsSave;
            s.numPixels = localHdr.scanPixelsPerLine;
            s.numLines = localHdr.scanLinesPerFrame;
            
            if isfield(localHdr,'acqNumAveragedFramesSaved')
                saveAverageFactor = localHdr.acqNumAveragedFramesSaved;
            elseif isfield(localHdr,'acqNumAveragedFrames')
                saveAverageFactor = localHdr.acqNumAveragedFrames;
            else
                assert(false);
            end

            s.numFrames = localHdr.acqNumFrames / saveAverageFactor;
            
            s.numSlices = localHdr.stackNumSlices;
            
            s.acqLUT = cell(1,size(localHdr.channelsLUT,1));
            for i=1:length(s.acqLUT)
                s.acqLUT{i} = localHdr.channelsLUT(i,:);
            end                
            
        else 
            assert(false);
        end

    end


    function frameTags = extractFrameTags(hTif,numImages)
       
        frameTags = [];
        warnNan = false;        
        
        for imgCount=1:numImages
            hTif.setDirectory(imgCount);
            c = regexpi(hTif.getTag('ImageDescription'),'\s*Frame Tag\s*=\s*(\d*)','tokens','once');
            frameTag = str2double(c{1});
            frameTags(end+1) = frameTag;
            
            if isnan(frameTag)
                warnNan = true;
            end
        end
        
        if warnNan
            fprintf(2,'WARNING: One or more frame tags could not be properly extracted and appear as NaN in the header struct frameTags field.\n');
        end
    end

end
