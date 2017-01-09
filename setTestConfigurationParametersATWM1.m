function [folderDefinition, parametersProjectFiles, aStrSubject, nSubjects, vSessionIndex, bAbort] = setTestConfigurationParametersATWM1(folderDefinition, parametersGroups, parametersProjectFiles)

global iStudy
global iSession
global strGroup

bAbort = false;

parametersProjectFiles.bForceDeletionOfAllExistingFiles = true;

%%% Reduce number of functional runs for testing purposes
parametersProjectFiles.nrOfTotalFunctionalRunsTestConfig = 1;

%%% Add alternative test folder for subject to avoid deletion of processed
%%% data set
parametersProjectFiles.bUseSingleSubjectTestFolder      = true;

fprintf('Test configuration enabled! Subject and parameter selection disabled!\n');
aStrSubject = {
    'VE85QGL'
    };
nSubjects = numel(aStrSubject);
iSession = 1;
strGroup = parametersGroups.strShortControls;
vSessionIndex(1:nSubjects) = 1;

%%% Load additional folder definitions
hFunction = str2func(sprintf('addServerFolderDefinitions%s', iStudy));
folderDefinition = feval(hFunction, folderDefinition);


end