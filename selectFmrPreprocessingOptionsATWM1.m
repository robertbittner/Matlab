function parametersProjectFiles = selectFmrPreprocessingOptionsATWM1(parametersProjectFiles)

parametersProjectFiles.bApplySliceScanTimeCorrection    = true;
parametersProjectFiles.bApplyMotionCorrection           = true;
parametersProjectFiles.bApplySpatialGaussianSmoothing   = true;
parametersProjectFiles.bApplyTemporalHighPassFilter     = true;
parametersProjectFiles.bCreateMotionPlot                = true;


end