function anonymiseDicomFilesManuallyATWM1()

clear all
clc

global iStudy
global strSubject
global strGroup
global iSession

global bTestConfiguration

iStudy = 'ATWM1';

bTestConfiguration = false;

folderDefinition                    = eval(['folderDefinition', iStudy]);
%parametersStudy             = eval(['parametersStudy', iStudy]);
parametersDialog            = eval(['parametersDialog', iStudy]);
%parametersDicomFiles        = eval(['parametersDicomFiles', iStudy]);
%parametersFileTransfer      = eval(['parametersFileTransfer', iStudy]);

parametersDicomFiles                = eval(['parametersDicomFiles' iStudy]);

%parametersProjectFiles      = eval(['parametersProjectFiles', iStudy]);
parametersGroups                    = eval(['parametersGroups', iStudy]);
parametersDicomFileAnonymisation    = parametersDicomFileAnonymisationATWM1;
%parametersParadigm_WM_MRI   = eval(['parametersParadigm_WM_MRI_', iStudy]);


parametersStructuralMriSequenceHighRes  = eval(['parametersStructuralMriSequenceHighRes', iStudy]);


%return

hFunction = str2func(sprintf('prepareDicomFileAnonymization%s', iStudy));
[folderDefinition, aStrSubject, nSubjects, vSessionIndex, bAbort] = feval(hFunction, folderDefinition, parametersGroups);
strSubject = aStrSubject{1};

%%% CHANGE & USE PREEXISTING CODE
strRoot = 'D:\Daten\ATWM1\';%Single_Subject_Data\zzzTEST\';
strFolderOriginalDicomFilesSubject = fullfile(strRoot, strGroup, '\', strSubject, '\');

%Trio_20160917_130814_CX75DJQ

strDialogTitle = 'Select folder containing DICOM files of selected subject:';
strFolderOriginalDicomFilesSubject = uigetdir(strRoot, strDialogTitle);
if ~contains(strFolderOriginalDicomFilesSubject, strSubject)
    strMessage = sprintf('Selected folder %s does not contain DICOM files for subject %s', strFolderOriginalDicomFilesSubject, strSubject);
    error(strMessage)
end



%{
[strFolderOriginalDicomFilesSubject, bSubjectFolderFound, bAbort] = determineSubjectFolderWithOriginalDicomFilesATWM1(folderDefinition, parametersDialog);
    if bAbort || ~bSubjectFolderFound
        return
    end
%}

%%% Load subject parameter file
parametersMriSession = analyzeParametersMriScanFileATWM1;


hFunction = str2func(sprintf('defineUnrenamedDicomFileNames%s', iStudy));
[parametersMriSession, aStrOriginalDicomFiles, aStrPathOriginalDicomFiles] = feval(hFunction, parametersMriSession, parametersDicomFiles, strFolderOriginalDicomFilesSubject);

hFunction = str2func(sprintf('defineHighResAnatomyDicomFiles%s', iStudy));
[aStrPathOriginalDicomFilesVmrHighRes, aStrOriginalDicomFilesVmrHighRes] = feval(hFunction, parametersMriSession, aStrPathOriginalDicomFiles);



folderDefinition = defineAnonymisedHighResAnatomyArchiveFolderSubjectATWM1(folderDefinition, parametersDicomFileAnonymisation, parametersStructuralMriSequenceHighRes);


if ~exist(folderDefinition.anonymisedDataArchiveHighResAnatomySubjectAnon, 'dir')
    mkdir(folderDefinition.anonymisedDataArchiveHighResAnatomySubjectAnon)
end

%%% Anonymize DICOM files and copy them to archive folder for anonymised
%%% data
nrOfDicomFiles = numel(aStrPathOriginalDicomFilesVmrHighRes);
for cf = 1:nrOfDicomFiles
    strDicomFileAnonymised = strcat(parametersDicomFileAnonymisation.strAnonymised, '_', aStrOriginalDicomFilesVmrHighRes{cf});
    strAnonDicomFile = strrep(aStrOriginalDicomFilesVmrHighRes{cf}, aStrOriginalDicomFilesVmrHighRes{cf}, strDicomFileAnonymised);
    strPathOriginalDicomFilesSubjectAnonDicomFile{cf}        = fullfile(folderDefinition.anonymisedDataArchiveHighResAnatomySubjectAnon, strAnonDicomFile);
    
    dicomanon(aStrPathOriginalDicomFilesVmrHighRes{cf}, strPathOriginalDicomFilesSubjectAnonDicomFile{cf});
    
end

[strZipFileAnonymisedHighResAnatomy, strPathLocalZipFileAnonymisedHighResAnatomy, success] = zipAnonymisedDicomFilesATWM1(folderDefinition, parametersStructuralMriSequenceHighRes);

if success
    fprintf('%s was created successfully!', strZipFileAnonymisedHighResAnatomy);
end


end


function [strZipFileAnonymisedHighResAnatomy, strPathLocalZipFileAnonymisedHighResAnatomy, success] = zipAnonymisedDicomFilesATWM1(folderDefinition, parametersStructuralMriSequenceHighRes)

global strSubject

strZipFileAnonymisedHighResAnatomy = sprintf('%s.zip', parametersStructuralMriSequenceHighRes.strSequence);
strPathLocalZipFileAnonymisedHighResAnatomy = fullfile(folderDefinition.anonymisedDataArchiveHighResAnatomySubject, strZipFileAnonymisedHighResAnatomy);
%%{
try
    zip(strPathLocalZipFileAnonymisedHighResAnatomy, folderDefinition.anonymisedDataArchiveHighResAnatomySubjectAnon);
    success = 1;
catch
    success = 0;
    fprintf('Error! Could not create zip file containing anonymised DICOM files for subject %s!\n\n', strSubject);
end

if success
    %%% Delete anonymised DICOM files
    try
        rmdir(folderDefinition.anonymisedDataArchiveHighResAnatomySubjectAnon, 's');
        success = true;
    catch
        success = false;
        fprintf('Error! Could not delete local folder containing anonymised DICOM files for subject %s!\n\n', strSubject);
    end
end
%}

end


function [folderDefinition, aStrSubject, nSubjects, vSessionIndex, bAbort] = prepareDicomFileAnonymizationATWM1(folderDefinition, parametersGroups)

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

%{
%%% Select file transfer options
hFunction = str2func(sprintf('selectFileTransferOptions%s', iStudy));
[folderDefinition, parametersFileTransfer, bAbort] = feval(hFunction, folderDefinition, parametersFileTransfer);
if bAbort
    return
end
%}

%%% Select subjects
aSubject = processSubjectArrayATWM1_IMAGING;
strDialogSelectionModeSubject = 'single';
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


