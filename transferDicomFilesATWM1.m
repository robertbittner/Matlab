function transferDicomFilesATWM1()

clear all
clc

global iStudy
global strSubject
global strGroup
global strGroupLong
global iSession

global bTestConfiguration

bTestConfiguration = true;

iStudy = 'ATWM1';

folderDefinition            = eval(['folderDefinition', iStudy]);
parametersStudy             = eval(['parametersStudy', iStudy]);
parametersDialog            = eval(['parametersDialog', iStudy]);
parametersDicomFiles        = eval(['parametersDicomFiles', iStudy]);
parametersFileTransfer      = eval(['parametersFileTransfer', iStudy]);
parametersGroups            = eval(['parametersGroups', iStudy]);
parametersProjectFiles      = eval(['parametersProjectFiles', iStudy]);

parametersStructuralMriSequenceHighRes  = eval(['parametersStructuralMriSequenceHighRes', iStudy]);
parametersStructuralMriSequenceLowRes   = eval(['parametersStructuralMriSequenceLowRes', iStudy]);
parametersFunctionalMriSequence_WM      = eval(['parametersFunctionalMriSequence_WM_', iStudy]);
parametersFunctionalMriSequence_LOC     = eval(['parametersFunctionalMriSequence_LOC_', iStudy]);
parametersFunctionalMriSequence_COPE    = eval(['parametersFunctionalMriSequence_COPE_', iStudy]);

strStudyType = defineStudyTypeImaging(parametersStudy);

%%% Select file transfer options
hFunction = str2func(sprintf('selectFileTransferOptions%s', iStudy));
[folderDefinition, parametersFileTransfer, parametersProjectFiles, bAbort] = feval(hFunction, folderDefinition, parametersFileTransfer, parametersProjectFiles);
if bAbort == true
    return
end

bSingleSubjectSeleted = false;
while ~bSingleSubjectSeleted
    [folderDefinition, parametersProjectFiles, aStrSubject, nSubjects, vSessionIndex, bAbort] = selectGeneralParametersATWM1(folderDefinition, parametersGroups, parametersProjectFiles);
    strSubject = aStrSubject{1};
    if nSubjects == 1
        bSingleSubjectSeleted = true;
    else
        %%% Warning about multiple subject selection
        strMessage = sprintf('The selection of multiple subjects for\nDICOM file transfer is currently not supported.\nPlease select only a single subject!');
        msgbox(strMessage);
    end
end
%strGroup = strGroup
%ett = folderDefinition.dicomFileTransferFromScanner
folderDefinition.strFolderRootTransferFromScanner = folderDefinition.dicomFileTransferFromScanner;
strFolderRootTransferFromScanner = folderDefinition.strFolderRootTransferFromScanner;
%folderDefinition.strFolderTransferFromScanner = 'D:\Daten\ATWM1\Single_Subject_Data\Pilot_Scans\Script_Test\Transfer_from_Scanner\Subject_TEST\'
%return
%%% Search for folder on server
[strPathOriginalDicomFiles, bAbort] = detectDicomFileFolderOnServerATWM1(strFolderRootTransferFromScanner, parametersDialog);
if bAbort == true
    return
end

%%% REMOVE AT LATER STAGE
[parametersProjectFiles] = disableProjectFileCreationATWM1(parametersProjectFiles);

%%% Load ParametersMriScan
parametersMriSession = analyzeParametersMriScanFileATWM1;
if isempty(parametersMriSession)
    return
end

[parametersMriSession, aStrOriginalDicomFiles, aStrPathOriginalDicomFiles, aStrPathMissingDicomFiles, bDicomFilesComplete] = checkOriginalDicomFilesATWM1(parametersMriSession, strPathOriginalDicomFiles)
if ~bDicomFilesComplete
    return
end

return

[bTransferSuccessful] = copyAnonymizedHighResAnatomyToServerATWM1(folderDefinition, parametersMriSession, parametersStructuralMriSequenceHighRes, aStrPathOriginalDicomFiles, aStrOriginalDicomFiles)

