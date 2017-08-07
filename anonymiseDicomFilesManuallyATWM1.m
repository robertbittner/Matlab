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

folderDefinition                        = eval(['folderDefinition', iStudy]);
parametersStudy                         = eval(['parametersStudy', iStudy]);
parametersGroups                        = eval(['parametersGroups', iStudy]);
parametersDicomFiles                    = eval(['parametersDicomFiles' iStudy]);
parametersDicomFileAnonymisation        = parametersDicomFileAnonymisationATWM1;
parametersStructuralMriSequenceHighRes 	= eval(['parametersStructuralMriSequenceHighRes', iStudy]);

%%% Select imaging study as current study
parametersStudy.strCurrentStudy                     = parametersStudy.aStrStudies{parametersStudy.indImagingStudy};

%%% REINSTATE
%%{
hFunction = str2func(sprintf('prepareDicomFileAnonymization%s', iStudy));
[folderDefinition, aStrSubject, nSubjects, vSessionIndex, bAbort] = feval(hFunction, folderDefinition, parametersStudy, parametersGroups);
%}
%%% REINSTATE

%{
%%% REMOVE
hFunction = str2func(sprintf('addServerFolderDefinitions%s', iStudy));
folderDefinition = feval(hFunction, folderDefinition);
aStrSubject = {'HD48ZQG'};
iSession = 1;
strGroup = 'CONT';
strSubject = aStrSubject{1};
%%% REMOVE
%}


%%% CHANGE & USE PREEXISTING CODE
strRoot = sprintf('%s\%s\', folderDefinition.archiveDICOMfiles, strGroup, '\');

strFolderOriginalDicomFilesSubject = fullfile(strRoot, 'HD48ZQG_ATWM1_MRI_s1', '\');


%%% REINSTATE AND COMPLETE
%{
strFilterSpec = '*.zip';
strDialogTitle = 'Select zip file containing DICOM files of selected subject:';
strDefaultName = sprintf('%s*', strSubject);

[strFile, strPath, FilterIndex] = uigetfile(strFilterSpec, strDialogTitle, strDefaultName)
%}
%%% REINSTATE AND COMPLETE

%%% REINSTATE
%%{
bDicomFilesFound = false;
strDialogTitle = 'Select folder containing DICOM files of selected subject:';
strFolderOriginalDicomFilesSubject = uigetdir(strRoot, strDialogTitle);
%}
%%% REINSTATE

if isequal(strFolderOriginalDicomFilesSubject, 0) || ~exist(strFolderOriginalDicomFilesSubject, 'dir')
    fprintf('No valid folder selected. Aborting function.\n');
elseif ~contains(strFolderOriginalDicomFilesSubject, strSubject)
    fprintf('Selected folder %s does not contain DICOM files for subject %s but possibly for a different subject!\n', strFolderOriginalDicomFilesSubject, strSubject);
else
    bDicomFilesFound = true;
end


if ~bDicomFilesFound
    fprintf('Aborting function\n\n');
    return
end


%{
[strFolderOriginalDicomFilesSubject, bSubjectFolderFound, bAbort] = determineSubjectFolderWithOriginalDicomFilesATWM1(folderDefinition, parametersDialog);
    if bAbort || ~bSubjectFolderFound
        return
    end
%}

%%% Temporarily add strFolderOriginalDicomFilesSubject as a Matlab path in
%%% order to read the parametersMriSession file of the subjects if it has
%%% not been saved locally
addpath(strFolderOriginalDicomFilesSubject);

%%% Load subject parameter file
parametersMriSession = analyzeParametersMriScanFileATWM1;
if isempty(parametersMriSession)
    fprintf('Aborting function!\n\n')
    return
end
%%% Remove strFolderOriginalDicomFilesSubject as a Matlab path
rmpath(strFolderOriginalDicomFilesSubject);

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
    strNew = strcat(parametersDicomFileAnonymisation.strAnonymised, '_', aStrOriginalDicomFilesVmrHighRes{cf});
    strAnonDicomFile = strrep(aStrOriginalDicomFilesVmrHighRes{cf}, aStrOriginalDicomFilesVmrHighRes{cf}, strNew);
    strPathOriginalDicomFilesSubjectAnonDicomFile{cf}        = fullfile(folderDefinition.anonymisedDataArchiveHighResAnatomySubjectAnon, strAnonDicomFile);
    
    dicomanon(aStrPathOriginalDicomFilesVmrHighRes{cf}, strPathOriginalDicomFilesSubjectAnonDicomFile{cf});
    
end

[strZipFileAnonymisedHighResAnatomy, strPathLocalZipFileAnonymisedHighResAnatomy, success] = zipAnonymisedDicomFilesATWM1(folderDefinition, parametersStructuralMriSequenceHighRes);

if success
    fprintf('%s was created successfully!\n\n', strZipFileAnonymisedHighResAnatomy);
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


function [folderDefinition, aStrSubject, nSubjects, vSessionIndex, bAbort] = prepareDicomFileAnonymizationATWM1(folderDefinition, parametersStudy, parametersGroups)

global iStudy
global strGroup
global strSubject
global iSession

aStrSubject = [];
nSubjects = [];
vSessionIndex = [];

%{
%%% Check server access
bAllFoldersCanBeAccessed = checkLocalComputerFolderAccessATWM1(folderDefinition);
if bAllFoldersCanBeAccessed == false
    bAbort = true;
    return
end
%}
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

%%% Select a single subject
aSubject = processSubjectArrayATWM1(parametersStudy);

strDialogSelectionModeSubject = 'single';
iSession = 1;
[strGroup, ~, aStrSubject, nSubjects, bAbort] = selectGroupAndSubjectIdATWM1(parametersStudy, parametersGroups, aSubject, strDialogSelectionModeSubject);
if bAbort == true
    return
end
if nSubjects == 1
    strSubject = aStrSubject{1};
else
    error('Selection of multiple subjects for anonymisation currently not supported!')
end

%%% Determine session for subject
[vSessionIndex, bAbort] = determineMriSessionATWM1(aStrSubject, nSubjects);
if bAbort
    return
end


end


