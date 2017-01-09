function createProjectDataFilesATWM1()
%%%

clear all
clc

global iStudy
global strGroup
global iSession
global strSubject
global nrOfSessions

global bTestConfiguration

iStudy = 'ATWM1';

folderDefinition            = eval(['folderDefinition', iStudy]);
parametersStudy             = eval(['parametersStudy', iStudy]);
parametersGroups            = eval(['parametersGroups', iStudy]);
parametersDicomFiles        = eval(['parametersDicomFiles', iStudy]);
parametersDataSubFolders    = eval(['parametersDataSubFolders', iStudy]);
parametersProjectFiles      = eval(['parametersProjectFiles', iStudy]);

[bAbort] = selectConfigurationForProjectFileProcessingATWM1();
if bAbort
    return
end

%{
%%% Determine, which project file types will be created
parametersProjectFiles.bCreateVmrFiles = false;
parametersProjectFiles.bCreateFmrFiles = true;

if ~bTestConfiguration
    bAbortFunction = false;
    %%% Load text and dialog elements
    [textElements, parametersDialog] = eval(['defineDialogTextElements', iStudy]);
    
    strTitle = 'Options for project file creation';
    strPrompt = 'Select options for project file creation:';
    
    strButton1 = sprintf('%sCreate VMRs and FMRs%s', parametersDialog.strEmpty, parametersDialog.strEmpty);
    strButton2 = sprintf('%sCreate VMRs but NO FMRs%s', parametersDialog.strEmpty, parametersDialog.strEmpty);
    strButton3 = sprintf('%sCreate FMRs but NO VMRs%s', parametersDialog.strEmpty, parametersDialog.strEmpty);
    default = strButton1;
    choice = questdlg(strPrompt, strTitle, strButton1, strButton2, strButton3, default);
    
    switch choice
        case strButton1
            parametersProjectFiles.bCreateVmrFiles = true;
            parametersProjectFiles.bCreateFmrFiles = true;
        case strButton2
            parametersProjectFiles.bCreateVmrFiles = true;
            parametersProjectFiles.bCreateFmrFiles = false;
        case strButton3
            parametersProjectFiles.bCreateVmrFiles = false;
            parametersProjectFiles.bCreateFmrFiles = true;
        otherwise
            parametersProjectFiles.bCreateVmrFiles = false;
            parametersProjectFiles.bCreateFmrFiles = false;
            fprintf('No option selected!\nAborting function.');
            bAbortFunction = true;
    end
else
    parametersProjectFiles.bCreateVmrFiles = false;
    parametersProjectFiles.bCreateFmrFiles = true;
    fprintf('Test config, skipping vmr creation!\n')
end
%}
[parametersProjectFiles, bAbortFunction] = selectProjectFileCreationOptionsATWM1(parametersProjectFiles)
if bAbortFunction
    return
end

bUnzipArchiveFolder = false;
bUnzipArchiveFolder = true;

parametersProjectFiles.bDeleteUnnecessaryFiles = true;

parametersProjectFiles.bFileCreation = true;

[folderDefinition, parametersProjectFiles, aStrSubject, nSubjects, vSessionIndex, bAbort] = selectGeneralParametersATWM1(folderDefinition, parametersGroups, parametersProjectFiles);
if bAbort
    return
end
displaySelectedParametersForProjectFileCreationATWM1(parametersProjectFiles);

%return

