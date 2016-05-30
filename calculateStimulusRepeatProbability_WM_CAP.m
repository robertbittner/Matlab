function stimulusRepeatProbabilityArray = calculateStimulusRepeatProbability_WM_CAP(noStimuli, wmLoad, factor, maxNoOfStimulusRepeats);
%{
for r = 1:maxNoOfStimulusRepeats
%    for l = wmLoadLevelVector
    res = noStimuli - wmLoad + (r-1);
    if res < 0
        res = 0;
    end
    stimulusRepeatProbabilityArray(r) = 1 - (res * factor);
    if stimulusRepeatProbabilityArray(r) < 0
        stimulusRepeatProbabilityArray(r) = 0;
    end
    old = stimulusRepeatProbabilityArray(r)
%    end
% test = stimulusRepeatProbabilityVector(r)
%    stimulusRepeatProbabilityVector(r) = stimulusRepeatProbabilityVector(r)(wmLoadLevelVector);
end
%}
for r = 1:maxNoOfStimulusRepeats
%    for l = wmLoadLevelVector
    res = noStimuli - wmLoad + (r+1);
    if res <= 2
        prob = 1;
    elseif res == 3
        prob = 0.5 * (2/3);
    elseif res == 4
        prob = 0.5 * (1/3);
    else
        prob = 0;
    end
    stimulusRepeatProbabilityArray(r) = prob;
    %{
    if res < 0
        res = 0;
    end
    stimulusRepeatProbabilityArray(r) = 1 - (res * factor);
    if stimulusRepeatProbabilityArray(r) < 0
        stimulusRepeatProbabilityArray(r) = 0;
    end
%    end
% test = stimulusRepeatProbabilityVector(r)
%    stimulusRepeatProbabilityVector(r) = stimulusRepeatProbabilityVector(r)(wmLoadLevelVector);
end

    %}
    
end
