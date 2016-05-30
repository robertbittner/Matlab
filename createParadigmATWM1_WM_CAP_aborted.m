function createParadigmATWM1_WM_CAP ();
%%% (c) Robert Bittner
%%% Study: ATWM1
%%% Paradigm: Working memory capacity
%%% This function creates the trials in presentation format.

clc
clear all

filePath = 'D:\Daten\ATWM1\';

%parametersParadigm = parametersParadigmATWM1_WM_CAP;

parametersParadigm = parametersParadigmATWM1_WM_CAP

changeSpecificationIndex.nochange = 'NoChange';
changeSpecificationIndex.change = 'Change';


encodingTime = 100;
intertrialInterval = 3000;
preparationTime = 500;
totalDelayIntervall = 2000 - encodingTime;                  %%% This is the total delay intervall, including ISI/SOA and mask intervals
maskPresentationTime = 500;

nTrialsPerCondition = 4;
nRuns = 1;


nPositions = 12;


factor = 0.2;               % used to calculate the probability for repeated stimuli to occur in an array
noStimuli = length(parametersParadigm.stimulusArray);

%wmLoadLevelVector = [1, 2, 3, 4, 5, 6, 7, 8];
wmLoadLevelVector = [2, 4, 6, 8];
%wmLoadLevelVector = [4];


for c = 1:length(wmLoadLevelVector)
    %    conditionCounter = conditionCounter + 1;
    conditionSpecification{c} = sprintf('%WM_Load_%i', wmLoadLevelVector(c));
end
nConditions = length(conditionSpecification);


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

trialSpecificationFile = sprintf('array_ATWM1_WM_CAP_%i_conds_%i_trials', length(conditionSpecification), nTrialsPerCondition);
trialSpecificationFileFormat = '.txt';



