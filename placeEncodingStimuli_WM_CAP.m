function encodingStimulusArray = placeEncodingStimuli_WM_CAP(wmLoad, nPositions, nTrialsPerCondition, averageStimulusFrequency, stimulusSpecifications, encodingPositionsArray, stimulusNameArray);
%%% (c) Robert Bittner
%%% Study: WMC2_WM_CAP
%%% This function places the target and distractor encoding stimuli on the
%%% respective positions

%{
maxNoAttempts = 1000;
trialCounter = 0; 
for col = 1:length(stimulusSpecifications.stimulusColorArray)    
    diffCounterMax = nPositions * length(stimulusSpecifications.stimulusArray{col});
    if trialCounter > maxNoAttempts
        for t = 1:nTrialsPerCondition
            for p = 1:nPositions
                encodingStimulusArray{col}{t}{p} = 'empty';
            end
        end
    break
    end
    trialCounter = 0;
    diffCounter = 0;
    while diffCounter < diffCounterMax
        trialCounter = trialCounter + 1;
        diffCounter = 0;
            if trialCounter > maxNoAttempts
                for t = 1:nTrialsPerCondition
                    for p = 1:nPositions
                        encodingStimulusArray{col}{t}{p} = 'empty';
                    end
                end
            break
            end
%}
    
        %%% The position information is loaded
        for t = 1:nTrialsPerCondition
            %positionVector = encodingPositionsArray{t};
            selectedPositions = find(encodingPositionsArray{t} == 1);
            emptyPositions = find(encodingPositionsArray{t} == 0);

            %%% The target stimuli are placed on the target positions
            for stim = 1:length(selectedPositions)
                encodingStimulusArray{t}{selectedPositions(stim)} = stimulusNameArray{t}{stim};
            end

            %{
            %%% The distractor stimuli are placed
            for distr = 1:length(distractorPositions)
                encodingStimulusArray{col}{t}{distractorPositions(distr)} = stimulusNameArray.distractorStimuli{col}{t}{distr};
            end
            %}
            
            %%{
            %%% The blank stimuli are placed on the 'distractor' positions
            for empty = 1:length(emptyPositions)
                encodingStimulusArray{t}{emptyPositions(empty)} = sprintf('%s', stimulusSpecifications.blank);
            end
            %}
            %test = encodingStimulusArray{t}

        end

        %}
        
        %{
        %%% The frequency of each target stimulus at each location is counted
        averageStimulusFrequencyPerPosition = averageStimulusFrequency / nPositions;
        for s = 1:length(stimulusSpecifications.stimulusArray{col})
            
            stimulusFrequency = [];
            for p = 1:nPositions
                %%{
                stimulusFrequencyCounter = 0;
                for t = 1:nTrialsPerCondition
                    %if encodingStimulusArray{col}{t}{p} == stimulusSpecifications.stimulusArray{col}{s}
                    %%    stimulusFrequencyCounter = stimulusFrequencyCounter + 1;
                    %end
                end
                stimulusFrequency(p) = stimulusFrequencyCounter;
                diff = abs(stimulusFrequency(p) - ceil(averageStimulusFrequencyPerPosition));
                %%}
                %% The next line should be cancelled out
                diffCounter = diffCounter + 1;
                %{
                if diff < 3
                    diffCounter = diffCounter + 1
                end
                %}
            end
end
        %}
        %diffCounter = diffCounterMax;
%    end
%end



end