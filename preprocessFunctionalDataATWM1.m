function preprocessFunctionalDataATWM1()

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

[bAbort] = selectConfigurationForProjectFileProcessingATWM1();
if bAbort
    return
end

%parametersProjectFiles.bDeleteUnnecessaryFiles = true;
parametersProjectFiles.bFileCreation = false;
%%% Set parameter for processing of full functional runs
parametersProjectFiles.bFunctionalRun = true;

%%% Set parameters for preprocessing steps
parametersProjectFiles = selectFmrPreprocessingOptionsAllATWM1(parametersProjectFiles);
% For MTCs
%parametersProjectFiles = selectFmrPreprocessingOptionsForCbaATWM1(parametersProjectFiles)

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
    if parametersMriSession.bAllRunsAcquired
        nrOfSessions = 1;
    else
        %%% EXPAND
        nrOfSessions = 2;
    end
    
    structProjectDataSubFolders = defineProjectDataSubFoldersATWM1(folderDefinition.strCurrentSubjectDataFolder);
    
    [parametersProjectFiles] = prepareParametersForFmrFileProcessingATWM1(parametersStudy, parametersMriSession, parametersProjectFiles);
    if bTestConfiguration
        parametersProjectFiles.nrOfFunctionalMriProjects = 2;
    end
    
    runFmrPreprocessingATWM1(folderDefinition, parametersStudy, parametersProjectFiles, parametersMriSession, structProjectDataSubFolders)
    
end


end


function runFmrPreprocessingATWM1(folderDefinition, parametersStudy, parametersProjectFiles, parametersMriSession, structProjectDataSubFolders)

global iStudy

global bTestConfiguration

parametersProcessDuration           = eval(['parametersProcessDuration', iStudy]);
parametersEpiDistortionCorrection   = eval(['parametersEpiDistortionCorrection', iStudy]);
parametersSliceScanTimeCorrection   = eval(['parametersSliceScanTimeCorrection', iStudy]);
parametersMotionCorrection          = eval(['parametersMotionCorrection', iStudy]);
parametersSpatialGaussianSmoothing  = eval(['parametersSpatialGaussianSmoothing', iStudy]);
parametersTemporalHighPassFiltering = eval(['parametersTemporalHighPassFiltering', iStudy]);

for cp = 1:parametersProjectFiles.nrOfFunctionalMriProjects
    [parametersParadigm, parametersProjectFiles, parametersMriSession] = setParametersForFmrFileProcessingATWM1(parametersProjectFiles, parametersMriSession, cp);
    if bTestConfiguration
        [parametersProjectFiles] = setNumberOfFunctionalRunsForTestConfigurationATWM1(parametersProjectFiles, parametersParadigm);
    end
    for cr = 1:parametersProjectFiles.nrOfTotalRuns
        parametersFunctionalMriSequence             = parametersProjectFiles.aParametersFunctionalMriSequence{cp};
        [parametersProjectFiles] = setParametersForCurrentFunctionalProjectFileATWM1(parametersStudy, parametersParadigm, parametersFunctionalMriSequence, parametersMriSession, parametersProjectFiles, cr);
        %%% Determine subfolder for current project file
        [folderDefinition, parametersProjectFiles] = determineCurrentProjectDataSubfolderATWM1(folderDefinition, parametersProjectFiles, structProjectDataSubFolders);
        [parametersProjectFiles] = definePreprocessedFmrFileNamesATWM1(folderDefinition, parametersStudy, parametersProjectFiles, parametersEpiDistortionCorrection, parametersSliceScanTimeCorrection, parametersMotionCorrection, parametersSpatialGaussianSmoothing, parametersTemporalHighPassFiltering);
        %%% Slice scan time correction
        if parametersProjectFiles.bApplySliceScanTimeCorrection
            hFunction = str2func(sprintf('fmrSliceScanTimeCorrection%s', iStudy));
            [parametersProjectFiles, bPreprocessingSuccessful] = feval(hFunction, parametersProjectFiles, parametersFunctionalMriSequence, parametersProcessDuration, parametersSliceScanTimeCorrection);
        end
        %%% 3D motion correction
        if parametersProjectFiles.bApplyMotionCorrection && bPreprocessingSuccessful
            hFunction = str2func(sprintf('fmrMotionCorrection%s', iStudy));
            [parametersProjectFiles, bPreprocessingSuccessful] = feval(hFunction, parametersProjectFiles, parametersProcessDuration, parametersMotionCorrection);
        end
        %%% 3D spatial gaussian smoothing
        if parametersProjectFiles.bApplySpatialGaussianSmoothing && bPreprocessingSuccessful
            hFunction = str2func(sprintf('fmrSpatialGaussianSmoothing%s', iStudy));
            [parametersProjectFiles, bPreprocessingSuccessful] = feval(hFunction, parametersProjectFiles, parametersProcessDuration, parametersSpatialGaussianSmoothing);
        end
        %%% Temporal high pass filtering
        if parametersProjectFiles.bApplyTemporalHighPassFilter && bPreprocessingSuccessful
            hFunction = str2func(sprintf('fmrApplyTemporalHighPassFilter%s', iStudy));
            [parametersProjectFiles, bPreprocessingSuccessful] = feval(hFunction, parametersProjectFiles, parametersProcessDuration, parametersTemporalHighPassFiltering);
        end
        %%% Creation of motion plots
        if parametersProjectFiles.bCreateMotionPlot && bPreprocessingSuccessful
            hFunction = str2func(sprintf('plotFmrMotionEstimates%s', iStudy));
            [bPlotCreationSuccessful] = feval(hFunction, folderDefinition, parametersProjectFiles, parametersFunctionalMriSequence, parametersMotionCorrection, cr);
        end
        if bTestConfiguration
            fprintf('Test configuration! Aborting preprocessing\n')
            return
        end
    end
end


end


function parametersProjectFiles = selectFmrPreprocessingOptionsForCbaATWM1(parametersProjectFiles)

parametersProjectFiles.bApplySliceScanTimeCorrection    = true;
parametersProjectFiles.bApplyMotionCorrection           = true;
parametersProjectFiles.bApplySpatialGaussianSmoothing   = false;
parametersProjectFiles.bApplyTemporalHighPassFilter     = false;
parametersProjectFiles.bCreateMotionPlot                = true;


end