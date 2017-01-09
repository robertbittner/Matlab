function computeBehavioralDataATWM1_PSYPHY_pre_EXP4 ();
    % ATWM1
    % Analyze psycho-physics presentation logfiles

    clear all; 
    clc;
    
    global iStudy
    global iSubject
    global folderDefinition
    global parametersStudy
    global parametersExperiment
    
    iStudy = 'ATWM1';
    
    %%% Specifies the psychophysical experiment
    experimentNumber = 4;
    
    folderDefinition        = eval(strcat('folderDefinition', iStudy));
    parametersStudy         = eval(strcat('parametersStudy', iStudy));

    %%% Specifies the psychophysical experiment
    parametersStudy.experimentNumber = experimentNumber;
    
    parametersExperiment    = eval(strcat('parametersExperiment', iStudy, '_', parametersStudy.iPsychophysics, '_', parametersStudy.iExperiment, num2str(parametersStudy.experimentNumber)));

    indicatorReprocessData = 1;
    
    aSubject = eval(['subjectArray', iStudy]);
    aSubject = aSubject.(genvarname([iStudy, '_', parametersStudy.iPsychophysics, '_', parametersStudy.iExperiment, num2str(parametersStudy.experimentNumber)])); 
    
    nSubjects = length(aSubject);
    
    strLogFilesFolderName = strcat(folderDefinition.logFiles, parametersStudy.iPsychophysics, '\', parametersStudy.iExperiment, num2str(parametersStudy.experimentNumber), '\');
    strResultsFolderName = strcat(folderDefinition.behavioralData, parametersStudy.iPsychophysics, '\', parametersStudy.iExperiment, num2str(parametersStudy.experimentNumber), '\');
    
    %%{
    for cs = 1%:nSubjects
        iSubject = aSubject{cs};
        
        for cco = 1:parametersExperiment.nConditionFiles
            for cr = 1:parametersExperiment.nRuns(cco)
                %strLogFileName = strcat(iSubject, '-', iStudy, '_', parametersStudy.iPsychophysics, '_', parametersStudy.iExperiment, num2str(parametersStudy.experimentNumber), '_', parametersStudy.iCondition, parametersExperiment.aConditionFiles{cco}, '_', parametersStudy.iRun, num2str(cr), '.log');
                strLogFileName = strcat(iSubject, '-', iStudy, '_', parametersStudy.iPsychophysics, '_', parametersStudy.iExperiment, num2str(parametersStudy.experimentNumber), '_', parametersExperiment.aConditionFiles{cco}, '_', parametersStudy.iRun, num2str(cr), '.log');
                strMatFileName =  strrep(strLogFileName, '.log', '.mat');
                strFilePath = strcat(strLogFilesFolderName,strLogFileName);
                
                
                %%% Checks whether mat-file already exists
                if indicatorReprocessData == 1
                    iMatFileExist = 0;
                else
                    iMatFileExist = exist(strcat(strLogFilesFolderName,strLogFileName), 'file');
                end
                
                if iMatFileExist ~= 2
                    AnalyzeLogFile(strFilePath);
                    movefile(strcat(strLogFilesFolderName,strMatFileName), strcat(strResultsFolderName,strMatFileName));
                end
            end
        end
        %%{
        dataRun = loadAndModifyRunData(strResultsFolderName);
        dataCondition = mergeRunData(dataRun, strResultsFolderName);
        dataSubject = mergeConditionData(dataCondition, strResultsFolderName);
        %}
        createTrialSpecificationFile(dataSubject);
    end 
    %
    %computeBHDATWM1
%end



%function computeBHDATWM1()    
    %%{
    for cs = 1:nSubjects
        iSubject = aSubject{cs};
        
        strMatFileName = strcat(iSubject, '-', iStudy, '_', parametersStudy.iPsychophysics, '_', parametersStudy.iExperiment, num2str(parametersStudy.experimentNumber), '.mat');
        dataSubject = load(strcat(strResultsFolderName,strMatFileName));
        
        %%% The performance for each condition is calculated. No distinction
        %%% between noChange and change conditions are made.
        for cco = 1:parametersExperiment.nConditions        
            indexReferenceArray = 'trialSpecification';
            condition = parametersExperiment.aConditions{cco};
            computedBehavioralData.conditionAccuracy(cs, cco) = computeConditionAccuracyATWM1(dataSubject, parametersExperiment, condition, indexReferenceArray);
            %test = computedBehavioralData.conditionAccuracy(cs, cco)
        end
        
        
        %%% The performance for each condition is calculated separately for
        %%% noChange and change conditions.
        for cco = 1:parametersExperiment.nConditionsChangeIndex
            indexReferenceArray = 'trialSpecificationChangeIndex';
            condition = parametersExperiment.aConditionsChangeIndex{cco};
            computedBehavioralData.conditionAccuracyChangeIndex(cs, cco) = computeConditionAccuracyATWM1(dataSubject, parametersExperiment, condition, indexReferenceArray);
            %test.(genvarname(condition)) = computedBehavioralData.conditionAccuracyChangeIndex(cs, cco)
        end

        %%% The number of sucessfully encoded items (Cowan's K) is calculated
        %%% for each condition
        for cco = 1:parametersExperiment.nConditions
            %test = parametersExperiment.nConditions
            %condition = parametersExperiment.aConditionsChangeIndex{cco}
            indexNoChange = cco*2-1;
            indexChange = cco*2;

            %wmLoad = str2num(parametersParadigm.conditionArray{cco}(6));
            %wmLoad = parametersExperiment.wmLoad(cco);
            wmLoad = 6;
            wmLoad = parametersExperiment.wmLoadCondition(cco);
            accuracyNoChange = computedBehavioralData.conditionAccuracyChangeIndex(cs, indexNoChange);
            accuracyChange = computedBehavioralData.conditionAccuracyChangeIndex(cs, indexChange);
            computedBehavioralData.cowansK(cs, cco) = computeCowansK(wmLoad, accuracyNoChange, accuracyChange);
            %test = computedBehavioralData.cowansK(cs, cco)
        end

    end
    
    %%% The mean values and standard error for performance and Cowan's K in
    %%% each condition are calculated
    for cco = 1:parametersExperiment.nConditions
        computedBehavioralData.meanConditionAccuracy(cco) = mean(computedBehavioralData.conditionAccuracy(:, cco));
        computedBehavioralData.standardErrorConditionAccuracy(cco) = std(computedBehavioralData.conditionAccuracy(:, cco)) / sqrt(length(aSubject));
        computedBehavioralData.meanCowansK(cco) = mean(computedBehavioralData.cowansK(:, cco));
        computedBehavioralData.standardErrorCowansK(cco) = std(computedBehavioralData.cowansK(:, cco) * 100) / sqrt(length(aSubject));
    end
    
    
    %%% The behavioral data are stored in a txt-file using a SPSS
    %%% compatible format
    %%% 
    %%% !!!
    %%% Change to excel file in the future
    %%% !!!
    spssBehavioralDataFileName = sprintf('%s_%s_%s%i_%i_subj_BHD_SPSS.txt', iStudy, parametersStudy.iPsychophysics, parametersStudy.iExperiment, parametersStudy.experimentNumber, length(aSubject));
    strOutputPath = strcat(folderDefinition.behavioralData, spssBehavioralDataFileName);
    fid = fopen(strOutputPath, 'wt');
    
    for cco = 1:parametersExperiment.nConditions
        labelAccuracyCondition{cco} = ['ACC_',  parametersExperiment.aConditions{cco}];
        labelCowansKCondition{cco} = ['Cowan''s_K_',  parametersExperiment.aConditions{cco}];
    end
    columnLabel = ['Subjects', labelAccuracyCondition, labelCowansKCondition];
    fprintf(fid,'%s \t', columnLabel{:});
    fprintf(fid,'\n');
        for cs = 1:length(aSubject)
            row = [computedBehavioralData.conditionAccuracy(cs, :), computedBehavioralData.cowansK(cs, :)]; 
            fprintf(fid,'%s\t', aSubject{cs});
            fprintf(fid,'%.2f\t', row(:));
            fprintf(fid,'\n');
        end
    fclose(fid);
    
    
    
    %%% create bar graph
    %%% this coud be transfered into a new function
    %%%
    
    colorFlicker = 'black';
    colorNonflicker = 'white';
    
    figure;
    %test = get(gcf)
    
    %set(handleFigure, 'PaperType', 'A0');
    
    figureTitle = sprintf('%s %s %s%i', iStudy, parametersStudy.iPsychophysics, parametersStudy.iExperiment, parametersStudy.experimentNumber);
     
    for cco = 1:(parametersExperiment.nConditions / 2)
        iFirstBar = (cco * 2) - 1;
        iSecondBar = cco * 2;
        subplot(1, (parametersExperiment.nConditions / 2), cco)
        x = computedBehavioralData.meanCowansK(iFirstBar:iSecondBar);
        for cb = 1:numel(x)
            %est = cb
            %barColor = 'r';
            behavioralDataPlot = bar(cb, x(cb));
            if cb == 1
                hold on
            end
            if cb == 1
                set(behavioralDataPlot, 'FaceColor', colorFlicker);
                %col = 'white';
            else
                set(behavioralDataPlot, 'FaceColor', colorNonflicker);
                %col = 'black';
            end
            
        end
        
        %{
        

data = [.142 3 1;.156 5 1;.191 2 0;.251 4 0];
%First column is the sorted value
%Second column is the index for the YTickLabel
%Third column is the reaction direction
% Data(1,3) = 1 -> bar in red
% Data(1,3) = 0 -> bar in blue
uniNames = {'eno','pck','zwf','foo' 'bar'};
%This was the original script....

H = data(:, 1);
N = numel(H);
for i=1:N
  h = bar(i, H(i));
  if i == 1, hold on, end
  if data(i, 3) == 1
    col = 'r';
  else
    col = 'b';
  end
  set(h, 'FaceColor', col) 
end
set(gca, 'XTickLabel', '')  

xlabetxt = uniNames(data(:,2));
ylim([0 .5]); ypos = -max(ylim)/50;
text(1:N,repmat(ypos,N,1), ...
     xlabetxt','horizontalalignment','right','Rotation',90,'FontSize',15)

text(.55,77.5,'A','FontSize',15)
ylabel('median log2 fold change','FontSize',15)


        
        %}
        
        
        title(parametersExperiment.aLabelConditions{cco});
        ylabel('Cowan''s K');
        handleAxes = get(gcf,'CurrentAxes');
        set(handleAxes, 'XTickLabel', {'', ''});
        set(handleAxes, 'YLim', [0 3])
        
    end
    %hold off
    handleLegend = legend('Flicker', 'Nonflicker');
    
    set(handleLegend, 'Location', 'north');
    
    handleFigure = gcf;
    %test = get(handleFigure)
    set(handleFigure, 'Name', figureTitle);
    
    
    %supertitle(plotTitle)
    %PaperType
    %{
    %%% Create first subplot
    subplot(1, 3, 1)
    x = computedBehavioralData.meanCowansK(1:2);
    behavioralDataPlot = bar(x);
    
    %%% Create second subplot    
    subplot(1, 3, 2)
    x = computedBehavioralData.meanCowansK(3:4);
    behavioralDataPlot = bar(x);
    
    %%% Create third subplot    
    subplot(1, 3, 3)
    x = computedBehavioralData.meanCowansK(5:6);
    behavioralDataPlot = bar(x);
    %}
    
    %tet = get(behavioralDataPlot)
    %set(behavioralDataPlot, 'BarWidth', 1.400);
    %BarWidth: 0.8000
    
   

    %title(plotTitle);
    
    %%% Save Behavioral Data Plot as BMP
    %set(gcf,'PaperPosition',[-1.17 1.82 13.33 4.85],'PaperType','A4', 'PaperOrientation', 'portrait')
    %set(gcf, 'InvertHardCopy', 'off');
    formatGraphicsFile = 'bmp';
    plotFileName = sprintf('%s_%s%i_Performance_%i_subj.%s', iStudy, parametersStudy.iExperiment, parametersStudy.experimentNumber, length(aSubject), formatGraphicsFile);
    
    %print(behavioralDataPlot,['-d' formatGraphicsFile],'-r600', plotFileName);
    saveas(behavioralDataPlot, strcat(folderDefinition.behavioralData, plotFileName));
    close all
    
    
    
    %movefile([folderDefinition.matlab, plotFileName, ['.' formatGraphicsFile]], folderDefinition.behavioralData);
    %{
    set(handleAxes, 'XTickLabel', {
        'NoBias_Cued'
        'NoBias_Uncued'
        'FlickerBias_Cued'
        'FlickerBias_Uncued'
        'NonflickerBias_Cued'
        'NonflickerBias_Uncued'
        });
    %}

end

function conditionAccuracy = computeConditionAccuracyATWM1(dataSubject, parametersExperiment, condition, indexReferenceArray);
%%% Study: ATWM1 
%%% Computes the response accurcay for one condition

nTrials = length(dataSubject.parametersParadigm.trialNumbers);

referenceArrayForComparison = dataSubject.parametersParadigm.(genvarname(indexReferenceArray));
%test = dataSubject.parametersParadigm.(genvarname(indexReferenceArray))
%test = condition
%test = dataSubject.behavioralData.response

i = 0;
for t = 1:nTrials
    %cond = condition
    %condTrial = referenceArrayForComparison{t}
    if strcmp(condition, referenceArrayForComparison{t}) == 1
        i = i + 1;
        response(i) = dataSubject.behavioralData.response(t);
    end
end


%%% The number of correct answers are counted
nCorrectAnswers = 0;
for i = 1:length(response)
    if response(i) == 1
        nCorrectAnswers = nCorrectAnswers + 1;
    end
end
%%% The accuracy is calculated
conditionAccuracy = (nCorrectAnswers/length(response));

%%% The accuracy is calculated as the percentage of correct answers
%%% conditionAccuracy = (nCorrectAnswers/length(response)) * 100; 


end

function dataRun = loadAndModifyRunData(strResultsFolderName);


    global iStudy
    global iSubject
    global folderDefinition
    global parametersStudy
    global parametersExperiment

    dataRun = {};
    counter = 0;
    for cco = 1:parametersExperiment.nConditionFiles
        for cr = 1:parametersExperiment.nRuns(cco)
            counter = counter + 1;
            strMatFileName = strcat(iSubject, '-', iStudy, '_', parametersStudy.iPsychophysics, '_', parametersStudy.iExperiment, num2str(parametersStudy.experimentNumber), '_', parametersExperiment.aConditionFiles{cco}, '_', parametersStudy.iRun, num2str(cr), '.mat');
            data = load(strcat(strResultsFolderName,strMatFileName));
            
            
            test = data.behavioralData.response
            
            %statisticalDataTest = data.statisticalData
            %{
            fieldnamesParametersParadigm = fieldnames(data.parametersParadigm);
            for cf = 1:length(fieldnamesParametersParadigm)
                fieldName = genvarname(fieldnamesParametersParadigm{cf})
                parametersParadigmTest = data.parametersParadigm.(genvarname(fieldnamesParametersParadigm{cf}))
            end
            %}
            
            nTrials = length(data.parametersParadigm.trialNumbers);
            
            %{
            if length(data.behavioralData.reactionTime) < 99
            subject = iSubject
            file = strMatFileName
            nRecordedReactionTime = length(data.behavioralData.reactionTime)
            nRecordedResponses = length(data.behavioralData.response)
            end
            %}
            
            fieldNamesBehavioralData = fieldnames(data.behavioralData);
            %fieldNamesParametersParadigm = fieldnames(data.parametersParadigm); 

            %%% Fill the reaction time variable with an arbitrary number to
            %%% prevent missing data.
            %%%
            %%% Remove the following code after Michael's code has been
            %%% modified.
            data.behavioralData.reactionTime(1:nTrials) = 666;
            
            
            %%% Remove fields shorter than the run length
            %%%
            %%% Remove the following code after Michael's code has been
            %%% modified.
            for cf = 1:length(fieldNamesBehavioralData)
                if length(data.behavioralData.(genvarname(fieldNamesBehavioralData{cf}))) < nTrials
                    data.behavioralData = rmfield(data.behavioralData, fieldNamesBehavioralData{cf});
                end
            end
            
            %%% Remove practise trial from trial count
            %{
            data.parametersParadigm.originalTrialNumbers = data.parametersParadigm.trialNumbers;
            data.parametersParadigm.trialNumbers = data.parametersParadigm.trialNumbers - parametersExperiment.nPractiseTrials(cco);
            %}
            
            %%% Change the trial numbers to a continuing count across run
            if cr > 1
                 data.parametersParadigm.trialNumbers = data.parametersParadigm.trialNumbers + ((cr - 1) * nTrials);
            end
            
            
            for ct = 1:nTrials
                
                %%% Add an index for the experimental condition and the run
                data.parametersParadigm.iCondition{ct} = parametersExperiment.aConditionFiles{cco};
                data.parametersParadigm.iRun(ct)       = cr;

                %%% Add an index for working memory load
                data.parametersParadigm.wmLoad{ct}  = parametersExperiment.wmLoad(cco);
                
                %%% Create trialType id
                data.parametersParadigm.trialSpecification{ct}              = sprintf('%s_%s', data.parametersParadigm.biastype{ct}, data.parametersParadigm.cues{ct});
                data.parametersParadigm.trialSpecificationChangeIndex{ct}   = sprintf('%s_%s_%s', data.parametersParadigm.biastype{ct}, data.parametersParadigm.cues{ct}, data.parametersParadigm.changeConditions{ct});
            
            end

            dataRun{cco, cr} = data;
        end
    end

end
        

function dataCondition = mergeRunData(dataRun, strResultsFolderName);
        
    global iStudy
    global iSubject
    global folderDefinition
    global parametersStudy
    global parametersExperiment
    
    for cco = 1:parametersExperiment.nConditionFiles
        behavioralData = {};
        parametersParadigm = {};
        for cr = 1:parametersExperiment.nRuns(cco)
            data = dataRun{cco, cr};
            nTrials = length(data.parametersParadigm.trialNumbers);
            fieldNamesBehavioralData = fieldnames(data.behavioralData);
            fieldNamesParametersParadigm = fieldnames(data.parametersParadigm); 
            
            %%% The behavioralData structure is merged across runs
            if cr == 1 
                for cf = 1:length(fieldNamesBehavioralData)
                    %test = fieldNamesBehavioralData
                    behavioralData.(genvarname(fieldNamesBehavioralData{cf})) = data.behavioralData.(genvarname(fieldNamesBehavioralData{cf}));
                end
            else
                for cf = 1:length(fieldNamesBehavioralData)
                    %test = cr
                    %tests = fieldNamesBehavioralData
                    %se = behavioralData
                    behavioralData.(genvarname(fieldNamesBehavioralData{cf})) = [ behavioralData.(genvarname(fieldNamesBehavioralData{cf})) data.behavioralData.(genvarname(fieldNamesBehavioralData{cf})) ];
                end
            end

            %%% The parametersParadigm structure is merged across runs
            if cr == 1 
                for cf = 1:length(fieldNamesParametersParadigm)
                    parametersParadigm.(genvarname(fieldNamesParametersParadigm{cf})) = data.parametersParadigm.(genvarname(fieldNamesParametersParadigm{cf}));
                end
            else
                for cf = 1:length(fieldNamesParametersParadigm)
                    parametersParadigm.(genvarname(fieldNamesParametersParadigm{cf})) = [ parametersParadigm.(genvarname(fieldNamesParametersParadigm{cf})) data.parametersParadigm.(genvarname(fieldNamesParametersParadigm{cf})) ];
                end
            end

        end
        dataCondition{cco}.behavioralData = behavioralData;
        dataCondition{cco}.parametersParadigm = parametersParadigm;

        strMatFileName = strcat(iSubject, '-', iStudy, '_', parametersStudy.iPsychophysics, '_', parametersStudy.iExperiment, num2str(parametersStudy.experimentNumber), '_', parametersStudy.iCondition, parametersExperiment.aConditionFiles{cco}, '.mat');
        strOutputPath = strcat(strResultsFolderName, strMatFileName);
        save(strOutputPath, 'behavioralData', 'parametersParadigm');
        strMessage = sprintf('Results saved to %s\n', strOutputPath);
        disp(strMessage);
    end

end

function dataSubject = mergeConditionData(dataCondition, strResultsFolderName);

    global iStudy
    global iSubject
    global folderDefinition
    global parametersStudy
    global parametersExperiment
    
    behavioralData = {};
    parametersParadigm = {};

    
    for cco = 1:parametersExperiment.nConditionFiles

        %strMatFileName = strcat(iSubject, '-', iStudy, '_', parametersStudy.iPsychophysics, '_', parametersStudy.iExperiment, num2str(parametersStudy.experimentNumber), '_', parametersStudy.iCondition, parametersExperiment.aConditionFiles{cco}, '.mat');
        %data = load(strcat(strResultsFolderName,strMatFileName));
        data = dataCondition{cco};
        fieldNamesBehavioralData = fieldnames(data.behavioralData);
        fieldNamesParametersParadigm = fieldnames(data.parametersParadigm); 

        %%% The behavioralData structure is merged across conditions
        if cco == 1 
            for cf = 1:length(fieldNamesBehavioralData)
                behavioralData.(genvarname(fieldNamesBehavioralData{cf})) = data.behavioralData.(genvarname(fieldNamesBehavioralData{cf}));
            end
        else
            for cf = 1:length(fieldNamesBehavioralData)
                behavioralData.(genvarname(fieldNamesBehavioralData{cf})) = [ behavioralData.(genvarname(fieldNamesBehavioralData{cf})) data.behavioralData.(genvarname(fieldNamesBehavioralData{cf})) ];
            end
        end
        
        %%% The parametersParadigm structure is merged across conditions
        if cco == 1 
            for cf = 1:length(fieldNamesParametersParadigm)
                parametersParadigm.(genvarname(fieldNamesParametersParadigm{cf})) = data.parametersParadigm.(genvarname(fieldNamesParametersParadigm{cf}));
            end
        else
            for cf = 1:length(fieldNamesParametersParadigm)
                parametersParadigm.(genvarname(fieldNamesParametersParadigm{cf})) = [ parametersParadigm.(genvarname(fieldNamesParametersParadigm{cf})) data.parametersParadigm.(genvarname(fieldNamesParametersParadigm{cf})) ];
            end
        end
        
    end
    dataSubject.behavioralData = behavioralData;
    dataSubject.parametersParadigm = parametersParadigm;
    
    strMatFileName = strcat(iSubject, '-', iStudy, '_', parametersStudy.iPsychophysics, '_', parametersStudy.iExperiment, num2str(parametersStudy.experimentNumber), '.mat');
    strOutputPath = strcat(strResultsFolderName, strMatFileName);
    save(strOutputPath, 'behavioralData', 'parametersParadigm'); 
    strMessage = sprintf('Results saved to %s\n', strOutputPath);
    disp(strMessage);

end


function createTrialSpecificationFile(dataSubject)
    global iStudy
    global iSubject
    global folderDefinition
    global parametersStudy
    global parametersExperiment

    trialSpecificationFile = sprintf('trialSpecification%s_%s_%s%i.m', iStudy, parametersStudy.iPsychophysics, parametersStudy.iExperiment, parametersStudy.experimentNumber);
    strOutputPath = strcat(folderDefinition.studyParameters, trialSpecificationFile);
    fid = fopen(strOutputPath, 'wt');
    iTrialType = unique(dataSubject.parametersParadigm.trialSpecification);
    for it = 1:length(iTrialType)
        fprintf(fid, '\t''%s''\n', iTrialType{it});
    end
    fprintf(fid, '\n');
    iTrialType = unique(dataSubject.parametersParadigm.trialSpecificationChangeIndex);
    for it = 1:length(iTrialType)
        fprintf(fid, '\t''%s''\n', iTrialType{it});
    end
    fclose(fid);
end