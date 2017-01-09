function createVolumeTimeCourseATWM1()
%%% © 2016 Robert Bittner
%%% Written for BrainVoyagerQX 2.8.4
%%% This function calls BrainVoyagerQX using the COM interface.
%%% This function creates VTC Projects in TAL Space.

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
parametersProjectFiles      = eval(['parametersProjectFiles', iStudy]);

parametersProcessDuration           = eval(['parametersProcessDuration', iStudy]);
parametersEpiDistortionCorrection   = eval(['parametersEpiDistortionCorrection', iStudy]);
parametersSliceScanTimeCorrection   = eval(['parametersSliceScanTimeCorrection', iStudy]);
parametersMotionCorrection          = eval(['parametersMotionCorrection', iStudy]);
parametersSpatialGaussianSmoothing  = eval(['parametersSpatialGaussianSmoothing', iStudy]);
parametersTemporalHighPassFiltering = eval(['parametersTemporalHighPassFiltering', iStudy]);
parametersCoregistration            = eval(['parametersCoregistration', iStudy]);

parametersStructuralMriSequenceHighRes      = eval(['parametersStructuralMriSequenceHighRes', iStudy]);
parametersBrainNormalisationAndSegmentation = eval(['parametersBrainNormalisationAndSegmentation', iStudy]);
parametersVolumeTimeCourse                  = eval(['parametersVolumeTimeCourse', iStudy]);

[bAbort] = selectConfigurationForProjectFileProcessingATWM1();
if bAbort
    return
end

parametersProjectFiles.bFileCreation = false;
%%% Set parameter for processing of full functional runs
parametersProjectFiles.bFunctionalRun = true;

[parametersProjectFiles] = selectFmrForVtcFileCreationATWM1(folderDefinition, parametersStudy, parametersProjectFiles, parametersEpiDistortionCorrection, parametersSliceScanTimeCorrection, parametersMotionCorrection, parametersSpatialGaussianSmoothing, parametersTemporalHighPassFiltering);

[folderDefinition, parametersProjectFiles, aStrSubject, nSubjects, ~, bAbort] = selectGeneralParametersATWM1(folderDefinition, parametersGroups, parametersProjectFiles);
if bAbort
    return
end

