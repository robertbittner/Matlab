function [parametersProjectFiles] = definePreprocessedFmrFileNamesATWM1(folderDefinition, parametersStudy, parametersProjectFiles, parametersEpiDistortionCorrection, parametersSliceScanTimeCorrection, parametersMotionCorrection, parametersSpatialGaussianSmoothing, parametersTemporalHighPassFiltering)

global iStudy

hFunction = str2func(sprintf('determineFmrFileName%s', iStudy));
[aStrFmrFile, aStrPathFmrFile] = feval(hFunction, folderDefinition, parametersStudy, parametersProjectFiles, parametersEpiDistortionCorrection);

%%% Original files
parametersProjectFiles.strCurrentFmrFileOriginal        = aStrFmrFile{1}; % index 1 = full run; index 2 = firstvol
parametersProjectFiles.strPathCurrentFmrFileOriginal    = aStrPathFmrFile{1}; % index 1 = full run; index 2 = firstvol

%%% EPI distortion correction
strExtFmrFileUndistort                                  = sprintf('_%s%s', parametersEpiDistortionCorrection.strDistortionCorrection, parametersProjectFiles.extFunctionalProject);
parametersProjectFiles.strCurrentFmrFileUndistort       = strrep(parametersProjectFiles.strCurrentFmrFileOriginal, parametersProjectFiles.extFunctionalProject, strExtFmrFileUndistort);
parametersProjectFiles.strPathCurrentFmrFileUndistort   = strrep(parametersProjectFiles.strPathCurrentFmrFileOriginal, parametersProjectFiles.extFunctionalProject, strExtFmrFileUndistort);

%%% Slice scan time correction
strExtFmrFileSliceScanTimeCorr                                  = sprintf('_%s%s', parametersSliceScanTimeCorrection.strAbbrInterpolationMethod, parametersProjectFiles.extFunctionalProject);
parametersProjectFiles.strCurrentFmrFileSliceScanTimeCorr       = strrep(parametersProjectFiles.strCurrentFmrFileUndistort, parametersProjectFiles.extFunctionalProject, strExtFmrFileSliceScanTimeCorr);
parametersProjectFiles.strPathCurrentFmrFileSliceScanTimeCorr   = strrep(parametersProjectFiles.strPathCurrentFmrFileUndistort, parametersProjectFiles.extFunctionalProject, strExtFmrFileSliceScanTimeCorr);

%%% 3D motion correction
strExtFmrFileMotionCorr                                 = sprintf('_%s%s', parametersMotionCorrection.strAbbrInterpolationMethod, parametersProjectFiles.extFunctionalProject);
parametersProjectFiles.strCurrentFmrFileMotionCorr      = strrep(parametersProjectFiles.strCurrentFmrFileSliceScanTimeCorr, parametersProjectFiles.extFunctionalProject, strExtFmrFileMotionCorr);
parametersProjectFiles.strPathCurrentFmrFileMotionCorr  = strrep(parametersProjectFiles.strPathCurrentFmrFileSliceScanTimeCorr, parametersProjectFiles.extFunctionalProject, strExtFmrFileMotionCorr);

%%% 3D spatial gaussian smoothing
strExtFmrFileSpatialSmoothing                                   = sprintf('_%s%s', parametersSpatialGaussianSmoothing.strSpatialSmoothingParameters, parametersProjectFiles.extFunctionalProject);
parametersProjectFiles.strCurrentFmrFileSpatialSmoothing        = strrep(parametersProjectFiles.strCurrentFmrFileMotionCorr, parametersProjectFiles.extFunctionalProject, strExtFmrFileSpatialSmoothing);
parametersProjectFiles.strPathCurrentFmrFileSpatialSmoothing    = strrep(parametersProjectFiles.strPathCurrentFmrFileMotionCorr, parametersProjectFiles.extFunctionalProject, strExtFmrFileSpatialSmoothing);

%%% Temporal high pass filtering
strExtFmrFileTemporalHighPassFiltering                                  = sprintf('_%s%s', parametersTemporalHighPassFiltering.strFilteringParameters, parametersProjectFiles.extFunctionalProject);
parametersProjectFiles.strCurrentFmrFileTemporalHighPassFiltering       = strrep(parametersProjectFiles.strCurrentFmrFileSpatialSmoothing, parametersProjectFiles.extFunctionalProject, strExtFmrFileTemporalHighPassFiltering);
parametersProjectFiles.strPathCurrentFmrFileTemporalHighPassFiltering   = strrep(parametersProjectFiles.strPathCurrentFmrFileSpatialSmoothing, parametersProjectFiles.extFunctionalProject, strExtFmrFileTemporalHighPassFiltering);

%%% Temporal high pass filtering without spatial smoothing
parametersProjectFiles.strCurrentFmrFileTemporalHighPassFilteringNoSpatialSmooth        = strrep(parametersProjectFiles.strCurrentFmrFileMotionCorr, parametersProjectFiles.extFunctionalProject, strExtFmrFileTemporalHighPassFiltering);
parametersProjectFiles.strPathCurrentFmrFileTemporalHighPassFilteringNoSpatialSmooth    = strrep(parametersProjectFiles.strPathCurrentFmrFileMotionCorr, parametersProjectFiles.extFunctionalProject, strExtFmrFileTemporalHighPassFiltering);

%%% Change file names, if no spatial smoothing is applied
if ~parametersProjectFiles.bApplySpatialGaussianSmoothing && parametersProjectFiles.bApplyTemporalHighPassFilter
    parametersProjectFiles.strCurrentFmrFileSpatialSmoothing                = parametersProjectFiles.strCurrentFmrFileMotionCorr;
    parametersProjectFiles.strPathCurrentFmrFileSpatialSmoothing            = parametersProjectFiles.strPathCurrentFmrFileMotionCorr;
    parametersProjectFiles.strCurrentFmrFileTemporalHighPassFiltering       = parametersProjectFiles.strCurrentFmrFileTemporalHighPassFilteringNoSpatialSmooth;
    parametersProjectFiles.strPathCurrentFmrFileTemporalHighPassFiltering   = parametersProjectFiles.strPathCurrentFmrFileTemporalHighPassFilteringNoSpatialSmooth;
end

%%% Detect field names related to FMR files
indFmrFiles = ~cellfun(@isempty, strfind(fieldnames(parametersProjectFiles), 'FmrFile'));
aStrFmrFileFieldnames = fieldnames(parametersProjectFiles);
parametersProjectFiles.aStrFmrFileFieldnames = aStrFmrFileFieldnames(indFmrFiles);

end