function createParametersMriSessionFileAtPresentationComputerATWM1()

clear all;
clc;

global iStudy

iStudy = 'ATWM1';
%{
% add path to locally stored study parameter files
folderDefinition.studyParametersLocalMriScanner = strcat('D:\presentation\Bittner\1_Scripting\', iStudy, '\Study_Parameters');
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
%}
%% Prepare execution of general matlab functions on MRI Presentation PC
[folderDefinition, bMriServerFolderCanBeAccessed] = prepareExecutionOfScriptsOnMriPresentationComputerATWM1();
if bMriServerFolderCanBeAccessed == false
    return
end


%% Execute general matlab function
hFunction = str2func(sprintf('createParametersMriSessionFile%s', iStudy));
feval(hFunction);


end