function varargout = run_tests(varargin)

% Work out if we're doing any filtering
[doFilter, fFilter, idxStart] = check_mode(varargin);

% Set up the path
oldpath = addpath(pwd, fullfile(pwd, 'tests', 'res'));

% Do this once, to pre-fill the persistant variable
utils.find_subclasses('CalcDetectSigs');

isOld = verLessThan('matlab', '8.2'); %$2013b
if isOld
    wngState = warning('off', 'CalcVelocityRadon:BadToolbox');
    warning('off', 'CalcFindROIsFLIKA:FindROIs:BadToolbox')
    warning('off', 'CalcDetectSigsClsfy:BadToolbox')
    warning('off', 'MATLAB:unittest:TestSuite:FileExcluded')
    warning('off', 'MATLAB:uitabgroup:OldVersion')
end

% Run the tests
import matlab.unittest.TestSuite;

doAll = idxStart - nargin == 1;
if doAll
    
    % Assume we want to run all tests, and create a suite from the folder
    dirTest = [pwd filesep 'tests'];
    try
        Suite = TestSuite.fromFolder(dirTest);
    catch
        addpath(fullfile(pwd, 'tests'))
        testNames = utils.find_subclasses('matlab.unittest.TestCase', ...
            true, true, false);
        varargout{1} = run_tests(varargin{:}, testNames{:});
        path(oldpath);
        return
    end
    
else
    
    % Assume we only want to run certain tests
    testsToRun = varargin(idxStart:end);
    if ischar(testsToRun)
        testsToRun = {testsToRun};
    end
    nTests = length(testsToRun);
    Suite = [];
    for iTest = 1:nTests
        
        hasExt = strcmpi(testsToRun{iTest}(end-1:end), '.m');
        if ~hasExt
            testsToRun{iTest} = [testsToRun{iTest} '.m'];
        end
        
        testFile = fullfile(pwd, 'tests', testsToRun{iTest});
        
        try
            Suite = [Suite, TestSuite.fromFile(testFile)]; %#ok<AGROW>
        catch ME
            [~, fnTest, ~] = fileparts(testFile);
            warning('RunTests:BadFromFile', ['An error occured when ' ...
                'attempting to import tests from the file "%s" '...
                'see below:\n\t%s\n'], fnTest, ME.message)
        end
        
    end
    
end

% Only run if we have tests to run
results = [];
if ~isempty(Suite)

    % Filter the tests, if necessary
    if doFilter
        try
            Suite = fFilter(Suite);
        catch ME
            warning(ME.identifier, ME.message)
        end
    end
    
    % Run the tests
    results = Suite.run();

end

% Assign the output argument
if nargout > 0
    varargout{1} = results;
end

% Restore the warnings
if isOld
    warning(wngState);
end

% Restore the path
path(oldpath);

end

% ---------------------------------------------------------------------- %

function [doFilter, fFilter, idxStart] = check_mode(args)

    % Setup the default arguments
    fFilter = [];
    idxStart = 1;
    modes = {...
        '-interactive', ...
        '-nointeractive'};
    
    % Work out if we're filtering the tests
    doFilter = numel(args) > 0 && (ischar(args{1}) || ...
        isempty(args{1})) && any(strcmpi(args{1}, modes));
    
    % Check if we have a new enough matlab for filtering the tests
    hasLicence = utils.verify_license('MATLAB', 'run_tests', ...
        'matlab', '8.5');
    if hasLicence
        import matlab.unittest.selectors.HasTag;
    elseif doFilter
        warning('RunTests:CheckMode:OldMatlab', ['MATLAB version ', ...
            'R2015a (8.5) or higher is required to filter tests.  All '...
            '(or all specified) tests will be run.'])
    end
    
    % Setup the appropriate filters
    if doFilter && hasLicence
        
        % Pull out the mode
        mode = args{1};
        idxStart = 2;
        
        % Return if the mode is empty or we don't have a licence
        if isempty(mode) || ~hasLicence
            return
        end
        
        switch lower(mode)
            
            % Do only interactive tests (i.e. involving java robot)
            case '-interactive'
                fFilter = @(Suite) Suite.selectIf(HasTag('interactive'));
                
            % Do only non-interative tests (i.e. those 
            case '-nointeractive'
                fFilter = @(Suite) Suite.selectIf(~HasTag('interactive'));
                
            % Throw an error for unrecognised tests
            otherwise
                error('RunTests:CheckMode:Unknown', ['The mode "%s" ' ...
                    'is not recognised'], mode)
        end
        
    end

end