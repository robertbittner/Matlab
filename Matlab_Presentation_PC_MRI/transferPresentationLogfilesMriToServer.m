function transferPresentationLogfilesMriToServer()

clear all;
clc;

global iStudy

iStudy = 'ATWM1';

% add path to locally stored study parameter files
folderDefinition.studyParametersLocalMriScanner = strcat('D:\presentation\Bittner\1_Scripting\', iStudy, '\Study_Parameters');
addpath(folderDefinition.studyParametersLocalMriScanner);

% Load parameter
folderDefinition            = feval(str2func(strcat('folderDefinition', iStudy)));
parametersStudy             = feval(str2func(strcat('parametersStudy', iStudy)));
parametersGroups            = feval(str2func(strcat('parametersGroups', iStudy)));
parametersParadigm_WM_MRI   = feval(str2func(strcat('parametersParadigm_WM_MRI_', iStudy)));

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
copyParameterFilesFromServerATWM1(folderDefinition)
copyScriptsFromServerATWM1(folderDefinition)

%% Select subject
aSubject = processSubjectArrayATWM1_IMAGING;
[strGroup, strSubject] = selectGroupAndSubjectIdATWM1(parametersGroups, aSubject);

%% Prepare 
[aStrPathPresentationLogfilesLocal, nLogfiles, nMissingFiles] = createLogfileInformationATWM1(folderDefinition, parametersStudy, parametersParadigm_WM_MRI, strSubject);
[aStrPathPresentationLogfilesServer, bLogfilesExistsOnServer, bOverwriteExistingFiles, bAbort] = prepareLogfileCopyingATWM1(folderDefinition, strGroup, strSubject, aStrPathPresentationLogfilesLocal, nLogfiles);
if bAbort == true
    return
end

copyLogfilesToServerATWM1(aStrPathPresentationLogfilesLocal, aStrPathPresentationLogfilesServer, nLogfiles, bLogfilesExistsOnServer, bOverwriteExistingFiles)

%% Remove previously added paths
rmpath(folderDefinition.studyParametersLocalMriScanner);
rmpath(folderDefinition.matlabLocalMriScanner);

deletePresentationScenarioFilesAfterDataAcquisitionATWM1(folderDefinition, strSubject);

end


function [aStrPathPresentationLogfilesLocal, nLogfiles, nMissingFiles] = createLogfileInformationATWM1(folderDefinition,  parametersStudy, parametersParadigm_WM_MRI,strSubject)
global iStudy

% Determine names of logfiles
nLogfiles = 0;
for cco = 1:parametersParadigm_WM_MRI.nConditions
    % WM instruction
    nLogfiles = nLogfiles + 1;
    aStrPathPresentationLogfilesLocal{nLogfiles} = sprintf('%s%s-%s_%s_%s_%s_Instruction.log', folderDefinition.logfilesLocalMriScanner, strSubject, iStudy, parametersStudy.strFullWorkingMemoryTask, parametersStudy.strMRI, parametersParadigm_WM_MRI.aConditions{cco});
    % WM task
    nLogfiles = nLogfiles + 1;
    aStrPathPresentationLogfilesLocal{nLogfiles} = sprintf('%s%s-%s_%s_%s_%s_Run1.log', folderDefinition.logfilesLocalMriScanner, strSubject, iStudy, parametersStudy.strFullWorkingMemoryTask, parametersStudy.strMRI, parametersParadigm_WM_MRI.aConditions{cco});
end
% Localizer
nLogfiles = nLogfiles + 1;
aStrPathPresentationLogfilesLocal{nLogfiles} = sprintf('%s%s-%s_%s_%s.log', folderDefinition.logfilesLocalMriScanner, strSubject, iStudy, parametersStudy.strFullLocalizer, parametersStudy.strMRI);

nMissingFiles = 0;
for cf = 1:nLogfiles
    if ~exist(aStrPathPresentationLogfilesLocal{cf}, 'file')
        strMessage = sprintf('Logfile %s not found\n', aStrPathPresentationLogfilesLocal{cf});
        disp(strMessage);
        nMissingFiles = nMissingFiles + 1;
    end
end

% Add special prompt for incomplete files
if nMissingFiles > 0
    strMessage = sprintf('\nError: %i missing logfiles for subject %s!\n', nMissingFiles, strSubject);
    disp(strMessage);
else
    strMessage = sprintf('\nLogfiles complete for subject %s!\n', strSubject);
    disp(strMessage);
end


end


function [aStrPathPresentationLogfilesServer, bLogfilesExistsOnServer, bOverwriteExistingFiles, bAbort] = prepareLogfileCopyingATWM1(folderDefinition, strGroup, strSubject, aStrPathPresentationLogfilesLocal, nLogfiles)
%% Prepare file copy
% Determine file path on server

strGroupLogfileFolderServer = strcat(folderDefinition.logfilesServerMriScanner, '\', strGroup, '\');
if ~exist(strGroupLogfileFolderServer, 'dir')
    mkdir(strGroupLogfileFolderServer);
end
strSubjectLogfileFolderServer = strcat(strGroupLogfileFolderServer, '\', strSubject, '\');
if ~exist(strSubjectLogfileFolderServer, 'dir')
    mkdir(strSubjectLogfileFolderServer);
end

aStrPathPresentationLogfilesServer = strrep(aStrPathPresentationLogfilesLocal, folderDefinition.logfilesLocalMriScanner, strSubjectLogfileFolderServer);

% Detect existing files on server
for cf = 1:nLogfiles
    if exist(aStrPathPresentationLogfilesServer{cf}, 'file')
        bLogfilesExistsOnServer(cf) = 1;
    else
        bLogfilesExistsOnServer(cf) = 0;
    end
end
nExistingLogfilesServer = sum(bLogfilesExistsOnServer);

% Select options for existing files
if nExistingLogfilesServer > 0
    strQuestion = sprintf('%s logfiles already found on server.', nExistingLogfilesServer);
    strTitle = 'Logfiles found on server';
    strOption1 = 'Skip existing files';
    strOption2 = 'Overwrite';
    strOption3 = 'Cancel';
    choice = questdlg(strQuestion, strTitle, strOption1, strOption2, strOption3, strOption1);
    switch choice
        case strOption1
            strMessage = sprintf('Preserving logfiles on server');
            disp(strMessage);
            bOverwriteExistingFiles = false;
            bAbort = false;
        case strOption2
            strMessage = sprintf('Overwriting logfiles on server');
            disp(strMessage);
            bOverwriteExistingFiles = true;
            bAbort = false;
        case strOption3
            strMessage = sprintf('Aborting function');
            disp(strMessage);
            bOverwriteExistingFiles = false;
            bAbort = true;
            return
    end
else
    bOverwriteExistingFiles = true;
end


end


function copyLogfilesToServerATWM1(aStrPathPresentationLogfilesLocal, aStrPathPresentationLogfilesServer, nLogfiles, bLogfilesExistsOnServer, bOverwriteExistingFiles)
%% Copy logfiles to server
for cf = 1:nLogfiles
    if exist(aStrPathPresentationLogfilesLocal{cf}, 'file')
        if bLogfilesExistsOnServer(cf) == false || bOverwriteExistingFiles == true
            [success(cf)] = copyfile(aStrPathPresentationLogfilesLocal{cf}, aStrPathPresentationLogfilesServer{cf}, 'f');
            if success(cf)
                strMessage = sprintf('Logfile %s\nsucessfully copied to server.\n', aStrPathPresentationLogfilesLocal{cf});
                disp(strMessage);
            end
        else
            strMessage = sprintf('Existing logfile %s\nwas not overwritten.\n', aStrPathPresentationLogfilesServer{cf});
            disp(strMessage);
        end
    else
        strMessage = sprintf('Logfile %s\ncould not be copied\n', aStrPathPresentationLogfilesLocal{cf});
        disp(strMessage);
    end
end


end