for cs = 1:nSubjects
    strSubject = aStrSubject{cs};
    [folderDefinition] = setCurrentSubjectDataFolderATWM1(folderDefinition, parametersProjectFiles);
    
    try
        parametersMriSession = analyzeParametersMriScanFileATWM1;
    catch
        fprintf('Error during processing of ParametersMriScanFile!\nSkipping subject %s\n\n', strSubject);
        continue
    end
    
    structProjectDataSubFolders = defineProjectDataSubFoldersATWM1(folderDefinition.strCurrentSubjectDataFolder);
    [parametersProjectFiles] = prepareParametersForFmrFileProcessingATWM1(parametersStudy, parametersMriSession, parametersProjectFiles);
    
    if bTestConfiguration
        parametersProjectFiles.nrOfFunctionalMriProjects = 2;
    end
    
    %%% Define VMR file for VTC file creation
    strVmrBrainExtrFile = sprintf('%s_%s_%s_%s_%s%s', strSubject, iStudy, parametersStructuralMriSequenceHighRes.strSequence, parametersStructuralMriSequenceHighRes.strResolution, parametersBrainNormalisationAndSegmentation.strBrainExtraction, parametersProjectFiles.extStructuralProject);
    strVmrInTalFile = sprintf('%s_%s_%s_%s_%s_%s%s', strSubject, iStudy, parametersStructuralMriSequenceHighRes.strSequence, parametersStructuralMriSequenceHighRes.strResolution, parametersBrainNormalisationAndSegmentation.strBrainExtraction, parametersBrainNormalisationAndSegmentation.strTalairachTransformation, parametersProjectFiles.extStructuralProject);
    strPathVmrInTalFile = fullfile(structProjectDataSubFolders.strFolder_MPRAGE_HIGH_RES, strVmrInTalFile);

    %%% create VTC files
    for cp = 1:parametersProjectFiles.nrOfFunctionalMriProjects
        [parametersParadigm, parametersProjectFiles, parametersMriSession] = setParametersForFmrFileProcessingATWM1(parametersProjectFiles, parametersMriSession, cp);
        if bTestConfiguration
            [parametersProjectFiles] = setNumberOfFunctionalRunsForTestConfigurationATWM1(parametersProjectFiles, parametersParadigm);
        end
        for cr = 1:parametersProjectFiles.nrOfTotalRuns
            parametersFunctionalMriSequence = parametersProjectFiles.aParametersFunctionalMriSequence{cp};
            [parametersProjectFiles] = setParametersForCurrentFunctionalProjectFileATWM1(parametersStudy, parametersParadigm, parametersFunctionalMriSequence, parametersMriSession, parametersProjectFiles, cr);
            %%% Determine subfolder for current project file
            [folderDefinition, parametersProjectFiles] = determineCurrentProjectDataSubfolderATWM1(folderDefinition, parametersProjectFiles, structProjectDataSubFolders);
            [parametersProjectFiles] = definePreprocessedVtcFileNamesATWM1(folderDefinition, parametersStudy, parametersProjectFiles, parametersEpiDistortionCorrection, parametersSliceScanTimeCorrection, parametersMotionCorrection, parametersSpatialGaussianSmoothing, parametersTemporalHighPassFiltering)
            
            %%% Add firstvol_undist
            
            %%% EPI distortion correction for firstvol
            strExtFmrFileFirstVolUndistort                                  = sprintf('_%s_%s%s', parametersProjectFiles.strFirstVolume, parametersEpiDistortionCorrection.strDistortionCorrection, parametersProjectFiles.extFunctionalProject);
            parametersProjectFiles.strCurrentFmrFileFirstVolUndistort       = strrep(parametersProjectFiles.strCurrentFmrFileOriginal, parametersProjectFiles.extFunctionalProject, strExtFmrFileFirstVolUndistort);
            parametersProjectFiles.strPathCurrentFmrFileFirstVolUndistort   = strrep(parametersProjectFiles.strPathCurrentFmrFileOriginal, parametersProjectFiles.extFunctionalProject, strExtFmrFileFirstVolUndistort);

            %%% Define files for VTC file creation
            strFmrFile              = parametersProjectFiles.(matlab.lang.makeValidName(parametersProjectFiles.strFieldnameSelectedFmrType))
            strVtcFile              = parametersProjectFiles.(matlab.lang.makeValidName(parametersProjectFiles.strFieldnameSelectedVtcType))
            
            strIntialAlignmentFile  = sprintf('%s-TO-%s_%s%s', parametersProjectFiles.strCurrentFmrFileFirstVolUndistort, strVmrBrainExtrFile, parametersCoregistration.strInitialAlignment, parametersProjectFiles.extTransformationFile)
            strFineAlignmentFile    = sprintf('%s-TO-%s_%s%s', parametersProjectFiles.strCurrentFmrFileFirstVolUndistort, strVmrBrainExtrFile, parametersCoregistration.strFineAlignment, parametersProjectFiles.extTransformationFile)
            
            strAcpcFile             = sprintf('%s_%s_%s_%s_%s_%s%s', strSubject, iStudy, parametersStructuralMriSequenceHighRes.strSequence, parametersStructuralMriSequenceHighRes.strResolution, parametersBrainNormalisationAndSegmentation.strBrainExtraction, parametersBrainNormalisationAndSegmentation.strAcpcTransformation, parametersProjectFiles.extTransformationFile)
            strTalFile              = sprintf('%s_%s_%s_%s_%s_%s%s', strSubject, iStudy, parametersStructuralMriSequenceHighRes.strSequence, parametersStructuralMriSequenceHighRes.strResolution, parametersBrainNormalisationAndSegmentation.strBrainExtraction, parametersBrainNormalisationAndSegmentation.strAcpcTransformation, parametersProjectFiles.extTalFile)
            
            filesForVtcCreation.strPathFmrFile              = parametersProjectFiles.(matlab.lang.makeValidName(parametersProjectFiles.strFieldnamePathSelectedFmrType));
            filesForVtcCreation.strPathVtcFile              = parametersProjectFiles.(matlab.lang.makeValidName(parametersProjectFiles.strFieldnamePathSelectedVtcType));
            filesForVtcCreation.strPathIntialAlignmentFile  = fullfile(folderDefinition.strCurrentProjectDataSubFolder, strIntialAlignmentFile);
            filesForVtcCreation.strPathFineAlignmentFile    = fullfile(folderDefinition.strCurrentProjectDataSubFolder, strFineAlignmentFile);
            filesForVtcCreation.strPathAcpcFile             = fullfile(structProjectDataSubFolders.strFolder_MPRAGE_HIGH_RES, strAcpcFile);
            filesForVtcCreation.strPathTalFile              = fullfile(structProjectDataSubFolders.strFolder_MPRAGE_HIGH_RES, strTalFile);

            [bFilesForVtcFileCreationComplete] = verifyExistenceOfFilesForVtcFileCreationATWM1(filesForVtcCreation, strVtcFile);
            
            if bFilesForVtcFileCreationComplete
                fprintf('\nStarting creation of VTC file %s with %s and a resolution of %s.\n', strVtcFile, parametersVolumeTimeCourse.strInterpolationMethod, parametersVolumeTimeCourse.strResolution);

                %%% Check compatibility of the currently installed version of BrainVoyager
                %%% and run BrainVoyager as a COM object
                hFunction = str2func(sprintf('runBrainVoyager%s', iStudy));
                [bvqx, parametersComProcess, bIncompatibleBrainVoyagerVersion] = feval(hFunction);
                if bIncompatibleBrainVoyagerVersion == true
                    bVtcFileCreated = false;
                    return
                end
                
                %%% Open additional Matlab command window to terminate crashed BrainVoyager
                %%% COM objects
                hFunction = str2func(sprintf('initiateDelayedTerminationOfBrainVoyagerComProcesses%s', iStudy));
                matlabCommandWindowProcessId = feval(hFunction, parametersComProcess, processDuration);
                
                %%% The files are opened in BrainVoyager and the VTCs are created.
                vmr = bvqx.OpenDocument(strPathVmrInTalFile);
                vmr.ExtendedTALSpaceForVTCCreation = parametersVolumeTimeCourse.extendedBoundingBox;
                bVtcFileCreated = vmr.CreateVTCInTALSpace(filesForVtcCreation.strPathFmrFile, filesForVtcCreation.strPathIntialAlignmentFile, filesForVtcCreation.strPathFineAlignmentFile, filesForVtcCreation.strPathAcpcFile, filesForVtcCreation.strPathTalFile, filesForVtcCreation.strPathVtcFile, parametersVolumeTimeCourse.dataType, parametersVolumeTimeCourse.resolution, parametersVolumeTimeCourse.interpolationMethod, parametersVolumeTimeCourse.threshold);
                vmr.Close();
                
                hFunction = str2func(sprintf('delayedTerminationOfMatlabCommandWindows%s', iStudy));
                feval(hFunction, matlabCommandWindowProcessId, processDuration);
                if bVtcFileCreated
                    fprintf('\nCreation of VTC file %s with %s and a resolution of %s successful!\n', strPathVtcFile, parametersVolumeTimeCourse.strInterpolationMethod, parametersVolumeTimeCourse.strResolution);
                end
            end

        end
    end
    
