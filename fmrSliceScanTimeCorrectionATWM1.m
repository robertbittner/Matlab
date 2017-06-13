function [parametersProjectFiles, bPreprocessingSuccessful] = fmrSliceScanTimeCorrectionATWM1(parametersProjectFiles, parametersFunctionalMriSequence, parametersProcessDuration, parametersSliceScanTimeCorrection)

global iStudy;

processDuration = parametersProcessDuration.fmrSliceScanTimeCorrection;

if exist(parametersProjectFiles.strPathCurrentFmrFileUndistort, 'file')
    %%% Check compatibility of the currently installed version of BrainVoyager
    %%% and run BrainVoyager as a COM object
    hFunction = str2func(sprintf('runBrainVoyagerQX%s', iStudy));
    %hFunction = str2func(sprintf('runBrainVoyager%s', iStudy));
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
        fprintf('Starting %s of fmr file %s\nusing interpolation method %s.\n', lower(parametersSliceScanTimeCorrection.strPreprocessingStep), parametersProjectFiles.strCurrentFmrFileUndistort, parametersSliceScanTimeCorrection.strInterpolationMethod);
        fmr = bvqx.OpenDocument(parametersProjectFiles.strPathCurrentFmrFileUndistort);
        bPreprocessingSuccessful = fmr.CorrectSliceTiming(parametersFunctionalMriSequence.scanOrder, parametersSliceScanTimeCorrection.interpolationMethod);
        parametersProjectFiles.strFileNameOfPreprocessedFmr = fmr.FileNameOfPreprocessdFMR;  %%% This variable may be overwritten by the next preprocessing function.
        fmr.Close();
        bvqx.Exit
        fprintf('%s for file %s successful!\n', parametersSliceScanTimeCorrection.strPreprocessingStep, parametersProjectFiles.strCurrentFmrFileUndistort);
        %%% Compare file names
        parametersProjectFiles.strCurrentPreprocessingStep = parametersSliceScanTimeCorrection.strPreprocessingStep;
        parametersProjectFiles.strPathCurrentFmrFileAfterPreprocessing = parametersProjectFiles.strPathCurrentFmrFileSliceScanTimeCorr;
        [parametersProjectFiles, bPreprocessingSuccessful] = processFileNameOfPreprocessedFmrATWM1(parametersProjectFiles, bPreprocessingSuccessful);
        fprintf('Saving file %s.\n', parametersProjectFiles.strFileNameOfPreprocessedFmr);
    catch
        fprintf('Error!\n%s for file %s failed!\n', parametersSliceScanTimeCorrection.strPreprocessingStep, parametersProjectFiles.strCurrentFmrFileUndistort);
        bPreprocessingSuccessful = false;
    end
    hFunction = str2func(sprintf('delayedTerminationOfMatlabCommandWindows%s', iStudy));
    feval(hFunction, matlabCommandWindowProcessId, processDuration);
else
    fprintf('Error!\nfmr file %s not found!\n', parametersProjectFiles.strPathCurrentFmrFileUndistort);
    bPreprocessingSuccessful = false;
end


end