function TEST2()


clear all;
clc;

global iStudy

iStudy = 'ATWM1';

folderDefinition.studyParametersLocalMriScanner = strcat('D:\presentation\Bittner\Scripts\', iStudy, '\Study_Parameters\');

% REMOVE
folderDefinition.studyParametersLocalMriScanner = 'D:\Daten\ATWM1\_TEST\Local\Study_Parameters\';
% REMOVE

% add path to locally stored study parameter files
addpath(folderDefinition.studyParametersLocalMriScanner);


folderDefinition            = feval(str2func(strcat('folderDefinition', iStudy)));
parametersStudy             = feval(str2func(strcat('parametersStudy', iStudy)));
parametersGroups            = feval(str2func(strcat('parametersGroups', iStudy)));
parametersParadigm_WM_MRI   = feval(str2func(strcat('parametersParadigm_WM_MRI_', iStudy)));

% Load addtional folder information
hFunction = str2func(sprintf('folderDefinitionLogfileMriTransfer%s', iStudy));
folderDefinition = feval(hFunction, folderDefinition);

% REMOVE
folderDefinition.logfilesLocalMriScanner            = 'D:\Daten\ATWM1\_TEST\Local\'
folderDefinition.logfilesServerMriScanner           = 'D:\Daten\ATWM1\_TEST\Server\Logfiles\'
folderDefinition.studyParametersLocalMriScanner     = 'D:\Daten\ATWM1\_TEST\Local\Study_Parameters\'
folderDefinition.studyParametersServerMriScanner    = folderDefinition.studyParameters
folderDefinition.matlabLocalMriScanner              = 'D:\Daten\ATWM1\_TEST\Local\Matlab\'
folderDefinition.matlabServerMriScanner             = folderDefinition.matlab
folderDefinition.dataAcquisition                    = 'D:\Daten\ATWM1\_TEST\Data_Acquisition\'
% REMOVE

% add paths required for scripts
addpath(folderDefinition.matlabLocalMriScanner);

%% Copy matlab files from server
copyParameterFilesFromServerATWM1(folderDefinition)
copyScriptsFromServerATWM1(folderDefinition)

%% Select subject
aSubject = processSubjectArrayATWM1_IMAGING;
[strGroup, strSubject] = selectGroupAndSubjectIdATWM1(parametersGroups, aSubject);


%% Find zipped Presentation scenario files on server
strFolder = strcat(folderDefinition.presentationScenarioFilesServerMriScanner, strGroup, '\', strSubject, '\')

%% Remove previously added paths
rmpath(folderDefinition.studyParametersLocalMriScanner);
rmpath(folderDefinition.matlabLocalMriScanner);


end