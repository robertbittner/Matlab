function transferDicomFilesATMW1();

clear all
clc

global iStudy
global strSubject
global strGroup
global strGroupLong
global iSession

iStudy = 'ATWM1';

folderDefinition            = eval(['folderDefinition', iStudy]);
parametersStudy             = eval(['parametersStudy', iStudy]);
parametersDialog            = eval(['parametersDialog', iStudy]);
parametersDicomFiles        = eval(['parametersDicomFiles', iStudy]);
parametersDicomFileTransfer = eval(['parametersDicomFileTransfer', iStudy]);
parametersGroups            = eval(['parametersGroups', iStudy]);

strStudyType = sprintf('%s_%s', iStudy, parametersStudy.strImaging);


%%% Load additional folder definitions for MRI file transfer
hFunction = str2func(sprintf('folderDefinitionMriFileTransfer%s', iStudy));
folderDefinition = feval(hFunction, folderDefinition);

%{
%%% Put this into the function 'defineParametersForFileTransfer'
hFunction = str2func(sprintf('checkFolderAccess%s', iStudy));
bAllFoldersCanBeAccessed = feval(hFunction, folderDefinition);
if bAllFoldersCanBeAccessed == false
    return
end
%}

aSubject = processSubjectArrayATWM1_IMAGING;
[strGroup, strSubject, bAbort] = selectGroupAndSubjectIdATWM1(parametersGroups, aSubject);

%%% Select file transfer options
hFunction = str2func(sprintf('selectFileTransferOptions%s', iStudy));
[bCreateProjectFiles, bAbort] = feval(hFunction);
if bAbort == true
    return
end

%%% Remove
if bCreateProjectFiles == true
    strMessage = sprintf('Implementation of project file creation not yet complete, switching to file transfer only!');
    disp(strMessage);
    bCreateProjectFiles = false;
end

%{
%%% Remove
strSubject = 'PAT01';
strGroup = parametersGroups.aStrShortGroups{1};
strGroupLong = parametersGroups.aStrLongGroups{1};
iSession = 1;
%}
parametersMriSession = analyzeParametersMriScanFileATWM1;


return

%%% These lines are only required for the simulation of data transfer
deleteFilesForSimulationATWM1(folderDefinition);
strCommand = sprintf('!matlab -automation -r "simulateDataTransferFromScanner%s" &', iStudy);
eval(strCommand);

