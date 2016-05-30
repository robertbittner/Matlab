function computedBehavioralData = computeBehavioralDataWM_CAP_PSYPHY ();
%%% Study: WM_CAP experiment of WMC2
%%% Computes the behavioral data for the MRI data

%%% Define the study index and set it to global
global indexStudy
indexStudy = 'WMC2';

%%% Determines, whether the behavioral data is read from the presentation
%%% logfiles and written into m-files. 
writeBehavioralDataToMFile = 0;     %%% 0 = no      1 = yes

%%% Defines the WM_CAP experiment number
experimentNumber = 2;


%%% This part loads the path definitions, parameters and subject names of
%%% the paradigm by calling different files as a function 
pathDefinition = eval(['pathDefinition', indexStudy]);
parametersStudy = eval(['parametersStudy', indexStudy]);
parametersStudy.experimentNumber = experimentNumber;

parametersParadigm  = eval(['parametersParadigm', parametersStudy.indexWorkingMemoryCapacity, '_', parametersStudy.indexPsychophysics, '_', parametersStudy.indexExperiment, num2str(parametersStudy.experimentNumber)]);

subjectArray = eval(['subjectArray', indexStudy]);
subjectArray = subjectArray.(genvarname([parametersStudy.indexWorkingMemoryCapacity, '_', parametersStudy.indexPsychophysics]));



%%% The behavioral data for each subject is read from the presentation
%%% logfiles and written into m-files.
if writeBehavioralDataToMFile == 1
    eval(['writeBehavioralDataToMFile', parametersStudy.indexWorkingMemoryCapacity]);
end


%%% The performance for all conditions are calculated. 
for s = 1:length(subjectArray)
    indexSubject = subjectArray{s};

    %%% The behavioral data is read from the Presentation logfiles.   
    behavioralData = eval([indexSubject, '_', parametersStudy.indexWorkingMemoryCapacity, '_', parametersStudy.indexPsychophysics, '_', parametersStudy.indexExperiment, num2str(parametersStudy.experimentNumber), '_', 'BehavioralData']);
    
    %%% The performance for each condition is calculated. No distinction
    %%% between noChange and change conditions are made.
    for c = 1:parametersParadigm.nOfConditions        
        indexReferenceArray = 'trialSpecification';
        condition = parametersParadigm.conditionArray{c};
        computedBehavioralData.conditionAccuracy(s, c) = computeConditionAccuracy(behavioralData, parametersParadigm, condition, indexReferenceArray);
    end
    
    %%% The performance for each condition is calculated separately for
    %%% noChange and change conditions.
    for c = 1:length(parametersParadigm.conditionArrayIndexRetrieval)
        indexReferenceArray = 'trialSpecificationChangeIndex';
        condition = parametersParadigm.conditionArrayIndexRetrieval{c};
        computedBehavioralData.conditionAccuracyChangeIndex(s, c) = computeConditionAccuracy(behavioralData, parametersParadigm, condition, indexReferenceArray);    
    end
    
    %%% The overall performance across all conditions is calculated
    computedBehavioralData.overallAccuracy(s) = mean(computedBehavioralData.conditionAccuracy(s, :));
%    test = computedBehavioralData.overallAccuracy(s)
    
    %%% The number of sucessfully encoded items (Cowan's K) is calculated
    %%% for each condition
    for c = 1:parametersParadigm.nOfConditions
        indexNoChange = c*2-1;
        indexChange = c*2;
        
        wmLoad = str2num(parametersParadigm.conditionArray{c}(6));
        accuracyNoChange = computedBehavioralData.conditionAccuracyChangeIndex(s, indexNoChange);
        accuracyChange = computedBehavioralData.conditionAccuracyChangeIndex(s, indexChange);
        computedBehavioralData.cowansK(s, c) = computeCowansK(wmLoad, accuracyNoChange, accuracyChange);
    end
end

%%% The mean values and standard error for performance and Cowan's K in
%%% each condition are calculated
for c = 1:parametersParadigm.nOfConditions
    computedBehavioralData.meanConditionAccuracy(c) = mean(computedBehavioralData.conditionAccuracy(:, c));
    computedBehavioralData.standardErrorConditionAccuracy(c) = std(computedBehavioralData.conditionAccuracy(:, c)) / sqrt(length(subjectArray));
    computedBehavioralData.meanCowansK(c) = mean(computedBehavioralData.cowansK(:, c));
    computedBehavioralData.standardErrorCowansK(c) = std(computedBehavioralData.cowansK(:, c) * 100) / sqrt(length(subjectArray));
end
    


%{
%%% The consolidation rate is determined by calculating the slope of the curve
%%% plotting Cowan's K against the ISI first for each subject and then over
%%% all subjects
interStimulusIntervals = parametersParadigm.conditionInterStimulusInterval;
for s = 1:length(subjectArray)
    slopeL3 = polyfit(interStimulusIntervals, computedBehavioralData.cowansK(s, :), 1);
    slopeLoad3(s) = slopeL3(1);
end
meanSlopeLoad3 = mean(slopeLoad3);
%}

%%% The behavioral data are stored in a txt-file using a SPSS
%%% compatible format
%%% 
%%% !!!
%%% Change to excel file in the future
%%% !!!
spssBehavioralDataFileName = sprintf('%s_%s%s_%i_subj_BHD_SPSS.txt', parametersStudy.indexWorkingMemoryCapacity, parametersStudy.indexExperiment, num2str(parametersStudy.experimentNumber), length(subjectArray));
fid = fopen([pathDefinition.behavioralData spssBehavioralDataFileName], 'wt');
for c = 1:parametersParadigm.nOfConditions
    labelOverallAccuracy = ['ACC_Overall'];
    labelAccuracyCondition{c} = ['ACC_', parametersParadigm.conditionArray{c}];
    labelCowansKCondition{c} = ['Cowan''s_K_', parametersParadigm.conditionArray{c}];
end
columnLabel = ['Subjects', labelOverallAccuracy, labelAccuracyCondition, labelCowansKCondition];
fprintf(fid,'%s \t', columnLabel{:});
fprintf(fid,'\n');
    for s = 1:length(subjectArray)
        row = [computedBehavioralData.overallAccuracy(s), computedBehavioralData.conditionAccuracy(s, :), computedBehavioralData.cowansK(s, :)]; 
        fprintf(fid,'%s\t', subjectArray{s});
        fprintf(fid,'%.2f\t', row(:));
        fprintf(fid,'\n');
    end
fclose(fid);

%eval(['plotBehavioralData', parametersStudy.indexWorkingMemoryCapacity, '(parametersStudy.indexWorkingMemoryCapacity, pathDefinition, subjectArray, parametersParadigm, computedBehavioralData)']);