%{
s%%% REINSTATE
%%% These lines are only required for the simulation of data transfer
deleteFilesForSimulationATWM1(folderDefinition);
strCommand = sprintf('!matlab -automation -r "simulateDataTransferFromScanner%s" &', iStudy);
eval(strCommand);
%}
%{
strSubjectDataTransferFolder = [];
while isempty(strSubjectDataTransferFolder)
    hFunction = str2func(sprintf('determineDataTransferFolderOfSubject%s', iStudy));
    strSubjectDataTransferFolder = feval(hFunction);
    if isempty(strSubjectDataTransferFolder)
        pause(3);
    end
end
folderDefinition.strFolderTransferFromScanner = strSubjectDataTransferFolder;
%}

%folderDefinition.strFolderTransferFromScanner = 'D:\Daten\ATWM1\Single_Subject_Data\Pilot_Scans\Script_Test\Transfer_from_Scanner\Subject_TEST\'

hFunction = str2func(sprintf('createFolderForDataTransferAndProjectFileCreation%s', iStudy));
feval(hFunction, folderDefinition);

hFunction = str2func(sprintf('setIntialParametersForFileTransferAndProjectFileCreation%s', iStudy));
[nTotalDicomFilesInSession, aStrDicomFilesCurrentlyCopied, nFilesCopied, bFileTransferComplete, nPartialFileTransfers, nTotalFilesTransferred, bIncompatibleBrainVoyagerVersion, maximumNumberOfRuns, bAllFilesCreated] = feval(hFunction);

while bFileTransferComplete == false
    nPartialFileTransfers = nPartialFileTransfers + 1;
    hFunction = str2func(sprintf('detectPartialDicomFileTransferFromScanner%s', iStudy));
    [aStrDicomFilesInScannerTransferFolder, aStrDicomFilesToBeCopied, nDicomFilesTransferred(nPartialFileTransfers)] = feval(hFunction, folderDefinition, parametersDicomFileTransfer, parametersDicomFiles, aStrDicomFilesCurrentlyCopied);
    
    hFunction = str2func(sprintf('copyDicomFilesToSingleSubjectFolder%s', iStudy));
    [aStrDicomFilesCurrentlyCopied, nFilesCopied, nTotalFilesTransferred] = feval(hFunction, folderDefinition, aStrDicomFilesCurrentlyCopied, aStrDicomFilesToBeCopied, nPartialFileTransfers, nDicomFilesTransferred, nTotalFilesTransferred, nFilesCopied);
    
    %%% Check, whether all files of scanning session have been copied
    nFilesInScannerTransferFolder = numel(aStrDicomFilesInScannerTransferFolder);
    nTotalFilesCopied = sum(nFilesCopied);
    if nTotalDicomFilesInSession == nTotalFilesCopied && nFilesInScannerTransferFolder == nTotalDicomFilesInSession
        bFileTransferComplete = true;
    end
    
    %%% Rename Dicom Files
    hFunction = str2func(sprintf('renameDicomFiles%s', iStudy));
    feval(hFunction, folderDefinition.strFolderCurrentSubject);
    hFunction = str2func(sprintf('scanFolderForDicomFiles%s', iStudy));
    [aStrRenamedDicomFiles, nRenamedDicomFiles] = feval(hFunction, folderDefinition.strFolderCurrentSubject, parametersDicomFiles);
    if bFileTransferComplete == true %% && nRenamedDicomFiles == nTotalDicomFilesInSession
        aStrCompleteRenamedDicomFiles = aStrRenamedDicomFiles;
        nCompleteRenamedDicomFiles = nRenamedDicomFiles;
    end
    
    
    %%% Create project files based on the newly transferred data
    hFunction = str2func(sprintf('createProjectFilesDuringDataTransfer%s', iStudy));
    %[aStrPathCreatedFiles, bAllFilesCreated, bIncompatibleBrainVoyagerVersion] = feval(hFunction, aStrPathCreatedFiles, bCreateProjectFiles, bAllFilesCreated, bIncompatibleBrainVoyagerVersion);
    [aStrPathCreatedFiles, bAllFilesCreated, bIncompatibleBrainVoyagerVersion] = feval(hFunction, folderDefinition, aStrPathCreatedFiles, bCreateProjectFiles, bAllFilesCreated, bIncompatibleBrainVoyagerVersion);
