function transferMriScanSessionFilesATMW1()
%%% Moves DICOM files and Presentation logfiles from beoserv to the local
%%% server, adds the parametersMriSession.m file, creates a zip archive and 
%%% stores it locally and on the server. 

clear all
clc

global iStudy
global strSubject
global strGroup
global iSession

global bTestConfiguration

iStudy = 'ATWM1';

bTestConfiguration = false;

folderDefinition            = eval(['folderDefinition', iStudy]);
parametersStudy             = eval(['parametersStudy', iStudy]);
parametersDialog            = eval(['parametersDialog', iStudy]);
%parametersDicomFiles        = eval(['parametersDicomFiles', iStudy]);
parametersFileTransfer      = eval(['parametersFileTransfer', iStudy]);

parametersProjectFiles      = eval(['parametersProjectFiles', iStudy]);
parametersGroups            = eval(['parametersGroups', iStudy]);

parametersParadigm_WM_MRI   = eval(['parametersParadigm_WM_MRI_', iStudy]);

parametersStructuralMriSequenceHighRes  = eval(['parametersStructuralMriSequenceHighRes', iStudy]);
%parametersStructuralMriSequenceLowRes   = eval(['parametersStructuralMriSequenceLowRes', iStudy]);
%parametersFunctionalMriSequence_WM      = eval(['parametersFunctionalMriSequence_WM_', iStudy]);
%parametersFunctionalMriSequence_LOC     = eval(['parametersFunctionalMriSequence_LOC_', iStudy]);
%parametersFunctionalMriSequence_COPE    = eval(['parametersFunctionalMriSequence_COPE_', iStudy]);

strStudyType = defineStudyTypeImaging(parametersStudy);


if ~bTestConfiguration
    hFunction = str2func(sprintf('prepareMriScanSessionFilesTransfer%s', iStudy));
    [folderDefinition, parametersFileTransfer, aStrSubject, nSubjects, vSessionIndex, bAbort] = feval(hFunction, folderDefinition, parametersGroups, parametersFileTransfer);
else
    [folderDefinition, parametersProjectFiles, aStrSubject, nSubjects, vSessionIndex, bAbort] = setTestConfigurationParametersATWM1(folderDefinition, parametersGroups, parametersProjectFiles);
end
if bAbort == true
    return
end

%{
%%% Adjust parametersProjectFiles to parametersFileTransfer
parametersProjectFiles.bCreateProjectFiles                          = parametersFileTransfer.bCreateProjectFiles;
parametersProjectFiles.bCompleteTransferBeforeProjectFileCreation   = parametersFileTransfer.bCompleteTransferBeforeProjectFileCreation;
%}

%%{
%%% REMOVE
%%% CHANGE LOCATION OF DATA FOLDER
folderDefinition.dicomFileTransferFromScanner = 'D:\Daten\ATWM1\Archive_DICOM_Files\Michael_Schaum\OriginalDatasets\';
folderDefinition.dicomFileTransferFromScanner = 'D:\Daten\ATWM1\Archive_DICOM_Files\';
fprintf('CHANGING DATA TRANSFER FOLDER TO %s\n', folderDefinition.dicomFileTransferFromScanner);
%}
%%% REMOVE
if parametersFileTransfer.bCreateProjectFiles == true
    fprintf('Implementation of project file creation not yet complete, switching to file transfer only!\n\n');
    parametersFileTransfer.bCreateProjectFiles = false;
end
%%% REMOVE

