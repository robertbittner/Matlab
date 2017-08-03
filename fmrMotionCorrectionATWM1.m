function [parametersProjectFiles, bPreprocessingSuccessful] = fmrMotionCorrectionATWM1(parametersProjectFiles, parametersProcessDuration, parametersMotionCorrection)

global iStudy;

processDuration = parametersProcessDuration.fmrMotionCorrection;

if exist(parametersProjectFiles.strPathCurrentFmrFileSliceScanTimeCorr, 'file')
    %%% Check compatibility of the currently installed version of BrainVoyager
    %%% and run BrainVoyager as a COM object
    hFunction = str2func(sprintf('runBrainVoyagerQX%s', iStudy));
    %hFunction = str2func(sprintf('runBrainVoyager%s', iStudy));
    [bvqx, parametersComProcess, parametersBrainVoyager, bIncompatibleBrainVoyagerVersion] = feval(hFunction);
    if bIncompatibleBrainVoyagerVersion == true
        bPreprocessingSuccessful = false;
        return
    end
    
    %%% Open additional Matlab command window to terminate crashed BrainVoyager
    %%% COM objects
    hFunction = str2func(sprintf('initiateDelayedTerminationOfBrainVoyagerComProcesses%s', iStudy));
    matlabCommandWindowProcessId = feval(hFunction, parametersComProcess, processDuration);
    try
        fprintf('Starting %s of fmr file %s\nusing interpolation method %s.\n', lower(parametersMotionCorrection.strPreprocessingStep), parametersProjectFiles.strCurrentFmrFileSliceScanTimeCorr, parametersMotionCorrection.strInterpolationMethod);
        fmr = bvqx.OpenDocument(parametersProjectFiles.strPathCurrentFmrFileSliceScanTimeCorr);
        bPreprocessingSuccessful = fmr.CorrectMotionEx(parametersMotionCorrection.targetVolume, parametersMotionCorrection.interpolationMethod, parametersMotionCorrection.reduceDataSet, parametersMotionCorrection.maxNumberOfIterations, parametersMotionCorrection.generateMovies, parametersMotionCorrection.generatExtendedLogFile);
        parametersProjectFiles.strFileNameOfPreprocessedFmr = fmr.FileNameOfPreprocessdFMR;  %%% This variable may be overwritten by the next preprocessing function.
        fmr.Close();
        bvqx.Exit
        fprintf('%s for file %s successful!\n', parametersMotionCorrection.strPreprocessingStep, parametersProjectFiles.strCurrentFmrFileSliceScanTimeCorr);
        %%% Compare file names
        parametersProjectFiles.strCurrentPreprocessingStep = parametersMotionCorrection.strPreprocessingStep;
        parametersProjectFiles.strPathCurrentFmrFileAfterPreprocessing = parametersProjectFiles.strPathCurrentFmrFileMotionCorr;
        [parametersProjectFiles, bPreprocessingSuccessful] = processFileNameOfPreprocessedFmrATWM1(parametersProjectFiles, bPreprocessingSuccessful);
        fprintf('Saving file %s.\n', parametersProjectFiles.strFileNameOfPreprocessedFmr);
    catch
        fprintf('Error!\n%s for file %s failed!\n', parametersMotionCorrection.strPreprocessingStep, parametersProjectFiles.strCurrentFmrFileSliceScanTimeCorr);
        bPreprocessingSuccessful = false;
    end
    hFunction = str2func(sprintf('delayedTerminationOfMatlabCommandWindows%s', iStudy));
    feval(hFunction, matlabCommandWindowProcessId, processDuration);
else
    fprintf('Error!\nfmr file %s not found!\n', parametersProjectFiles.strPathCurrentFmrFileSliceScanTimeCorr);
    bPreprocessingSuccessful = false;
end


end