end
bSingleSubjectDataComplete = false;
while bSingleSubjectDataComplete == false
    hFunction = str2func(sprintf('confirmCompleteTransferOfDicomFiles%s', iStudy));
    [bSingleSubjectDataComplete] = feval(hFunction, folderDefinition, parametersDicomFiles, aStrDicomFilesCurrentlyCopied, nTotalDicomFilesInSession, bSingleSubjectDataComplete);
end
%%% Prepare zipping of complete data set
hFunction = str2func(sprintf('scanAllFileTransferTargetFolderForDicomFiles%s', iStudy));
[aStrRenamedDicomFiles, aStrDicomFilesInZipFolder, nRenamedDicomFiles, nDicomFilesInZipFolder] = feval(hFunction, folderDefinition, parametersDicomFiles);
aStrFilesToBeZipped = [aStrDicomFilesInZipFolder];

hFunction = str2func(sprintf('zipSingleSubjectData%s', iStudy));
[aStrZippedFiles] = feval(hFunction, folderDefinition, aStrFilesToBeZipped);


end


function [parametersProjectFiles] = disableProjectFileCreationATWM1(parametersProjectFiles)

%if exist (parametersProjectFiles.bCreateProjectFiles,'var') && parametersProjectFiles.bCreateProjectFiles
    fprintf('Implementation of project file creation not yet fully implemented!\nswitching to file transfer only!\n\n');
    parametersProjectFiles.bCreateProjectFiles = false;
%end

end


function [strPathOriginalDicomFiles, bAbort] = detectDicomFileFolderOnServerATWM1(strFolderRootTransferFromScanner, parametersDialog)
%%% Search for folder containing DICOM files of selected subject

global strSubject

strucFolderContentTransferFromScanner = dir(strFolderRootTransferFromScanner);
strucFolderContentTransferFromScanner = strucFolderContentTransferFromScanner(3:end);
nrOfSubjFolders = 0;
for ccont = 1:numel(strucFolderContentTransferFromScanner)
    strFolderContent = strucFolderContentTransferFromScanner(ccont).name;
    strPathSubfolder = strcat(strFolderRootTransferFromScanner, strFolderContent);
    if exist(strPathSubfolder, 'dir')
        if ~isempty(find(strfind(strPathSubfolder, strSubject), 1))
            nrOfSubjFolders = nrOfSubjFolders + 1;
            aStrPathOriginalDicomFiles{nrOfSubjFolders} = strPathSubfolder;
        end
    end
end
if nrOfSubjFolders == 1
    strPathOriginalDicomFiles = aStrPathOriginalDicomFiles{1};
    bAbort = false;
else    
    % Special case of more than 1 folder for selected subject
    [strPathOriginalDicomFiles, bAbort] = manualSelectionOfDicomFileFolderATWM1(strFolderRootTransferFromScanner, parametersDialog);
end


end


function [strPathOriginalDicomFiles, bAbort] = manualSelectionOfDicomFileFolderATWM1(strFolderRootTransferFromScanner, parametersDialog)

global strSubject

bInvalidFolderSelected = true;
while bInvalidFolderSelected
    strCurrentMatlabFolder = pwd;
    cd(strFolderRootTransferFromScanner);
    startFolder = strcat(strFolderRootTransferFromScanner);
    strTitle = sprintf('Please select folder for subject %s.', strSubject);
    strPathOriginalDicomFiles = uigetdir(startFolder, strTitle);
    if ~isempty(find(strfind(strPathOriginalDicomFiles, strSubject), 1))
        bInvalidFolderSelected = false;
        bAbort = false;
    else
        strTitle = 'Select DICOM file folder';
        strMessage = sprintf('No valid DICOM file folder selected for subject %s!\nPlease retry.', strSubject);
        strButton1 = sprintf('%sRetry%s', parametersDialog.strEmpty, parametersDialog.strEmpty);
        strButton2 = sprintf('%sCancel%s', parametersDialog.strEmpty, parametersDialog.strEmpty);
        default = strButton1;
        choice = questdlg(strMessage, strTitle, strButton1, strButton2, default);
        switch choice
            case strButton1
                bAbort = false;
            otherwise
                bAbort = true;
        end
        if bAbort == true
            fprintf('Function aborted by user.');
            bInvalidFolderSelected = false;
            strPathOriginalDicomFiles = '';
        end
    end
