function createSdmFilesATWM1(parametersStimulationProtocol, pathVmrInTalFile, pathVtcFile, pathPrtFile, pathSdmFile, bOverwriteExistingFiles);
%%% © 2015 Robert Bittner
%%% Written for BrainVoyagerQX 2.8.4
%%% This function creates a sdm file
%%%
%%% Missing functionalities: 
%%% - Add confound predictors
%%% - Apply high-pass filter


%pathSdmFile = sprintf('%s', strrep(pathPrtFile, 'prt', 'sdm'));

%test = strFolderSdmFiles
pathSdmFile  = pathSdmFile
if bOverwriteExistingFiles == false
    if exist(pathSdmFile, 'file')
        return
    end
end

%%{
%%% Read protocol parameters
prt = xff(pathPrtFile);
structConditions = prt.Cond;
%}
bvqx = actxserver('BrainVoyagerQX.BrainVoyagerQXScriptAccess.1');

doc = bvqx.OpenDocument(pathVmrInTalFile);
doc.LinkVTC(pathVtcFile);
doc.LinkStimulationProtocol(pathPrtFile);
bvqx.PrintToLog(sprintf('Linking stimulation protocol %s', pathPrtFile));
doc.ClearDesignMatrix;
doc.StimulationProtocolResolution = parametersStimulationProtocol.iResolution;

for cc = 1:prt.NrOfConditions
    strCondition = structConditions(cc).ConditionName{1};
    
    doc.AddPredictor(strCondition);
    doc.SetPredictorValuesFromCondition(strCondition, strCondition, 1.0);
    doc.ApplyHemodynamicResponseFunctionToPredictor(strCondition);
    
end

doc.SDMContainsConstantPredictor = 0;
doc.SaveSingleStudyGLMDesignMatrix(pathSdmFile);
doc.Close();

bvqx.Exit;
prt.ClearObject;

end


