%%{
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

%{
strGroup = parametersGroups.strShortControls;
folderDefinition.strFolderTransferFromScanner = strcat(folderDefinition.singleSubjectData, strGroup, '\', strSubject, '\');
%}

folderDefinition.strFolderTransferFromScanner = 'D:\Daten\ATWM1\Single_Subject_Data\Pilot_Scans\Script_Test\Transfer_from_Scanner\Subject_TEST\'

%{
%%% Create folder for data transfer
hFunction = str2func(sprintf('createFolderForDataTransfer%s', iStudy));
feval(hFunction, folderDefinition);
hFunction = str2func(sprintf('createProjectDataSubFolder%s', iStudy));
feval(hFunction, folderDefinition.strFolderTransferFromScanner);
%}
hFunction = str2func(sprintf('createFolderForDataTransferAndProjectFileCreation%s', iStudy));
feval(hFunction, folderDefinition);


%{
%%% Change to different definition
nTotalDicomFilesInSession = parametersDicomFileTransfer.iFilesToCopy(end, end);

aStrDicomFilesCurrentlyCopied = {};
nFilesCopied = [];
bFileTransferComplete = false;
nPartialFileTransfers = 0;
nTotalFilesTransferred = [];

%%% Parameters for file creation
bIncompatibleBrainVoyagerVersion = false;
maximumNumberOfRuns = 12;
bAllFilesCreated(1:maximumNumberOfRuns) = 0;
%}
hFunction = str2func(sprintf('setIntialParametersForFileTransferAndProjectFileCreation%s', iStudy));
[nTotalDicomFilesInSession, aStrDicomFilesCurrentlyCopied, nFilesCopied, bFileTransferComplete, nPartialFileTransfers, nTotalFilesTransferred, bIncompatibleBrainVoyagerVersion, maximumNumberOfRuns, bAllFilesCreated] = feval(hFunction);

while bFileTransferComplete == false
    %commandwindow
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
    
    %%% Presentation log files
    
    
    %%% ParametersMriScan
    %{
    strParametersMriScanFile = sprintf('%s%sParametersMriScan.m', strSubject, iStudy);
    pathParametersMriScanFile = strcat(folderDefinition.parametersMriScan, strParametersMriScanFile);
    newPathParametersMriScanFile = strcat(folderDefinition.strFolderCurrentSubject, strParametersMriScanFile);
    zipPathParametersMriScanFile = strcat(folderDefinition.strFolderCurrentSubjectZip, strParametersMriScanFile);
    
    rehash;
    if exist(pathParametersMriScanFile, 'file') && parametersMriScan.bVerified == true
        status = copyfile(pathParametersMriScanFile, newPathParametersMriScanFile);
        status = copyfile(zipPathParametersMriScanFile, newPathParametersMriScanFile);
    elseif parametersMriScan.bVerified == false
        strMessage = sprintf('%s has not been verified!', strParametersMriScanFile);
        disp(strMessage);
    end
    %}
    
    
end
%%% Prepare zipping of complete data set
hFunction = str2func(sprintf('scanAllFileTransferTargetFolderForDicomFiles%s', iStudy));
[aStrRenamedDicomFiles, aStrDicomFilesInZipFolder, nRenamedDicomFiles, nDicomFilesInZipFolder] = feval(hFunction, folderDefinition, parametersDicomFiles);
aStrFilesToBeZipped = [aStrDicomFilesInZipFolder];

hFunction = str2func(sprintf('zipSingleSubjectData%s', iStudy));
[aStrZippedFiles] = feval(hFunction, folderDefinition, aStrFilesToBeZipped);



end

%{
function [bCreateProjectFiles, bAbort] = defineParametersForFileTransferATWM1(strStudyType);

global iStudy
global strSubject
global strGroup
global strGroupLong

bCreateProjectFiles = [];
%%% Select subject for data transfer
hFunction = str2func(sprintf('selectSubject%s', iStudy));
[strSubject, strGroup, strGroupLong, bAbort] = feval(hFunction, strStudyType);
if bAbort == true
    return
end

%%% Select file transfer options
hFunction = str2func(sprintf('selectFileTransferOptions%s', iStudy));
[bCreateProjectFiles, bAbort] = feval(hFunction);
if bAbort == true
    return
end


end
%}

function [bCreateProjectFiles, bAbort] = selectFileTransferOptionsATWM1();
%%% Create dialog to decide whether project files will be created or only
%%% all files transferred
global iStudy
global strSubject
global strGroupLong

parametersDialog = eval(['parametersDialog', iStudy]);

strQuestion = sprintf('Select file transfer options for\n\n%s\n\n%s', strSubject, strGroupLong);
strTitle = 'File transfer options';
strOption1 = sprintf('%sFile transfer & Project file creation %s', parametersDialog.strEmpty, parametersDialog.strEmpty);
strOption2 = sprintf('%sFile transfer only%s', parametersDialog.strEmpty, parametersDialog.strEmpty);
strOption3 = sprintf('%sAbort%s', parametersDialog.strEmpty, parametersDialog.strEmpty);
choice = questdlg(strQuestion, strTitle, strOption1, strOption2, strOption3, strOption1);
if ~isempty(choice)
    switch choice
        case strOption1
            bCreateProjectFiles = true;
            bAbort = false;
        case strOption2
            bCreateProjectFiles = false;
            bAbort = false;
        case strOption3
            bCreateProjectFiles = false;
            bAbort = true;
            strMessage = sprintf('No file transfer option selected.\nAborting function.');
            disp(strMessage);
    end
else
    bCreateProjectFiles = false;
    bAbort = true;
    strMessage = sprintf('No file transfer option selected.\nAborting function.');
    disp(strMessage);
end


end


function createFolderForDataTransferAndProjectFileCreationATWM1(folderDefinition);
global iStudy

hFunction = str2func(sprintf('createFolderForDataTransfer%s', iStudy));
feval(hFunction, folderDefinition);
hFunction = str2func(sprintf('createProjectDataSubFolder%s', iStudy));
feval(hFunction, folderDefinition.strFolderTransferFromScanner);

end


function createFolderForDataTransferATWM1(folderDefinition);
%%% Create folder for data transfer
if ~exist(folderDefinition.strFolderCurrentSubject, 'dir')
    mkdir(folderDefinition.strFolderCurrentSubject)
end
if ~exist(folderDefinition.strFolderCurrentSubjectZip, 'dir')
    mkdir(folderDefinition.strFolderCurrentSubjectZip)
end


end


function [nTotalDicomFilesInSession, aStrDicomFilesCurrentlyCopied, nFilesCopied, bFileTransferComplete, nPartialFileTransfers, nTotalFilesTransferred, bIncompatibleBrainVoyagerVersion, maximumNumberOfRuns, bAllFilesCreated] = setIntialParametersForFileTransferAndProjectFileCreationATWM1();

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

function deleteFilesForSimulationATWM1(folderDefinition);
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


function waitForDicomFileScanRepeatATWM1(parametersDicomFileTransfer, bAdditionalDicomFilesDetected);
%%% Adjust time interval for DICOM file search
if bAdditionalDicomFilesDetected == true
    fTimeIntervalDicomFileCount = parametersDicomFileTransfer.fTimeIntervalDicomFileCountFast;
else
    fTimeIntervalDicomFileCount = parametersDicomFileTransfer.fTimeIntervalDicomFileCountStandard;
end
%%% Wait before repeating the DICOM file count
pause(fTimeIntervalDicomFileCount);

end


function [aStrDicomFilesCurrentlyCopied, nFilesCopied, nTotalFilesTransferred] = copyDicomFilesToSingleSubjectFolderATWM1(folderDefinition, aStrDicomFilesCurrentlyCopied, aStrDicomFilesToBeCopied, nPartialFileTransfers, nDicomFilesTransferred, nTotalFilesTransferred, nFilesCopied);
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
            strMessage = sprintf('Could not copy file %s to %s', pathDicomFileTransferFolder, folderDefinition.strFolderCurrentSubject);
            disp(strMessage);
        else
            strMessage = sprintf('File %s successfully copied to %s', pathDicomFileTransferFolder, folderDefinition.strFolderCurrentSubject);
            disp(strMessage);
            iFilesCopied(nPartialFileTransfers, cf) = 1;
            %%% Also copy the file to the temporary folder used for zipping
            pathDicomFileSingleSubjectFolderZip = strcat(folderDefinition.strFolderCurrentSubjectZip, aStrDicomFilesToBeCopied{cf});
            copyfile(pathDicomFileTransferFolder, pathDicomFileSingleSubjectFolderZip);
            aStrDicomFilesCopiedPartialTransfer{cf} = aStrDicomFilesToBeCopied{cf};
        end
    else
        strMessage = sprintf('Could not find file %s', pathDicomFileTransferFolder);
        disp(strMessage);
    end
    nFilesCopied(nPartialFileTransfers) = sum(iFilesCopied(nPartialFileTransfers, :));
end
aStrDicomFilesCurrentlyCopied = unique([aStrDicomFilesCurrentlyCopied, aStrDicomFilesCopiedPartialTransfer]);

end


function copyMissingDicomFilesATWM1(folderDefinition, aStrDicomFilesInTargetFolder, aStrCompleteDicomFiles, aStrDicomFilesInScannerTransferFolder);
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


function [bSingleSubjectDataComplete] = confirmCompleteTransferOfDicomFilesATWM1(folderDefinition, parametersDicomFiles, aStrDicomFilesCurrentlyCopied, nTotalDicomFilesInSession, bSingleSubjectDataComplete);
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


function [aStrRenamedDicomFiles, aStrDicomFilesInZipFolder, nRenamedDicomFiles, nDicomFilesInZipFolder] = scanAllFileTransferTargetFolderForDicomFilesATWM1(folderDefinition, parametersDicomFiles);
global iStudy

hFunction = str2func(sprintf('scanFolderForDicomFiles%s', iStudy));
[aStrRenamedDicomFiles, nRenamedDicomFiles] = feval(hFunction, folderDefinition.strFolderCurrentSubject, parametersDicomFiles);
hFunction = str2func(sprintf('scanFolderForDicomFiles%s', iStudy));
[aStrDicomFilesInZipFolder, nDicomFilesInZipFolder] = feval(hFunction, folderDefinition.strFolderCurrentSubjectZip, parametersDicomFiles);

end


function [aStrZippedFiles] = zipSingleSubjectDataATWM1(folderDefinition, aStrFilesToBeZipped);
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