end
cd(strCurrentMatlabFolder);

end


function createFolderForDataTransferAndProjectFileCreationATWM1(folderDefinition)
global iStudy

hFunction = str2func(sprintf('createFolderForDataTransfer%s', iStudy));
feval(hFunction, folderDefinition);
hFunction = str2func(sprintf('createProjectDataSubFolder%s', iStudy));
feval(hFunction, folderDefinition.strFolderTransferFromScanner);

end


function createFolderForDataTransferATWM1(folderDefinition)
%%% Create folder for data transfer
if ~exist(folderDefinition.strFolderCurrentSubject, 'dir')
    mkdir(folderDefinition.strFolderCurrentSubject)
end
if ~exist(folderDefinition.strFolderCurrentSubjectZip, 'dir')
    mkdir(folderDefinition.strFolderCurrentSubjectZip)
end


end


function [nTotalDicomFilesInSession, aStrDicomFilesCurrentlyCopied, nFilesCopied, bFileTransferComplete, nPartialFileTransfers, nTotalFilesTransferred, bIncompatibleBrainVoyagerVersion, maximumNumberOfRuns, bAllFilesCreated] = setIntialParametersForFileTransferAndProjectFileCreationATWM1()

global iStudy
parametersDicomFileTransfer = eval(['parametersDicomFileTransfer', iStudy]);

%%% Change to different definition
nTotalDicomFilesInSession = parametersDicomFileTransfer.iFilesToCopy(end, end);

%%% Parameters for file transfer
aStrDicomFilesCurrentlyCopied = {};
nFilesCopied = [];
bFileTransferComplete = false;
nPartialFileTransfers = 0;
nTotalFilesTransferred = [];

%%% Parameters for file creation
bIncompatibleBrainVoyagerVersion = false;
maximumNumberOfRuns = 12;
bAllFilesCreated(1:maximumNumberOfRuns) = 0;


end


function deleteFilesForSimulationATWM1(folderDefinition)
%%% Delete existing directory for testing purposes
if exist(folderDefinition.strFolderCurrentSubject, 'dir')
    rmdir(folderDefinition.strFolderCurrentSubject, 's')
end

%%% Delete files in transfer folder for simulation purposes
structFilesToBeDeleted = dir(folderDefinition.strFolderTransferFromScanner);
structFilesToBeDeleted = structFilesToBeDeleted(3:end);
nFilesToBeDeleted = numel(structFilesToBeDeleted);
for cf = 1:nFilesToBeDeleted
    pathFileToBeDeleted = strcat(folderDefinition.strFolderTransferFromScanner, structFilesToBeDeleted(cf).name);
    delete(pathFileToBeDeleted)
end


end


function [aStrDicomFiles, aStrDicomFilesToBeCopied, nDicomFilesTransferred] = detectPartialDicomFileTransferFromScannerATWM1(folderDefinition, parametersDicomFileTransfer, parametersDicomFiles, aStrDicomFilesCurrentlyCopied);
global iStudy

