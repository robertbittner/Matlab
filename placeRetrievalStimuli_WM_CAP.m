function [retrievalStimulusArray, changeSpecificationArray] = placeRetrievalStimuli_WM_CAP(nTrialsPerCondition, nChangeTrials, stimulusSpecifications, encodingPositionsArray, encodingStimulusArray, changeSpecificationIndex);
%%% (c) Robert Bittner
%%% Study: WMC2
%%% This function creates the retrieval arrays, randomly determining the
%%% nonmatch trials and randomly selecting the changed target stimulus

%%{
%%% Define the proportion of nonmatch trials
% nChangeTrials = floor(nTrialsPerCondition / 2);

%%% Determine randomly the trial index for the nonmatch trials
changeIndexVector = sort(randsample(nTrialsPerCondition, nChangeTrials));


%%{
%for col = 1:length(stimulusSpecifications.stimulusColorArray)    

    %%% Create retrieval arrays 
    for t = 1:nTrialsPerCondition
        positions = encodingPositionsArray{t};
        stimulusPositionVector = find(positions == 1);
        emptyPositionVector = find(positions == 0);

        %%% Create retrieval arrays for the match condition
        unchangedRetrievalStimulusArray{t} = encodingStimulusArray{t};

%        targetStimuli = encodingStimulusArray{t}(stimulusPositionVector)
        targetStimuli = sort(encodingStimulusArray{t}(stimulusPositionVector));

        stimulusIndex = 1:length(stimulusSpecifications.stimulusArray);
        for s = 1:length(stimulusPositionVector)
            ind = strmatch(targetStimuli{s}, stimulusSpecifications.stimulusArray);
            stimulusIndex(ind) = 0;
        end

        %%% create vector indicating stimuli not present in the encoding
        %%% array
        stimulusIndex = nonzeros(stimulusIndex)';
        if length(stimulusIndex) > 1
            nonMatchStimulusIndex(t) = randsample(stimulusIndex, 1);
        else
            nonMatchStimulusIndex(t) = stimulusIndex;
        end
%        nonMatchStimulusIndex(t) = randsample(stimulusIndex, 1);
        nonMatchStimulus{t} = stimulusSpecifications.stimulusArray{nonMatchStimulusIndex(t)};
%        arrray = targetStimuli
%        nmatchstim = nonMatchStimulus{t}

%{        

        %%% Determine, which target stimulus can be changed in the
        %%% nonmatch condition
        stimulusIndex = 1:length(stimulusSpecifications.stimulusArray);
        changedStimulusIndex{t}(1) = nonMatchStimulusIndex{t} - 1;
        changedStimulusIndex{t}(2) = nonMatchStimulusIndex{t} + 1;
        if changedStimulusIndex{t}(1) == stimulusIndex(1) - 1
            changedStimulusIndex{t}(1) = stimulusIndex(length(stimulusIndex));
        end
        if changedStimulusIndex{t}(2) == stimulusIndex(length(stimulusIndex)) + 1
            changedStimulusIndex{t}(2) = stimulusIndex(1);
        end
        changedStimulusIndex{t} = sort(changedStimulusIndex{t});
%}
%{        
        %%% Search for position in encoding array of stimuli, which can
        %%% be changed in the nonmatch condition
        for s = 1:length(changedStimulusIndex{t})
            changedStimulusPosition{t}(s) = strmatch(stimulusSpecifications.stimulusArray(changedStimulusIndex{t}(s)), encodingStimulusArray{t});
        end

        %%% Determine randomly, which of the possible target stimuli
        %%% are changed in the nonmatch condition
        selectedChangedStimulusPosition{t} = changedStimulusPosition{t}(randIndex(t));
%}
        changedRetrievalStimulusArray{t} = unchangedRetrievalStimulusArray{t};
        if length(stimulusSpecifications.stimulusArray) - length(stimulusIndex) > 1
            selectedChangedStimulusPosition{t} = randsample(stimulusPositionVector, 1);
            changedRetrievalStimulusArray{t}{selectedChangedStimulusPosition{t}} = nonMatchStimulus{t};
        else
            sprintf('TEST')
            selectedChangedStimulusPosition{t} = stimulusPositionVector;
            changedRetrievalStimulusArray{t}{selectedChangedStimulusPosition{t}} = nonMatchStimulus{t};
        end
        %selectedChangedStimulusPosition{t} = randsample(stimulusPositionVector, 1);
%        test =  selectedChangedStimulusPosition{t}

        %%% Change the randomly selected target stimulus in the
        %%% retrieval array

        changedRetrievalStimulusArray{t}{selectedChangedStimulusPosition{t}} = nonMatchStimulus{t};
%        testEnc = unchangedRetrievalStimulusArray{t}
%        testRet = changedRetrievalStimulusArray{t}
        
%        noChange = unchangedRetrievalStimulusArray{t}
%        change = changedRetrievalStimulusArray{t}

        %%% Create the retrieval arrays
        if ismember(t, changeIndexVector) == 1
            retrievalStimulusArray{t} = changedRetrievalStimulusArray{t};
            changeSpecificationArray{t} = changeSpecificationIndex.change;
        else
            retrievalStimulusArray{t} = unchangedRetrievalStimulusArray{t};
            changeSpecificationArray{t} = changeSpecificationIndex.nochange;
        end
    end

    %{
    for t = 1:nTrialsPerCondition
        est = t
        test = changeSpecificationArray{col}{t}
        
    end
    %}
%end

%}
%retrievalStimulusArray = '';
%changeSpecificationArray = '';
end