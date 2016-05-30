function createParadigmATWM1_WM_CAP ();
%%% (c) Robert Bittner
%%% Study: ATWM1_WM_CAP
%%% Paradigm: Working memory capacity
%%% This function creates the trials in presentation format.


clear all
clc

iStudy = 'ATWM1';

filePath = 'D:\Daten\ATWM1\';

parametersParadigm = parametersParadigmATWM1_WM_CAP;

changeSpecificationIndex.nochange   = parametersParadigm.changeSpecificationIndex.nochange;
changeSpecificationIndex.change     = parametersParadigm.changeSpecificationIndex.change;

%{
encodingTime = 100;
intertrialInterval = 3000;
preparationTime = 500;
delayInterval = 2000 - encodingTime;                  %%% This is the total delay interval, including ISI/SOA and mask intervals
maskPresentationTime = 500;

nTrialsPerCondition = 8;
nRuns = 1;
%}


nTrialsPerCondition = parametersParadigm.nTrialsPerCondition;% = 8;
nRuns = parametersParadigm.nRuns;% = 1;

nPositions = 12;

%%% Currently not used
factor = 0.2;               % This factor is used to calculate the probability that two identical stimuli are displayed in the same array

noStimuli = length(parametersParadigm.stimulusArray);

wmLoadLevelVector = parametersParadigm.wmLoadLevelVector;


for c = 1:length(wmLoadLevelVector)
    %    conditionCounter = conditionCounter + 1;
    conditionSpecification{c} = sprintf('%WM_Load_%i', wmLoadLevelVector(c));
end
nConditions = length(conditionSpecification);

%%% Calculate the maximum number of stimulus duplicates presented in an
%%% array
maxWmLoad = max(wmLoadLevelVector);
if maxWmLoad >= noStimuli
    maxNoOfStimulusRepeats = maxWmLoad - (noStimuli - 1);
else
    maxNoOfStimulusRepeats = 1;
end


nTotalTrials = nTrialsPerCondition*nConditions;
nTrialsPerRun = nTotalTrials/nRuns;
nTrialsPerConditionPerRun = nTrialsPerRun/nConditions;

%%% The actual number of trials per condition per run are calculated.
nTrials = distributeTrialsAmongRunsATWM1_WM_CAP(nConditions, nRuns, nTrialsPerRun, nTrialsPerConditionPerRun);

%%% Define the proportion of nonmatch trials
nChangeTrials = floor(nTrialsPerCondition / 2);

trialSpecificationFile = sprintf('array%s_WM_CAP_%i_conds_%i_trials', iStudy, length(conditionSpecification), nTrialsPerCondition);
trialSpecificationFileFormat = '.txt';




%%% Parameters for imaginary circle used for position coordinates
circleParameters.radius = 120;
circleParameters.xCenter = 0;
circleParameters.yCenter = 0;

%%% The coordinates for each stimulus position on an imaginary cirlce are determined
for positionNo = 1:nPositions
    stimulusCoordinateArray{positionNo} = calculateStimulusPositionInArrayATWM1_WM_CAP(circleParameters, nPositions, positionNo);
end



%%% The probability for the repeated presentation of the same stimulus in
%%% an encoding array is calculated
for c = 1:nConditions
    wmLoad = wmLoadLevelVector(c);
    stimulusRepeatProbabilityArray{c} = calculateStimulusRepeatProbabilityATWM1_WM_CAP(noStimuli, wmLoad, factor, maxNoOfStimulusRepeats);
    %stimulusRepeatProbabilityArrayTEST = stimulusRepeatProbabilityArray{c}
end

%%% The number of stimulus repeats for each trial of each condition is
%%% calculated.
for c = 1:nConditions
    
    wmLoad = wmLoadLevelVector(c);
    stimulusRepeatProbability = stimulusRepeatProbabilityArray{c};
    stimulusRepeatIndexArray{c} = determineNrOfStimulusRepeatsATWM1_WM_CAP(stimulusRepeatProbability, nTrialsPerCondition, maxNoOfStimulusRepeats, wmLoad);
    
