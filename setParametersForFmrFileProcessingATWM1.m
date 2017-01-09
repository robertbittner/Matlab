function [parametersParadigm, parametersProjectFiles, parametersMriSession] = setParametersForFmrFileProcessingATWM1(parametersProjectFiles, parametersMriSession, cp)

%%% cp = counterParadigm

parametersParadigm                          = parametersProjectFiles.aParametersParadigm{cp};
parametersProjectFiles.strCurrentParadigm   = parametersProjectFiles.aStrParadigms{cp};
parametersMriSession.fileIndexCurrentFmr    = parametersProjectFiles.aFileIndicesFmr{cp};

%%% Determine number of runs for current paradigm
parametersProjectFiles.nrOfTotalRuns        = parametersParadigm.nTotalRuns;

%%% This paramater is only needed for the test configuration
parametersProjectFiles.bNrOfTotalRunsActuallyReducedDuringTestConfig = false;

end