%%{
%%% Parameters for imaginary circle used for position coordinates
circleParameters.radius = 120;
circleParameters.xCenter = 0;
circleParameters.yCenter = 0;

%%% The coordinates for each stimulus position on an imaginary cirlce are determined
for positionNo = 1:nPositions
    stimulusCoordinateArray{positionNo} = calculateStimulusPositionInArrayATMWM_WM_CAP(circleParameters, nPositions, positionNo);
end

%conditionCounter = 0;
%for m = 1:length(maskType)

%end

%%% The probability for the repeated presentation of the same stimulus in
%%% an encoding array is calculated
for c = 1:nConditions
    wmLoad = wmLoadLevelVector(c);
    stimulusRepeatProbabilityArray{c} = calculateStimulusRepeatProbabilityATWM1_WM_CAP(noStimuli, wmLoad, factor, maxNoOfStimulusRepeats);
    
end

%%% The number of stimulus repeats for each trial of each condition is
%%% calculated.
for c = 1:nConditions
    
    wmLoad = wmLoadLevelVector(c);
    %    displayWmLoad = wmLoad
    stimulusRepeatProbability = stimulusRepeatProbabilityArray{c};
    stimulusRepeatIndexArray{c} = determineNoOfStimulusRepeatsATWM1_WM_CAP(stimulusRepeatProbability, nTrialsPerCondition, maxNoOfStimulusRepeats);
end

%{
if noGaps == 1
    nGapTrialsAllowed = ceil(nTrialsPerCondition / 2);
elseif noGaps == 0
    nGapTrialsAllowed = nTrialsPerCondition;
end
%}




%%% The stimulus positions in the encoding array are randomly determined
for c = 1:nConditions
    wmLoad = wmLoadLevelVector(c);
    %    counter = 0;
    %    while counter == 0
    [encodingPositionsArray{c}] = determineEncodingPositionsATWM1_WM_CAP(wmLoad, nPositions, nTrialsPerCondition);
    %        if sum(encodingPositionsArray{c}{nTrialsPerCondition}) == 0
    %
    %        elseif nGapTrials{c} ~= nGapTrialsAllowed
    %
    %        else
    %            counter = 1;
    %        end
    %        %counter = 1;
    %    end
end
sprintf('stimulus positions determined')

%%% The jittered stimulus coordinates in the encoding array are determined
for c = 1:nConditions
    encodingstimulusCoordinateArray{c} = determineEncodingStimulusCoordinatesATWM1_WM_CAP(nPositions, nTrialsPerCondition, stimulusCoordinateArray);
end
sprintf('encoding stimulus coordinates determined')

%{
%%% The mask positions in the mask array are randomly determined
for c = 1:nConditions
    counter = 0;
    while counter == 0
        maskPositionsArray{c} = determineMaskPositions(wmLoad, nPositions, nTrialsPerCondition, nConditions, encodingPositionsArray{c});
        if sum(maskPositionsArray{c}{nTrialsPerCondition}) == 0

        else
            counter = 1;
        end
        counter = 1;
    end
end
sprintf('mask positions determined')
%}


%%% The encoding stimulus files are randomly determined
for c = 1:nConditions
    wmLoad = wmLoadLevelVector(c);
    stimulusRepeatIndex = stimulusRepeatIndexArray{c};
    %counter = 0;
    %while counter == 0
    [stimulusNameArray{c}, averageStimulusFrequency] = determineStimulusNamesATWM1_WM_CAP(wmLoad, nTrialsPerCondition, parametersParadigm, stimulusRepeatIndex);
    %    counter = 1;
    %    if strcmp(stimulusNameArray{c}.targetStimuli{1}{nTrialsPerCondition}{wmLoad}(1:3), parametersParadigm.stimulusShape) ~= 1 %'bar'
    %
    %        else
    %            counter = 1;
    %        end
    %counter = 1;
    %    end
end
sprintf('encoding stimulus files determined')

%{
%%% The mask names are randomly determined
for c = 1:nConditions
    maskNameArray{c} = determineMaskNames(wmLoad, nTrialsPerCondition, parametersParadigm);
end

%%% The cueing array is created
for c = 1:nConditions
    cueingStimulusArray{c} = placeCueingStimuli(nTrialsPerCondition, parametersParadigm, encodingPositionsArray{c});
end
%}

%%% The encoding array is created
for c = 1:nConditions
    wmLoad = wmLoadLevelVector(c);
    %    counter = 0;
    %    while counter == 0
    encodingStimulusArray{c} = placeEncodingStimuliATWM1_WM_CAP(wmLoad, nPositions, nTrialsPerCondition, averageStimulusFrequency, parametersParadigm, encodingPositionsArray{c}, stimulusNameArray{c});
    %{
        if strcmp(encodingStimulusArray{c}{1}{nTrialsPerCondition}{nPositions}(1:3), parametersParadigm.stimulusShape) ~= 1

        else
            counter = 1;
        end
        %%{
        counter = 1;
        %%}
    end
    %}
end
sprintf('encoding arrays created')

%{
%%% The mask arrays are created
for c = 1:nConditions
    maskingStimulusArray{c} = placeMaskingStimuli(nTrialsPerCondition, parametersParadigm, encodingPositionsArray{c}, maskPositionsArray{c}, maskNameArray{c});
end
%}

%%% retrieval arrays are created
for c = 1:nConditions
    [retrievalStimulusArray{c}, changeSpecificationArray{c}] = placeRetrievalStimuliATWM1_WM_CAP(nTrialsPerCondition, nChangeTrials, parametersParadigm, encodingPositionsArray{c}, encodingStimulusArray{c}, changeSpecificationIndex);
end
sprintf('retrieval arrays created')
%}

%%{

%%% randomize the trial order across conditions
trialIndex = randomizeTrialOrderATWM1_WM_CAP(nConditions, nRuns, nTrials, nTrialsPerRun);


wmLoad = wmLoadLevelVector;

%%% write the trial specificiations
writeTrialSpecificationsATWM1_WM_CAP(filePath, trialSpecificationFile, trialSpecificationFileFormat, parametersParadigm, trialIndex, conditionSpecification, stimulusCoordinateArray, nPositions, nTrialsPerCondition, nConditions, nRuns, nTotalTrials, nTrialsPerRun, nTrialsPerConditionPerRun, encodingStimulusArray, retrievalStimulusArray, changeSpecificationArray, intertrialInterval, preparationTime, encodingTime, totalDelayIntervall, maskPresentationTime, wmLoad)
%}
end

%}




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


function stimulusCoordinateArray = calculateStimulusPositionInArrayATMWM_WM_CAP(circleParameters, nPositions, positionNo);