end


%%% The stimulus positions in the encoding array are randomly determined
for c = 1:nConditions
    wmLoad = wmLoadLevelVector(c);
    [encodingPositionsArray{c}] = determineEncodingPositionsATWM1_WM_CAP(wmLoad, nPositions, nTrialsPerCondition);
end
sprintf('stimulus positions determined')

%%% The jittered stimulus coordinates in the encoding array are determined
for c = 1:nConditions
    encodingstimulusCoordinateArray{c} = determineEncodingStimulusCoordinatesATWM1_WM_CAP(nPositions, nTrialsPerCondition, stimulusCoordinateArray);
end
sprintf('encoding stimulus coordinates determined')


%%% The encoding stimulus files are randomly determined
for c = 1:nConditions
    wmLoad = wmLoadLevelVector(c);
    stimulusRepeatIndex = stimulusRepeatIndexArray{c};
    [stimulusNameArray{c}] = determineStimulusNamesATWM1_WM_CAP(wmLoad, nTrialsPerCondition, parametersParadigm, stimulusRepeatIndex);
end
sprintf('encoding stimulus files determined')


%%% The encoding array is created
for c = 1:nConditions
    wmLoad = wmLoadLevelVector(c);
    encodingStimulusArray{c} = placeEncodingStimuliATWM1_WM_CAP(wmLoad, nPositions, nTrialsPerCondition, parametersParadigm, encodingPositionsArray{c}, stimulusNameArray{c});
end
sprintf('encoding arrays created')


%%% retrieval arrays are created
for c = 1:nConditions
    [retrievalStimulusArray{c}, changeSpecificationArray{c}] = placeRetrievalStimuliATWM1_WM_CAP(nTrialsPerCondition, nChangeTrials, parametersParadigm, encodingPositionsArray{c}, encodingStimulusArray{c}, changeSpecificationIndex);
end
sprintf('retrieval arrays created')

%%% randomize the trial order across conditions
trialIndex = randomizeTrialOrderATWM1_WM_CAP(nConditions, nRuns, nTrials, nTrialsPerRun);


%wmLoad = wmLoadLevelVector;

%%% write the trial specificiations
writeTrialSpecificationsATWM1_WM_CAP(filePath, trialSpecificationFile, trialSpecificationFileFormat, parametersParadigm, trialIndex, conditionSpecification, stimulusCoordinateArray, nPositions, nTrialsPerCondition, nConditions, nRuns, nTotalTrials, nTrialsPerRun, nTrialsPerConditionPerRun, encodingStimulusArray, retrievalStimulusArray, changeSpecificationArray, wmLoadLevelVector)

end




function [stimulusNameArray] = determineStimulusNamesATWM1_WM_CAP(wmLoad, nTrialsPerCondition, parametersParadigm, stimulusRepeatIndex);
%%% (c) Robert Bittner
%%% Study: ATWM1_WM_CAP
%%% This function randomly selects the stimuli for the encoding array


for t = 1:nTrialsPerCondition
    
    nrOfStimulusRepeats = stimulusRepeatIndex(t);
    
    stimulusNameArrayIndex = randperm(numel(parametersParadigm.stimulusArray));
    stimulusNameArrayIndex = stimulusNameArrayIndex(1:wmLoad - nrOfStimulusRepeats);
    
    %%% Randomly determine, which stimuli will be shown at least twice in
    %%% the current array
    repeatIndex = randperm(numel(stimulusNameArrayIndex));
    repeatIndex = repeatIndex(1:nrOfStimulusRepeats);
    
    indexRepeatedStimuli = stimulusNameArrayIndex(repeatIndex);
    
    
    completeStimulusNameArrayIndex{t} = [stimulusNameArrayIndex, indexRepeatedStimuli];
    
    for cl = 1:wmLoad
        stimulusNameArray{t}{cl} = parametersParadigm.stimulusArray{completeStimulusNameArrayIndex{t}(cl)};
    end
end

end




