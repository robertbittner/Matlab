function [folderDefinition, bMriServerFolderCanBeAccessed] = prepareExecutionOfScriptsOnMriPresentationComputerATWM1()

global iStudy

% add path to locally stored study parameter files
folderDefinition.studyParametersLocalMriScanner = strcat('D:\presentation\Bittner\1_Scripting\', iStudy, '\Study_Parameters\');
addpath(folderDefinition.studyParametersLocalMriScanner);

% Load parameter
folderDefinition = feval(str2func(strcat('folderDefinition', iStudy)));

% Load addtional folder information
hFunction = str2func(sprintf('folderDefinitionPresentationMri%s', iStudy));
folderDefinition = feval(hFunction, folderDefinition);

% add paths required for scripts
addpath(folderDefinition.matlabLocalMriScanner);
addpath(folderDefinition.exclusiveMatlabLocalMriScanner);

%% Check server access
bMriServerFolderCanBeAccessed = checkMriServerFolderAccessATWM1(folderDefinition);
if bMriServerFolderCanBeAccessed == false
    return
end

%% Copy matlab files from server
copyParameterFilesFromServerATWM1(folderDefinition);
copyScriptsFromServerATWM1(folderDefinition);


end