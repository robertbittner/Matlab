function transferDicomFilesATWM1()

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

parametersParadigm_WM_MRI   = eval(['parametersParadigm_WM_MRI_', iStudy]);

parametersStructuralMriSequenceHighRes  = eval(['parametersStructuralMriSequenceHighRes', iStudy]);
parametersStructuralMriSequenceLowRes   = eval(['parametersStructuralMriSequenceLowRes', iStudy]);
parametersFunctionalMriSequence_WM      = eval(['parametersFunctionalMriSequence_WM_', iStudy]);
parametersFunctionalMriSequence_LOC     = eval(['parametersFunctionalMriSequence_LOC_', iStudy]);
parametersFunctionalMriSequence_COPE    = eval(['parametersFunctionalMriSequence_COPE_', iStudy]);


strStudyType = sprintf('%s_%s', iStudy, parametersStudy.strImaging);

%%% Check server access
bAllFoldersCanBeAccessed = checkLocalComputerFolderAccessATWM1(folderDefinition);
if bAllFoldersCanBeAccessed == false
    return
end

%%% Load additional folder definitions for MRI file transfer
hFunction = str2func(sprintf('folderDefinitionMriFileTransfer%s', iStudy));
folderDefinition = feval(hFunction, folderDefinition);
return




%{
%%% REINSTATE
aSubject = processSubjectArrayATWM1_IMAGING;
strDialogSelectionModeSubject = 'multiple';
iSession = 1;

[strGroup, strSubject, aStrSubject, nSubjects, bAbort] = selectGroupAndSubjectIdATWM1(parametersGroups, aSubject, strDialogSelectionModeSubject);
if bAbort == true
    return
end

%%% REINSTATE
%}

%%{
%%% REMOVE
iSession = 1;
strSubject = 'DJ32GUZ'
aStrSubject = {strSubject}
nSubjects = numel(aStrSubject)
strGroup = 'CONT'
strGroupLong  = 'Controls';
%%% REMOVE
%}

%%% REINSTATE AND EXTEND
%%{
bSkipFileTransferSelectionOption = true;
if bSkipFileTransferSelectionOption == false
    %%% Select file transfer options
    hFunction = str2func(sprintf('selectFileTransferOptions%s', iStudy));
    [bCreateProjectFiles, bAbort] = feval(hFunction);
    if bAbort == true
        return
    end
    
    %%% REMOVE
    if bCreateProjectFiles == true
        strMessage = sprintf('Implementation of project file creation not yet complete, switching to file transfer only!\n\n');
        disp(strMessage);
        bCreateProjectFiles = false;
    end
    %%% REMOVE
    %}
end

folderDefinition.strFolderRootTransferFromScanner = 'D:\Daten\ATWM1\Archive_DICOM_Files\';

%{
%%% REINSTATE
%%% Determine session for each subject
[iSession, bAbort] = determineMriSessionATWM1(aStrSubject, nSubjects);
if bAbort == true
    return
end
%}