end


end


function [parametersProjectFiles] = selectFmrForVtcFileCreationATWM1(folderDefinition, parametersStudy, parametersProjectFiles, parametersEpiDistortionCorrection, parametersSliceScanTimeCorrection, parametersMotionCorrection, parametersSpatialGaussianSmoothing, parametersTemporalHighPassFiltering)

global iStudy

%%% Prepare standard FMR file names
parametersProjectFiles = selectFmrPreprocessingOptionsATWM1(parametersProjectFiles);

[parametersProjectFiles] = definePreprocessedFmrFileNamesATWM1(folderDefinition, parametersStudy, parametersProjectFiles, parametersEpiDistortionCorrection, parametersSliceScanTimeCorrection, parametersMotionCorrection, parametersSpatialGaussianSmoothing, parametersTemporalHighPassFiltering);

aStrFieldnamesFmrFileVariants = parametersProjectFiles.aStrFmrFileFieldnames(1:2:end);

for cfn = 1:numel(aStrFieldnamesFmrFileVariants)
    aStrFmrFileVariants{cfn} = parametersProjectFiles.(matlab.lang.makeValidName(aStrFieldnamesFmrFileVariants{cfn}));
end

%%% Open dialog for FMR file type selection
strSelectionMode = 'single';
strPrompt = sprintf('Please select FMR file type for VTC file creation');
strDialogTitle = sprintf('FMR-Selection');
[indFmrForVtcFileCreation, ~] = listdlg('ListString',aStrFmrFileVariants, 'SelectionMode', strSelectionMode, 'Name', strDialogTitle, 'PromptString', strPrompt, 'ListSize', [600, 200]);