for cs = 1:nSubjects
    strSubject = aStrSubject{cs};
    iSession = vSessionIndex(cs);
    
    [folderDefinition] = setCurrentSubjectDataFolderATWM1(folderDefinition, parametersProjectFiles);

    try
        parametersMriSession = analyzeParametersMriScanFileATWM1;
    catch
        fprintf('Error during processing of ParametersMriScanFile!\nSkipping subject %s\n', strSubject);
        continue
    end

    if parametersMriSession.bAllRunsAcquired
        nrOfSessions = 1;
    else
        %%% EXPAND
        nrOfSessions = 2;
    end
    
    %%{
    %%% Prepare subject data folder for file transfer
    structProjectDataSubFolders = defineProjectDataSubFoldersATWM1(folderDefinition.strCurrentSubjectDataFolder);
    folderDefinition = determineTargetFoldersForSessionDataATWM1(folderDefinition, parametersDicomFiles, parametersDataSubFolders, structProjectDataSubFolders);
    
    
    if exist(folderDefinition.strCurrentSubjectDataFolder, 'dir')
        [aStrDicomFiles, nrOfDicomFiles] = detectAllDicomFilesInFolderATWM1(folderDefinition, parametersDicomFiles);
        if isequal(nrOfDicomFiles, parametersMriSession.nDicomFiles)
            bOverwriteMriScanSessionFiles = false;
        else
            bOverwriteMriScanSessionFiles = true;
        end
    else
        bOverwriteMriScanSessionFiles = true;
    end
    
    %%% MOVE TO SEPARATE FUNCTION
    if exist(folderDefinition.strCurrentSubjectDataFolder, 'dir') && parametersProjectFiles.bForceDeletionOfAllExistingFiles
        try
            rmdir(folderDefinition.strCurrentSubjectDataFolder, 's');
            fprintf('Deleting folder %s\n\n', folderDefinition.strCurrentSubjectDataFolder);
        catch
            
        end
    end
    if exist(folderDefinition.strCurrentSubjectDataFolder, 'dir') && bOverwriteMriScanSessionFiles == true
        %%% Delete existing Dicom files by deleting the folder
        if exist(folderDefinition.strDicomFilesSubFolderCurrentSession, 'dir') 
            try
                rmdir(folderDefinition.strDicomFilesSubFolderCurrentSession, 's');
                fprintf('Deleting folder %s\n\n', folderDefinition.strDicomFilesSubFolderCurrentSession);
            catch
                
            end
        end
        %%% Create missing subfolders
        for cd = 1:structProjectDataSubFolders.nDataSubFolder
            if ~exist(structProjectDataSubFolders.aStrProjectDataSubFolder{cd}, 'dir')
                try
                    mkdir(structProjectDataSubFolders.aStrProjectDataSubFolder{cd});
                    fprintf('Creating subfolder %s\n', structProjectDataSubFolders.aStrProjectDataSubFolder{cd});
                catch
                    
                end
            end
        end
        fprintf('\n');
        %%% Unzip files
        
        % Include check, wheter DICOMs are already complete (and renamed?)
        
        if bUnzipArchiveFolder
            [bUnzipArchiveFolderSuccessful] = unzipSubjectArchiveFolderATWM1(folderDefinition, parametersStudy, parametersDicomFiles);
            if ~bUnzipArchiveFolderSuccessful
                return
            end
        end
    elseif ~exist(folderDefinition.strCurrentSubjectDataFolder, 'dir')
        [~] = createProjectDataSubFoldersATWM1(folderDefinition.strCurrentSubjectDataFolder);
        %%% Unzip files
        if bUnzipArchiveFolder
            [bUnzipArchiveFolderSuccessful] = unzipSubjectArchiveFolderATWM1(folderDefinition, parametersStudy, parametersDicomFiles);
            if ~bUnzipArchiveFolderSuccessful
                return
            end
        end
    end
    
    
    
    
    %%% Rename dicom files
    
    %%% Include check, whether DICOMs are already complete and renamed
    
    bRenameDicomFilesSuccessful = false;
    fprintf('Initiating renaming of DICOM files in folder %s!\n', folderDefinition.strDicomFilesSubFolderCurrentSession);
    counterRenameUnsuccessful = 0;
    nrOfUnsuccessfulRenameAttemps = 3;
    while ~bRenameDicomFilesSuccessful
        bRenameDicomFilesSuccessful = renameDicomFilesATWM1(folderDefinition, parametersDicomFiles, bRenameDicomFilesSuccessful);
        removeSpaceFromDicomFileNameATWM1(folderDefinition);
        if ~bRenameDicomFilesSuccessful
            counterRenameUnsuccessful = counterRenameUnsuccessful + 1;
        end
        if counterRenameUnsuccessful == nrOfUnsuccessfulRenameAttemps
            break
        end
    end
    if ~bRenameDicomFilesSuccessful
        fprintf('Failed renaming of DICOM files in folder %s!\nSkipping subject %s\n', folderDefinition.strDicomFilesSubFolderCurrentSession, strSubject);
        continue
    end
    %removeSpaceFromDicomFileNameATWM1(folderDefinition);
    
    %%% Create project files
    if parametersProjectFiles.bCreateVmrFiles
        [bAbortFunction] = prepareVmrFileCreationATWM1(folderDefinition, parametersMriSession, parametersDicomFiles, parametersProjectFiles, structProjectDataSubFolders);
        if bAbortFunction == true
            return
        end
    end
    if parametersProjectFiles.bCreateFmrFiles
        [bAbortFunction] = prepareFmrFileCreationATWM1(folderDefinition, parametersStudy, parametersMriSession, parametersDicomFiles, parametersProjectFiles, structProjectDataSubFolders);
        %%{
        if bAbortFunction == true
            return
        end
        %}
    end
end

end


function [parametersProjectFiles, bAbortFunction] = selectProjectFileCreationOptionsATWM1(parametersProjectFiles)

global iStudy
global bTestConfiguration

%%% Determine, which project file types will be created
%parametersProjectFiles.bCreateVmrFiles = false;
%parametersProjectFiles.bCreateFmrFiles = true;
bAbortFunction = false;

if ~bTestConfiguration
    %%% Load text and dialog elements
    [textElements, parametersDialog] = eval(['defineDialogTextElements', iStudy]);
    
    strTitle = 'Options for project file creation';
    strPrompt = 'Select options for project file creation:';
    
    strButton1 = sprintf('%sCreate VMRs and FMRs%s', parametersDialog.strEmpty, parametersDialog.strEmpty);
    strButton2 = sprintf('%sCreate VMRs but NO FMRs%s', parametersDialog.strEmpty, parametersDialog.strEmpty);
    strButton3 = sprintf('%sCreate FMRs but NO VMRs%s', parametersDialog.strEmpty, parametersDialog.strEmpty);
    default = strButton1;
    choice = questdlg(strPrompt, strTitle, strButton1, strButton2, strButton3, default);
    
    switch choice
        case strButton1
            parametersProjectFiles.bCreateVmrFiles = true;
            parametersProjectFiles.bCreateFmrFiles = true;
        case strButton2
            parametersProjectFiles.bCreateVmrFiles = true;
            parametersProjectFiles.bCreateFmrFiles = false;
        case strButton3
            parametersProjectFiles.bCreateVmrFiles = false;
            parametersProjectFiles.bCreateFmrFiles = true;
        otherwise
            parametersProjectFiles.bCreateVmrFiles = false;
            parametersProjectFiles.bCreateFmrFiles = false;
            fprintf('No option selected!\nAborting function.');
            bAbortFunction = true;
    end
else
    parametersProjectFiles.bCreateVmrFiles = false;
    parametersProjectFiles.bCreateFmrFiles = true;
    %fprintf('Test config, skipping vmr creation!\n')
end


end


function displaySelectedParametersForProjectFileCreationATWM1(parametersProjectFiles)

global bTestConfiguration

%%% Print selected parameters in command window
if parametersProjectFiles.bCreateVmrFiles
    fprintf('Creation of VMR files enabled.\n');
else
    fprintf('Creation of VMR files disabled.\n');
end

if parametersProjectFiles.bCreateFmrFiles 
    fprintf('Creation of FMR files enabled.\n');
else
    fprintf('Creation of FMR files disabled.\n');
end

if bTestConfiguration
    fprintf('Test configuration enabled!\n');
end
if parametersProjectFiles.bForceDeletionOfAllExistingFiles
    fprintf('Warning!!!\nAll files of all selected subjects will be deleted!\n');
end

end


function [bAbortFunction] = prepareVmrFileCreationATWM1(folderDefinition, parametersMriSession, parametersDicomFiles, parametersProjectFiles, structProjectDataSubFolders)

global iStudy
global strGroup
global iSession
global strSubject
global nrOfSessions

parametersProcessDuration = eval(['parametersProcessDuration', iStudy]);

parametersProjectFiles.strCurrentProjectType = parametersProjectFiles.strStructuralProject;

[aParametersStructuralMriSequence, vFileIndicesVmr, nrOfStructuralMriProjects] = prepareParametersForVmrFileCreationATWM1(parametersMriSession);

for cf = 1:nrOfStructuralMriProjects
    %%% Determine the parameters of the project
    parametersStructuralMriSequence                 = aParametersStructuralMriSequence{cf};
    parametersProjectFiles.iDicomFileRun            = vFileIndicesVmr(cf);
    parametersProjectFiles.nrOfDicomFilesForProject = parametersStructuralMriSequence.nSlices;
    %%% Determine subfolder and copy DICOM files
    parametersProjectFiles.strCurrentProject = sprintf('%s_%s', parametersStructuralMriSequence.strSequence , parametersStructuralMriSequence.strResolution);
    [folderDefinition, parametersProjectFiles] = determineCurrentProjectDataSubfolderATWM1(folderDefinition, parametersProjectFiles, structProjectDataSubFolders);
    [parametersProjectFiles, bAbortFunction] = prepareDicomFilesForProjectATWM1(folderDefinition, parametersProjectFiles);
    if bAbortFunction
        return
    end
    %%% Create project file and delete files not required for further processing
    [bFileCreated] = createVmrFileATWM1(folderDefinition, parametersProjectFiles, parametersStructuralMriSequence, parametersProcessDuration);
    deleteDicomFilesFromSubfolderATWM1(folderDefinition, parametersDicomFiles);
    deleteUntitledFilesFromSubfolderATWM1(folderDefinition, parametersProjectFiles);
end


end


function [aParametersStructuralMriSequence, vFileIndicesVmr, nrOfStructuralMriProjects] = prepareParametersForVmrFileCreationATWM1(parametersMriSession)

global iStudy

parametersStructuralMriSequenceHighRes  = eval(['parametersStructuralMriSequenceHighRes', iStudy]);
parametersStructuralMriSequenceLowRes   = eval(['parametersStructuralMriSequenceLowRes', iStudy]);

aParametersStructuralMriSequence = {
    parametersStructuralMriSequenceHighRes
    parametersStructuralMriSequenceLowRes
    };
vFileIndicesVmr = [
    parametersMriSession.fileIndexVmrHighRes
    parametersMriSession.fileIndexVmrLowRes
    ];
nrOfStructuralMriProjects = numel(aParametersStructuralMriSequence);


end


function [bAbortFunction] = prepareFmrFileCreationATWM1(folderDefinition, parametersStudy, parametersMriSession, parametersDicomFiles, parametersProjectFiles, structProjectDataSubFolders)

global iStudy
global strGroup
global iSession
global strSubject
global nrOfSessions
global bTestConfiguration

parametersProcessDuration           = eval(['parametersProcessDuration', iStudy]);
parametersEpiDistortionCorrection   = eval(['parametersEpiDistortionCorrection', iStudy]);

parametersProjectFiles.strCurrentProjectType    = parametersProjectFiles.strFunctionalProject;

[parametersProjectFiles] = prepareParametersForFmrFileProcessingATWM1(parametersStudy, parametersMriSession, parametersProjectFiles);

for cp = 1:parametersProjectFiles.nrOfFunctionalMriProjects
    [parametersParadigm, parametersProjectFiles, parametersMriSession] = setParametersForFmrFileProcessingATWM1(parametersProjectFiles, parametersMriSession, cp);
    if bTestConfiguration
        [parametersProjectFiles] = setNumberOfFunctionalRunsForTestConfigurationATWM1(parametersProjectFiles, parametersParadigm);
    end
    for cr = 1:parametersProjectFiles.nrOfTotalRuns
        parametersFunctionalMriSequence             = parametersProjectFiles.aParametersFunctionalMriSequence{cp};
        [parametersProjectFiles] = setParametersForCurrentFunctionalProjectFileATWM1(parametersStudy, parametersParadigm, parametersFunctionalMriSequence, parametersMriSession, parametersProjectFiles, cr);
        %%% Determine subfolder and copy DICOM files
        [folderDefinition, parametersProjectFiles] = determineCurrentProjectDataSubfolderATWM1(folderDefinition, parametersProjectFiles, structProjectDataSubFolders);
        [parametersProjectFiles, bAbortFunction] = prepareDicomFilesForProjectATWM1(folderDefinition, parametersProjectFiles, parametersMriSession);
        if bAbortFunction
            return
        end
        %%% Create project file and delete files not required for further processing
        parametersProjectFiles.bFunctionalRun = true;
        [bFileCreated] = createFmrFileATWM1(folderDefinition, parametersStudy, parametersProjectFiles, parametersFunctionalMriSequence, parametersEpiDistortionCorrection, parametersProcessDuration);
        deleteUnnecessaryFilesAfterProjectFileCreationATWM1(folderDefinition, parametersDicomFiles, parametersProjectFiles)
        %%% Create files for EPI distortion correction
        [parametersMriSession, parametersFunctionalMriSequence, parametersProjectFiles] = prepareFileCreationForEpiDistortionCorrectionATWM1(parametersStudy, parametersParadigm, parametersMriSession, parametersFunctionalMriSequence, parametersProjectFiles, parametersEpiDistortionCorrection, cr);
        [folderDefinition, parametersProjectFiles] = determineCurrentProjectDataSubfolderATWM1(folderDefinition, parametersProjectFiles, structProjectDataSubFolders);
        for cf = 1:numel(parametersMriSession.aFileIndexSequencesForCopeCurrentRun)
            [parametersProjectFiles, parametersEpiDistortionCorrection] = setParametersForEpiDistortionCorrectionFileATWM1(parametersMriSession, parametersProjectFiles, parametersEpiDistortionCorrection, cf);
            [parametersProjectFiles, bAbortFunction] = prepareDicomFilesForProjectATWM1(folderDefinition, parametersProjectFiles, parametersMriSession);
            if bAbortFunction
                return
            end
            [bFileCreated] = createFmrFileATWM1(folderDefinition, parametersStudy, parametersProjectFiles, parametersFunctionalMriSequence, parametersEpiDistortionCorrection, parametersProcessDuration);
        end
        deleteUnnecessaryFilesAfterProjectFileCreationATWM1(folderDefinition, parametersDicomFiles, parametersProjectFiles)        
    end
end

end


function [parametersProjectFiles, parametersEpiDistortionCorrection] = setParametersForEpiDistortionCorrectionFileATWM1(parametersMriSession, parametersProjectFiles, parametersEpiDistortionCorrection, cf)

parametersProjectFiles.nrOfDicomFilesForProject             = parametersEpiDistortionCorrection.nVolumes;
parametersProjectFiles.iDicomFileRun                        = parametersMriSession.aFileIndexSequencesForCopeCurrentRun(cf);
parametersEpiDistortionCorrection.strPhaseEncodingDirection = parametersEpiDistortionCorrection.aStrPhaseEncodingDirections{cf};
parametersProjectFiles.bFunctionalRun                       = false;


end


function deleteUnnecessaryFilesAfterProjectFileCreationATWM1(folderDefinition, parametersDicomFiles, parametersProjectFiles)

if parametersProjectFiles.bDeleteUnnecessaryFiles
    %%% Delete unnecessary files
    fprintf('\nDeleting unnecessary files from folder %s\n', folderDefinition.strCurrentProjectDataSubFolder)
    deleteDicomFilesFromSubfolderATWM1(folderDefinition, parametersDicomFiles);
    deleteUntitledFilesFromSubfolderATWM1(folderDefinition, parametersProjectFiles);
    fprintf('\n\n');
end

end


function [parametersMriSession, parametersFunctionalMriSequence, parametersProjectFiles] = prepareFileCreationForEpiDistortionCorrectionATWM1(parametersStudy, parametersParadigm, parametersMriSession, parametersFunctionalMriSequence, parametersProjectFiles, parametersEpiDistortionCorrection, cr)

parametersMriSession.fileIndexStandardPhaseEncoding  = parametersMriSession.fileIndexCurrentFmr(cr);
parametersMriSession.fileIndexInversePhaseEncoding   = parametersMriSession.fileIndexFmr_COPE(parametersMriSession.fileIndexFmr_COPE < parametersMriSession.fileIndexStandardPhaseEncoding);
parametersMriSession.fileIndexInversePhaseEncoding   = max(parametersMriSession.fileIndexInversePhaseEncoding);

parametersMriSession.aFileIndexSequencesForCopeCurrentRun = [
    parametersMriSession.fileIndexStandardPhaseEncoding
    parametersMriSession.fileIndexInversePhaseEncoding
    ];

parametersFunctionalMriSequence.nVolumes        = parametersEpiDistortionCorrection.nVolumes;
parametersFunctionalMriSequence.nVolumesToSkip  = parametersEpiDistortionCorrection.nVolumesToSkip;
parametersFunctionalMriSequence.nVolumesFmr     = parametersEpiDistortionCorrection.nVolumesFmr;

if parametersProjectFiles.nrOfTotalRuns == 1
    parametersProjectFiles.strCurrentProject = sprintf('%s_%s', parametersStudy.strMethodEpiDistortionCorrection, parametersProjectFiles.strCurrentParadigm);
elseif parametersProjectFiles.nrOfTotalRuns == 1 && parametersProjectFiles.bNrOfTotalRunsActuallyReducedDuringTestConfig
    parametersProjectFiles.strCurrentProject = sprintf('%s_%s_%s_%i', parametersStudy.strMethodEpiDistortionCorrection, parametersProjectFiles.strCurrentParadigm, parametersStudy.strRun, cr);
else
    parametersProjectFiles.strCurrentProject = sprintf('%s_%s_%s_%i', parametersStudy.strMethodEpiDistortionCorrection, parametersProjectFiles.strCurrentParadigm, parametersStudy.strRun, cr);
end


end


function [bUnzipArchiveFolderSuccessful] = unzipSubjectArchiveFolderATWM1(folderDefinition, parametersStudy, parametersDicomFiles)

global iStudy
global iSession
global strSubject

%%% Define files and paths
structSubjectArchiveFolders                     = defineSubjectArchiveFoldersATWM1(folderDefinition);
strZipFileArchiveDicomFilesSubject              = defineZipFileArchiveDicomFilesSubjectATWM1(parametersStudy);
strPathZipFileLocalArchiveDicomFilesSubject     = fullfile(structSubjectArchiveFolders.strFolderLocalArchiveDicomFilesGroup, strZipFileArchiveDicomFilesSubject);

%%% Unzip files
fprintf('Unzipping raw data for subject: %s\t\tsession: %i\n', strSubject, iSession);
try
    unzip(strPathZipFileLocalArchiveDicomFilesSubject, folderDefinition.strDicomFilesSubFolderCurrentSession);
    bUnzipArchiveFolderSuccessful = true;
    fprintf('Unzipping of raw data for subject %s successful!\n', strSubject);
catch
    bUnzipArchiveFolderSuccessful = false;
    fprintf('Error while unzipping subject archive files %s\n', strZipFileArchiveDicomFilesSubject);
end
fprintf('\n');
moveSessionLogfilesToLogfileFolderATWM1(folderDefinition, parametersDicomFiles);


end


function moveSessionLogfilesToLogfileFolderATWM1(folderDefinition, parametersDicomFiles)

global iStudy
global iSession
global strSubject

%%% Move session logfiles to logfile folder
strucFiles = dir(folderDefinition.strDicomFilesSubFolderCurrentSession);
strucFiles = strucFiles(3:end);
counterFiles = 0;
aStrPathLogfilesSource = [];
for cf = 1:numel(strucFiles)
    if isempty(strfind(strucFiles(cf).name, parametersDicomFiles.extDicomFile))
        counterFiles = counterFiles + 1;
        aStrPathLogfilesSource{counterFiles} = fullfile(folderDefinition.strDicomFilesSubFolderCurrentSession, strucFiles(cf).name);
    end
end

if ~isempty(aStrPathLogfilesSource)
    aStrPathLogfilesDestination = strrep(aStrPathLogfilesSource, folderDefinition.strDicomFilesSubFolderCurrentSession, folderDefinition.strLogfilesSubFolderCurrentSession);
    for cf = 1:numel(aStrPathLogfilesSource)
        success(cf) = movefile(aStrPathLogfilesSource{cf}, aStrPathLogfilesDestination{cf});
    end
end


end


function deleteDicomFilesFromSubfolderATWM1(folderDefinition, parametersDicomFiles)

%%% Delete all DICOM files from subfolder
strDicomFilesInSubfolder = sprintf('%s*%s', folderDefinition.strCurrentProjectDataSubFolder, parametersDicomFiles.extDicomFile);
try
    delete(strDicomFilesInSubfolder)
    fprintf('Deleting DICOM files from folder %s\n', folderDefinition.strCurrentProjectDataSubFolder)
catch
    fprintf('Error!\nCould not delete DICOM files from folder %s\n', folderDefinition.strCurrentProjectDataSubFolder)
end


end


function deleteUntitledFilesFromSubfolderATWM1(folderDefinition, parametersProjectFiles)

% Delete untitled files
strUntitledFilesInSubfolder = sprintf('%s%s.*', folderDefinition.strCurrentProjectDataSubFolder, parametersProjectFiles.strUntitledFiles);
try
    delete(strUntitledFilesInSubfolder)
    fprintf('Deleting UNTITLED files from folder %s\n', folderDefinition.strCurrentProjectDataSubFolder)
catch
    fprintf('Error!\nCould not delete UNTITLED files from folder %s\n', folderDefinition.strCurrentProjectDataSubFolder)
end


end