function trialIndex = randomizeTrialOrderATWM1_WM_CAP(nConditions, nRuns, nTrials, nTrialsPerRun);

conditionCounter(1:nConditions) = 0;
trialCounter = 0;
for r = 1:nRuns
    orderedTrialIndex = [];
    for c = 1:nConditions
        indexCondition = [];
        indexCondition(1:nTrials{c}(r)) = c;
        orderedTrialIndex = [orderedTrialIndex, indexCondition];
    end
    completeTrialIndex{r} = orderedTrialIndex;
    randomizationIndex = randperm(nTrialsPerRun);
    randomizedTrialIndex{r} = completeTrialIndex{r}(randomizationIndex);
    
    for t = 1:nTrialsPerRun
        trialCounter = trialCounter + 1;
        cond = randomizedTrialIndex{r}(t);
        conditionCounter(cond) = conditionCounter(cond) + 1;
        
        %%% Write trial index
        trialIndex.trialCounter{r}{t} = trialCounter;
        trialIndex.conditionIndex{r}{t} = randomizedTrialIndex{r}(t);
        trialIndex.conditionCounter{r}{t} = conditionCounter(cond);
    end
end


end




function [retrievalStimulusArray, changeSpecificationArray] = placeRetrievalStimuliATWM1_WM_CAP(nTrialsPerCondition, nChangeTrials, parametersParadigm, encodingPositionsArray, encodingStimulusArray, changeSpecificationIndex);
%%% (c) Robert Bittner
%%% Study: ATWM1
%%% This function creates the retrieval arrays, randomly determining the
%%% nonmatch trials and randomly selecting the changed target stimulus


%%% Determine randomly the trial index for the nonmatch trials
%nTrialsPerCondition = nTrialsPerCondition
%nChangeTrials = nChangeTrials

changeIndexVector = randperm(nTrialsPerCondition);
changeIndexVector = sort(changeIndexVector(1:nChangeTrials));

%changeIndexVector = sort(randsample(nTrialsPerCondition, nChangeTrials));


%%% Create retrieval arrays
for t = 1:nTrialsPerCondition
    positions = encodingPositionsArray{t};
    stimulusPositionVector = find(positions == 1);
    emptyPositionVector = find(positions == 0);
    
    %%% Create retrieval arrays for the match condition
    unchangedRetrievalStimulusArray{t} = encodingStimulusArray{t};
    

    targetStimuli = sort(encodingStimulusArray{t}(stimulusPositionVector));
    
    
    retrievalStimulusIndex = 1:length(parametersParadigm.stimulusArray);
    for s = 1:length(stimulusPositionVector)
        ind = strmatch(targetStimuli{s}, parametersParadigm.stimulusArray);
        retrievalStimulusIndex(ind) = 0;
    end
    
    %%% create vector indicating stimuli not present in the encoding
    %%% array
    retrievalStimulusIndex = nonzeros(retrievalStimulusIndex)';
    if length(retrievalStimulusIndex) > 1
        %retrievalStimulusIndex = retrievalStimulusIndex
        %retrievalStimulusIndex = retrievalStimulusIndex(randi(numel(retrievalStimulusIndex)))
        %index = randi(numel(retrievalStimulusIndex))
        %nonMatchStimulusIndex(t) = randsample(retrievalStimulusIndex, 1);
        randomIndex = randi(numel(retrievalStimulusIndex));
        nonMatchStimulusIndex(t) = retrievalStimulusIndex(randomIndex);
    else
        nonMatchStimulusIndex(t) = retrievalStimulusIndex;
    end
    
    nonMatchStimulus{t} = parametersParadigm.stimulusArray{nonMatchStimulusIndex(t)};
    
    
    changedRetrievalStimulusArray{t} = unchangedRetrievalStimulusArray{t};
    retrievalArray = changedRetrievalStimulusArray{t};
    %if length(parametersParadigm.stimulusArray) - length(retrievalStimulusIndex) > 1
    %stimulusPositionVector = stimulusPositionVector
    %randomIndex = randi(numel(stimulusPositionVector))
    selectedChangedStimulusPosition{t} = stimulusPositionVector(randomIndex);
    %selectedChangedStimulusPosition{t} = randsample(stimulusPositionVector, 1);
    changedRetrievalStimulusArray{t}{selectedChangedStimulusPosition{t}} = nonMatchStimulus{t};
    %{
    else
        sprintf('ERROR')

        changedRetrievalStimulusArray{t}{selectedChangedStimulusPosition{t}} = nonMatchStimulus{t}
    end
    %}
    
    changedRetrievalStimulusArray{t}{selectedChangedStimulusPosition{t}} = nonMatchStimulus{t};
    
    %%% Create the retrieval arrays
    if ismember(t, changeIndexVector) == 1
        retrievalStimulusArray{t} = changedRetrievalStimulusArray{t};
        changeSpecificationArray{t} = changeSpecificationIndex.change;
    else
        retrievalStimulusArray{t} = unchangedRetrievalStimulusArray{t};
        changeSpecificationArray{t} = changeSpecificationIndex.nochange;
    end