strSelectedFmrType = aStrFmrFileVariants{indFmrForVtcFileCreation};
parametersProjectFiles.strSelectedFmrType = strSelectedFmrType(strfind(strSelectedFmrType, parametersStudy.strParadigm) + length(parametersStudy.strParadigm) + 1 : end);
fprintf('Selected FMR file type: %s\n\n', parametersProjectFiles.strSelectedFmrType);

parametersProjectFiles.strFieldnameSelectedFmrType = aStrFieldnamesFmrFileVariants{indFmrForVtcFileCreation};
%parametersProjectFiles.strFieldnamePathSelectedFmrType = '';    % Dummy to ensure the correct order of fields

indFieldSelectedFmrType = find(strcmp(fieldnames(parametersProjectFiles), parametersProjectFiles.strFieldnameSelectedFmrType));
indFieldPathSelectedFmrType = indFieldSelectedFmrType + 1;
aStrAllFieldnames = fieldnames(parametersProjectFiles);

parametersProjectFiles.strFieldnamePathSelectedFmrType = aStrAllFieldnames{indFieldPathSelectedFmrType};

parametersProjectFiles.strFieldnameSelectedVtcType = strrep(parametersProjectFiles.strFieldnameSelectedFmrType, 'Fmr', 'Vtc');
parametersProjectFiles.strFieldnamePathSelectedVtcType = strrep(parametersProjectFiles.strFieldnamePathSelectedFmrType, 'Fmr', 'Vtc');

end


function [bFilesForVtcFileCreationComplete] = verifyExistenceOfFilesForVtcFileCreationATWM1(filesForVtcCreation, strVtcFile)
%%% This function checks, whether all the files necessary for VTC file 
%%% creation exist.

aStrFieldNamesFilesForVtcFileCreation = fieldnames(filesForVtcCreation);
nrOfFilesForVtcFileCreation = numel(aStrFieldNamesFilesForVtcFileCreation);

fileCounter = 0;
for cfn = 1:nrOfFilesForVtcFileCreation
    strPathFile = filesForVtcCreation.(matlab.lang.makeValidName(aStrFieldNamesFilesForVtcFileCreation{cfn}));
    if exist(strPathFile, 'file') > 0
        fileCounter = fileCounter + 1;
    else
        fprintf('File %s required for VTC file creation not found!\n', strPathFile);
    end
