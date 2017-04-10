function archiveAnonymisedHigResAnatomyOfSelectedSubjectsOnServerATWM1()

global iStudy
global strGroup
global strSubject
global iSession

iStudy = 'ATWM1';

%%% Load parameters
folderDefinition            = eval(['folderDefinition', iStudy]);
parametersFileTransfer      = eval(['parametersFileTransfer', iStudy]);
parametersStructuralMriSequenceHighRes  = eval(['parametersStructuralMriSequenceHighRes', iStudy]);

[folderDefinition, parametersFileTransfer, aStrSubject, nSubjects, vSessionIndex, bAbort] = prepareArchivingOfAnonymisedHighResAnatomyATWM1(folderDefinition, parametersGroups, parametersFileTransfer);
if bAbort
    return
end

%%% Ensure that files will be transfered to / stored on server
if ~parametersFileTransfer.bArchiveFilesOnServer
    parametersFileTransfer.bArchiveFilesOnServer = true;
end


for cs = 1:nSubjects
    strSubject = aStrSubject{cs};
    iSession = vSessionIndex(cs);
    
    % Load ParametersMriScan for subject
    parametersMriSession = analyzeParametersMriScanFileATWM1;
    if isempty(parametersMriSession)
        fprintf('Error! ParametersMriScanFile for subject %s not found!\nSkipping subject!\n', strSubject);
        continue
    end
    [strPathZipFileArchiveDicomFilesSubject, bAbort] = findCompleteZipArchiveSubjectATWM1(folderDefinition);
    if bAbort
        continue
    end
    [folderDefinition, success] = unzipArchiveFileToTemporaryLocalFolderATWM1(folderDefinition, parametersDicomFileAnonymisation, strPathZipFileArchiveDicomFilesSubject);
    if ~success
        continue
    end
    % Define DICOM files in temporary folder
    [parametersMriSession, ~, aStrLocalPathOriginalDicomFiles, ~, bDicomFilesComplete] = checkOriginalDicomFilesATWM1(parametersMriSession, folderDefinition.strTempArchiveFolderSubject);
    if ~bDicomFilesComplete
        continue
    end
    
    [strPathLocalZipFileAnonymisedHighResAnatomy, strPathServerZipFileAnonymisedHighResAnatomy, success] = archiveAnonymisedHighResAnatomyToServerATWM1(folderDefinition, parametersMriSession, parametersStructuralMriSequenceHighRes, aStrLocalPathOriginalDicomFiles, parametersFileTransfer);
    
    %%% Delete separate temporary local folder
    rmdir(folderDefinition.strTempArchiveFolder);
end

end


function [folderDefinition, parametersFileTransfer, aStrSubject, nSubjects, vSessionIndex, bAbort] = prepareArchivingOfAnonymisedHighResAnatomyATWM1(folderDefinition, parametersGroups, parametersFileTransfer)

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


function [strPathZipFileArchiveDicomFilesSubject, bAbort] = findCompleteZipArchiveSubjectATWM1(folderDefinition)
%%% Detect zip archive with all DICOM files on local computer or server

global iStudy
global strGroup
global strSubject
global iSession

strZipFileArchiveDicomFilesSubject              = defineZipFileArchiveDicomFilesSubjectATWM1(parametersStudy);
strFolderLocalArchiveDicomFilesGroup            = strcat(folderDefinition.archiveDICOMfiles, strGroup, '\');
strFolderServerArchiveDicomFilesGroup           = strcat(folderDefinition.archiveDICOMfilesServer, strGroup, '\');
strPathZipFileLocalArchiveDicomFilesSubject     = fullfile(strFolderLocalArchiveDicomFilesGroup, strZipFileArchiveDicomFilesSubject);
strPathZipFileServerArchiveDicomFilesSubject    = fullfile(strFolderServerArchiveDicomFilesGroup, strZipFileArchiveDicomFilesSubject);
bAbort = false;
if exist(strPathZipFileLocalArchiveDicomFilesSubject, 'file')
    strPathZipFileArchiveDicomFilesSubject = strPathZipFileLocalArchiveDicomFilesSubject;
    fprintf('%s found on local computer.\n\n', strPathZipFileLocalArchiveDicomFilesSubject);
elseif exist(strPathZipFileServerArchiveDicomFilesSubject, 'file')
    strPathZipFileArchiveDicomFilesSubject = strPathZipFileServerArchiveDicomFilesSubject;
    fprintf('%s found on server.\n\n', strPathZipFileServerArchiveDicomFilesSubject);
else
    fprintf('Error!\n%s not found on local computer or server!\nSkipping subject %s!\n\n', strZipFileArchiveDicomFilesSubject, strSubject);
    bAbort = true;
end

fprintf('Add special case for more than 1 session in a subject,\nto properly detect in which session a valid HigResAnatomy was acquired.\n');

end


function [folderDefinition, success] = unzipArchiveFileToTemporaryLocalFolderATWM1(folderDefinition, parametersDicomFileAnonymisation, strPathZipFileArchiveDicomFilesSubject)
%%% Unzip zip archive to separate temporary local folder

global strGroup
global strSubject

% Define temporary output directory
folderDefinition.strTempArchiveFolder = strcat(folderDefinition.archiveDICOMfiles, '\', parametersDicomFileAnonymisation.strTempFolder);
folderDefinition.strTempArchiveFolderSubject = strcat(folderDefinition.strTempArchiveFolder, '\', strGroup, '\', strSubject);
try
    unzip(strPathZipFileArchiveDicomFilesSubject, folderDefinition.strTempArchiveFolderSubject);
    success = true;
catch
    fprintf('Error! Could not unzip archive file %s\nto temporary folder %s\nSkipping subject %s\n', strPathZipFileArchiveDicomFilesSubject, folderDefinition.strTempArchiveFolder, strSubject);
    success = false;
end

end