strMessage = sprintf('Searching for newly transferred files.');
disp(strMessage);
nDicomFileCounts = 0;
bPartialFileTransferStarted = false;
bPartialFileTransferComplete = false;
bAdditionalDicomFilesDetected = false;
while bPartialFileTransferComplete == false
    nDicomFileCounts = nDicomFileCounts + 1;
    %%% Scan folder containing the DICOM files transferred from the Scanner
    hFunction = str2func(sprintf('scanFolderForDicomFiles%s', iStudy));
    [aStrDicomFiles, nDicomFiles(nDicomFileCounts)] = feval(hFunction, folderDefinition.strFolderTransferFromScanner, parametersDicomFiles);
    
    %%% Compare DICOM file arrays to detected files, which have not been
    %%% copied
    nDicomFilesNotCopied(nDicomFileCounts) = numel(setxor(aStrDicomFiles, aStrDicomFilesCurrentlyCopied));
    if nDicomFilesNotCopied(nDicomFileCounts) > 0
        aStrDicomFilesToBeCopied = setxor(aStrDicomFiles, aStrDicomFilesCurrentlyCopied);
    end
    
    if nDicomFileCounts == 1
        nIntitialDicomFiles = nDicomFiles(nDicomFileCounts);
    else
        %%% Check, whether the number of DICOM files has increased
        if nDicomFiles(nDicomFileCounts) ~= nDicomFiles(nDicomFileCounts - 1)
            bAdditionalDicomFilesDetected = true;
        elseif nDicomFilesNotCopied(nDicomFileCounts) ~= nDicomFilesNotCopied(nDicomFileCounts) && bAdditionalDicomFilesDetected == false
            bAdditionalDicomFilesDetected = true;
        else
            bAdditionalDicomFilesDetected = false;
        end
    end
    
    %%% Check, whether partial data transfer has started
    if bAdditionalDicomFilesDetected == true && bPartialFileTransferStarted == false
        bPartialFileTransferStarted = true;
        strMessage = sprintf('Newly transferred files detected.');
        disp(strMessage);
    end
    %%% Check, whether partial data transfer has finished
    if bAdditionalDicomFilesDetected == false && bPartialFileTransferStarted == true && nDicomFileCounts > parametersDicomFileTransfer.nIntervalsToCheck
        if nDicomFiles(nDicomFileCounts) == nDicomFiles(nDicomFileCounts - parametersDicomFileTransfer.nIntervalsToCheck)
            bPartialFileTransferComplete = true;
            nDicomFilesTransferred = nDicomFiles(nDicomFileCounts) - nIntitialDicomFiles;
        end
    end
    %%% This ensures, that at the beginning of the transfer the DICOM
    %%% files, which have already been transferred from the scanner will be
    %%% immediately copied
    if isempty(aStrDicomFilesCurrentlyCopied) && bPartialFileTransferStarted == false && nDicomFilesNotCopied(nDicomFileCounts) > 0 && nDicomFileCounts > 0
        bPartialFileTransferComplete = true;
        nDicomFilesTransferred = 0;
    end
    if bPartialFileTransferComplete == false
        hFunction = str2func(sprintf('waitForDicomFileScanRepeat%s', iStudy));
        feval(hFunction, parametersDicomFileTransfer, bAdditionalDicomFilesDetected);
    end
end
if ~isempty(aStrDicomFilesCurrentlyCopied)
    strMessage = sprintf('Partial data transfer of %i files finished!', nDicomFilesTransferred);
    disp(strMessage);
else
    if nDicomFilesTransferred ~= nDicomFilesNotCopied(nDicomFileCounts) && ~isempty(aStrDicomFilesCurrentlyCopied)
        strMessage = sprintf('Number of new files transferred from scanner: %i', nDicomFilesTransferred);
        disp(strMessage);
    elseif nDicomFilesTransferred ~= nDicomFilesNotCopied(nDicomFileCounts)
        strMessage = sprintf('Number of files not yet copied to single subject folder: %i', nDicomFilesNotCopied(nDicomFileCounts));
        disp(strMessage);
    end
end


end


function waitForDicomFileScanRepeatATWM1(parametersDicomFileTransfer, bAdditionalDicomFilesDetected)
%%% Adjust time interval for DICOM file search
if bAdditionalDicomFilesDetected == true
    fTimeIntervalDicomFileCount = parametersDicomFileTransfer.fTimeIntervalDicomFileCountFast;
else
    fTimeIntervalDicomFileCount = parametersDicomFileTransfer.fTimeIntervalDicomFileCountStandard;
end
%%% Wait before repeating the DICOM file count
pause(fTimeIntervalDicomFileCount);


end


