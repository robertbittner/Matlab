function [stimulusNameArray, averageStimulusFrequency] = determineStimulusNames_WM_CAP(wmLoad, nTrialsPerCondition, stimulusSpecifications, stimulusRepeatIndex); 
%%% (c) Robert Bittner
%%% Study: WMC2_WM_CAP
%%% This function randomly determines the name of the encoding stimuli 

%trialCounter = 0;
%for col = 1:length(stimulusSpecifications.stimulusColorArray)

%{
    %%% The target color is determined
    stimulusArrayTarget = stimulusSpecifications.stimulusArray{stimulusSpecifications.targetColorIndex(col)};
    stimulusArrayDistractor = stimulusSpecifications.stimulusArray{stimulusSpecifications.distractorColorIndex(col)};
    if trialCounter > 1000
        for t = 1:nTrialsPerCondition
            stimulusNameArray.targetStimuli{col}{t} = zeros(1, wmLoad);
            stimulusNameArray.distractorStimuli{col}{t} = zeros(1, nDistractors);
        end
    break
    end
    trialCounter = 0;
    diffCounter = 0;
    while diffCounter < length(stimulusArrayTarget)
        trialCounter = trialCounter + 1;
        diffCounter = 0;
            if trialCounter > 1000
                for t = 1:nTrialsPerCondition
                    stimulusNameArray.targetStimuli{col}{t} = zeros(1, wmLoad);
                    stimulusNameArray.distractorStimuli{col}{t} = zeros(1, nDistractors);
                end
            break
            end
%}

        for t = 1:nTrialsPerCondition

            %%% The target stimuli are drawn at random without replacement.
            %%% This should be changed in the future. Luck & Vogel allowed
            %%% 2 items of the same color to appear in each encoding array. 
%            stimulusNameArrayIndex{t} = randsample(length(stimulusSpecifications.stimulusArray), wmLoad);
%            for l = 1:wmLoad
%                stimulusNameArray{t}{l} = stimulusSpecifications.stimulusArray{stimulusNameArrayIndex{t}(l)};
%            end
            
            
            %%% The target stimuli are drawn at random with or without 
            %%% replacement, depending on the noOfStimulusRepeats variable.
%            noOfStimulusRepeats = stimulusRepeatIndexArray;
            noOfStimulusRepeats = stimulusRepeatIndex(t);

            if wmLoad <= noOfStimulusRepeats + 1
                stimulusNameArrayIndex{t} = randsample(length(stimulusSpecifications.stimulusArray), wmLoad);
                for l = 1:wmLoad
                    stimulusNameArray{t}{l} = stimulusSpecifications.stimulusArray{stimulusNameArrayIndex{t}(l)};
                end
                stimulusNameArray{t}{l} = stimulusSpecifications.stimulusArray{stimulusNameArrayIndex{t}(l)};
            else
                stimulusNameArrayIndex{t} = randsample(length(stimulusSpecifications.stimulusArray), (wmLoad - noOfStimulusRepeats));

                for l = 1:wmLoad - noOfStimulusRepeats
                    stimulusNameArray{t}{l} = stimulusSpecifications.stimulusArray{stimulusNameArrayIndex{t}(l)};
                end

%                if noOfStimulusRepeats == length(stimulusNameArrayIndex{t})
%                    repeatIndex{t} = stimulusNameArrayIndex{t};
%                else

                repeatIndex{t} = randsample(length(stimulusNameArrayIndex{t}), noOfStimulusRepeats);
                repeatedStimulusIndex{t} = stimulusNameArrayIndex{t}(repeatIndex{t});
%                end

                if noOfStimulusRepeats == 0
                    stimulusNameArray{t} = stimulusNameArray{t}(Randperm(wmLoad));
                else
                    for r = 1:noOfStimulusRepeats
                        repeatedStimulusArrayIndex{t}{r} = stimulusSpecifications.stimulusArray{repeatedStimulusIndex{t}(r)};
                    end
                    stimulusNameArray{t} = [stimulusNameArray{t}, repeatedStimulusArrayIndex{t}];
                    stimulusNameArray{t} = stimulusNameArray{t}(Randperm(wmLoad));
                end
            end
            
            %{
            %%% The distractor stimuli are drawn at random
            additionalDistractorIndex = randsample(length(stimulusArrayDistractor), nDistractors-length(stimulusArrayDistractor));
            stimulusNameArray.distractorIndex{t} = [randperm(length(stimulusArrayDistractor)), additionalDistractorIndex];
            for distr = 1:nDistractors
                stimulusNameArray.distractorStimuli{col}{t}{distr} = stimulusArrayDistractor{stimulusNameArray.distractorIndex{t}(distr)};
                %stimulusNameArray.distractorStimuli{col}{t}{distr} = sprintf('%s.bmp', stimulusSpecifications.blank);
            end
            %}
        end

        %{
        %%% The number of times each target stimulus was drawn is counted
        for s = 1:length(stimulusArrayTarget)
            stimulusFrequencyCounter = 0;
            for t = 1:nTrialsPerCondition
                for targ = 1:wmLoad
                    if stimulusNameArray.targetStimuli{col}{t}{targ} == stimulusArrayTarget{s}
                        stimulusFrequencyCounter = stimulusFrequencyCounter + 1;
                    end
                end
            end
            %}
            %{
            %%% The number of times each target stimulus was drawn is
            %%% compared to the expected average stimulus frequency
            averageStimulusFrequency = (nTrialsPerCondition * wmLoad) / length(stimulusArrayTarget);
            stimulusFrequency(s) = stimulusFrequencyCounter;
            diff = ceil(abs(stimulusFrequency(s) - averageStimulusFrequency));
            if diff < 2
                diffCounter = diffCounter + 1;
            end
            %}
            averageStimulusFrequency = 0;
        end
    %end
%end


%end