end

if fileCounter == nrOfFilesForVtcFileCreation
    bFilesForVtcFileCreationComplete = true;
else
    fprintf('\nError! Files for %s incomplete!\nVTC file is not created!\n\n', strVtcFile);
    bFilesForVtcFileCreationComplete = false;
end


end


function bVtcFileCreated = dkdk()

global iStudy
global strGroup
global iSession
global strSubject
global nrOfSessions

fprintf('\nStarting creation of VTC file %s.\n', strVtcFile);

%%% Check compatibility of the currently installed version of BrainVoyager
%%% and run BrainVoyager as a COM object
hFunction = str2func(sprintf('runBrainVoyager%s', iStudy));
[bvqx, parametersComProcess, bIncompatibleBrainVoyagerVersion] = feval(hFunction);
if bIncompatibleBrainVoyagerVersion == true
    bVtcFileCreated = false;
    return
end

%%% Open additional Matlab command window to terminate crashed BrainVoyager
%%% COM objects
hFunction = str2func(sprintf('initiateDelayedTerminationOfBrainVoyagerComProcesses%s', iStudy));
matlabCommandWindowProcessId = feval(hFunction, parametersComProcess, processDuration);

%%% The files are opened in BrainVoyager and the VTCs are created.
vmr = bvqx.OpenDocument(strPathVmrInTalFile);
vmr.ExtendedTALSpaceForVTCCreation = parametersVolumeTimeCourse.extendedBoundingBox;
bVtcFileCreated = vmr.CreateVTCInTALSpace(strPathFmrFile, strPathIntialAlignmentFile, strPathFineAlignmentFile, strPathAcpcFile, strPathTalFile, strPathVtcFile, parametersVolumeTimeCourse.dataType, parametersVolumeTimeCourse.resolution, parametersVolumeTimeCourse.interpolationMethod, parametersVolumeTimeCourse.threshold);
vmr.Close();

hFunction = str2func(sprintf('delayedTerminationOfMatlabCommandWindows%s', iStudy));
feval(hFunction, matlabCommandWindowProcessId, processDuration);
if bVtcFileCreated
    fprintf('\nCreation of VTC file %s successful!\n', strPathVtcFile);
end


end