%{
%%% Define the study
global indexStudy;
global indexMethod;
global indexExperiment;
global indexSubject;
global indexDataSource
global fileNameOfPreprocessedFmrArray;

indexStudy = 'WMC2';
experimentNo = 1;
parametersStudy = eval(['parametersStudy', indexStudy]);

indexMethod = parametersStudy.indexMRI;
indexExperiment = [parametersStudy.indexExperiment, num2str(experimentNo)];

indexCorrectTrials = 'corr_trials';

strCorrect      = 'correct';
strIncorrect    = 'incorrect';
aStrAccuracy = {
    strCorrect
    strIncorrect
    };
nResponseTypes = length(aStrAccuracy);

%sprintf('reactivate BV at the top of the script')

%%% This part loads the path definitions, parameters and subject names of
%%% the paradigm by calling different files as a function
pathDefinition                      = eval(['pathDefinition', indexStudy]);
parametersParadigm                  = eval(['parametersParadigm', indexStudy, '_', indexMethod, '_', indexExperiment]);
parametersStructuralMriSequence     = eval(['parametersStructuralMriSequence', indexStudy]);
parametersTalairachTransformation   = eval(['parametersTalairachTransformation', indexStudy]);
parametersInhomogeneityCorrection   = eval(['parametersInhomogeneityCorrection', indexStudy]);
%parametersCoregistration            = eval(['parametersCoregistration', indexStudy]);
%parametersFunctionalMriSequence     = eval(['parametersFunctionalMriSequence', indexStudy]);
parametersEpiDistortionCorrection   = eval(['parametersEpiDistortionCorrection', indexStudy]);
parametersSliceScanTimeCorrection   = eval(['parametersSliceScanTimeCorrection', indexStudy]);
parametersSpatialGaussianSmoothing  = eval(['parametersSpatialGaussianSmoothing', indexStudy]);
parametersMotionCorrection          = eval(['parametersMotionCorrection', indexStudy]);
parametersTemporalHighPassFilter    = eval(['parametersTemporalHighPassFilter', indexStudy]);
%parametersVolumeTimeCourse          = eval(['parametersVolumeTimeCourse', indexStudy]);
parametersStimulationProtocol       = eval(['parametersStimulationProtocol', indexStudy]);

subjectArray = eval(['subjectArray', indexStudy]);
subjectArray = subjectArray.WMC2_MRI_EXP_1_GEN;

%%% This needs to be removed for analysis of the whole dataset.
%subjectArray = subjectArray.WMC2_MRI_EXP_1_subsample;

%{
subjectArray = {
    'CZQH786657554'
    };
%}


%designMatrixSuffix = sprintf('%i%i%i%i', parametersStimulationProtocol.nVolumesTaskPhase(1), parametersStimulationProtocol.nVolumesTaskPhase(2), parametersStimulationProtocol.nVolumesTaskPhase(3), parametersStimulationProtocol.nVolumesTaskPhase(4));


%%% Design Matrix name in case of 3 delay predictors
%designMatrixLabelArray = parametersStimulationProtocol.designMatrixLabelArray;

[indexDesignMatrixLabelArray, OK]  = listdlg('ListString', parametersStimulationProtocol.designMatrixLabelArray);

designMatrixLabel   = parametersStimulationProtocol.designMatrixLabelArray{indexDesignMatrixLabelArray};
taskPhaseLabel      = parametersStimulationProtocol.taskPhaseLabelArray{indexDesignMatrixLabelArray};
nRegressors         = parametersStimulationProtocol.nRegressors(indexDesignMatrixLabelArray);

if OK == 0
    sprintf('No design matrix template selected, design matrix cannot be created.')
else
    sprintf('Design matrix template %s selected.', designMatrixLabel)
end

nProtocolTypes = parametersStimulationProtocol.nProtocolTypes;


%%% The names of the different regressors are defined by combining the
%%% condition names with the task phase names.
for cond = 1:parametersParadigm.nConditions
    for reg = 1:nRegressors
        conditionNameArray{cond}{reg} = [parametersParadigm.conditionArray{cond}, '_', taskPhaseLabel{reg}];
    end
end


%%% The names of the different regressors are defined by combining the
%%% condition names with accuracy (correct or incorrect) and the task phase
%%% names
for answ = 1:nResponseTypes
    for cond = 1:parametersParadigm.nConditions
        for reg = 1:nRegressors
            conditionNameAccuracyArray{answ}{cond}{reg} = [parametersParadigm.conditionArray{cond}, '_', aStrAccuracy{answ}, '_', taskPhaseLabel{reg}];
        end
    end
end


%%% The names of the different regressors for the merged conditgion are
%%% defined by combining the merged condition name with the task phase
%%% name.
for reg = 1:nRegressors
    conditionMergedNameArray{reg} = [parametersParadigm.conditionMerged, '_', taskPhaseLabel{reg}];
end


%%% The names of the different regressors for the merged condition are
%%% defined by combining the merged condition name with accuracy (correct
%%% or incorrect) and the task phase
for answ = 1:nResponseTypes
    for reg = 1:nRegressors
        conditionMergedNameAccuracyArray{answ}{reg} = [parametersParadigm.conditionMerged, '_', aStrAccuracy{answ}, '_', taskPhaseLabel{reg}];
    end
end


bvqx = actxserver('BrainVoyagerQX.BrainVoyagerQXScriptAccess.1');

for s = 1:length(subjectArray)
    indexSubject = subjectArray{s};
    projectDataPath = [pathDefinition.singleSubjectData, indexExperiment, '\', indexSubject, '\'];
    for indexSession = 1:parametersParadigm.nSessions
        bvqx.ShowLogTab;
        prtFileNameStandard                     = sprintf('%s_%s_%s%i_%s_stim.prt', indexSubject, indexStudy, lower(parametersParadigm.indexSession), indexSession, designMatrixLabel);
        prtFileNameCorrTrials                   = sprintf('%s_%s_%s%i_%s_%s_stim.prt', indexSubject, indexStudy, lower(parametersParadigm.indexSession), indexSession, designMatrixLabel, indexCorrectTrials);
        prtFileNameConditionMerged              = sprintf('%s_%s_%s%i_%s_%s_stim.prt', indexSubject, indexStudy, lower(parametersParadigm.indexSession), indexSession, designMatrixLabel, parametersParadigm.indexConditionMerged);
        prtFileNameConditionMergedCorrTrials    = sprintf('%s_%s_%s%i_%s_%s_%s_stim.prt', indexSubject, indexStudy, lower(parametersParadigm.indexSession), indexSession, designMatrixLabel, parametersParadigm.indexConditionMerged, indexCorrectTrials);

        
        aPrtFileNames = {
            prtFileNameStandard
            prtFileNameCorrTrials
            prtFileNameConditionMerged
            prtFileNameConditionMergedCorrTrials
            };
        for cp = 1:nProtocolTypes
            
            if parametersStimulationProtocol.vbCreateProtocol(cp) == false
                continue
            else

                prtFileName = aPrtFileNames{cp};
                sdmFileName = sprintf('%s', strrep(prtFileName, 'prt', 'sdm'));

                bvqx.PrintToLog(sprintf('Creating SDM files for %s', [indexSubject, '_', indexStudy, '_', lower(parametersParadigm.indexSession), num2str(indexSession)]));

                %%% The VMR file and the VTC files for protocol generation are
                %%% defined.
                vmrInTalFileName    = [projectDataPath, indexSubject, '_', indexStudy, '_', parametersStructuralMriSequence.indexSequence, '_', parametersInhomogeneityCorrection.indexInhomogeneityCorrection, '_', parametersInhomogeneityCorrection.indexManualCorrection, '_', parametersInhomogeneityCorrection.indexIntensityNormalisation, '_', parametersTalairachTransformation.indexAutomaticTalTransformation, '.vmr'];

                %%%  Loads VTCs, which have not been spatially smoothed.
                vtcFileName = [projectDataPath, indexSubject '_' indexStudy, '_s', num2str(indexSession), '_', parametersEpiDistortionCorrection.strDistortionCorrection, '_', parametersSliceScanTimeCorrection.indexInterpolationMethod, '_', parametersMotionCorrection.indexInterpolationMethod, '.vtc'];

                %%%  Loads VTCs, which have been spatially smoothed.
                %vtcFileName = [projectDataPath, indexSubject, '_', indexStudy, '_' lower(parametersParadigm.indexSession), num2str(sessionIndex), '_', parametersEpiDistortionCorrection.strDistortionCorrection, '_', parametersSliceScanTimeCorrection.indexInterpolationMethod, '_', parametersMotionCorrection.indexInterpolationMethod, '_', parametersSpatialGaussianSmoothing.indexSpatialSmoothingMethod, parametersSpatialGaussianSmoothing.indexFwhm, parametersSpatialGaussianSmoothing.unit, '_', parametersTemporalHighPassFilter.indexLinearTrendRemoval, '_', parametersTemporalHighPassFilter.indexTemporalHighPass, parametersTemporalHighPassFilter.indexCutOffValue, parametersTemporalHighPassFilter.indexUnit '.vtc']



                %%% Check, whether all the files necessary for PRT creation exist.
                filesForPRTcreation = {vmrInTalFileName, vtcFileName};
                fileCounter = 0;
                for f = 1:length(filesForPRTcreation)
                    if exist(filesForPRTcreation{f}, 'file') > 0
                        fileCounter = fileCounter + 1;
                    else
                        message = sprintf('File %s missing.', filesForPRTcreation{f});
                        disp(message);
                    end
                end
                if fileCounter <  length(filesForPRTcreation)
                    sprintf('%s - SESSION %i incomplete. SDM-files are not created!', indexSubject, indexSession)
                else

                    doc = bvqx.OpenDocument(vmrInTalFileName);
                    doc.LinkVTC(vtcFileName);
                    doc.LinkStimulationProtocol([projectDataPath, prtFileName]);
                    bvqx.PrintToLog(sprintf('Linking stimulation protocol %s', prtFileName));
                    doc.ClearDesignMatrix;
                    doc.StimulationProtocolResolution = parametersStimulationProtocol.resolution;

                    %%% Create design matrix based on standard stimulation
                    %%% protocol
                    if strcmp(parametersStimulationProtocol.protocolTypeArray{cp}, 'StandardProtocol')
                        for cond = 1:parametersParadigm.nConditions
                            for reg = 1:nRegressors
                                doc.AddPredictor(conditionNameArray{cond}{reg});
                                doc.SetPredictorValuesFromCondition(conditionNameArray{cond}{reg}, conditionNameArray{cond}{reg}, 1.0);
                                doc.ApplyHemodynamicResponseFunctionToPredictor(conditionNameArray{cond}{reg});
                            end
                        end

                    %%% Create design matrix based on stimulation protocol
                    %%% separating correct and incorrect trials
                    elseif strcmp(parametersStimulationProtocol.protocolTypeArray{cp}, 'CorrectIncorrectProtocol')
                        for answ = 1:nResponseTypes
                            for cond = 1:parametersParadigm.nConditions
                                for reg = 1:nRegressors
                                    doc.AddPredictor(conditionNameAccuracyArray{answ}{cond}{reg});
                                    doc.SetPredictorValuesFromCondition(conditionNameAccuracyArray{answ}{cond}{reg}, conditionNameAccuracyArray{answ}{cond}{reg}, 1.0);
                                    doc.ApplyHemodynamicResponseFunctionToPredictor(conditionNameAccuracyArray{answ}{cond}{reg});
                                end
                            end
                        end
                        
                    %%% Create design matrix based on standard stimulation
                    %%% protocol with merged conditions
                    elseif strcmp(parametersStimulationProtocol.protocolTypeArray{cp}, 'ConditionMergedStandardProtocol')
                        for reg = 1:nRegressors
                            doc.AddPredictor(conditionMergedNameArray{reg});
                            doc.SetPredictorValuesFromCondition(conditionMergedNameArray{reg}, conditionMergedNameArray{reg}, 1.0);
                            doc.ApplyHemodynamicResponseFunctionToPredictor(conditionMergedNameArray{reg});
                        end

                    %%% Create design matrix based on stimulation  protocol
                    %%% with merged conditions separating correct and
                    %%% incorrect trials
                    elseif strcmp(parametersStimulationProtocol.protocolTypeArray{cp}, 'ConditionMergedCorrectIncorrectProtocol')
                        for answ = 1:nResponseTypes
                             for reg = 1:nRegressors
                                doc.AddPredictor(conditionMergedNameAccuracyArray{answ}{reg});
                                doc.SetPredictorValuesFromCondition(conditionMergedNameAccuracyArray{answ}{reg}, conditionMergedNameAccuracyArray{answ}{reg}, 1.0);
                                doc.ApplyHemodynamicResponseFunctionToPredictor(conditionMergedNameAccuracyArray{answ}{reg});
                            end
                        end
                        
                    end

                    doc.SDMContainsConstantPredictor = 0;
                    doc.SaveSingleStudyGLMDesignMatrix(sdmFileName);
                    doc.Close();
                end
            end
        end
    end
    
end

end
%}