for cs = 1:nSubjects
    strSubject = aStrSubject{cs};
    [strFolderOriginalDicomFilesSubject, bSubjectFolderFound, bAbort] = determineSubjectFolderWithOriginalDicomFilesATWM1(folderDefinition, parametersDialog);
    if bAbort == true
        return
    elseif bSubjectFolderFound == false
        continue
    end
    
    % Load ParametersMriScan
    parametersMriSession = analyzeParametersMriScanFileATWM1;
    
    %parametersMriSession.nDicomFiles = sum(parametersMriSession.nMeasurementsInRun)
    %return
    
    
    [parametersMriSession, aStrOriginalDicomFiles, aStrPathOriginalDicomFiles, aStrPathMissingDicomFiles, bDicomFilesComplete] = checkOriginalDicomFilesATWM1(parametersMriSession, strFolderOriginalDicomFilesSubject);
    if ~bDicomFilesComplete
        continue
    end
    
    %{
    %%% Detect high-res anatomy
    fileIndexVmrHighRes = parametersMriSession.fileIndexVmrHighRes;
    nFilesVmrHighRes    = parametersMriSession.nMeasurementsInRun(fileIndexVmrHighRes);
    indexStart  = parametersMriSession.vStartIndexDicomFileRune(fileIndexVmrHighRes);
    indexEnd    = indexStart + nFilesVmrHighRes;
    aStrPathOriginalDicomFilesVmrHighRes    = aStrPathOriginalDicomFiles(indexStart : indexEnd - 1);
    aStrOriginalDicomFilesVmrHighRes        = aStrOriginalDicomFiles(indexStart : indexEnd - 1);
    
    
    %%% Copy DICOM files of high-res anatomy in separate folder
    folderHighResAnatomy = strcat('X:\ATWM1\Archive_DICOM_Files\', '_High_Res_', parametersStructuralMriSequenceHighRes.strSequence, '\');
    
    
    folderHighResAnatomyGroup = strcat(folderHighResAnatomy, strGroup, '\');
    folderHighResAnatomySubject = strcat(folderHighResAnatomyGroup, strSubject, '_', parametersStructuralMriSequenceHighRes.strSequence, '\');
    if ~exist(folderHighResAnatomySubject, 'dir')
        mkdir(folderHighResAnatomySubject);
    end
    
    for cf = 1:nFilesVmrHighRes
        strServerPathHighResAnatomy = fullfile(folderHighResAnatomySubject, aStrOriginalDicomFilesVmrHighRes{cf});
        strPathOriginalDicomFilesVmrHighRes = aStrPathOriginalDicomFilesVmrHighRes{cf};
        success(cf) = copyfile(strPathOriginalDicomFilesVmrHighRes, strServerPathHighResAnatomy);
    end
    
    if sum(success) == nFilesVmrHighRes
        strMessage = sprintf('All %i DICOM files for high-res anatomy of subject %s successfully copied to server!\n', nFilesVmrHighRes, strSubject);
        disp(strMessage);
    else
        nrOfFilesNotCopied = nFilesVmrHighRes - sum(success);
        strMessage = sprintf('Error while copying DICOM files for high-res anatomy of subject %s to server!', strSubject);
        disp(strMessage);
        strMessage = sprintf('%i DICOM files were not copied!\n', nrOfFilesNotCopied);
        disp(strMessage);
    end
    %}
    
    %%% Transfer all files to server & local computer
    %{
    % Server
    strFolderServerArchiveDicomFiles    = 'X:\ATWM1\Archive_DICOM_Files\';
    strFolderServerArchiveDicomFilesGroup = strcat(strFolderServerArchiveDicomFiles, strGroup, '\');
    strFolderServerArchiveDicomFilesSubject = strcat(strFolderServerArchiveDicomFilesGroup, strSubject, '\');
    
    if ~exist(strFolderServerArchiveDicomFilesSubject, 'dir')
        mkdir(strFolderServerArchiveDicomFilesSubject);
    end
    
    for cf = 1:parametersMriSession.nDicomFiles
        strServerPathOriginalDicomFilesSubject = fullfile(strFolderServerArchiveDicomFilesSubject, aStrOriginalDicomFiles{cf});
        strPathOriginalDicomFilesSubject = aStrPathOriginalDicomFiles{cf};
        success(cf) = copyfile(strPathOriginalDicomFilesSubject, strServerPathOriginalDicomFilesSubject);
    end
    
    if sum(success) == parametersMriSession.nDicomFiles
        strMessage = sprintf('All %i DICOM files of subject %s successfully copied to server!\n', parametersMriSession.nDicomFiles, strSubject);
        disp(strMessage);
    else
        nrOfFilesNotCopied = parametersMriSession.nDicomFiles - sum(success);
        strMessage = sprintf('Error while copying DICOM files of subject %s to server!', strSubject);
        disp(strMessage);
        strMessage = sprintf('%i DICOM files were not copied!\n', nrOfFilesNotCopied);
        disp(strMessage);
    end
    %}
    
    %%{
    % Local
    strFolderLocalArchiveDicomFiles    = folderDefinition.archiveDICOMfiles;
    strFolderLocalArchiveDicomFilesGroup = strcat(strFolderLocalArchiveDicomFiles, strGroup, '\');
    strFolderLocalArchiveDicomFilesSubject = strcat(strFolderLocalArchiveDicomFilesGroup, strSubject, '\');
    
    if ~exist(strFolderLocalArchiveDicomFilesSubject, 'dir')
        mkdir(strFolderLocalArchiveDicomFilesSubject);
    end
    %{
    %%% Copy DICOM files
    for cf = 1:parametersMriSession.nDicomFiles
        strLocalPathOriginalDicomFilesSubject = fullfile(strFolderLocalArchiveDicomFilesSubject, aStrOriginalDicomFiles{cf});
        strPathOriginalDicomFilesSubject = aStrPathOriginalDicomFiles{cf};
        success(cf) = copyfile(strPathOriginalDicomFilesSubject, strLocalPathOriginalDicomFilesSubject);
    end
    
    if sum(success) == parametersMriSession.nDicomFiles
        strMessage = sprintf('All %i DICOM files of subject %s successfully copied to local computer!\n', parametersMriSession.nDicomFiles, strSubject);
        disp(strMessage);
    else
        nrOfFilesNotCopied = parametersMriSession.nDicomFiles - sum(success);
        strMessage = sprintf('Error while copying DICOM files of subject %s to local computer!', strSubject);
        disp(strMessage);
        strMessage = sprintf('%i DICOM files were not copied!\n', nrOfFilesNotCopied);
        disp(strMessage);
    end
    %}
    
    %%% Copy Presentation logfiles
    [aStrPresentationLogfilesLocal, nLogfiles] = determineLogfileInformationATWM1(parametersStudy, parametersParadigm_WM_MRI);
    
    %{
    folderDefinition.logfilesServer = strrep(folderDefinition.logfiles, folderDefinition.dataDirectoryLocal, folderDefinition.dataDirectoryServer);
    strFolderLogfilesServerGroup    = strcat(folderDefinition.logfiles, strGroup, '\');
    strFolderLogfilesServerSubject  = strcat(strFolderLogfilesServerGroup, strSubject, '\');
    %}
    
    folderDefinition.logfilesServer = strrep(folderDefinition.logfiles, folderDefinition.dataDirectoryLocal, folderDefinition.dataDirectoryServer);
    strFolderLogfilesServerGroup    = strcat(folderDefinition.logfilesServer, strGroup, '\');
    strFolderLogfilesServerSubject  = strcat(strFolderLogfilesServerGroup, strSubject, '\');
    
    
    for cf = 1:nLogfiles
        strPathPresentationLogfilesServer   = fullfile(strFolderLogfilesServerSubject, aStrPresentationLogfilesLocal{cf});
        strPathPresentationLogfilesLocal    = fullfile(strFolderLocalArchiveDicomFilesSubject, aStrPresentationLogfilesLocal{cf});
        success(cf) = copyfile(strPathPresentationLogfilesServer, strPathPresentationLogfilesLocal);
    end
    
    if sum(success) == nLogfiles
        strMessage = sprintf('All %i Presentation logfiles of subject %s successfully copied to local computer!\n', nLogfiles, strSubject);
        disp(strMessage);
    else
        nrOfFilesNotCopied = nLogfiles - sum(success);
        strMessage = sprintf('Error while copying Presentation logfiles of subject %s to local computer!', strSubject);
        disp(strMessage);
        strMessage = sprintf('%i Presentation logfiles were not copied!\n', nrOfFilesNotCopied);
        disp(strMessage);
    end
    
    %strPathPresentationLogfilesLocal
    %end
    
    %{
    %%% Copy ParametersMriScan file
    hFunction = str2func(sprintf('defineParametersMriSessionFileName%s', iStudy));
    strParametersMriSessionFile = feval(hFunction, strSubject, iSession);
    strPathParametersMriSessionFile = fullfile(folderDefinition.parametersMriScan, strParametersMriSessionFile);
    strLocalPathParametersMriSessionFile = fullfile(strFolderLocalArchiveDicomFilesSubject, strParametersMriSessionFile);
    success = copyfile(strPathParametersMriSessionFile, strLocalPathParametersMriSessionFile);
    if success
        strMessage = sprintf('File %s successfully copied to local computer!\n', strParametersMriSessionFile);
        disp(strMessage);
    else
        strMessage = sprintf('Error while copying file %s to local computer!\nFile was not copied', strPathParametersMriSessionFile);
        disp(strMessage);
    end
    %}
    %strFolderLocalArchiveDicomFiles     = folderDefinition.archiveDICOMfiles
    
    
end


end


function [strFolderOriginalDicomFilesSubject, bSubjectFolderFound, bAbort] = determineSubjectFolderWithOriginalDicomFilesATWM1(folderDefinition, parametersDialog)

global strSubject

%%% Search for folder containing DICOM files of selected subject
strFolderRootTransferFromScanner = folderDefinition.strFolderRootTransferFromScanner;
strucFolderContentTransferFromScanner = dir(strFolderRootTransferFromScanner);
strucFolderContentTransferFromScanner = strucFolderContentTransferFromScanner(3:end);
nrOfSubjFolders = 0;
for ccont = 1:numel(strucFolderContentTransferFromScanner)
    strFolderContent = strucFolderContentTransferFromScanner(ccont).name;
    strPathSubfolder = strcat(strFolderRootTransferFromScanner, strFolderContent);
    if exist(strPathSubfolder, 'dir')
        if ~isempty(find(strfind(strPathSubfolder, strSubject), 1))
            nrOfSubjFolders = nrOfSubjFolders + 1;
            aStrFolderOriginalDicomFilesSubject{nrOfSubjFolders} = strPathSubfolder;
        end
    end
end

bAbort = false;
bSubjectFolderFound = true;
if nrOfSubjFolders == 0
    strFolderOriginalDicomFilesSubject = '';
    bSubjectFolderFound = false;
    strMessage = sprintf('No folder containing DICOM files found for subject %s.\nSkipping subject.\n', strSubject);
    disp(strMessage);
elseif nrOfSubjFolders == 1
    strFolderOriginalDicomFilesSubject = aStrFolderOriginalDicomFilesSubject{1};
else
    % Special case of more than 1 folder for selected subject
    bInvalidFolderSelected = true;
    while bInvalidFolderSelected
        startFolder = strcat(strFolderRootTransferFromScanner);
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


end