%{
%localHDD    = 'Local Harddrive';
%server      = 'Beoserv1-t';
dataSourceArray = {
    'Local Harddrive'
    'Beoserv1-t'
    };

[indexDataSource, OK]  = listdlg('ListString', dataSourceArray);
if OK == 0
    sprintf('No data source selected. Script cannot be executed properly')
else
    sprintf('Selected Data Source: %s', dataSourceArray{indexDataSource})
end


pathDefinition                      = eval(['pathDefinition', indexStudy]);
parametersParadigm                  = eval(['parametersParadigm', indexStudy, '_', indexMethod, '_', indexExperiment]);
parametersStructuralMriSequence     = eval(['parametersStructuralMriSequence', indexStudy]);
parametersTalairachTransformation   = eval(['parametersTalairachTransformation', indexStudy]);
parametersInhomogeneityCorrection   = eval(['parametersInhomogeneityCorrection', indexStudy]);
parametersCoregistration            = eval(['parametersCoregistration', indexStudy]);
parametersEpiDistortionCorrection   = eval(['parametersEpiDistortionCorrection', indexStudy]);
parametersSliceScanTimeCorrection   = eval(['parametersSliceScanTimeCorrection', indexStudy]);
parametersSpatialGaussianSmoothing  = eval(['parametersSpatialGaussianSmoothing', indexStudy]);
parametersMotionCorrection          = eval(['parametersMotionCorrection', indexStudy]);
parametersTemporalHighPassFilter    = eval(['parametersTemporalHighPassFilter', indexStudy]);
parametersVolumeTimeCourse          = eval(['parametersVolumeTimeCourse', indexStudy]);

%%% This needs to be reinstated
subjectArray = eval(['subjectArray', indexStudy]);
subjectArray = subjectArray.WMC2_MRI_EXP_1_GEN;

%subjectArray = subjectArray.WMC2_MRI_EXP_1;

%%% This array must be cancelled out for the full subject array to be
%%% processed
%{
subjectArray = {
    'EQKU788592662'
    'GUDE675880772'
    'GWDH788323782'
    'HYJF798340782'
    'JTPL756766894'
    'KUHM077727831'
    'RHPJ853767673'
    'RJAL478657781'
    'RKPD374788711'
    'ZDLA787786884'
    };
%}
%subjectArray = subjectArray.WMC2_MRI_EXP_1_new_coreg
%{
[iSelectedSubject, OK]  = listdlg('ListString', subjectArray);
if OK == 0
    sprintf('No subject selected. Script cannot be executed properly')
    return
else
    subjectArray = {subjectArray{iSelectedSubject}};
    sprintf('Selected subject: %s', subjectArray{iSelectedSubject})
end
%}

for s = 1:length(subjectArray)
    indexSubject = subjectArray{s};
    projectDataPath = [pathDefinition.singleSubjectData, indexExperiment, '\', indexSubject, '\'];

    for indexSession = 1:parametersParadigm.nSessions
        
        %%%  Loads FMRs, which have already been spatially smoothed
        fmrFileName = [projectDataPath, indexSubject '_' indexStudy, '_s', num2str(indexSession), '_', parametersEpiDistortionCorrection.strDistortionCorrection, '_', parametersSliceScanTimeCorrection.indexInterpolationMethod, '_', parametersMotionCorrection.indexInterpolationMethod, '_', parametersSpatialGaussianSmoothing.indexSpatialSmoothingParameters, '_', parametersTemporalHighPassFilter.indexFilteringParameters, '.fmr'];

        %%%  Loads FMRs, which have not been spatially smoothed. Should be
        %%%  used for MTC creation and CBA.
        %%%  !!! The code is not yet changed.
        %fmrFileName = [projectDataPath, indexSubject '_' indexStudy, '_s', num2str(indexSession), '_', parametersEpiDistortionCorrection.strDistortionCorrection, '_', parametersSliceScanTimeCorrection.indexInterpolationMethod, '_', parametersMotionCorrection.indexInterpolationMethod, '.fmr'];


        %fmrFileName = [projectDataPath, indexSubject, '_', indexStudy, '_' lower(parametersParadigm.indexSession), num2str(sessionIndex), '_', parametersEpiDistortionCorrection.strDistortionCorrection, '_', parametersSliceScanTimeCorrection.indexInterpolationMethod, '_', parametersMotionCorrection.indexInterpolationMethod, '_', parametersSpatialGaussianSmoothing.indexSpatialSmoothingMethod, parametersSpatialGaussianSmoothing.indexFwhm, parametersSpatialGaussianSmoothing.unit, '_', parametersTemporalHighPassFilter.indexLinearTrendRemoval, '_', parametersTemporalHighPassFilter.indexTemporalHighPass, parametersTemporalHighPassFilter.indexCutOffValue, parametersTemporalHighPassFilter.indexUnit '.fmr']

%%{
        %%% This loads the unpeeled brain, could be replaced by the peeled
        %%% brain
        vmrInTalFileName = [projectDataPath, indexSubject, '_', indexStudy, '_', parametersStructuralMriSequence.indexSequence, '_', parametersInhomogeneityCorrection.indexInhomogeneityCorrection, '_', parametersInhomogeneityCorrection.indexManualCorrection, '_', parametersInhomogeneityCorrection.indexIntensityNormalisation, '_', parametersTalairachTransformation.indexAutomaticTalTransformation, '.vmr'];
        intialAlignmentFileName = [projectDataPath, indexSubject, '_', indexStudy, '_' lower(parametersParadigm.indexSession), num2str(indexSession), '_', parametersEpiDistortionCorrection.strDistortionCorrection, '-TO-', indexSubject, '_', indexStudy, '_', parametersStructuralMriSequence.indexSequence, '_', parametersInhomogeneityCorrection.indexInhomogeneityCorrection, '_', parametersInhomogeneityCorrection.indexManualCorrection, '_', parametersInhomogeneityCorrection.indexIntensityNormalisation, '_', parametersCoregistration.indexInitialAlignment, '.trf'];
        fineAlignmentFileName = [projectDataPath, indexSubject, '_', indexStudy, '_' lower(parametersParadigm.indexSession), num2str(indexSession), '_', parametersEpiDistortionCorrection.strDistortionCorrection, '-TO-', indexSubject, '_', indexStudy, '_', parametersStructuralMriSequence.indexSequence, '_', parametersInhomogeneityCorrection.indexInhomogeneityCorrection, '_', parametersInhomogeneityCorrection.indexManualCorrection, '_', parametersInhomogeneityCorrection.indexIntensityNormalisation, '_', parametersCoregistration.indexFineAlignment, '.trf'];
        acpcFileName = [projectDataPath, indexSubject, '_', indexStudy, '_', parametersStructuralMriSequence.indexSequence, '_', parametersInhomogeneityCorrection.indexInhomogeneityCorrection, '_', parametersInhomogeneityCorrection.indexManualCorrection, '_', parametersInhomogeneityCorrection.indexIntensityNormalisation,'_' parametersTalairachTransformation.indexAutomaticAcpcTransformation, '.trf'];
        talFileName = [projectDataPath, indexSubject, '_', indexStudy, '_', parametersStructuralMriSequence.indexSequence, '_', parametersInhomogeneityCorrection.indexInhomogeneityCorrection, '_', parametersInhomogeneityCorrection.indexManualCorrection, '_', parametersInhomogeneityCorrection.indexIntensityNormalisation,'_' parametersTalairachTransformation.indexAutomaticAcpcTransformation, '.tal'];

        %%% There should be a function checking, whether all the files
        %%% necessary for VTC creation exist.
        filesForVTCcreation = {vmrInTalFileName, intialAlignmentFileName, fineAlignmentFileName, acpcFileName, talFileName};
        fileCounter = 0;
        for f = 1:length(filesForVTCcreation)
            if exist(filesForVTCcreation{f}, 'file') > 0
               fileCounter = fileCounter + 1;
            else
                message = sprintf('%s not found!', filesForVTCcreation{f});
                disp(message);
            end
        end
        
        if fileCounter <  length(filesForVTCcreation)
            message = sprintf('%s - SESSION %i incomplete. VTC files are not created!', indexSubject, indexSession);
            disp(message);
        else
            bvqx = actxserver('BrainVoyagerQX.BrainVoyagerQXScriptAccess.1');
            
            vtcFileName = [fmrFileName(1:length(fmrFileName)-4), '.vtc'];
    %%{
            %%% The files are opened in BrainVoyager and the VTCs are created.
            vmr = bvqx.OpenDocument(vmrInTalFileName);
            vmr.ExtendedTALSpaceForVTCCreation = parametersVolumeTimeCourse.extendedBoundingBox;
            vtc = vmr.CreateVTCInTALSpace(fmrFileName, intialAlignmentFileName, fineAlignmentFileName, acpcFileName, talFileName, vtcFileName, parametersVolumeTimeCourse.dataType, parametersVolumeTimeCourse.resolution, parametersVolumeTimeCourse.interpolationMethod, parametersVolumeTimeCourse.threshold);
            vmr.Close();
        %%}
            bvqx.Exit
            message = sprintf('%s created!', vtcFileName);
            disp(message);
        end
    end
end
%}
