function createStimulationProtocolATWM1();
%%% This function creates stimulation protocols 
%%% Written for BVQX 2.8.2

clear all
clc

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
parametersStudy.experimentNumber = experimentNo;

indexMethod = parametersStudy.indexMRI;
indexExperiment = [parametersStudy.indexExperiment, num2str(experimentNo)];

indexCorrectTrial = 1;
indexIncorrectTrial = 0;
indexMissingAnswer = -1;

indexConditionMerged = 'combined_cond';

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
parametersFunctionalMriSequence     = eval(['parametersFunctionalMriSequence', indexStudy]);
parametersEpiDistortionCorrection   = eval(['parametersEpiDistortionCorrection', indexStudy]);
parametersSliceScanTimeCorrection   = eval(['parametersSliceScanTimeCorrection', indexStudy]);
parametersSpatialGaussianSmoothing  = eval(['parametersSpatialGaussianSmoothing', indexStudy]);
parametersMotionCorrection          = eval(['parametersMotionCorrection', indexStudy]);
parametersTemporalHighPassFilter    = eval(['parametersTemporalHighPassFilter', indexStudy]);
%parametersVolumeTimeCourse          = eval(['parametersVolumeTimeCourse', indexStudy]); 
parametersStimulationProtocol       = eval(['parametersStimulationProtocol', indexStudy]);

subjectArray = eval(['subjectArray', indexStudy]);
subjectArray = subjectArray.WMC2_MRI_EXP_1_GEN;

%{
subjectArray = {
    'DQMC896637794'
    'EGRV896726594'
    'QUMH225696883'
    'RPCU886627594'
    'TNJX757786834'
    'UVKJ647677934'
    'VTAL657756854'
    'XDVN857826324'
    };
%}


%%% This dialog lets the user choose a specific design matrix
[indexDesignMatrixLabelArray, OK]  = listdlg('ListString', parametersStimulationProtocol.designMatrixLabelArray);

designMatrixLabel   = parametersStimulationProtocol.designMatrixLabelArray{indexDesignMatrixLabelArray};
designMatrix        = parametersStimulationProtocol.designMatrixArray{indexDesignMatrixLabelArray};
taskPhaseLabel      = parametersStimulationProtocol.taskPhaseLabelArray{indexDesignMatrixLabelArray};
nRegressors         = parametersStimulationProtocol.nRegressors(indexDesignMatrixLabelArray);

if OK == 0
    sprintf('No design matrix template selected, design matrix cannot be created.')
else
    sprintf('Design matrix template %s selected.', designMatrixLabel)
end

nProtocolTypes = parametersStimulationProtocol.nProtocolTypes;


conditionArray = parametersParadigm.conditionArray;

%{
for answ = 1:nResponseTypes
    for cond = 1:parametersParadigm.nConditions
        conditionAccuracyArray{answ}{cond} = [parametersParadigm.conditionArray{cond}, '_', aStrAccuracy{answ}];
    end    
end


%%% The different conditions are extracted
for t = 1:parametersParadigm.nTrials
    isiIndex = num2str(parametersParadigm.intervallInterStimulus(t));

    %%% The following definition separates the different masking conditions
    trialSpecificationArray{t} = parametersParadigm.trialSpecification{t};
end

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


%%% The trial indices for each session are calculated.
for indexSession = 1:parametersParadigm.nSessions
    firstTrialNumberSession(indexSession) = ((indexSession - 1) * parametersParadigm.nTrialsPerSession) + 1;
    lastTrialNumberSession(indexSession) = indexSession * parametersParadigm.nTrialsPerSession;
end

%%% The trial numbers for each trial type are extracted.
for cond = 1:parametersParadigm.nConditions
    indexCondition{cond} = strmatch(conditionArray{cond}, trialSpecificationArray);
end



%%% The trial numbers for each trial type per session are extracted.
for cond = 1:parametersParadigm.nConditions
    for indexSession = 1:parametersParadigm.nSessions
        indexConditionSession{cond}{indexSession} = indexCondition{cond}(find(firstTrialNumberSession(indexSession) <= indexCondition{cond} &  indexCondition{cond} <= lastTrialNumberSession(indexSession)));
    end
end

%%% Merge trials of all conditions in a session
for indexSession = 1:parametersParadigm.nSessions
    indexConditionMergedSession{indexSession} = [];
    for cond = 1:parametersParadigm.nConditions
        tempIndexConditionSession{cond} = indexConditionSession{cond}{indexSession}'; %= indexCondition{cond}(find(firstTrialNumberSession(indexSession) <= indexCondition{cond} &  indexCondition{cond} <= lastTrialNumberSession(indexSession)));
        indexConditionMergedSession{indexSession} = sort([indexConditionMergedSession{indexSession}, tempIndexConditionSession{cond}]);
    end
end
%}