function [aStrDicomFilesCurrentlyCopied, nFilesCopied, nTotalFilesTransferred] = copyDicomFilesToSingleSubjectFolderATWM1(folderDefinition, aStrDicomFilesCurrentlyCopied, aStrDicomFilesToBeCopied, nPartialFileTransfers, nDicomFilesTransferred, nTotalFilesTransferred, nFilesCopied)
%%% Copy newly transferred files to single subject folder and to temporary
%%% folder used for zipping
nFilesToBeCopied(nPartialFileTransfers) = numel(aStrDicomFilesToBeCopied);
nFilesCopied(nPartialFileTransfers) = 0;
iFilesCopied(nPartialFileTransfers, 1:nDicomFilesTransferred(nPartialFileTransfers)) = 0;
for cf = 1:nFilesToBeCopied(nPartialFileTransfers)
    pathDicomFileTransferFolder = strcat(folderDefinition.strFolderTransferFromScanner, aStrDicomFilesToBeCopied{cf});
    pathDicomFileSingleSubjectFolder = strcat(folderDefinition.strFolderCurrentSubject, aStrDicomFilesToBeCopied{cf});
    if exist(pathDicomFileTransferFolder, 'file')
        status = copyfile(pathDicomFileTransferFolder, pathDicomFileSingleSubjectFolder);
        if status == 0
            fprintf('Could not copy file %s to %s\n', pathDicomFileTransferFolder, folderDefinition.strFolderCurrentSubject);
        else
            fprintf('File %s successfully copied to %s\n', pathDicomFileTransferFolder, folderDefinition.strFolderCurrentSubject);
            iFilesCopied(nPartialFileTransfers, cf) = 1;
            %%% Also copy the file to the temporary folder used for zipping
            pathDicomFileSingleSubjectFolderZip = strcat(folderDefinition.strFolderCurrentSubjectZip, aStrDicomFilesToBeCopied{cf});
            copyfile(pathDicomFileTransferFolder, pathDicomFileSingleSubjectFolderZip);
            aStrDicomFilesCopiedPartialTransfer{cf} = aStrDicomFilesToBeCopied{cf};
        end
    else
        fprintf('Could not find file %s\n', pathDicomFileTransferFolder);
    end
    nFilesCopied(nPartialFileTransfers) = sum(iFilesCopied(nPartialFileTransfers, :));
end
aStrDicomFilesCurrentlyCopied = unique([aStrDicomFilesCurrentlyCopied, aStrDicomFilesCopiedPartialTransfer]);


end


function copyMissingDicomFilesATWM1(folderDefinition, aStrDicomFilesInTargetFolder, aStrCompleteDicomFiles, aStrDicomFilesInScannerTransferFolder)
%%% Determine missing DICOM files
aStrMissingDicomFiles = setxor(aStrDicomFilesInTargetFolder, aStrCompleteDicomFiles);
nMissingDicomFiles = numel(aStrMissingDicomFiles);
iMissingDicomFiles = find(ismember(aStrCompleteDicomFiles, aStrMissingDicomFiles));

%%% Copy missing DICOM files to target folder
for cf = 1:nMissingDicomFiles
    pathDicomFileSourceFolder = strcat(folderDefinition.strFolderTransferFromScanner, aStrDicomFilesInScannerTransferFolder{iMissingDicomFiles(cf)});
    pathDicomFileTargetFolder = strcat(folderDefinition.strFolderWithMissingDicomFiles, aStrDicomFilesInScannerTransferFolder{iMissingDicomFiles(cf)});
    if exist(pathDicomFileSourceFolder, 'file')
        status = copyfile(pathDicomFileSourceFolder, pathDicomFileTargetFolder);
        if status == 0
            strMessage = sprintf('Could not copy file %s to %s', pathDicomFileSourceFolder, folderDefinition.strFolderWithMissingDicomFiles);
            disp(strMessage);
        else
            strMessage = sprintf('File %s successfully copied to %s', pathDicomFileSourceFolder, folderDefinition.strFolderWithMissingDicomFiles);
            disp(strMessage);
        end
    else
        strMessage = sprintf('Could not find file %s', pathDicomFileSourceFolder);
        disp(strMessage);
    end
end


end


function [bSingleSubjectDataComplete] = confirmCompleteTransferOfDicomFilesATWM1(folderDefinition, parametersDicomFiles, aStrDicomFilesCurrentlyCopied, nTotalDicomFilesInSession, bSingleSubjectDataComplete)
global iStudy