end


end




function nTrials = distributeTrialsAmongRunsATWM1_WM_CAP(nConditions, nRuns, nTrialsPerRun, nTrialsPerConditionPerRun);

%%% The number of trials per run for each condition is calculated
if ceil(nTrialsPerConditionPerRun) == nTrialsPerConditionPerRun
    for c = 1:nConditions
        for r = 1:nRuns
            nTrials{c}(r) = nTrialsPerConditionPerRun;
        end
    end
else
    for c = 1:nConditions
        if c/2 == ceil(c/2)
            for r = 1:nRuns
                if r/2 == ceil(r/2)
                    nTrials{c}(r) = ceil(nTrialsPerConditionPerRun);
                else
                    nTrials{c}(r) = floor(nTrialsPerConditionPerRun);
                end
            end
        else
            for r = 1:nRuns
                if r/2 == ceil(r/2)
                    nTrials{c}(r) = floor(nTrialsPerConditionPerRun);
                else
                    nTrials{c}(r) = ceil(nTrialsPerConditionPerRun);
                end
            end
        end
    end
end

errorcounter = 0;
for r = 1:nRuns
    addedTrialsPerRun = 0;
    for c = 1:nConditions
        addedTrialsPerRun = addedTrialsPerRun + nTrials{c}(r);
    end
    if addedTrialsPerRun == nTrialsPerRun
        
    else
        errorcounter = errorcounter +1;
    end
    
end

if errorcounter > 0
    sprintf('Errors in %i runs', errorcounter)
    for c = 1:nConditions
        sprintf('condition %i', c)
        sprintf('%i\t', nTrials{c})
    end
    sprintf('Total trial number cannot be distributed among current number of runs');
end

end


function stimulusCoordinateArray = calculateStimulusPositionInArrayATWM1_WM_CAP(circleParameters, nPositions, positionNo);

theta = pi/nPositions + ((positionNo - 1)*((2*pi)/nPositions));

stimulusCoordinateArray.x = circleParameters.radius*cos(theta) + circleParameters.xCenter;
stimulusCoordinateArray.y = circleParameters.radius*sin(theta) + circleParameters.yCenter;

end


function stimulusRepeatProbabilityArray = calculateStimulusRepeatProbabilityATWM1_WM_CAP(noStimuli, wmLoad, factor, maxNoOfStimulusRepeats);
%%% Calculate the probability, that two identical stimuli will be displayed
%%% in the same array

if maxNoOfStimulusRepeats ~= 0
    for nRepetitions = 1:maxNoOfStimulusRepeats

        res = noStimuli - wmLoad + (nRepetitions + 1);
        %%{
        if res <= 2
            prob = 1;
        elseif res == 3
            prob = 0.5 * (2/3);
        elseif res == 4
            prob = 0.5 * (1/3);
        else
            prob = 0;
        end
        %}
        stimulusRepeatProbabilityArray(nRepetitions) = prob;
    end
