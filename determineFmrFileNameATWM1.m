function [aStrFmrFile, aStrPathFmrFile] = determineFmrFileNameATWM1(folderDefinition, parametersStudy, parametersProjectFiles, parametersEpiDistortionCorrection)
%%% Determine the name and path of the project file

global iStudy
global strSubject
global bTestConfiguration

try
if parametersProjectFiles.nrOfTotalRuns == 1
    if parametersProjectFiles.bFunctionalRun
        strFmrFileFullRun   = sprintf('%s_%s_%s.fmr', strSubject, iStudy, parametersProjectFiles.strCurrentParadigm);
    else
        strFmrFileFullRun   = sprintf('%s_%s_%s_%s_%s.fmr', strSubject, iStudy, parametersProjectFiles.strCurrentParadigm, parametersEpiDistortionCorrection.strMethod, parametersEpiDistortionCorrection.strPhaseEncodingDirection);
    end
elseif parametersProjectFiles.nrOfTotalRuns == 1 && parametersProjectFiles.bNrOfTotalRunsActuallyReducedDuringTestConfig
    if parametersProjectFiles.bFunctionalRun
        strFmrFileFullRun   = sprintf('%s_%s_%s_%s%i.fmr', strSubject, iStudy, parametersProjectFiles.strCurrentParadigm, parametersStudy.strRun, parametersProjectFiles.iRunCurrentProject);
    else
        strFmrFileFullRun   = sprintf('%s_%s_%s_%s_%s_%s%i.fmr', strSubject, iStudy, parametersProjectFiles.strCurrentParadigm, parametersEpiDistortionCorrection.strMethod, parametersEpiDistortionCorrection.strPhaseEncodingDirection, parametersStudy.strRun, parametersProjectFiles.iRunCurrentProject);
    end
else
    if parametersProjectFiles.bFunctionalRun
        strFmrFileFullRun   = sprintf('%s_%s_%s_%s%i.fmr', strSubject, iStudy, parametersProjectFiles.strCurrentParadigm, parametersStudy.strRun, parametersProjectFiles.iRunCurrentProject);
    else
        strFmrFileFullRun   = sprintf('%s_%s_%s_%s_%s_%s%i.fmr', strSubject, iStudy, parametersProjectFiles.strCurrentParadigm, parametersEpiDistortionCorrection.strMethod, parametersEpiDistortionCorrection.strPhaseEncodingDirection, parametersStudy.strRun, parametersProjectFiles.iRunCurrentProject);
    end
end
strPathFmrFileFullRun       = fullfile(folderDefinition.strCurrentProjectDataSubFolder, strFmrFileFullRun);

strFmrFileFirstVol          = strrep(strFmrFileFullRun, parametersProjectFiles.extFunctionalProject, ['_', parametersProjectFiles.strFirstVolume, parametersProjectFiles.extFunctionalProject]);
strPathFmrFileFirstVol      = fullfile(folderDefinition.strCurrentProjectDataSubFolder, strFmrFileFirstVol);

aStrFmrFile     = {
    strFmrFileFullRun
    strFmrFileFirstVol
    };
aStrPathFmrFile = {
    strPathFmrFileFullRun
    strPathFmrFileFirstVol
    };
catch    
    aStrFmrFile     = {sprintf('%s_%s_%s.fmr', parametersStudy.strSubjectId, iStudy, parametersStudy.strParadigm)};
    aStrPathFmrFile = {sprintf('%s\\%s', parametersStudy.strPath, aStrFmrFile{1})};
end

end