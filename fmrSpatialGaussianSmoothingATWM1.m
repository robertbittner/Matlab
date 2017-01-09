function [parametersProjectFiles, bPreprocessingSuccessful] = fmrSpatialGaussianSmoothingATWM1(parametersProjectFiles, parametersProcessDuration, parametersSpatialGaussianSmoothing)

global iStudy;

processDuration = parametersProcessDuration.fmrSpatialSmoothing;

if exist(parametersProjectFiles.strPathCurrentFmrFileMotionCorr, 'file')
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
        fprintf('Starting %s of fmr file %s\nwith a smoothing kernel of %s fwhm.\n', lower(parametersSpatialGaussianSmoothing.strPreprocessingStep), parametersProjectFiles.strCurrentFmrFileMotionCorr, parametersSpatialGaussianSmoothing.strSmoothingKernel);
        fmr = bvqx.OpenDocument(parametersProjectFiles.strPathCurrentFmrFileMotionCorr);
        bPreprocessingSuccessful = fmr.SpatialGaussianSmoothing(parametersSpatialGaussianSmoothing.fwhm, parametersSpatialGaussianSmoothing.strUnit);
        parametersProjectFiles.strFileNameOfPreprocessedFmr = fmr.FileNameOfPreprocessdFMR;
        fmr.Close();
        bvqx.Exit;
        fprintf('%s for file %s successful!\n', parametersSpatialGaussianSmoothing.strPreprocessingStep, parametersProjectFiles.strCurrentFmrFileMotionCorr);
        %%% Compare file names
        parametersProjectFiles.strCurrentPreprocessingStep = parametersSpatialGaussianSmoothing.strPreprocessingStep;
        parametersProjectFiles.strPathCurrentFmrFileAfterPreprocessing = parametersProjectFiles.strPathCurrentFmrFileSpatialSmoothing;
        [parametersProjectFiles, bPreprocessingSuccessful] = processFileNameOfPreprocessedFmrATWM1(parametersProjectFiles, bPreprocessingSuccessful);
        fprintf('Saving file %s.\n', parametersProjectFiles.strFileNameOfPreprocessedFmr);
    catch
        fprintf('Error!\n%s for file %s failed!\n', parametersSpatialGaussianSmoothing.strPreprocessingStep, parametersProjectFiles.strCurrentFmrFileSliceScanTimeCorr);
        bPreprocessingSuccessful = false;
    end
    hFunction = str2func(sprintf('delayedTerminationOfMatlabCommandWindows%s', iStudy));
    feval(hFunction, matlabCommandWindowProcessId, processDuration);
else
    fprintf('Error!\nfmr file %s not found!\n', parametersProjectFiles.strPathCurrentFmrFileSliceScanTimeCorr);
    bPreprocessingSuccessful = false;
end


end