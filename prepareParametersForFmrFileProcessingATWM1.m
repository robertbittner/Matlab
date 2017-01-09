function [parametersProjectFiles] = prepareParametersForFmrFileProcessingATWM1(parametersStudy, parametersMriSession, parametersProjectFiles)

global iStudy

%%% Define arrays containing the parameters of the different functional MRI
%%% projects of the study
parametersParadigm_WM_MRI           = eval(['parametersParadigm_WM_MRI_', iStudy]);
parametersParadigm_LOC_MRI          = eval(['parametersParadigm_LOC_MRI_', iStudy]);

parametersFunctionalMriSequence_WM  = eval(['parametersFunctionalMriSequence_WM_', iStudy]);
parametersFunctionalMriSequence_LOC = eval(['parametersFunctionalMriSequence_LOC_', iStudy]);

parametersProjectFiles.aParametersFunctionalMriSequence = {
    parametersFunctionalMriSequence_WM
    parametersFunctionalMriSequence_LOC
    };
parametersProjectFiles.aParametersParadigm = {
    parametersParadigm_WM_MRI
    parametersParadigm_LOC_MRI
    };
parametersProjectFiles.aFileIndicesFmr = {
    parametersMriSession.fileIndexFmr_WM
    parametersMriSession.fileIndexFmr_LOC
    };
parametersProjectFiles.aStrParadigms = {
    parametersStudy.strWorkingMemoryTask
    parametersStudy.strLocalizer
    };
parametersProjectFiles.nrOfFunctionalMriProjects = numel(parametersProjectFiles.aParametersFunctionalMriSequence);


end