end

end



function stimulusRepeatIndexArray = determineNrOfStimulusRepeatsATWM1_WM_CAP(stimulusRepeatProbability, nTrialsPerCondition, maxNoOfStimulusRepeats, wmLoad);


stimulusRepeatIndexArray(1:nTrialsPerCondition) = 0;
nTotalRepetitionTrials = 0;
for nRepetitions = 1:maxNoOfStimulusRepeats
    nStimulusRepeatTrials(nRepetitions) = floor(nTrialsPerCondition * stimulusRepeatProbability(nRepetitions));
end
for nRepetitions = 1:maxNoOfStimulusRepeats
    if sum(nStimulusRepeatTrials) < wmLoad
        nTotalRepetitionTrials = nTotalRepetitionTrials + nStimulusRepeatTrials(nRepetitions);
        if nRepetitions == 1
            iFirstTrial = 1;
        else
            iFirstTrial = nTotalRepetitionTrials;
        end
        iLastTrial = iFirstTrial + nStimulusRepeatTrials(nRepetitions) - 1;
        stimulusRepeatIndexArray(iFirstTrial:iLastTrial) = nRepetitions;
    else
        nTotalRepetitionTrials = nTotalRepetitionTrials + nStimulusRepeatTrials(nRepetitions);
        iFirstTrial = 1;
        iLastTrial = nStimulusRepeatTrials(nRepetitions);
        stimulusRepeatIndexArray(iFirstTrial:iLastTrial) = nRepetitions;
    end
end

randomizationIndex = randperm(nTrialsPerCondition);
stimulusRepeatIndexArray = stimulusRepeatIndexArray(randomizationIndex);

%%% This is only used for checking
%stimulusRepeatIndexArrayTEST = stimulusRepeatIndexArray
end




function [encodingPositionsArray] = determineEncodingPositionsATWM1_WM_CAP(wmLoad, nPositions, nTrialsPerCondition);
%%% (c) Robert Bittner
%%% Study: ATWM1_WMC_CAP
%%% This function randomly determines the positions of the stimlui shown
%%% during endoding.




%%{
%%% The number of trials containing each position is calculated and written
%%% in the vector "positionTokenVector"
if nPositions > (nTrialsPerCondition * wmLoad)
    positionTokenVector(1:nPositions) = 1;
else
    positionTokenVector(1:nPositions) = floor((nTrialsPerCondition * wmLoad) / nPositions);
    remainingPositionTokens = nTrialsPerCondition * wmLoad - sum(positionTokenVector);
    for r = 1:remainingPositionTokens
        counter = 0;
        while counter < 1
            %randomSlot = randsample(1:nPositions, 1);
            randomSlot = randi(nPositions);
            if positionTokenVector(randomSlot) == floor((nTrialsPerCondition * wmLoad) / nPositions)
                counter = counter + 1;
                positionTokenVector(randomSlot) = positionTokenVector(randomSlot) + 1;
            end
        end
    end
end
%}


for t = 1:nTrialsPerCondition
    
    
    %%% Create emtpy vector for the positions
    positionVector = zeros(1, nPositions);
    selectedPosition = [];
    for l = 1:wmLoad
        counter = 0;
        while counter == 0
            index = find(positionTokenVector == max(positionTokenVector));              % Determine the position(s), which has been selected most infrequently
            randomPosition = index(randi(length(index)));                               % Select at random one of theses positions
            if ismember(randomPosition, selectedPosition) == 0
                counter = 1;
            end
        end                                 %
        selectedPosition(l) = randomPosition;
        positionTokenVector(randomPosition) = positionTokenVector(randomPosition) - 1;  % Adjust the variable 'positionTokenVector' accordingly
        positionVector(randomPosition) = 1;                                             % Mark the selected position
        
    end
    

    encodingPositionsArray{t} = positionVector;
end


end



function encodingStimulusCoordinatesArray = determineEncodingStimulusCoordinatesATWM1_WM_CAP(nPositions, nTrialsPerCondition, stimulusCoordinatesArray);
%%% (c) Robert Bittner
%%% Study: ATWM1_WMC_CAP
%%% This function determines the coordinates for each stimlus shown
%%% during endoding

