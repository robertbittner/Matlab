function [parametersProjectFiles, bPreprocessingSuccessful] = fmrApplyTemporalHighPassFilterATWM1(parametersProjectFiles, parametersProcessDuration, parametersTemporalHighPassFiltering)

global iStudy;

processDuration = parametersProcessDuration.fmrTemporalHighPassFiltering;

if exist(parametersProjectFiles.strPathCurrentFmrFileSpatialSmoothing, 'file')
    %%% Check compatibility of the currently installed version of BrainVoyager
    %%% and run BrainVoyager as a COM object
    hFunction = str2func(sprintf('runBrainVoyager%s', iStudy));
    [bvqx, parametersComProcess, bIncompatibleBrainVoyagerVersion] = feval(hFunction);
    if bIncompatibleBrainVoyagerVersion == true
        bPreprocessingSuccessful = false;
        return
    end
    
    %%% Open additional Matlab command window to terminate crashed BrainVoyager
    %%% COM objects
    hFunction = str2func(sprintf('initiateDelayedTerminationOfBrainVoyagerComProcesses%s', iStudy));
    matlabCommandWindowProcessId = feval(hFunction, parametersComProcess, processDuration);
    try
        fprintf('Starting %s of fmr file %s\nwith %s.\n', lower(parametersTemporalHighPassFiltering.strPreprocessingStep), parametersProjectFiles.strCurrentFmrFileSpatialSmoothing, 'Put in parameters!!!');
        fmr = bvqx.OpenDocument(parametersProjectFiles.strPathCurrentFmrFileSpatialSmoothing);
        bPreprocessingSuccessful = fmr.TemporalHighPassFilterGLMFourier(parametersTemporalHighPassFiltering.cutOffValue);
        parametersProjectFiles.strFileNameOfPreprocessedFmr = fmr.FileNameOfPreprocessdFMR;
        fmr.Close();
        bvqx.Exit;
        fprintf('%s for file %s successful!\n', parametersTemporalHighPassFiltering.strPreprocessingStep, parametersProjectFiles.strCurrentFmrFileSpatialSmoothing);        
        %%% Compare file names
        parametersProjectFiles.strCurrentPreprocessingStep = parametersTemporalHighPassFiltering.strPreprocessingStep;
        parametersProjectFiles.strPathCurrentFmrFileAfterPreprocessing = parametersProjectFiles.strPathCurrentFmrFileTemporalHighPassFiltering;
        [parametersProjectFiles, bPreprocessingSuccessful] = processFileNameOfPreprocessedFmrATWM1(parametersProjectFiles, bPreprocessingSuccessful);
        fprintf('Saving file %s.\n', parametersProjectFiles.strFileNameOfPreprocessedFmr);
        %}
    catch
        fprintf('Error!\n%s for file %s failed!\n', parametersTemporalHighPassFiltering.strPreprocessingStep, parametersProjectFiles.strCurrentFmrFileSpatialSmoothing);
        bPreprocessingSuccessful = false;
    end
    hFunction = str2func(sprintf('delayedTerminationOfMatlabCommandWindows%s', iStudy));
    feval(hFunction, matlabCommandWindowProcessId, processDuration);
else
    fprintf('Error!\nfmr file %s not found!\n', parametersProjectFiles.strPathCurrentFmrFileSpatialSmoothing);
    bPreprocessingSuccessful = false;
end


end


function oldfmrApplyTemporalHighPassFilterWithGlmATWM1()

global indexStudy;
global indexMethod;
global indexExperiment;
global indexSubject;
global fileNameOfPreprocessedFmrArray;

bvqx = actxserver('BrainVoyagerQX.BrainVoyagerQXScriptAccess.1');

pathDefinition                      = eval(['pathDefinition', indexStudy]);
parametersParadigm                  = eval(['parametersParadigm',indexStudy, '_', indexMethod, '_' indexExperiment]);
parametersSliceScanTimeCorrection   = eval(['parametersSliceScanTimeCorrection', indexStudy]);
parametersMotionCorrection          = eval(['parametersMotionCorrection', indexStudy]);
parametersSpatialGaussianSmoothing  = eval(['parametersSpatialGaussianSmoothing', indexStudy]);
parametersTemporalHighPassFilter    = eval(['parametersTemporalHighPassFilter', indexStudy]);
parametersEpiDistortionCorrection   = eval(['parametersEpiDistortionCorrection',indexStudy]);

projectDataPath = [pathDefinition.singleSubjectData, indexExperiment, '\', indexSubject, '\'];

if isempty(fileNameOfPreprocessedFmrArray)
    bDefineFileNames = true;
else
    bDefineFileNames = false;
end

for indexSession = 1:parametersParadigm.nSessions
    if bDefineFileNames == true && parametersEpiDistortionCorrection.bUseDistortionCorrecteFmrFiles == true
        fmrFileName = [indexSubject, '_', indexStudy, '_s', num2str(indexSession), '_', parametersEpiDistortionCorrection.strDistortionCorrection, '_', parametersSliceScanTimeCorrection.indexInterpolationMethod, '_', parametersMotionCorrection.indexInterpolationMethod, '_', parametersSpatialGaussianSmoothing.indexSpatialSmoothingParameters, '.fmr'];
        fileNameOfPreprocessedFmrArray{indexSession} = strcat(projectDataPath, fmrFileName);
    elseif bDefineFileNames == true
        fmrFileName = [indexSubject, '_', indexStudy, '_s', num2str(indexSession), '_', parametersSliceScanTimeCorrection.indexInterpolationMethod, '_', parametersMotionCorrection.indexInterpolationMethod, '_', parametersSpatialGaussianSmoothing.indexSpatialSmoothingParameters, '.fmr'];
        fileNameOfPreprocessedFmrArray{indexSession} = strcat(projectDataPath, fmrFileName);
    end
    %fileNameOfPreprocessedFmrArray{indexSession} = [projectDataPath, indexSubject '_' indexStudy, '_s', num2str(indexSession), '_', parametersSliceScanTimeCorrection.indexInterpolationMethod, '_', parametersMotionCorrection.indexInterpolationMethod, '_', parametersSpatialGaussianSmoothing.indexSpatialSmoothingParameters, '.fmr'];
    fmr = bvqx.OpenDocument(fileNameOfPreprocessedFmrArray{indexSession});
    temporalHighPassFilter = fmr.TemporalHighPassFilterGLMFourier(parametersTemporalHighPassFilter.cutOffValue);
    fileNameOfPreprocessedFmrArray{indexSession} = fmr.FileNameOfPreprocessdFMR;
    fmr.Close();
end
bvqx.Exit;


end