theta = pi/nPositions + ((positionNo - 1)*((2*pi)/nPositions));

stimulusCoordinateArray.x = circleParameters.radius*cos(theta) + circleParameters.xCenter;
stimulusCoordinateArray.y = circleParameters.radius*sin(theta) + circleParameters.yCenter;

end


function stimulusRepeatProbabilityArray = calculateStimulusRepeatProbabilityATWM1_WM_CAP(noStimuli, wmLoad, factor, maxNoOfStimulusRepeats);
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

end


function stimulusRepeatIndexArray = determineNoOfStimulusRepeatsATWM1_WM_CAP(stimulusRepeatProbability, nTrialsPerCondition, maxNoOfStimulusRepeats);

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




function [encodingPositionsArray] = determineEncodingPositionsATWM1_WM_CAP(wmLoad, nPositions, nTrialsPerCondition);
%%% (c) Robert Bittner
%%% Study: WMC2_WMC_CAP
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
            randomSlot = randi(nPositions);
            %randomSlot = randsample(1:nPositions, 1);
            if positionTokenVector(randomSlot) == floor((nTrialsPerCondition * wmLoad) / nPositions)
                counter = counter + 1;
                positionTokenVector(randomSlot) = positionTokenVector(randomSlot) + 1;
            end
        end
    end
end
%}