for cs = 1:nSubjects
    strSubject = aStrSubject{cs};
    iSession = vSessionIndex(cs);
    [strFolderOriginalDicomFilesSubject, bSubjectFolderFound, bAbort] = determineSubjectFolderWithOriginalDicomFilesATWM1(folderDefinition, parametersDialog);
    if bAbort == true
        return
    elseif bSubjectFolderFound == false
        continue
    end
    
    [parametersMriSession, aStrOriginalDicomFiles, aStrPathOriginalDicomFiles, aStrPathMissingDicomFiles, bSkipSubject] = verifyDicomFilesATWM1(strFolderOriginalDicomFilesSubject);
    if bSkipSubject
        continue
    end
    
    %%{
    %try
        % Transfer files
        executeMriScanSessionFilesTransferATWM1(folderDefinition, parametersStudy, parametersMriSession, parametersFileTransfer, parametersParadigm_WM_MRI, parametersStructuralMriSequenceHighRes, aStrOriginalDicomFiles, aStrPathOriginalDicomFiles)
        %{
    catch
        fprintf('Error while transferring files for subject %s!\nSkipping subject!\n\n', strSubject);
        continue
    end
    %}
end

end


function [folderDefinition, parametersFileTransfer, aStrSubject, nSubjects, vSessionIndex, bAbort] = prepareMriScanSessionFilesTransferATWM1(folderDefinition, parametersGroups, parametersFileTransfer)

global iStudy
global strGroup
global iSession

aStrSubject = [];
nSubjects = [];
vSessionIndex = [];

%%% Check server access
bAllFoldersCanBeAccessed = checkLocalComputerFolderAccessATWM1(folderDefinition);
if bAllFoldersCanBeAccessed == false
    bAbort = true;
    return
end

%%% Load additional folder definitions
hFunction = str2func(sprintf('addServerFolderDefinitions%s', iStudy));
folderDefinition = feval(hFunction, folderDefinition);

%%% Select file transfer options
hFunction = str2func(sprintf('selectFileTransferOptions%s', iStudy));
[folderDefinition, parametersFileTransfer, bAbort] = feval(hFunction, folderDefinition, parametersFileTransfer);
if bAbort
    return
end

%%% Select subjects
aSubject = processSubjectArrayATWM1_IMAGING;
strDialogSelectionModeSubject = 'multiple';
iSession = 1;

[strGroup, ~, aStrSubject, nSubjects, bAbort] = selectGroupAndSubjectIdATWM1(parametersGroups, aSubject, strDialogSelectionModeSubject);
if bAbort == true
    return
end

%%% Determine session for each subject
[vSessionIndex, bAbort] = determineMriSessionATWM1(aStrSubject, nSubjects);
if bAbort
    return
end


end


function [parametersMriSession, aStrOriginalDicomFiles, aStrPathOriginalDicomFiles, aStrPathMissingDicomFiles, bSkipSubject] = verifyDicomFilesATWM1(strFolderOriginalDicomFilesSubject)

global strSubject

bSkipSubject = false;
% Load ParametersMriScan for subject
parametersMriSession = analyzeParametersMriScanFileATWM1;
if isempty(parametersMriSession)
    fprintf('Error! ParametersMriScanFile for subject %s not found!\nSkipping subject!\n', strSubject);
    bSkipSubject = true;
    
    aStrOriginalDicomFiles = [];
    aStrPathOriginalDicomFiles = [];
    aStrPathMissingDicomFiles = [];
    return
end

[parametersMriSession, aStrOriginalDicomFiles, aStrPathOriginalDicomFiles, aStrPathMissingDicomFiles, bDicomFilesComplete] = checkOriginalDicomFilesATWM1(parametersMriSession, strFolderOriginalDicomFilesSubject);
if ~bDicomFilesComplete
    bSkipSubject = true;
    return
end

end


function executeMriScanSessionFilesTransferATWM1(folderDefinition, parametersStudy, parametersMriSession, parametersFileTransfer, parametersParadigm_WM_MRI, parametersStructuralMriSequenceHighRes, aStrOriginalDicomFiles, aStrPathOriginalDicomFiles)

global iStudy
global strGroup
global strSubject

% Transfer DICOM files
[strFolderLocalArchiveDicomFilesGroup, strFolderLocalArchiveDicomFilesSubject, strFolderServerArchiveDicomFilesGroup, strFolderServerArchiveDicomFilesSubject, aStrLocalPathOriginalDicomFiles, bDicomLocalTransfer, bDicomServerTransfer] = transferDicomFilesATWM1(folderDefinition, parametersMriSession, aStrOriginalDicomFiles, aStrPathOriginalDicomFiles, parametersFileTransfer);

% Transfer Presentation logfiles
[bLogfilesLocalTransfer, bLogfilesServerTransfer] = transferPresentationLogfilesATWM1(folderDefinition, parametersStudy, parametersParadigm_WM_MRI, parametersFileTransfer, strFolderLocalArchiveDicomFilesSubject, strFolderServerArchiveDicomFilesSubject);

% Transfer ParametersMriScanFile
[bParametersFileLocalTransfer, bParametersFileServerTransfer] = transferParametersMriScanFileATWM1(folderDefinition, strFolderLocalArchiveDicomFilesSubject, strFolderServerArchiveDicomFilesSubject);

% Zip archive files
zipMriSessionFilesLocalAndServerATWM1(parametersStudy, parametersFileTransfer, strFolderLocalArchiveDicomFilesGroup, strFolderLocalArchiveDicomFilesSubject, strFolderServerArchiveDicomFilesGroup, bDicomLocalTransfer, bLogfilesLocalTransfer, bParametersFileLocalTransfer, bDicomServerTransfer, bLogfilesServerTransfer, bParametersFileServerTransfer);

% Transfer highRes anatomy so separate archive folder
if parametersFileTransfer.bArchiveAnonymisedHighResAnatomySeparately
    [strPathLocalZipFileAnonymisedHighResAnatomy, strPathServerZipFileAnonymisedHighResAnatomy, success] = archiveAnonymisedHighResAnatomyToServerATWM1(folderDefinition, parametersMriSession, parametersStructuralMriSequenceHighRes, aStrLocalPathOriginalDicomFiles, parametersFileTransfer);
end

end


function [strFolderOriginalDicomFilesSubject, bSubjectFolderFound, bAbort] = determineSubjectFolderWithOriginalDicomFilesATWM1(folderDefinition, parametersDialog)

global strSubject

[aStrFolderOriginalDicomFilesSubject, nrOfSubjFolders] = searchForFolderContainingSubjectDicomFilesATMW1(folderDefinition);

bAbort = false;
bSubjectFolderFound = true;
if nrOfSubjFolders == 0
    strFolderOriginalDicomFilesSubject = '';
    bSubjectFolderFound = false;
    fprintf('No folder containing DICOM files found for subject %s.\nSkipping subject.\n\n', strSubject);
elseif nrOfSubjFolders == 1
    strFolderOriginalDicomFilesSubject = aStrFolderOriginalDicomFilesSubject{1};
else
    % Special case of more than 1 folder for selected subject
    bInvalidFolderSelected = true;
    while bInvalidFolderSelected
        startFolder = strcat(dicomFileTransferFromScanner);
        strTitle = sprintf('Multiple folders exist for subject %s. Please select folder.', strSubject);
        strFolderOriginalDicomFilesSubject = uigetdir(startFolder, strTitle);
        if ~isempty(find(strfind(strFolderOriginalDicomFilesSubject, strSubject), 1))
            bInvalidFolderSelected = false;
        else
            strTitle = 'Select DICOM file folder';
            strMessage = sprintf('No valid DICOM file folder selected for subject %s!\nPlease retry.', strSubject);
            strButton1 = sprintf('%sRetry%s', parametersDialog.strEmpty, parametersDialog.strEmpty);
            strButton2 = sprintf('%sCancel%s', parametersDialog.strEmpty, parametersDialog.strEmpty);
            default = strButton1;
            choice = questdlg(strMessage, strTitle, strButton1, strButton2, default);
            switch choice
                case strButton1

                otherwise
                    bAbort = true;
                    strMessage = sprintf('Function aborted by user.');
                    disp(strMessage);
            end
            if bAbort == true
                bInvalidFolderSelected = false;
                strFolderOriginalDicomFilesSubject = '';
            end
        end
    end
end
if bSubjectFolderFound
    strMessage = sprintf('Folder containing DICOM files found for subject %s!\n', strSubject);
    disp(strMessage);
end

end


function [aStrFolderOriginalDicomFilesSubject, nrOfSubjFolders] = searchForFolderContainingSubjectDicomFilesATMW1(folderDefinition)
%%% Search for folder containing DICOM files of selected subject

global strSubject

dicomFileTransferFromScanner = folderDefinition.dicomFileTransferFromScanner;
strucFolderContentTransferFromScanner = dir(dicomFileTransferFromScanner);
strucFolderContentTransferFromScanner = strucFolderContentTransferFromScanner(3:end);
nrOfSubjFolders = 0;
for ccont = 1:numel(strucFolderContentTransferFromScanner)
    strFolderContent = strucFolderContentTransferFromScanner(ccont).name;
    strPathSubfolder = strcat(dicomFileTransferFromScanner, strFolderContent);
    if exist(strPathSubfolder, 'dir')
        if ~isempty(find(strfind(strPathSubfolder, strSubject), 1))
            nrOfSubjFolders = nrOfSubjFolders + 1;
            aStrFolderOriginalDicomFilesSubject{nrOfSubjFolders} = strPathSubfolder;
        end
    end
end

end


function [strFolderLocalArchiveDicomFilesGroup, strFolderLocalArchiveDicomFilesSubject, strFolderServerArchiveDicomFilesGroup, strFolderServerArchiveDicomFilesSubject, aStrLocalPathOriginalDicomFiles, bDicomLocalTransfer, bDicomServerTransfer] = transferDicomFilesATWM1(folderDefinition, parametersMriSession, aStrOriginalDicomFiles, aStrPathOriginalDicomFiles, parametersFileTransfer)
%%% Transfer all files to local computer & server

global strGroup
global strSubject

[parametersFileTransfer] = calculateFileTransferProgressStepsATWM1(parametersFileTransfer, parametersMriSession.nDicomFiles);

%%% Copy DICOM files to local archive
strFileDestinationLocal                 = folderDefinition.strLocal;
strFolderLocalArchiveDicomFilesGroup    = strcat(folderDefinition.archiveDICOMfiles, strGroup, '\');
strFolderLocalArchiveDicomFilesSubject  = strcat(strFolderLocalArchiveDicomFilesGroup, strSubject, '\');

if ~exist(strFolderLocalArchiveDicomFilesSubject, 'dir')
    mkdir(strFolderLocalArchiveDicomFilesSubject);
end

fprintf('Starting file transfer for subject %s to %s.\n', strSubject, upper(strFileDestinationLocal));
success = [];
for cf = 1:parametersMriSession.nDicomFiles
    aStrLocalPathOriginalDicomFiles{cf} = fullfile(strFolderLocalArchiveDicomFilesSubject, aStrOriginalDicomFiles{cf});
    strPathOriginalDicomFilesSubject = aStrPathOriginalDicomFiles{cf};
    if parametersFileTransfer.bOverwriteExistingFiles == true || ~exist(aStrLocalPathOriginalDicomFiles{cf}, 'file')
        success(cf) = copyfile(strPathOriginalDicomFilesSubject, aStrLocalPathOriginalDicomFiles{cf});
        if ismember(sum(success), parametersFileTransfer.vFileTransferProgress)
            displayFileTransferProgressATWM1(parametersFileTransfer, success, strFileDestinationLocal);
        end
    else
        success(cf) = 1;
    end
end

[bDicomLocalTransfer] = determineDicomFileTransferSuccessATWM1(parametersMriSession, success, strFileDestinationLocal);

%%{
%%% Copy DICOM files from local archive to server archive (Copying from 
%%% DICOM folder on common to server archive might lead to errors!)
if parametersFileTransfer.bArchiveFilesOnServer
    strFileDestinationServer                = folderDefinition.strServer;
    strFolderServerArchiveDicomFiles        = folderDefinition.archiveDICOMfilesServer;
    strFolderServerArchiveDicomFilesGroup   = strcat(strFolderServerArchiveDicomFiles, strGroup, '\');
    strFolderServerArchiveDicomFilesSubject = strcat(strFolderServerArchiveDicomFilesGroup, strSubject, '\');
    
    if ~exist(strFolderServerArchiveDicomFilesSubject, 'dir')
        mkdir(strFolderServerArchiveDicomFilesSubject);
    end

    fprintf('Starting file transfer for subject %s to %s.\n', strSubject, upper(strFileDestinationServer));
    success = [];
    for cf = 1:parametersMriSession.nDicomFiles
        aStrServerPathOriginalDicomFiles{cf} = fullfile(strFolderServerArchiveDicomFilesSubject, aStrOriginalDicomFiles{cf});
        if parametersFileTransfer.bOverwriteExistingFiles == true || ~exist(aStrServerPathOriginalDicomFiles{cf}, 'file')
            success(cf) = copyfile(aStrLocalPathOriginalDicomFiles{cf}, aStrServerPathOriginalDicomFiles{cf});
            if ismember(sum(success), parametersFileTransfer.vFileTransferProgress)
                displayFileTransferProgressATWM1(parametersFileTransfer, success, strFileDestinationServer);
            end
        else
            success(cf) = 1;
        end
    end

    [bDicomServerTransfer] = determineDicomFileTransferSuccessATWM1(parametersMriSession, success, strFileDestinationServer);
else
    fprintf('Files for subject %s are NOT archived on server!\n\n', strSubject);
    strFolderServerArchiveDicomFilesGroup = '';
    strFolderServerArchiveDicomFilesSubject = '';
    bDicomServerTransfer = false;
end
%}
end


function [parametersFileTransfer] = calculateFileTransferProgressStepsATWM1(parametersFileTransfer, nFiles)

magnitudeOrderFileNumber = length(num2str(nFiles));
magnitude = 10^(magnitudeOrderFileNumber - 1);
factor = floor(nFiles / magnitude);
step = magnitude * factor * parametersFileTransfer.transferProgressFraction;

parametersFileTransfer.vFileTransferProgress = step:step:nFiles;


end


function displayFileTransferProgressATWM1(parametersFileTransfer, success, strFileDestination)

global strSubject

fprintf('%i files of subject %s transferred to %s.\n', sum(success), strSubject, upper(strFileDestination));


if isequal(sum(success), parametersFileTransfer.vFileTransferProgress(end))
    fprintf('\n');
end

end


function [bDicomLocalTransfer] = determineDicomFileTransferSuccessATWM1(parametersMriSession, success, strFileDestination)

global strSubject

if sum(success) == parametersMriSession.nDicomFiles
    bDicomLocalTransfer = true;
    fprintf('All %i DICOM files of subject %s successfully copied to %s!\n\n', parametersMriSession.nDicomFiles, strSubject, upper(strFileDestination));
else
    bDicomLocalTransfer = false;
    nrOfFilesNotCopied = parametersMriSession.nDicomFiles - sum(success);
    fprintf('Error while copying DICOM files of subject %s to %s!\n', strSubject, upper(strFileDestination));
	fprintf('%i DICOM files were not copied!\n\n', nrOfFilesNotCopied);
end

end


function [bLogfilesLocalTransfer, bLogfilesServerTransfer] = transferPresentationLogfilesATWM1(folderDefinition, parametersStudy, parametersParadigm_WM_MRI, parametersFileTransfer, strFolderLocalArchiveDicomFilesSubject, strFolderServerArchiveDicomFilesSubject)

global strGroup
global strSubject

%%% Copy Presentation logfiles
[aStrPresentationLogfiles, nLogfiles] = defineNamesOfPresentationLogfilesATWM1(parametersStudy, parametersParadigm_WM_MRI);

%%% Determine local path for logfiles
strFolderLogfilesLocalGroup    = strcat(folderDefinition.logfiles, strGroup, '\');
strFolderLogfilesLocalSubject  = strcat(strFolderLogfilesLocalGroup, strSubject, '\');
for cf = 1:nLogfiles
    aStrPathLocalPresentationLogfiles{cf}           = fullfile(strFolderLogfilesLocalSubject, aStrPresentationLogfiles{cf});
    aStrPathLocalArchivePresentationLogfiles{cf}    = fullfile(strFolderLocalArchiveDicomFilesSubject, aStrPresentationLogfiles{cf});
end

%%% Determine server path for logfiles
strFolderLogfilesServerGroup    = strcat(folderDefinition.logfilesServer, strGroup, '\');
strFolderLogfilesServerSubject  = strcat(strFolderLogfilesServerGroup, strSubject, '\');
for cf = 1:nLogfiles
    aStrPathServerPresentationLogfiles{cf}          = fullfile(strFolderLogfilesServerSubject, aStrPresentationLogfiles{cf});
    aStrPathServerArchivePresentationLogfiles{cf}   = fullfile(strFolderServerArchiveDicomFilesSubject, aStrPresentationLogfiles{cf});
end


%%% Copy logfiles from server to local computer and to subject archive
%%% folders (local and server)
if ~exist(strFolderLogfilesLocalGroup, 'dir')
    mkdir(strFolderLogfilesLocalGroup)
end
if ~exist(strFolderLogfilesLocalSubject, 'dir')
    mkdir(strFolderLogfilesLocalSubject)
end

for cf = 1:nLogfiles
    successLocal(cf)            = copyfile(aStrPathServerPresentationLogfiles{cf}, aStrPathLocalPresentationLogfiles{cf});
end
[bLogfilesFolderTransfer] = determinePresentationLogfileTransferSuccessATWM1(nLogfiles, successLocal, parametersFileTransfer.strLocalAchiveFolder);

for cf = 1:nLogfiles
    successLocalArchive(cf)     = copyfile(aStrPathServerPresentationLogfiles{cf}, aStrPathLocalArchivePresentationLogfiles{cf});
end
[bLogfilesLocalTransfer] = determinePresentationLogfileTransferSuccessATWM1(nLogfiles, successLocalArchive, parametersFileTransfer.strServerAchiveFolder);

if parametersFileTransfer.bArchiveFilesOnServer
    for cf = 1:nLogfiles
        successServerArchive(cf)    = copyfile(aStrPathServerPresentationLogfiles{cf}, aStrPathServerArchivePresentationLogfiles{cf});
    end
    [bLogfilesServerTransfer] = determinePresentationLogfileTransferSuccessATWM1(nLogfiles, successServerArchive, parametersFileTransfer.strLocalLogfilesFolder);
else
    bLogfilesServerTransfer = false;
end

end


function [bLogfilesTransfer] = determinePresentationLogfileTransferSuccessATWM1(nLogfiles, success, strLogfilesDestination)

global strSubject

if sum(success) == nLogfiles
    bLogfilesTransfer = true;
    fprintf('All %i Presentation logfiles of subject %s successfully copied to %s!\n\n', nLogfiles, strSubject, strLogfilesDestination);
else
    bLogfilesTransfer = false;
    nrOfFilesNotCopied = nLogfiles - sum(success);
    fprintf('Error while copying Presentation logfiles of subject %s to %s!\n', strSubject, strLogfilesDestination);
	fprintf('%i Presentation logfiles were not copied!\n\n', nrOfFilesNotCopied);
end

end


function [bParametersFileLocalTransfer, bParametersFileServerTransfer] = transferParametersMriScanFileATWM1(folderDefinition, strFolderLocalArchiveDicomFilesSubject, strFolderServerArchiveDicomFilesSubject)
%%% Copy ParametersMriScan file

global iStudy
global iSession
global strSubject

hFunction = str2func(sprintf('defineParametersMriSessionFileName%s', iStudy));
strParametersMriSessionFile = feval(hFunction, strSubject, iSession);
strPathParametersMriSessionFile = fullfile(folderDefinition.parametersMriScan, strParametersMriSessionFile);
strPathLocalArchiveParametersMriSessionFile     = fullfile(strFolderLocalArchiveDicomFilesSubject, strParametersMriSessionFile);
strPathServerArchiveParametersMriSessionFile    = fullfile(strFolderServerArchiveDicomFilesSubject, strParametersMriSessionFile);

successLocal = copyfile(strPathParametersMriSessionFile, strPathLocalArchiveParametersMriSessionFile);
[bParametersFileLocalTransfer] = determineParametersMriScanFileTransferSuccessATWM1(successLocal, strParametersMriSessionFile, upper(folderDefinition.strLocal));

successServer = copyfile(strPathParametersMriSessionFile, strPathServerArchiveParametersMriSessionFile);
[bParametersFileServerTransfer] = determineParametersMriScanFileTransferSuccessATWM1(successServer, strParametersMriSessionFile, upper(folderDefinition.strServer));

end


function [bParametersFileTransfer] = determineParametersMriScanFileTransferSuccessATWM1(success, strParametersMriSessionFile, strParametersMriScanFileDestination)

global strSubject


if success
    bParametersFileTransfer = true;
    fprintf('Parameter file %s for subject %s successfully copied to %s!\n\n', strParametersMriSessionFile, strSubject, strParametersMriScanFileDestination);
else
    bParametersFileTransfer = false;
    fprintf('Error while copying parameter file %s for subject %s to %s!\nParameter file was not copied!\n\n', strPathParametersMriSessionFile, strSubject, strParametersMriScanFileDestination);
end

end


function zipMriSessionFilesLocalAndServerATWM1(parametersStudy, parametersFileTransfer, strFolderLocalArchiveDicomFilesGroup, strFolderLocalArchiveDicomFilesSubject, strFolderServerArchiveDicomFilesGroup, bDicomLocalTransfer, bLogfilesLocalTransfer, bParametersFileLocalTransfer, bDicomServerTransfer, bLogfilesServerTransfer, bParametersFileServerTransfer)
%%% Zip subject archive folder

global iStudy
global strSubject
global iSession

strZipFileArchiveDicomFilesSubject              = defineZipFileArchiveDicomFilesSubjectATWM1(parametersStudy);
strPathZipFileLocalArchiveDicomFilesSubject     = fullfile(strFolderLocalArchiveDicomFilesGroup, strZipFileArchiveDicomFilesSubject);
strPathZipFileServerArchiveDicomFilesSubject    = fullfile(strFolderServerArchiveDicomFilesGroup, strZipFileArchiveDicomFilesSubject);

% Zip local archive folder
if bDicomLocalTransfer == true && bLogfilesLocalTransfer == true && bParametersFileLocalTransfer == true
    fprintf('Creating file %s\n\n', strPathZipFileLocalArchiveDicomFilesSubject);
    aStrZippedFilesLocal    = zip(strPathZipFileLocalArchiveDicomFilesSubject, strFolderLocalArchiveDicomFilesSubject);
    strMessage = sprintf('MRI session files successfully stored in file %s', strPathZipFileLocalArchiveDicomFilesSubject); 
    disp(strMessage);
else
    strMessage = sprintf('MRI session files were not stored in file %s', strPathZipFileLocalArchiveDicomFilesSubject);
    disp(strMessage);
end

% Copy local zip file to server archive folder
if parametersFileTransfer.bArchiveFilesOnServer
    if bDicomServerTransfer == true && bLogfilesServerTransfer == true && bParametersFileServerTransfer == true
        success = copyfile(strPathZipFileLocalArchiveDicomFilesSubject, strPathZipFileServerArchiveDicomFilesSubject);
        if success
            strMessage = sprintf('MRI session files successfully stored in file %s', strPathZipFileServerArchiveDicomFilesSubject);
            disp(strMessage);
        else
            strMessage = sprintf('MRI session files were not stored in file %s', strPathZipFileServerArchiveDicomFilesSubject);
            disp(strMessage);
        end
    end
end
    
end

