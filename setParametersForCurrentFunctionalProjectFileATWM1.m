function [parametersProjectFiles] = setParametersForCurrentFunctionalProjectFileATWM1(parametersStudy, parametersParadigm, parametersFunctionalMriSequence, parametersMriSession, parametersProjectFiles, cr)

parametersProjectFiles.nrOfTotalRuns            = parametersParadigm.nTotalRuns;
parametersProjectFiles.nrOfDicomFilesForProject = parametersFunctionalMriSequence.nVolumes;
parametersProjectFiles.iDicomFileRun            = parametersMriSession.fileIndexCurrentFmr(cr);
parametersProjectFiles.iRunCurrentProject       = cr;

%%% Add parameters for FIRSTVOL
parametersProjectFiles.nrOfDicomFilesForProjectFirstVol = parametersFunctionalMriSequence.nVolumesFirstVol;

if parametersParadigm.nTotalRuns == 1
    parametersProjectFiles.strCurrentProject 	= sprintf('%s', parametersProjectFiles.strCurrentParadigm);
else
    parametersProjectFiles.strCurrentProject	= sprintf('%s_%s_%i', parametersProjectFiles.strCurrentParadigm, parametersStudy.strRun, cr);
end


end