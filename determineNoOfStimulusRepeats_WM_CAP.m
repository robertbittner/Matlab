function stimulusRepeatIndexArray = determineNoOfStimulusRepeats_WM_CAP(stimulusRepeatProbability, nTrialsPerCondition, maxNoOfStimulusRepeats);

stimulusRepeatIndexArray(1:nTrialsPerCondition) = 0;
for r = 1:maxNoOfStimulusRepeats

    %%% This is only used for checking
    %displayStimulusRepeatProbability = stimulusRepeatProbability(r)

    noStimulusRepeatTrials(r) = floor(nTrialsPerCondition * stimulusRepeatProbability(r));
    stimulusRepeatIndexArray(1:noStimulusRepeatTrials(r)) = r;

end

stimulusRepeatIndexArray = stimulusRepeatIndexArray(randperm(nTrialsPerCondition));

    %%% This is only used for checking
    %displayStimulusRepeatIndexArray = stimulusRepeatIndexArray
end