%%% Double check whether all DICOM files have been copied from scanner
%%% transfer folder to single subject folder and temporary zip folder
nDicomFilesCopiedToSingleSubjectFolder = numel(aStrDicomFilesCurrentlyCopied);
hFunction = str2func(sprintf('scanAllFileTransferTargetFolderForDicomFiles%s', iStudy));
[aStrRenamedDicomFiles, aStrDicomFilesInZipFolder, nRenamedDicomFiles, nDicomFilesInZipFolder] = feval(hFunction, folderDefinition, parametersDicomFiles);

if nDicomFilesCopiedToSingleSubjectFolder == nTotalDicomFilesInSession && nRenamedDicomFiles == nDicomFilesCopiedToSingleSubjectFolder && nDicomFilesInZipFolder == nDicomFilesCopiedToSingleSubjectFolder
    bSingleSubjectDataComplete = true;
elseif nRenamedDicomFiles ~= nDicomFilesCopiedToSingleSubjectFolder
    folderDefinition.strFolderWithMissingDicomFiles = folderDefinition.strFolderCurrentSubject;
    aStrDicomFilesInTargetFolder = aStrRenamedDicomFiles;
    aStrCompleteDicomFiles = aStrCompleteRenamedDicomFiles;
    hFunction = str2func(sprintf('copyMissingDicomFiles%s', iStudy));
    feval(hFunction, folderDefinition, aStrDicomFilesInTargetFolder, aStrCompleteDicomFiles, aStrDicomFilesInScannerTransferFolder);
    hFunction = str2func(sprintf('renameDicomFiles%s', iStudy));
    feval(hFunction, folderDefinition.strFolderCurrentSubject);
elseif nDicomFilesInZipFolder ~= nDicomFilesCopiedToSingleSubjectFolder
    folderDefinition.strFolderWithMissingDicomFiles = folderDefinition.strFolderCurrentSubjectZip;
    aStrDicomFilesInTargetFolder = aStrDicomFilesInZipFolder;
    aStrCompleteDicomFiles = aStrDicomFilesInScannerTransferFolder;
    hFunction = str2func(sprintf('copyMissingDicomFiles%s', iStudy));
    feval(hFunction, folderDefinition, aStrDicomFilesInTargetFolder, aStrCompleteDicomFiles, aStrDicomFilesInScannerTransferFolder);
end


end


function [aStrRenamedDicomFiles, aStrDicomFilesInZipFolder, nRenamedDicomFiles, nDicomFilesInZipFolder] = scanAllFileTransferTargetFolderForDicomFilesATWM1(folderDefinition, parametersDicomFiles)
global iStudy

hFunction = str2func(sprintf('scanFolderForDicomFiles%s', iStudy));
[aStrRenamedDicomFiles, nRenamedDicomFiles] = feval(hFunction, folderDefinition.strFolderCurrentSubject, parametersDicomFiles);
hFunction = str2func(sprintf('scanFolderForDicomFiles%s', iStudy));
[aStrDicomFilesInZipFolder, nDicomFilesInZipFolder] = feval(hFunction, folderDefinition.strFolderCurrentSubjectZip, parametersDicomFiles);


end


function [aStrZippedFiles] = zipSingleSubjectDataATWM1(folderDefinition, aStrFilesToBeZipped)
global iStudy
global strSubject

%%% Zip all files stored in the temporary zip folder
strZipFileSingleSubjectData = sprintf('%s_%s.zip', strSubject, iStudy);
pathZipFileSingleSubjectData = strcat(folderDefinition.archiveZip, strZipFileSingleSubjectData);
strMessage = sprintf('Storing files for %s in file %s', strSubject, pathZipFileSingleSubjectData);
disp(strMessage);
aStrZippedFiles = zip(pathZipFileSingleSubjectData, aStrFilesToBeZipped, folderDefinition.strFolderCurrentSubjectZip);

%%% Delete temporary zip folder and all files
if exist(folderDefinition.strFolderCurrentSubjectZip, 'dir')
    rmdir(folderDefinition.strFolderCurrentSubjectZip, 's')
end


end