function transferPresentationLogfilesMriToServer()

clear all
clc

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
if ~bMriServerFolderCanBeAccessed
    return
end

%% Copy matlab files from server
try 
    copyParameterFilesFromServerATWM1(folderDefinition);
    copyScriptsFromServerATWM1(folderDefinition);
catch
    reportErrorDuringTransferOfMatlabFilesFromServerToLocalATWM1;
end

%% Select subject
aSubject = processSubjectArrayATWM1_IMAGING;
[strGroup, strSubject, aStrSubject, nSubjects, bAbort] = selectGroupAndSubjectIdATWM1(parametersGroups, aSubject);
%% Prepare 
[aStrPathPresentationLogfilesLocal, nLogfiles, nMissingFiles] = createLogfileInformationATWM1(folderDefinition, parametersStudy, parametersParadigm_WM_MRI,strSubject);
[aStrPathPresentationLogfilesServer, bLogfilesExistsOnServer, bOverwriteExistingFiles, bAbort] = prepareLogfileCopyingATWM1(folderDefinition, strGroup, strSubject, aStrPathPresentationLogfilesLocal, nLogfiles);
if bAbort
    return
end

for c = 1:numel(aStrPathPresentationLogfilesServer)
    test = aStrPathPresentationLogfilesServer{c}
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
aStrPathPresentationLogfilesLocal{nLogfiles} = sprintf('%s%s-%s_%s_%s.log', folderDefinition.logfilesLocalMriScanner, strSubject, iStudy, parametersStudy.strFullLocalizerTask, parametersStudy.strMRI);

nMissingFiles = 0;
for cf = 1:nLogfiles
    if ~exist(aStrPathPresentationLogfilesLocal{cf}, 'file')
        fprintf('Logfile %s not found\n\n', aStrPathPresentationLogfilesLocal{cf});
        nMissingFiles = nMissingFiles + 1;
    end
end

% Add special prompt for incomplete files
if nMissingFiles > 0
    fprintf('\nError: %i missing logfiles for subject %s!\n\n', nMissingFiles, strSubject);
else
    fprintf('\nLogfiles complete for subject %s!\n\n', strSubject);
end


end


function [aStrPathPresentationLogfilesServer, bLogfilesExistsOnServer, bOverwriteExistingFiles, bAbort] = prepareLogfileCopyingATWM1(folderDefinition, strGroup, strSubject, aStrPathPresentationLogfilesLocal, nLogfiles)
%% Prepare file copy
% Determine file path on server

%strGroupLogfileFolderServer = strcat(folderDefinition.logfilesServerMriScanner, '\', strGroup, '\');
strGroupLogfileFolderServer = strcat(folderDefinition.logfilesServerMriScanner, strGroup, '\');

if ~exist(strGroupLogfileFolderServer, 'dir')
    mkdir(strGroupLogfileFolderServer);
end
%strSubjectLogfileFolderServer = strcat(strGroupLogfileFolderServer, '\', strSubject, '\');
strSubjectLogfileFolderServer = strcat(strGroupLogfileFolderServer, strSubject, '\');

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
bAbort = false;
if nExistingLogfilesServer > 0
    strQuestion = sprintf('%s logfiles already found on server.', nExistingLogfilesServer);
    strTitle = 'Logfiles found on server';
    strOption1 = 'Skip existing files';
    strOption2 = 'Overwrite';
    strOption3 = 'Cancel';
    choice = questdlg(strQuestion, strTitle, strOption1, strOption2, strOption3, strOption1);
    switch choice
        case strOption1
            fprintf('Preserving logfiles on server\n');
            bOverwriteExistingFiles = false;
        case strOption2
            fprintf('Overwriting logfiles on server\n');
            bOverwriteExistingFiles = true;
        otherwise
            fprintf('Aborting function\n');
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
                fprintf('Logfile %s\nsucessfully copied to server.\n\n', aStrPathPresentationLogfilesLocal{cf});
            end
        else
            fprintf('Existing logfile %s\nwas not overwritten.\n\n', aStrPathPresentationLogfilesServer{cf});
        end
    else
        fprintf('Logfile %s\ncould not be copied\n\n', aStrPathPresentationLogfilesLocal{cf});
    end
end


end