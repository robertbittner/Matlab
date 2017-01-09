function writeTrialSpecifications_WM_CAP(filePath, trialSpecificationFile, trialSpecificationFileFormat, stimulusSpecifications, trialIndex, conditionSpecification, stimulusCoordinateArray, nPositions, nTrialsPerCondition, nConditions, nRuns, nTotalTrials, nTrialsPerRun, nTrialsPerConditionPerRun, encodingStimulusArray, retrievalStimulusArray, changeSpecificationArray, intertrialInterval, preparationTime, encodingTime, totalDelayIntervall, maskPresentationTime, wmLoad);

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
                fprintf(fid, '%s ', stimulusSpecifications.alertingCross);
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