%determineConditionAndTrialDataWMC2
hFunction = str2func(sprintf('determineConditionAndTrialData%s', indexStudy));
[conditionAccuracyArray, trialSpecificationArray, conditionNameArray, conditionNameAccuracyArray, conditionMergedNameArray, conditionMergedNameAccuracyArray, indexConditionSession, firstTrialNumberSession, lastTrialNumberSession] = feval(hFunction, nResponseTypes, aStrAccuracy, parametersParadigm, taskPhaseLabel, nRegressors, conditionArray);


%%{
bvqx = actxserver('BrainVoyagerQX.BrainVoyagerQXScriptAccess.1');

for s = 1:length(subjectArray)
    indexSubject = subjectArray{s};
    projectDataPath = [pathDefinition.singleSubjectData, indexExperiment, '\', indexSubject, '\'];
    
    %%% The correct trials are extracted from the BehavioralData file
    strBehavioralDataFile = strcat(indexSubject, '_', indexStudy, '_', parametersStudy.indexMRI, '_', parametersStudy.indexExperiment, num2str(parametersStudy.experimentNumber), '_', 'BehavioralData', '.m');
    if exist(strcat(pathDefinition.behavioralData, '\', indexMethod, '\', indexExperiment, '\', strBehavioralDataFile), 'file')
        behavioralData = eval([indexSubject, '_', indexStudy, '_', parametersStudy.indexMRI, '_', parametersStudy.indexExperiment, num2str(parametersStudy.experimentNumber), '_', 'BehavioralData']);
    else
        strMessage = sprintf('No behavioral data file found for subject %s', indexSubject);
        disp(strMessage);
        continue
    end
    for ct = 1:parametersParadigm.nTrials
        if behavioralData.response(ct) == 1 
            aCorrectTrials{ct} = 1;
        else
            aCorrectTrials{ct} = 0;
        end
    end
    
    %%% The correct and incorrect trials are determined for each session 
    %%% and condition
    for cond = 1:parametersParadigm.nConditions
        
        for indexSession = 1:parametersParadigm.nSessions
            indexConditionSessionCorrectTrials{cond}{indexSession}      = indexConditionSession{cond}{indexSession};
            indexConditionSessionIncorrectTrials{cond}{indexSession}    = indexConditionSession{cond}{indexSession};
            for ct = 1:length(indexConditionSession{cond}{indexSession})
                if aCorrectTrials{indexConditionSession{cond}{indexSession}(ct)} == indexCorrectTrial
                    indexConditionSessionIncorrectTrials{cond}{indexSession}(ct) = 0;
                else
                    indexConditionSessionCorrectTrials{cond}{indexSession}(ct) = 0;
                end
            end
            indexConditionSessionCorrectTrials{cond}{indexSession}      = indexConditionSessionCorrectTrials{cond}{indexSession}(indexConditionSessionCorrectTrials{cond}{indexSession}~=0);
            indexConditionSessionIncorrectTrials{cond}{indexSession}    = indexConditionSessionIncorrectTrials{cond}{indexSession}(indexConditionSessionIncorrectTrials{cond}{indexSession}~=0);

            %%% add trial to incorrect trials, when no incorrect trials can
            %%% be detected. 
            if isempty(indexConditionSessionCorrectTrials{cond}{indexSession})
                %%% randomly determine trial to be added to correct trials
                randNumber = randi(length(indexConditionSession{cond}{indexSession}), 1);
                iTrialToBeAdded = indexConditionSessionIncorrectTrials{cond}{indexSession}(randNumber);
                
                %%% Add randomly determined trial to correct trials
                indexConditionSessionCorrectTrials{cond}{indexSession}(1) = iTrialToBeAdded;
                
                %%% Remove randomly determined trial from incorrect trials
                indexConditionSessionIncorrectTrials{cond}{indexSession}(randNumber) = 0;
                indexConditionSessionIncorrectTrials{cond}{indexSession} = indexConditionSessionIncorrectTrials{cond}{indexSession}(indexConditionSessionIncorrectTrials{cond}{indexSession}~=0);
                
                strMessage = sprintf('\nNo correct trials in condition %i of subject %s!\n', cond, indexSubject);
                disp(strMessage);
            elseif isempty(indexConditionSessionIncorrectTrials{cond}{indexSession})
                %%% randomly determine trial to be added to incorrect trials
                randNumber = randi(length(indexConditionSession{cond}{indexSession}), 1);
                iTrialToBeAdded = indexConditionSessionCorrectTrials{cond}{indexSession}(randNumber);
                
                %%% Add randomly determined trial to incorrect trials
                indexConditionSessionIncorrectTrials{cond}{indexSession}(1) = iTrialToBeAdded;
                
                %%% Remove randomly determined trial from incorrect trials
                indexConditionSessionCorrectTrials{cond}{indexSession}(randNumber) = 0;
                indexConditionSessionCorrectTrials{cond}{indexSession} = indexConditionSessionCorrectTrials{cond}{indexSession}(indexConditionSessionCorrectTrials{cond}{indexSession}~=0);
            end
        end
    end

    
    %%% Merge trials of all conditions in a session separately for correct
    %%% and incorrect trials
    for indexSession = 1:parametersParadigm.nSessions
        indexConditionMergedSessionCorrectTrials{indexSession} = [];
        indexConditionMergedSessionIncorrectTrials{indexSession} = [];
        for cond = 1:parametersParadigm.nConditions
            tempIndexConditionSessionCorrectTrials{cond} = indexConditionSessionCorrectTrials{cond}{indexSession}'; 
            indexConditionMergedSessionCorrectTrials{indexSession} = sort([indexConditionMergedSessionCorrectTrials{indexSession}, tempIndexConditionSessionCorrectTrials{cond}]);
            
            tempIndexConditionSessionIncorrectTrials{cond} = indexConditionSessionIncorrectTrials{cond}{indexSession}';
            indexConditionMergedSessionIncorrectTrials{indexSession} = sort([indexConditionMergedSessionIncorrectTrials{indexSession}, tempIndexConditionSessionIncorrectTrials{cond}]);

        end
    end

    %%% Create new array with the index arrays for correct and incorrect
    %%% trials
    indexConditionSessionAccuracy       = {indexConditionSessionCorrectTrials, indexConditionSessionIncorrectTrials};
    indexConditionMergedSessionAccuracy = {indexConditionMergedSessionCorrectTrials, indexConditionMergedSessionIncorrectTrials};

    
    %%% Define the regressor intervals
    for indexSession = 1:parametersParadigm.nSessions
        for indexTrial = firstTrialNumberSession(indexSession):lastTrialNumberSession(indexSession)
            
            %%% This defines the initial volume of each trial
            startVolumeTrial = parametersParadigm.volumeTrigger(indexTrial) - parametersFunctionalMriSequence.nVolumesToSkip;
            
            for reg = 1:nRegressors
                if reg == 1
                    regressorIntervalArray{indexSession}{indexTrial}{reg}(1) = startVolumeTrial;
                    regressorIntervalArray{indexSession}{indexTrial}{reg}(2) = regressorIntervalArray{indexSession}{indexTrial}{reg}(1) + (designMatrix(reg, 1) - 1); 
                else
                    regressorIntervalArray{indexSession}{indexTrial}{reg}(1) = regressorIntervalArray{indexSession}{indexTrial}{reg - 1}(2) + 1 + (designMatrix(reg - 1, 2));
                    regressorIntervalArray{indexSession}{indexTrial}{reg}(2) = regressorIntervalArray{indexSession}{indexTrial}{reg}(1) + (designMatrix(reg, 1) - 1);
                end                
            end
        end
    end


%%{   
    %%% The PRT-Files are created
    %%% 1) The PRT-Files for the SDM-Files are created
    for indexSession = 1:parametersParadigm.nSessions
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

                prtFileName = aPrtFileNames{cp};%sprintf('%s_%s_%s%i_%s_%s_stim.prt', indexSubject, indexStudy, lower(parametersParadigm.indexSession), indexSession, designMatrixLabel, indexCorrectTrials);
                strMessage = sprintf('Creating protocol %s', prtFileName);
                disp(strMessage);

                %%% ???? These prtFiles are created for GCM
                %%% These prtFiles are used for event-related averaging
                % prtFileName = sprintf('%s_%s_%s%i_avg.prt', subject, indexStudy, lower(parametersParadigm.indexSession), indexSession);

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
                    sprintf('%s - SESSION %i incomplete. Stimulation prt-files are not created!', indexSubject, indexSession)
                else

                    %%{
                    bvqx.ShowLogTab;
                    bvqx.PrintToLog(sprintf('Creating stimulation protocol files for %s', [indexSubject, '_', indexStudy, '_', lower(parametersParadigm.indexSession), num2str(indexSession)]));

                    doc = bvqx.OpenDocument(vmrInTalFileName);
                    doc.LinkVTC(vtcFileName);
                    doc.ClearStimulationProtocol();
                    doc.StimulationProtocolExperimentName = indexStudy;
                    doc.StimulationProtocolResolution = parametersStimulationProtocol.resolution;


                    %%% Create standard stimulation protocol
                    if strcmp(parametersStimulationProtocol.protocolTypeArray{cp}, 'StandardProtocol')

                        %%% Add conditions to protocol
                        for cond = 1:parametersParadigm.nConditions
                            for reg = 1:nRegressors
                                doc.AddCondition(conditionNameArray{cond}{reg});
                            end    
                        end

                        %%% Add intervals to protocol
                        for cond = 1:parametersParadigm.nConditions
                            for trialNumber = 1:length(indexConditionSession{cond}{indexSession})
                                for reg = 1:nRegressors
                                    indexTrial = indexConditionSession{cond}{indexSession}(trialNumber);
                                    doc.AddInterval(conditionNameArray{cond}{reg}, regressorIntervalArray{indexSession}{indexTrial}{reg}(1), regressorIntervalArray{indexSession}{indexTrial}{reg}(2));
                                end
                            end
                        end

                    %%% Create stimulation protocol separating correct and 
                    %%% incorrect trials
                    elseif strcmp(parametersStimulationProtocol.protocolTypeArray{cp}, 'CorrectIncorrectProtocol')
                        
                        %%% Add conditions to protocol 
                        for answ = 1:nResponseTypes
                            for cond = 1:parametersParadigm.nConditions
                                for reg = 1:nRegressors
                                    doc.AddCondition(conditionNameAccuracyArray{answ}{cond}{reg});
                                end
                            end    
                        end

                        %%% Add intervals to protocol 
                        for answ = 1:nResponseTypes
                            for cond = 1:parametersParadigm.nConditions
                                for trialNumber = 1:length(indexConditionSessionAccuracy{answ}{cond}{indexSession})
                                    for reg = 1:nRegressors
                                        indexTrial = indexConditionSessionAccuracy{answ}{cond}{indexSession}(trialNumber);
                                        doc.AddInterval(conditionNameAccuracyArray{answ}{cond}{reg}, regressorIntervalArray{indexSession}{indexTrial}{reg}(1), regressorIntervalArray{indexSession}{indexTrial}{reg}(2));
                                    end
                                end
                            end
                        end

                    %%% Create standard stimulation protocol with merged 
                    %%% conditions 
                    elseif strcmp(parametersStimulationProtocol.protocolTypeArray{cp}, 'ConditionMergedStandardProtocol')
                        
                        %%% Add conditions to protocol
                        for reg = 1:nRegressors
                            doc.AddCondition(conditionMergedNameArray{reg});
                        end    
                        
                        %%% Add intervals to protocol
                        for trialNumber = 1:length(indexConditionMergedSession{indexSession})
                            for reg = 1:nRegressors
                                indexTrial = indexConditionMergedSession{indexSession}(trialNumber);
                                doc.AddInterval(conditionMergedNameArray{reg}, regressorIntervalArray{indexSession}{indexTrial}{reg}(1), regressorIntervalArray{indexSession}{indexTrial}{reg}(2));
                            end
                        end

                        
                    %%% Create stimulation  protocol with merged conditions
                    %%% separating correct and incorrect trials
                    elseif strcmp(parametersStimulationProtocol.protocolTypeArray{cp}, 'ConditionMergedCorrectIncorrectProtocol')

                        %%% Add conditions to protocol 
                        for answ = 1:nResponseTypes
                            for reg = 1:nRegressors
                                doc.AddCondition(conditionMergedNameAccuracyArray{answ}{reg});
                            end
                        end

                        %%% Add intervals to protocol 
                        for answ = 1:nResponseTypes
                            for trialNumber = 1:length(indexConditionMergedSessionAccuracy{answ}{indexSession})
                                for reg = 1:nRegressors
                                    indexTrial = indexConditionMergedSessionAccuracy{answ}{indexSession}(trialNumber);
                                    doc.AddInterval(conditionMergedNameAccuracyArray{answ}{reg}, regressorIntervalArray{indexSession}{indexTrial}{reg}(1), regressorIntervalArray{indexSession}{indexTrial}{reg}(2));
                                end
                            end
                        end

                    end
                    
                    %%% Set additional protocol parameters and save protocol
                    doc.StimulationProtocolBackgroundColorR = 0;
                    doc.StimulationProtocolBackgroundColorG = 0;
                    doc.StimulationProtocolBackgroundColorB = 0;
                    doc.StimulationProtocolTimeCourseColorR = 255;
                    doc.StimulationProtocolTimeCourseColorG = 255;
                    doc.StimulationProtocolTimeCourseColorB = 255;
                    doc.StimulationProtocolTimeCourseThickness = 4;
                    doc.SaveStimulationProtocol(prtFileName);
                    doc.Save();
                    doc.Close();
                    %}
                end
            end
        end
    end
%end
%{

    %%% 2) The PRT-Files for the event-related averaging are created
    for indexSession = 1:parametersParadigm.nSessions

        %prtFileName = aPrtFileNames{cp};%sprintf('%s_%s_%s%i_%s_%s_stim.prt', indexSubject, indexStudy, lower(parametersParadigm.indexSession), indexSession, designMatrixLabel, indexCorrectTrials);

        prtFileNameStandard = sprintf('%s_%s_%s%i_avg.prt', indexSubject, indexStudy, lower(parametersParadigm.indexSession), indexSession);
        prtFileNameCorrTrials = sprintf('%s_%s_%s%i_%s_avg.prt', indexSubject, indexStudy, lower(parametersParadigm.indexSession), indexSession, indexCorrectTrials);

        %prtFileNameStandard = sprintf('%s_%s_%s%i_%s_stim.prt', indexSubject, indexStudy, lower(parametersParadigm.indexSession), indexSession, designMatrixLabel);
        %prtFileNameCorrTrials = sprintf('%s_%s_%s%i_%s_%s_stim.prt', indexSubject, indexStudy, lower(parametersParadigm.indexSession), indexSession, designMatrixLabel, indexCorrectTrials);

        aPrtFileNames = {
            prtFileNameStandard
            prtFileNameCorrTrials
            };

        for cp = 1:nProtocolTypes
            if cp == 1
                bCreateStandardProtocol                             = true;
                bCreateCorrectIncorrectProtocol  = false;
            elseif cp == 2
                bCreateStandardProtocol                             = false;
                bCreateCorrectIncorrectProtocol  = true;                
            end
            prtFileName = aPrtFileNames{cp};

            strMessage = sprintf('Creating event-related averaging protocol files for %s', [indexSubject, '_', indexStudy, '_', lower(parametersParadigm.indexSession), num2str(indexSession)]));
            disp(strMessage);

            bvqx.ShowLogTab;
            bvqx.PrintToLog(sprintf('Creating event-related averaging protocol files for %s', [indexSubject, '_', indexStudy, '_', lower(parametersParadigm.indexSession), num2str(indexSession)]));

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
                end
            end
            if fileCounter <  length(filesForPRTcreation)
                sprintf('%s - SESSION %i incomplete. Averaging prt-files are not created!', indexSubject, indexSession)
            else
                doc = bvqx.OpenDocument(vmrInTalFileName);
                doc.LinkVTC(vtcFileName);
                doc.ClearStimulationProtocol();
                doc.StimulationProtocolExperimentName = indexStudy;
                doc.StimulationProtocolResolution = parametersStimulationProtocol.resolution;

                %%% Create event-related averaging protocol
                if bCreateStandardProtocol == true

                    for cond = 1:parametersParadigm.nConditions
                        doc.AddCondition(conditionArray{cond});
                    end

                    for cond = 1:parametersParadigm.nConditions
                        for trialNumber = 1:length(indexConditionSession{cond}{indexSession})
                            indexTrial = indexConditionSession{cond}{indexSession}(trialNumber);
                            doc.AddInterval(conditionArray{cond}, regressorIntervalArray{indexSession}{indexTrial}{1}(1), regressorIntervalArray{indexSession}{indexTrial}{nRegressors}(2));
                        end
                    end

                %%% Create event-related averaging protocol separating 
                %%% correct and incorrect trials
                elseif bCreateCorrectIncorrectProtocol == true
                    
                    %%% Add conditions to protocol 
                    for answ = 1:nResponseTypes
                        for cond = 1:parametersParadigm.nConditions
                            doc.AddCondition(conditionAccuracyArray{answ}{cond});
                        end    
                    end

                    %%% Add intervals to protocol 
                    for answ = 1:nResponseTypes
                        for cond = 1:parametersParadigm.nConditions
                            for trialNumber = 1:length(indexConditionSessionAccuracy{answ}{cond}{indexSession})
                                for reg = 1:nRegressors
                                    indexTrial = indexConditionSession{cond}{indexSession}(trialNumber);
                                    doc.AddInterval(conditionAccuracyArray{answ}{cond}, regressorIntervalArray{indexSession}{indexTrial}{1}(1), regressorIntervalArray{indexSession}{indexTrial}{nRegressors}(2));
                                end
                            end
                        end
                    end
                end
                
                %%% Set additional protocol parameters and save protocol                
                doc.StimulationProtocolBackgroundColorR = 0;
                doc.StimulationProtocolBackgroundColorG = 0;
                doc.StimulationProtocolBackgroundColorB = 0;
                doc.StimulationProtocolTimeCourseColorR = 255;
                doc.StimulationProtocolTimeCourseColorG = 255;
                doc.StimulationProtocolTimeCourseColorB = 255;
                doc.StimulationProtocolTimeCourseThickness = 4;
                doc.SaveStimulationProtocol(prtFileName);
                doc.Save();
                doc.Close();
            end
        end
    end
end
%}

end

end
%}