%trialCounter = 0;
for t = 1:nTrialsPerCondition
    
    %{
    %%% Abort function if no solution can be found, create empty arrays
    if trialCounter > 1000
        for i = 1:nTrialsPerCondition
            encodingPositionsArray{i} = zeros(1, nPositions);
            gapIndexArray{i} = zeros(1, wmLoad);
        end
        break
    end
    %}
    %{
    counter = 0;
    gapCounter = 0;
    %}
    %while counter == 0
    %   trialCounter = trialCounter + 1;
    %   counter = 0;
    %  gapCounter = 0;
    
    
    %{
    %}
    
    %%% Create emtpy vector for the positions
    positionVector = zeros(1, nPositions);
    %draw(1:nPositions) = 1;
    %        if noGaps == 1
    selectedPosition = [];
    for l = 1:wmLoad
        counter = 0;
        while counter == 0
            index = find(positionTokenVector == max(positionTokenVector));                  % Determine the position(s), which has been selected most infrequently
            
            %randomPosition = index(randsample(length(index), 1));                           % Select at random one of theses positions
            %etstse = randi(numel(index))
            %test = randsample(length(index), 1)
            %randomPosition = index(randsample(length(index), 1));                           % Select at random one of theses positions
            randomPosition = index(randi(numel(index)));                                    % Select at random one of theses positions
            if ismember(randomPosition, selectedPosition) == 0
                counter = 1;
            end
        end                                 %
        selectedPosition(l) = randomPosition;
        positionTokenVector(randomPosition) = positionTokenVector(randomPosition) - 1;  % Adjust the variable 'positionTokenVector' accordingly
        positionVector(randomPosition) = 1;                                             % Mark the selected position
        
    end
    
    %{
        elseif noGaps == 0
            for l = 1:wmLoad
                if l == 1
                    index = find(positionTokenVector == max(positionTokenVector));                   % Determine the position(s), which has been selected most infrequently
                    randomPosition = index(randsample(length(index), 1));                            % Select at random one of theses positions
                    positionTokenVector(randomPosition) = positionTokenVector(randomPosition) - 1;   % Adjust the variable 'positionTokenVector' accordingly
                    positionVector(randomPosition) = 1;                                              % Mark the selected position
                    selectedPosition(l) = randomPosition;
                                      
                    %%% Determine the positions eligible as the position
                    %%% for the next stimulus
                    if randomPosition == nPositions
                        eligiblePositionVector(1) = 2;
                    elseif randomPosition == nPositions - 1
                        eligiblePositionVector(1) = 1;
                    else
                        eligiblePositionVector(1) = randomPosition + 2;
                    end
                    
                    if randomPosition == 1
                        eligiblePositionVector(2) = nPositions - 1;
                    elseif randomPosition == 2
                        eligiblePositionVector(2) = nPositions;
                    else
                        eligiblePositionVector(2) = randomPosition - 2;
                    end
                    
                    if positionVector(eligiblePositionVector(2)) == 1
                        eligiblePositionVector(2) = [];
                    end
                    if positionVector(eligiblePositionVector(1)) == 1
                        eligiblePositionVector(1) = [];
                    end
                    
                elseif l > 1
                    index = eligiblePositionVector(find(positionTokenVector(eligiblePositionVector) == max(positionTokenVector(eligiblePositionVector))));  % Determine the position(s), which has been selected most infrequently
                    
                    randomPosition = index(randsample(length(index), 1));                                       % Select at random one of theses positions
                    positionTokenVector(randomPosition) = positionTokenVector(randomPosition) - 1;              % Adjust the variable 'positionTokenVector' accordingly
                    positionVector(randomPosition) = 1;                                                         % Mark the selected position
                    selectedPosition(l) = randomPosition;
                    
                    %%% Determine the positions eligible as the position
                    %%% for the next stimulus
                    if randomPosition == nPositions
                        eligiblePositionVector(1) = 2;
                    elseif randomPosition == nPositions - 1
                        eligiblePositionVector(1) = 1;
                    else
                        eligiblePositionVector(1) = randomPosition + 2;
                    end
                    
                    if randomPosition == 1
                        eligiblePositionVector(2) = nPositions - 1;
                    elseif randomPosition == 2
                        eligiblePositionVector(2) = nPositions;
                    else
                        eligiblePositionVector(2) = randomPosition - 2;
                    end
            
                    if positionVector(eligiblePositionVector(2)) == 1
                        eligiblePositionVector(2) = [];
                    end
                    if positionVector(eligiblePositionVector(1)) == 1
                        eligiblePositionVector(1) = [];
                    end
                end
            end
        end
        
        %%% Test whether there is a gap betweeen position 1 and position 2
        if abs(selectedPosition(1) - selectedPosition(2)) < 2
            gapCounter = gapCounter + 1;
            gapIndex(1) = 0;
        elseif abs(selectedPosition(1) - selectedPosition(2)) == 7
            gapCounter = gapCounter + 1;
            gapIndex(1) = 0;
        else
            gapIndex(1) = 1;
        end

        %%% Test whether there is a gap betweeen position 2 and position 3
        if abs(selectedPosition(2) - selectedPosition(3)) < 2
            gapCounter = gapCounter + 1;
            gapIndex(2) = 0;
        elseif abs(selectedPosition(2) - selectedPosition(3)) == 7
            gapCounter = gapCounter + 1;
            gapIndex(2) = 0;
        else
            gapIndex(2) = 1;
        end

        %%% Test whether there is a gap betweeen position 1 and position 3
        if abs(selectedPosition(1) - selectedPosition(3)) < 2
            gapCounter = gapCounter + 1;
            gapIndex(3) = 0;
        elseif abs(selectedPosition(1) - selectedPosition(3)) == 7
            gapCounter = gapCounter + 1;
            gapIndex(3) = 0;
        else
            gapIndex(3) = 1;
        end

        %%% Generate final gapIndex
        gapIndex = floor(sum(gapIndex)/wmLoad);

        %%% Evaluate, whether three adjacent positions have been selected
        %%% and if so, repeat the while loop
        if gapCounter >= 2
            for l = 1:wmLoad
                positionTokenVector(selectedPosition(l)) = positionTokenVector(selectedPosition(l)) + 1;
            end
            
        %%% Test, whether three different positions have been selected
        elseif sum(positionVector) ~= wmLoad
            for l = 1:wmLoad
                positionTokenVector(selectedPosition(l)) = positionTokenVector(selectedPosition(l)) + 1;
            end

        %%% Set counter to 1 to break the while loop and move on to the next trial
        else
            counter = 1;
            for l = 1:wmLoad
                positionVector(selectedPosition(l)) = 1;
            end
        end

        %%% Abort function if no solution can be found
        if trialCounter > 1000
            for i = 1:nTrialsPerCondition
                encodingPositionsArray{i} = zeros(1, nPositions);
                gapIndexArray{i} = zeros(1, wmLoad);
            end
            break
        end
    end
    %}
    encodingPositionsArray{t} = positionVector;
    %test = encodingPositionsArray{t}
    %gapIndexArray{t} = gapIndex;
end