for t = 1:nTrialsPerCondition
    for pos = 1:nPositions
        encodingStimulusCoordinatesArray{t}{pos} = stimulusCoordinatesArray{pos};
    end
end


end





function encodingStimulusArray = placeEncodingStimuliATWM1_WM_CAP(wmLoad, nPositions, nTrialsPerCondition, stimulusSpecifications, encodingPositionsArray, stimulusNameArray);
%%% (c) Robert Bittner
%%% Study: ATWM1_WM_CAP
%%% This function places the target and blank encoding stimuli on the
%%% respective positions

%%% The position information is loaded
for t = 1:nTrialsPerCondition
    selectedPositions = find(encodingPositionsArray{t} == 1);
    emptyPositions = find(encodingPositionsArray{t} == 0);
    
    %%% The target stimuli are placed on the target positions
    for stim = 1:length(selectedPositions)
        encodingStimulusArray{t}{selectedPositions(stim)} = stimulusNameArray{t}{stim};
    end
    
    %%% The blank stimuli are placed on the remaining positions
    for empty = 1:length(emptyPositions)
        encodingStimulusArray{t}{emptyPositions(empty)} = sprintf('%s', stimulusSpecifications.blank);
    end
    
end


end





function writeTrialSpecificationsATWM1_WM_CAP(filePath, trialSpecificationFile, trialSpecificationFileFormat, parametersParadigm, trialIndex, conditionSpecification, stimulusCoordinateArray, nPositions, nTrialsPerCondition, nConditions, nRuns, nTotalTrials, nTrialsPerRun, nTrialsPerConditionPerRun, encodingStimulusArray, retrievalStimulusArray, changeSpecificationArray, wmLoadLevelVector)


%%{
intertrialInterval = parametersParadigm.intertrialInterval;% = 3000;
alertTime = parametersParadigm.alertTime;
preparationTime = parametersParadigm.preparationTime;% = 500;
encodingTime = parametersParadigm.encodingTime;% = 100;
delayInterval = parametersParadigm.delayInterval;% = 2000 - parametersParadigm.encodingTime;                  %%% This is the total delay interval, including ISI/SOA and mask intervals
%maskPresentationTime = parametersParadigm.maskPresentationTime;% = 500;
retrievalTime = parametersParadigm.retrievalTime;
%}


