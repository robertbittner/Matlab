function encodingStimulusCoordinatesArray = determineEncodingStimulusCoordinates_WM_CAP(nPositions, nTrialsPerCondition, stimulusCoordinatesArray);
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