%{
%%% Count the number of gap trials
nGapTrials = 0;
for i = 1:nTrialsPerCondition
    if gapIndexArray{i} == 1
        nGapTrials = nGapTrials + 1;
    end
end
%}
%}

%encodingPositionsArray = 0;

end


function encodingStimulusCoordinatesArray = determineEncodingStimulusCoordinatesATWM1_WM_CAP(nPositions, nTrialsPerCondition, stimulusCoordinatesArray);
%%% (c) Robert Bittner
%%% Study: WMC2_WMC_CAP
%%% This function determines the coordinates for each stimlus shown
%%% during endoding

for t = 1:nTrialsPerCondition
    for pos = 1:nPositions
        encodingStimulusCoordinatesArray{t}{pos} = stimulusCoordinatesArray{pos};
    end
end


end



function [stimulusNameArray, averageStimulusFrequency] = determineStimulusNamesATWM1_WM_CAP(wmLoad, nTrialsPerCondition, parametersParadigm, stimulusRepeatIndex);
%%% (c) Robert Bittner
%%% Study: ATWM1_WM_CAP
%%% This function randomly determines the name of the encoding stimuli

%trialCounter = 0;
%for col = 1:length(parametersParadigm.stimulusColorArray)

%{
    %%% The target color is determined
    stimulusArrayTarget = parametersParadigm.stimulusArray{parametersParadigm.targetColorIndex(col)};
    stimulusArrayDistractor = parametersParadigm.stimulusArray{parametersParadigm.distractorColorIndex(col)};
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
    %            stimulusNameArrayIndex{t} = randsample(length(parametersParadigm.stimulusArray), wmLoad);
    %            for l = 1:wmLoad
    %                stimulusNameArray{t}{l} = parametersParadigm.stimulusArray{stimulusNameArrayIndex{t}(l)};
    %            end
    
    
    %%% The target stimuli are drawn at random with or without
    %%% replacement, depending on the noOfStimulusRepeats variable.
    %            noOfStimulusRepeats = stimulusRepeatIndexArray;
    noOfStimulusRepeats = stimulusRepeatIndex(t);
    
    %load = wmLoad
    %rep = noOfStimulusRepeats
    
    if wmLoad <= noOfStimulusRepeats + 1
        stimulusNameArrayIndex{t} = randsample(length(parametersParadigm.stimulusArray), wmLoad);
        for l = 1:wmLoad
            stimulusNameArray{t}{l} = parametersParadigm.stimulusArray{stimulusNameArrayIndex{t}(l)};
        end
        stimulusNameArray{t}{l} = parametersParadigm.stimulusArray{stimulusNameArrayIndex{t}(l)};
    else
        %test = (randi(numel(parametersParadigm.stimulusArray), (wmLoad - noOfStimulusRepeats), 1))'
        %testmin = (wmLoad - noOfStimulusRepeats)
        stimulusNameArrayIndex{t} = randi(numel(parametersParadigm.stimulusArray), (wmLoad - noOfStimulusRepeats), 1)';
        
        %stimulusNameArrayIndex{t} = randsample(length(parametersParadigm.stimulusArray), (wmLoad - noOfStimulusRepeats));

        
        for l = 1:wmLoad - noOfStimulusRepeats
            stimulusNameArray{t}{l} = parametersParadigm.stimulusArray{stimulusNameArrayIndex{t}(l)};
        end
        
        %                if noOfStimulusRepeats == length(stimulusNameArrayIndex{t})
        %                    repeatIndex{t} = stimulusNameArrayIndex{t};
        %                else+
        %testel= numel(stimulusNameArrayIndex{t})
        %ets  = noOfStimulusRepeats
        %test = randi(numel(stimulusNameArrayIndex{t}), noOfStimulusRepeats)
        repeatIndex{t} = randi(numel(stimulusNameArrayIndex{t}), noOfStimulusRepeats);
        %repeatIndex{t} = randsample(length(stimulusNameArrayIndex{t}), noOfStimulusRepeats);
        repeatedStimulusIndex{t} = stimulusNameArrayIndex{t}(repeatIndex{t});
        %                end
        
        if noOfStimulusRepeats == 0
            %load = wmLoad
            stimulusNameArray{t} = stimulusNameArray{t}(randperm(wmLoad));
        else
            for r = 1:noOfStimulusRepeats
                repeatedStimulusArrayIndex{t}{r} = parametersParadigm.stimulusArray{repeatedStimulusIndex{t}(r)};
            end
            stimulusNameArray{t} = [stimulusNameArray{t}, repeatedStimulusArrayIndex{t}];
            stimulusNameArray{t} = stimulusNameArray{t}(randperm(wmLoad));
        end
    end
    
    %{
            %%% The distractor stimuli are drawn at random
            additionalDistractorIndex = randsample(length(stimulusArrayDistractor), nDistractors-length(stimulusArrayDistractor));
            stimulusNameArray.distractorIndex{t} = [randperm(length(stimulusArrayDistractor)), additionalDistractorIndex];
            for distr = 1:nDistractors
                stimulusNameArray.distractorStimuli{col}{t}{distr} = stimulusArrayDistractor{stimulusNameArray.distractorIndex{t}(distr)};
                %stimulusNameArray.distractorStimuli{col}{t}{distr} = sprintf('%s.bmp', parametersParadigm.blank);
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



function encodingStimulusArray = placeEncodingStimuliATWM1_WM_CAP(wmLoad, nPositions, nTrialsPerCondition, averageStimulusFrequency, parametersParadigm, encodingPositionsArray, stimulusNameArray);
%%% (c) Robert Bittner
%%% Study: ATWM1_WM_CAP
%%% This function places the target and distractor encoding stimuli on the
%%% respective positions

%{
maxNoAttempts = 1000;
trialCounter = 0; 
for col = 1:length(parametersParadigm.stimulusColorArray)    
    diffCounterMax = nPositions * length(parametersParadigm.stimulusArray{col});
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
                encodingStimulusArray{t}{emptyPositions(empty)} = sprintf('%s', parametersParadigm.blank);
            end
            %}
            %test = encodingStimulusArray{t}

        end

        %}
        
        %{
        %%% The frequency of each target stimulus at each location is counted
        averageStimulusFrequencyPerPosition = averageStimulusFrequency / nPositions;
        for s = 1:length(parametersParadigm.stimulusArray{col})
            
            stimulusFrequency = [];
            for p = 1:nPositions
                %%{
                stimulusFrequencyCounter = 0;
                for t = 1:nTrialsPerCondition
                    %if encodingStimulusArray{col}{t}{p} == parametersParadigm.stimulusArray{col}{s}
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



function [retrievalStimulusArray, changeSpecificationArray] = placeRetrievalStimuliATWM1_WM_CAP(nTrialsPerCondition, nChangeTrials, parametersParadigm, encodingPositionsArray, encodingStimulusArray, changeSpecificationIndex);
%%% (c) Robert Bittner
%%% Study: WMC2
%%% This function creates the retrieval arrays, randomly determining the
%%% nonmatch trials and randomly selecting the changed target stimulus

%%{
%%% Define the proportion of nonmatch trials
% nChangeTrials = floor(nTrialsPerCondition / 2);

%%% Determine randomly the trial index for the nonmatch trials
%changeIndexVector = sort(randsample(nTrialsPerCondition, nChangeTrials));
%nTrialsPerCondition = nTrialsPerCondition
%nChangeTrials = nChangeTrials
changeIndexVector = sort(randi(nTrialsPerCondition, nChangeTrials, 1))'


%%{
%for col = 1:length(parametersParadigm.stimulusColorArray)    

    %%% Create retrieval arrays 
    for t = 1:nTrialsPerCondition
        positions = encodingPositionsArray{t};
        stimulusPositionVector = find(positions == 1);
        emptyPositionVector = find(positions == 0);

        %%% Create retrieval arrays for the match condition
        unchangedRetrievalStimulusArray{t} = encodingStimulusArray{t};

%        targetStimuli = encodingStimulusArray{t}(stimulusPositionVector)
        targetStimuli = sort(encodingStimulusArray{t}(stimulusPositionVector));

        stimulusIndex = 1:length(parametersParadigm.stimulusArray);
        for s = 1:length(stimulusPositionVector)
            ind = strmatch(targetStimuli{s}, parametersParadigm.stimulusArray);
            stimulusIndex(ind) = 0;
        end

        %%% create vector indicating stimuli not present in the encoding
        %%% array
        stimulusIndex = nonzeros(stimulusIndex)';
        if length(stimulusIndex) > 1
            
            nonMatchStimulusIndex(t) = stimulusIndex(randi(numel(stimulusIndex)));
            %nonMatchStimulusIndex(t) = randsample(stimulusIndex, 1);
        else
            nonMatchStimulusIndex(t) = stimulusIndex;
        end
%        nonMatchStimulusIndex(t) = randsample(stimulusIndex, 1);
        nonMatchStimulus{t} = parametersParadigm.stimulusArray{nonMatchStimulusIndex(t)};
%        arrray = targetStimuli
%        nmatchstim = nonMatchStimulus{t}

%{        

        %%% Determine, which target stimulus can be changed in the
        %%% nonmatch condition
        stimulusIndex = 1:length(parametersParadigm.stimulusArray);
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
            changedStimulusPosition{t}(s) = strmatch(parametersParadigm.stimulusArray(changedStimulusIndex{t}(s)), encodingStimulusArray{t});
        end

        %%% Determine randomly, which of the possible target stimuli
        %%% are changed in the nonmatch condition
        selectedChangedStimulusPosition{t} = changedStimulusPosition{t}(randIndex(t));
%}
        changedRetrievalStimulusArray{t} = unchangedRetrievalStimulusArray{t};
        if length(parametersParadigm.stimulusArray) - length(stimulusIndex) > 1
            
            %stimulusPositionVector = stimulusPositionVector
            
            selectedChangedStimulusPosition{t} = stimulusPositionVector(randi(numel(stimulusPositionVector)))
            
            %selectedChangedStimulusPosition{t} = randsample(stimulusPositionVector, 1);
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


function trialIndex = randomizeTrialOrderATWM1_WM_CAP(nConditions, nRuns, nTrials, nTrialsPerRun);

conditionCounter(1:nConditions) = 0;
trialCounter = 0;
for r = 1:nRuns
    orderedTrialIndex = [];
    for c = 1:nConditions
        conditionc = c
        indexCondition = [];
        indexCondition(1:nTrials{c}(r)) = c;
        orderedTrialIndex = [orderedTrialIndex, indexCondition];
    end    
	completeTrialIndex{r} = orderedTrialIndex;
    test = completeTrialIndex{r}
    %test = completeTrialIndex{r}
    
    randomizedTrialIndex{r} = randsample(completeTrialIndex{r}, nTrialsPerRun);

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



function writeTrialSpecificationsATWM1_WM_CAP(filePath, trialSpecificationFile, trialSpecificationFileFormat, parametersParadigm, trialIndex, conditionSpecification, stimulusCoordinateArray, nPositions, nTrialsPerCondition, nConditions, nRuns, nTotalTrials, nTrialsPerRun, nTrialsPerConditionPerRun, encodingStimulusArray, retrievalStimulusArray, changeSpecificationArray, intertrialInterval, preparationTime, encodingTime, totalDelayIntervall, maskPresentationTime, wmLoad);

for r = 1:nRuns
    trialSpecificationFileName = sprintf('%s_s%i%s', trialSpecificationFile, r, trialSpecificationFileFormat);
    fid = fopen([filePath, trialSpecificationFileName], 'wt');
    if r/2 ~= ceil(r/2)
        col = 1;
    else
        col = 1;
    end

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
                delayInterval = totalDelayIntervall;
                
                %%% Determine, whether current trial is a change or nochange trial 
                
                conditionIndex = conditionIndex
                conditionCounter = conditionCounter
                arraysize = size(changeSpecificationArray)
                changeIndex = changeSpecificationArray{conditionIndex}{conditionCounter};
                
                %%% Create encoding code
%                encodingCode = sprintf('"%i_Load_%i_%s_%s_%i_%i_%i_%i_%i"', trialCounter, wmLoad(conditionIndex), conditionSpecification{conditionIndex}, changeIndex, intertrialInterval, preparationTime, encodingTime, interstimulusInterval, delayInterval);
                encodingCode = sprintf('"%i_Load_%i_%s"', trialCounter, wmLoad(conditionIndex), changeIndex);
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
                    blankSpaces = sprintf('   ');
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
                fprintf(fid, '%i %i %i %i\t\t', intertrialInterval, preparationTime, encodingTime, delayInterval);
                
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

