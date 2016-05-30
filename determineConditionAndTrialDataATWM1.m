function [conditionAccuracyArray, trialSpecificationArray, conditionNameArray, conditionNameAccuracyArray, conditionMergedNameArray, conditionMergedNameAccuracyArray, indexConditionSession, firstTrialNumberSession, lastTrialNumberSession] = determineConditionAndTrialDataATWM1(nResponseTypes, aStrAccuracy, parametersParadigm, taskPhaseLabel, nRegressors, conditionArray);

%{    
global indexStudy;
global indexMethod;
global indexExperiment;
global indexSubject;
%}

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

end

