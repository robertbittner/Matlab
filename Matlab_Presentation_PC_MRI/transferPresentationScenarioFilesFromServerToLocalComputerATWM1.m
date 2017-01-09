function transferPresentationScenarioFilesFromServerToLocalComputerATWM1()

clear all;
clc;

global iStudy

iStudy = 'ATWM1';

% add path to locally stored study parameter files
folderDefinition.studyParametersLocalMriScanner = strcat('D:\presentation\Bittner\1_Scripting\', iStudy, '\Study_Parameters');
addpath(folderDefinition.studyParametersLocalMriScanner);

% Load parameter
folderDefinition            = feval(str2func(strcat('folderDefinition', iStudy)));
parametersGroups            = feval(str2func(strcat('parametersGroups', iStudy)));

extZip = '.zip';

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

%% Select subject
aSubject = processSubjectArrayATWM1_IMAGING;
[strGroup, strSubject] = selectGroupAndSubjectIdATWM1(parametersGroups, aSubject);

%% Find zipped Presentation scenario files on server
strFolderGroupPresentationScenarioFilesServer = strcat(folderDefinition.presentationScenarioFilesServerMriScanner, strGroup, '\');
strZipFilePresentationScenarioFiles = sprintf('%s_%s_Presentation_Scenario_Files%s', strSubject, iStudy, extZip);
strPathZipFilePresentationScenarioFilesServer = fullfile(strFolderGroupPresentationScenarioFilesServer, strZipFilePresentationScenarioFiles);

if exist(strPathZipFilePresentationScenarioFilesServer, 'file')
    strFolderPresentationScenarioFilesLocal = 'D:\presentation\Bittner\ATWM1\Scenario_Files\';
    strPathZipFilePresentationScenarioFilesLocal = strrep(strPathZipFilePresentationScenarioFilesServer, strFolderGroupPresentationScenarioFilesServer, strFolderPresentationScenarioFilesLocal);
    copyfile(strPathZipFilePresentationScenarioFilesServer, strPathZipFilePresentationScenarioFilesLocal);
    bZipFileFound = true;
else
    strMessage = sprintf('File %s not found!', strPathZipFilePresentationScenarioFilesServer);
    disp(strMessage);
    bZipFileFound = false;
end

%% Dialog for manual selection of zip file
if ~bZipFileFound
    strDefaultSearchFolder = folderDefinition.presentationScenarioFiles;
    strFilterSpec = [strDefaultSearchFolder, '*', extZip];
    strDialogTitle = sprintf('File not found! Please select zip-file.');
    [strZipFilePresentationScenarioFiles, strFolderZipFile] = uigetfile(strFilterSpec,strDialogTitle);
    if ~ischar(strZipFilePresentationScenarioFiles)
        strMessage = sprintf('No file selected. Aborting function.');
        disp(strMessage);
        return
    else
        strPathZipFilePresentationScenarioFilesLocal = [strFolderZipFile, strZipFilePresentationScenarioFiles];
    end
end

%% Unzip scenario files in data aquisition folder
strSubjectFolder = strrep(strZipFilePresentationScenarioFiles, extZip, '');
strFolderPresentationScenarioFiles = strcat(folderDefinition.dataAcquisition, strSubjectFolder);

unzip(strPathZipFilePresentationScenarioFilesLocal, strFolderPresentationScenarioFiles);

%% Remove previously added paths
rmpath(folderDefinition.studyParametersLocalMriScanner);
rmpath(folderDefinition.matlabLocalMriScanner);
rmpath(folderDefinition.exclusiveMatlabLocalMriScanner);

end


