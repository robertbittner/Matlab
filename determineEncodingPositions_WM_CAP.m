function [encodingPositionsArray] = determineEncodingPositions_WM_CAP(wmLoad, nPositions, nTrialsPerCondition);
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
            randomSlot = randsample(1:nPositions, 1);
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

                    randomPosition = index(randsample(length(index), 1));                           % Select at random one of theses positions 
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
    test = encodingPositionsArray{t}
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
      
   