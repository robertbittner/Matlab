function [parametersProjectFiles] = setNumberOfFunctionalRunsForTestConfigurationATWM1(parametersProjectFiles, parametersParadigm)
%%% Reduce number of functional runs for testing purposes

parametersProjectFiles.nrOfTotalRuns = parametersProjectFiles.nrOfTotalFunctionalRunsTestConfig;
fprintf('\n\nWarning!!!\nNumber of functional runs reduced to %i for testing purposes!\n\n', parametersProjectFiles.nrOfTotalRuns);

if parametersParadigm.nTotalRuns > parametersProjectFiles.nrOfTotalRuns
    parametersProjectFiles.bNrOfTotalRunsActuallyReducedDuringTestConfig = true;
end


end