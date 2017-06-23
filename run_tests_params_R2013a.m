function run_tests_params_R2013a(varargin)

% Set up the path
testDir = fullfile(utils.CHIPS_rootdir, 'tests');
oldpath = addpath(testDir);
addpath(fullfile(utils.CHIPS_rootdir, 'tests', 'res'));
clear run_method_params

% Work out which tests we should be running
if nargin > 0
    testlist = varargin;
else
    % Assume we're doing all of them
    classlist = utils.find_classlist();
    maskUse = ~cellfun(@isempty, regexp(classlist, 'Test_.+_params'));
    testlist = classlist(maskUse);
end

% Setup a diary to track the output
fnDiary = utils.GetFullPath.GetFullPath(fullfile('.', 'diary_temp'));
hasDiary = exist(fnDiary, 'file') == 2;
if hasDiary
    diary off
    delete(fnDiary);
end
diary(fnDiary)

% Turn off some warnings
wngState = warning('off', 'CalcVelocityRadon:BadToolbox');
warning('off', 'CalcFindROIsFLIKA:FindROIs:BadToolbox')
warning('off', 'CalcDetectSigsClsfy:BadToolbox')
warning('off', 'MATLAB:uitabgroup:OldVersion')

% Loop through and run the tests
msg_out = {};
nTests = numel(testlist);
for iTest = 1:nTests
    
    % Move the original file to a temporary name
    iClassName = testlist{iTest};
    fnOrig = which(iClassName);
    [iPath, iFN, iExt] = fileparts(fnOrig);
    fnTemp = fullfile(iPath, [iFN '_temp', iExt]);
    [success, msg, msgid] = copyfile(fnOrig, fnTemp, 'f');
    if ~success
        error(msgid, msg);
    end
    
    % Temporarily replace the test parameter label in the class
    strIn = '(TestParameter)';
    strOut = '%TODO: REMOVED';
    flag = utils.replace_in_file(fnOrig, [], strIn, strOut);
    if flag < 1
        % Restore the original file and skip to the next test
        restore_file(fnTemp, fnOrig)
        continue
    end
    
    % Run the tests
    fConstructor = str2func(iClassName);
    tc = fConstructor();
    fprintf('\n\nRunning class %s...\n', iClassName);
    msg_out = run_class_params(tc);
    
    % Restore the original file
    restore_file(fnTemp, fnOrig)
    
end

% Restore the warnings
warning(wngState);

% Turn of the diary now
diary off

% Restore the path
path(oldpath);

% Display the errors!
nErrs = numel(msg_out);
for iErr = 1:nErrs
    fprintf(2, '%s\n', msg_out{iErr});
end

% Read in the contents of the diary
fID = fopen(fnDiary, 'r');
lines = textscan(fID, '%s', 'Delimiter', '\n');
fclose(fID);

% Find how many times a failed verification occured
lines = [lines{:}];
strToken = 'Interactive verification failed.';
nFails = sum(~cellfun(@isempty, strfind(lines, strToken)));
if nFails > 0
    fprintf(2, ['%d failed verifications were detected.\nPlease ' ...
        'search within the file "%s" for the string "%s" for more ' ...
        'information.\n'], nFails, fnDiary, strToken);
else
    delete(fnDiary)
end

end

% ====================================================================== %

function msg_out = run_class_params(tc)

% Extract some information about the current test class
mc = metaclass(tc);
maskUnitTest = arrayfun(@(aa) isa(aa, 'matlab.unittest.meta.method'), ...
    mc.MethodList);
idxUnitTests = find(maskUnitTest);
maskTest = [mc.MethodList(maskUnitTest).Test];
idxTests = idxUnitTests(maskTest);

% Loop through all the test methods
nTests = numel(idxTests);
for iTest = 1:nTests
    
    % Make a function handle for the test
    idxTest = idxTests(iTest);
    strMethod = mc.MethodList(idxTest).Name;
    fTest = @(varargin) tc.(strMethod)(varargin{:});
    
    % Work out if this test method needs additional arguments
    inputNames = mc.MethodList(idxTest).InputNames;
    nArgsReq = numel(inputNames) - 1;
    needsProp = nArgsReq > 0;
    if needsProp
        
        % Pull out the names and values of the additional arguments
        propsList = inputNames(2:end);
        for iProp = nArgsReq:-1:1
            propsVals{iProp} = tc.(propsList{iProp});
        end
        
        % Run the tests
        fprintf('\nRunning method %s...\n', strMethod);
        msg_out = run_method_params(fTest, nArgsReq, propsVals{:});
        
    end
    
end

end

% ====================================================================== %

function msg_out = run_method_params(fTest, nArgsReq, varargin)

persistent msg_all

% Extract out the appropriate argument
argOpts = varargin{1};
if iscell(argOpts)
    fArg = @(iOpt) argOpts{iOpt};
    nArgOpts = numel(argOpts);
elseif isstruct(argOpts)
    fns = fieldnames(argOpts);
    nArgOpts = numel(fns);
    fArg = @(iOpt) argOpts.(fns{iOpt});
else
    fArg = @(iOpt) argOpts(iOpt);
    nArgOpts = numel(argOpts);
end

% See if we're as deep as we need to be
if nArgsReq > 1
    
    % Loop through the options at this level, but...
    nArgsReqNew = nArgsReq - 1;
    for iOpt = 1:nArgOpts
        
        % Extract the argument
        iArg = fArg(iOpt);
        
        % Setup a string to help with debugging
        try
            strCase = char(iArg);
        catch
            strCase = fprintf('%d of %d', iOpt, nArgOpts);
        end
        
        % Repackage the function handle and call this function recursively
        fTestNew = @(varargin) fTest(iArg, varargin{:});
        fprintf('\nRunning cases %s (loop level %d)...\n', ...
            strCase, nArgsReq);
        msg_out = run_method_params(fTestNew, nArgsReqNew, varargin{2:end});
        
    end
    
else
    
    % Run through the options at this level
    for iOpt = 1:nArgOpts
        
        % Extract the argument
        iArg = fArg(iOpt);
        
        % Setup a string to help with debugging
        try
            strCase = char(iArg);
        catch
            strCase = fprintf('%d of %d', iOpt, nArgOpts);
        end
        fprintf('\nRunning case %s...\n', ...
            strCase, nArgsReq);
        
        % Run the actual tests
        try
            fTest(iArg)
        catch ME
            strError = sprintf(['The following error occured during ' ...
                'the test:\n\n\t%s\n'], ME.getReport);
            fprintf(2, '%s', strError);
            msg_all = [msg_all, {strError}]; %#ok<AGROW>
        end
        
    end
    
    % Return the error count
    msg_out = msg_all;
    
end

end

% ====================================================================== %

function restore_file(fnTemp, fnOrig)

% Restore the original file
[success, msg, msgid] = movefile(fnTemp, fnOrig, 'f');
if ~success
    error(msgid, msg);
end

end
