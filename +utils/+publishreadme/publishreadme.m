function publishreadme(folder, xmlflag, batchflag, outFolder)
%PUBLISHREADME Publish a README.m file to HTML and GitHub-flavored markdown
%
% publishreadme(folder, xmlflag)
%
% This function is designed to publish a README.m documentation and
% examples script to both HTML and GitHub-flavored markdown, making it
% easier to use a single file for GitHub and MatlabCentral File Exchange
% documentation.
%
% The markdown stylesheet can also be used independently by publish.m to
% convert any file written with Matlab markup to markdown. 
%
% Input variables:
%
%   folder:     folder name.  The folder should contain a file names
%               README.m. A README.md and README.html file will be added to
%               this folder. If necessary, a readmeExtras folder that holds
%               any supporting images will also be added.
%
%   xmlflag:    logical scalar, true to produce an XML output as well.  If not
%               included, will be false.

% Copyright 2016 Kelly Kearney

validateattributes(folder, {'char'}, {}, 'publishreadme', 'folder');

if nargin < 2
    xmlflag = false;
end
if nargin < 3
    batchflag = false;
end
if nargin < 4
    outFolder = folder;
end

validateattributes(xmlflag, {'logical'}, {'scalar'}, 'publishreadme', 'xmlflag');
validateattributes(batchflag, {'logical'}, {'scalar'}, 'publishreadme', 'batchflag');

if batchflag
    %// Check whether supplied path is file or folder
    [~, filename, ext] = fileparts(folder);
    hasExt = ~isempty(ext);
    
    %// Call the function with
    if ~hasExt
        
        % Get a list of the m-files, and
        files = what(folder);
        filelist = files.m;

        %// Loop through the remaining files and call publishreadme
        %// recursively
        for iFile = 1:numel(filelist)
            filePath = fullfile(folder, filelist(iFile));
            publishreadme(char(filePath), xmlflag, batchflag);
        end
        return
    else
        mfile = folder;
        [folder, ~, ~] = fileparts(folder);
        readmefolder = 'D:\Code\Matlab\2p-img-analysis\doc\md';
        
        tmpfile = mfile;
        [~,tmpbase,~] = fileparts(tmpfile);
    end
else
    filename = 'README';
    mfile = fullfile(folder, [filename,'.m']);
    readmefolder = fullfile(folder, 'readmeExtras');
    
    tmpfile = [tempname('.') '.m'];
    [~,tmpbase,~] = fileparts(tmpfile);
    copyfile(mfile, tmpfile);
end

% READMEs already on the path (pretty common in external toolboxes) will
% shadow these, which prevents the target file from being published.  Make
% a copy to get around that.   

if ~exist(mfile, 'file')
    error('File %s not found', mfile);
end


% Remve old published versions
if ~batchflag
    if exist(readmefolder, 'dir')
        rmdir(readmefolder, 's');
    end
else
    if ~exist(readmefolder, 'dir')
        mkdir(readmefolder);
    end
end
% Options for html and markdown publishing

htmlOpt = struct('format', 'html', ...
               'showCode', true, ...
               'outputDir', tempdir, ...
               'createThumbnail', false, ...
               'maxWidth', 800);
           
mdOpt = struct('format', 'html', ...
               'stylesheet', '+utils/+publishreadme/mxdom2md.xsl', ...
               'showCode', true, ...
               'outputDir', readmefolder, ...
               'createThumbnail', false, ...
               'maxWidth', 800);
           
xmlOpt = struct('format', 'xml', ...
               'showCode', true, ...
               'outputDir', readmefolder, ...
               'createThumbnail', false, ...
               'maxWidth', 800);

% Publish, and rename READMEs back to original names
           
%htmlfile = publish(tmpfile, htmlOpt);
mdfile   = publish(tmpfile, mdOpt);
if xmlflag
    xmlfile  = publish(tmpfile, xmlOpt);
end

% Correct HTML in markdown (R2016b+ uses html in command window printouts)

mdtxt = fileread(mdfile);
%mdtxt = strrep(mdtxt, '&times;', 'x');
mdtxt = strrep(mdtxt, '{{', '{{ "{{" }}');
%mdtxt = strrep(mdtxt, '<tt>', '`');
%mdtxt = strrep(mdtxt, '&gt;', '>');
fid = fopen(mdfile, 'wt');
fprintf(fid, '%s', mdtxt);
fclose(fid);

movefile(mdfile,   fullfile(readmefolder, [filename, '.md']));
%movefile(htmlfile, fullfile(readmefolder, [filename, '.html']));
if xmlflag
    movefile(xmlfile,  fullfile(readmefolder, [filename, '.xml']));
end

if ~batchflag
    delete(tmpfile);
end

% Move main files up, and replace references to supporting materials
if ~batchflag
    if xmlflag
        movefile(fullfile(readmefolder, [filename, '.xml']), outFolder);
    end
    
    Files = dir(readmefolder);
    fname = setdiff({Files.name}, {'.', '..', [filename, '.md'], [filename, '.html']});
    fnamenew = strrep(fname, tmpbase, filename);
    if isempty(fname)
        movefile(fullfile(readmefolder, [filename, '.md']), outFolder);
        %movefile(fullfile(readmefolder, [filename, '.html']), outFolder);
        rmdir(readmefolder, 's');
    else
        
        fid = fopen(fullfile(readmefolder, [filename, '.md']), 'r');
        textmd = textscan(fid, '%s', 'delimiter', '\n');
        textmd = textmd{1};
        fclose(fid);
        
        fid = fopen(fullfile(readmefolder, [filename, '.html']), 'r');
        texthtml = textscan(fid, '%s', 'delimiter', '\n');
        texthtml = texthtml{1};
        fclose(fid);
        
        textmd   = strrep(textmd, '&times;', 'x'); % until I figure out how to do this in the XSL file
        textmd   = strrep(textmd,   tmpbase, fullfile('.', 'readmeExtras', filename));
        texthtml = strrep(texthtml, tmpbase, fullfile('.', 'readmeExtras', filename));
        for ii = 1:length(fname)
            movefile(fullfile(readmefolder, fname{ii}), fullfile(readmefolder, fnamenew{ii}));
        end
        fid = fopen(fullfile(folder, [filename, '.md']), 'wt');
        fprintf(fid, '%s\n', textmd{:});
        fclose(fid);
        fid = fopen(fullfile(folder, [filename, '.html']), 'wt');
        fprintf(fid, '%s\n', texthtml{:});
        fclose(fid);
        
        delete(fullfile(readmefolder, [filename, '.md']));
        delete(fullfile(readmefolder, [filename, '.html']));
        
    end
end