for r = 1:nRuns
    trialSpecificationFileName = sprintf('%s_s%i%s', trialSpecificationFile, r, trialSpecificationFileFormat);
    fid = fopen([filePath, trialSpecificationFileName], 'wt');

    for t = 1:nTrialsPerRun
        %%% Determine the trial number
        trialCounter = trialIndex.trialCounter{r}{t};
        
        %%% Determine the condition index of the current trial
        conditionIndex = trialIndex.conditionIndex{r}{t};
        
        %%% Determine the condition counter of the current condition
        conditionCounter = trialIndex.conditionCounter{r}{t};
        
        %%% Determine the inter trial interval
        %intertrialInterval = randomizedTimeIntervals.intertrialInterval{r}{t};
        %intertrialInterval = 3000; %randomizedTimeIntervals.intertrialInterval{r}{t};
        
        %%% Determine the interstimulus interval
        %interstimulusInterval = str2num(conditionSpecification{conditionIndex}((strfind(conditionSpecification{conditionIndex}, '_')) + 1:length(conditionSpecification{conditionIndex})));
        
        %%% Determine the delay interval
        %                delayInterval = randomizedTimeIntervals.totalDelayInterval{r}{t};%totalDelayInterval{1}{r}{t} - interstimulusInterval - maskPresentationTime;
        %delayInterval = randomizedTimeIntervals.totalDelayInterval{r}{t} - interstimulusInterval - maskPresentationTime;
        %delayInterval = delayInterval;
        
        %%% Determine, whether current trial is a change or nochange trial
        %conditionIndex = conditionIndex
        %conditionCounter = conditionCounter
        %arraySize = size(changeSpecificationArray)
        changeIndex = changeSpecificationArray{conditionIndex}{conditionCounter};
        
        %%% Create encoding code
        %                encodingCode = sprintf('"%i_Load_%i_%s_%s_%i_%i_%i_%i_%i"', trialCounter, wmLoad(conditionIndex), conditionSpecification{conditionIndex}, changeIndex, intertrialInterval, preparationTime, encodingTime, interstimulusInterval, delayInterval);
        encodingCode = sprintf('"%i_Load_%i_%s"', trialCounter, wmLoadLevelVector(conditionIndex), changeIndex);
        %{
                typicalLengthEncodingCode = 19;
                lengthEncodingCode = length(encodingCode);
                tabLength = 3;
                deviationFromTypicalLengthEncodingCode = lengthEncodingCode - (typicalLengthEncodingCode * tabLength);
                blankSpaces  = '';
                if deviationFromTypicalLengthEncodingCode < 0
                    for i = 1:abs(deviationFromTypicalLengthEncodingCode)
                        blankSpaces = sprintf('%s', [' ', blankSpaces]);
                    end
                    blankSpaces = sprintf('%s   ', blankSpaces);
                elseif deviationFromTypicalLengthEncodingCode == 0
                    blankSpaces = s printf('   ');
                else
                    for i = 1:(tabLength - abs(deviationFromTypicalLengthEncodingCode))
                        blankSpaces = sprintf('%s', [' ', blankSpaces]);
                    end
                end
                encodingCode = [encodingCode, sprintf('%s', blankSpaces)];
        %}
        %%% Create retrieval code
        retrievalCode = sprintf('"%i_%s"', trialCounter, changeIndex);
        
        
        %%% Write MR-Trigger
        %fprintf(fid,'%3i\t', mrTrigger{r}{t})
        
        %%% Write the timing parameters
        fprintf(fid, '%i %i %i %i %i %i\t\t', intertrialInterval, alertTime, preparationTime, encodingTime, delayInterval, retrievalTime);
        
        %%% Write the alerting cross
        fprintf(fid, '%s ', parametersParadigm.alertingCross);
        fprintf(fid, '\t');
        
        %%% Write the encoding array
        for p = 1:nPositions
            fprintf(fid, '%s ', encodingStimulusArray{conditionIndex}{conditionCounter}{p});
        end
        fprintf(fid, '\t');
        
        %%% Write encoding code
        fprintf(fid, '%s', encodingCode);
        fprintf(fid, '\t');
        
        %%% Write the retrieval array
        for p = 1:nPositions
            fprintf(fid, '%s ', retrievalStimulusArray{conditionIndex}{conditionCounter}{p});
        end
        fprintf(fid, '\t');
        
        %{
                %%% Write the cueing array
                for p = 1:nPositions
                    fprintf(fid, '%s ', cueingStimulusArray{conditionIndex}{col}{conditionCounter}{p});
                end
                fprintf(fid, '\t');
        %}
        
        %{
                %%% Write the mask array
                for p = 1:nPositions
                    fprintf(fid, '%s ', maskingStimulusArray{conditionIndex}{col}{conditionCounter}{p});
                end
                fprintf(fid, '\t');
        %}
        
        %%% Write retrieval code
        fprintf(fid, '%s', retrievalCode);
        fprintf(fid, '\t');
        
        %%% Write the stimulus coordinates
        for p = 1:nPositions
            fprintf(fid, ' %.2f', stimulusCoordinateArray{p}.x);
            fprintf(fid, ' %.2f', stimulusCoordinateArray{p}.y);
            %fprintf(fid, ' %.2f', stimulusCoordinateArray{p}(1));
            %fprintf(fid, ' %.2f', stimulusCoordinateArray{p}(2));
        end
        
        %%% Write the end of the line and switch to the next line
        fprintf(fid, ';\n');
    end
    
    fclose(fid);
end

end


