function computeBehavioralDataATWM1_LOC ();
% ATWM1
% Analyze presentation logfiles for localizer experiment

clear all; 
clc;

global iStudy
global iSubject

iStudy = 'ATWM1';

% Specifies the psychophysical experiment
%experimentNumber = 7;

folderDefinition        = feval(str2func(strcat('folderDefinition', iStudy)));
parametersStudy         = feval(str2func(strcat('parametersStudy', iStudy)));

% Specifies the psychophysical experiment
%parametersStudy.experimentNumber = experimentNumber;


%parametersParadigm                  = feval(str2func(strcat('parametersParadigm', iStudy, '_', parametersStudy.iPsychophysics, '_', parametersStudy.iExperiment, num2str(parametersStudy.experimentNumber))));
parametersParadigm                  = feval(str2func('parametersParadigmATWM1_LOC'));
parametersAnalysisBehavioralData    = feval(str2func(strcat('parametersAnalysisBehavioralData', iStudy)));
parametersStudy.strExperiment       = strcat(iStudy, '_', 'LOC');

%%{
hFunction = str2func(sprintf('selectReprocessingOption%s_%s', iStudy, 'LOC'));
[bReprocessAllData, bAbortFunction] = feval(hFunction, iStudy, parametersStudy);
if bAbortFunction == true
    strMessage = sprintf('No valid option selected. Script cannot be executed properly!');
    disp(strMessage);
    return
end
%}

aSubject = feval(str2func(strcat('aSubject', iStudy)));

% This needs to be removed
%{
aSubject = {
    'TEST'
    %'TEST'
    };
%}


hFunction = str2func(sprintf('prepareGroupInformation%s_%s', iStudy, 'LOC'));
[aSubject, nGroups, nSubjects] = feval(hFunction, parametersStudy, aSubject);



%strLogFilesFolderName	= strcat(folderDefinition.logFiles, parametersStudy.iPsychophysics, '\', parametersStudy.iExperiment, num2str(parametersStudy.experimentNumber), '\');
strLogFilesFolderName	= 'D:\Daten\ATWM1\Presentation_Logfiles\PSY\LOC\'; 
%strResultsFolderName	= strcat(folderDefinition.behavioralData, parametersStudy.iPsychophysics, '\', parametersStudy.iExperiment, num2str(parametersStudy.experimentNumber), '\');
strResultsFolderName	= 'D:\Daten\ATWM1\Behavioral_Data\LOC\';

for cg = 1:nGroups
    % Process the log files and save the trial data
    for cs = 1:nSubjects(cg)
        iSubject = aSubject.(genvarname(aSubject.aStrGroupVariableName{cg})){cs};
        %strBehavioralDataFile = sprintf('%s_%s_%s_%s%i_BehavioralData.mat', iSubject, iStudy, parametersStudy.iPsychophysics, parametersStudy.iExperiment, parametersStudy.experimentNumber);
        strBehavioralDataFile = sprintf('%s_%s_%s_BehavioralData.mat', iSubject, iStudy, 'LOC');
        strPathBehavioralDataFile = strcat(strResultsFolderName, strBehavioralDataFile);
        if exist(strPathBehavioralDataFile, 'file') && bReprocessAllData == false
            continue 
        end
        
        % Extract and modify trial data from presentation logfiles
        %strLogFileName = strcat(iSubject, '-', iStudy, '_', parametersStudy.iExperiment, num2str(parametersStudy.experimentNumber), '_', parametersStudy.iPsychophysics, '_', parametersParadigm.aConditions{cco}, '_', parametersStudy.iRun, num2str(parametersParadigm.iFullRuns(cr)), '.log');
        %strLogFileName = 'TEST_ATWM1_PSYPHY_LOCALIZER.log';
        strLogFileName = sprintf('%s-%s_LOCALIZER.log', iSubject, iStudy); %

        strLogFilePath = strcat(strLogFilesFolderName, strLogFileName);
        
        if ~exist(strLogFilePath, 'file')
            strMessage = sprintf('\nCould not open %s\n', strLogFilePath);
            disp(strMessage);
            continue
        end
        
        % Read trial data from logfile
        %hFunction = str2func(sprintf('readLogfile%s', iStudy));
        hFunction = str2func(sprintf('readLogfile%s_%s', iStudy, 'LOC'));
        tempTrialData = feval(hFunction, parametersParadigm, strLogFilePath);

        if isempty(tempTrialData),
            break
        end

        % Determine additional information based on the extracted
        % trial data
        hFunction = str2func(sprintf('addTrialInformation%s_%s', iStudy, 'LOC'));
        tempTrialData = feval(hFunction, parametersParadigm, tempTrialData, strBehavioralDataFile);
        
        hFunction = str2func(sprintf('determineTrialAccuracy%s_%s', iStudy, 'LOC'));
        tempTrialData = feval(hFunction, parametersParadigm, tempTrialData);

        hFunction = str2func(sprintf('calculateTrialReactionTime%s_%s', iStudy, 'LOC'));
        tempTrialData = feval(hFunction, parametersParadigm, tempTrialData);
        
        % Write data of current run into permanent variable
        trialData = tempTrialData;

        %%% Save subject's behavioral data in a mat-file
        hFunction = str2func(sprintf('saveBehavioralData%s_%s', iStudy, 'LOC'));
        feval(hFunction, trialData, strBehavioralDataFile, strPathBehavioralDataFile);
    end
end

%%{
% Calculate and store performance data for each subject
for cg = 1:nGroups
    for cs = 1:nSubjects(cg)
        iSubject = aSubject.(genvarname(aSubject.aStrGroupVariableName{cg})){cs};
        %strPerformanceDataFile = sprintf('%s_%s_%s_%s%i_PerformanceData.mat', iSubject, iStudy, parametersStudy.iPsychophysics, parametersStudy.iExperiment, parametersStudy.experimentNumber);
        strPerformanceDataFile = sprintf('%s_%s_%s_PerformanceData.mat', iSubject, iStudy, 'LOC');
        strPathPerformanceDataFile{cg, cs} = strcat(strResultsFolderName, strPerformanceDataFile);
        if exist(strPathPerformanceDataFile{cg, cs}, 'file') && bReprocessAllData == false
            load('-mat', strPathPerformanceDataFile{cg, cs});
        else
            strBehavioralDataFile = sprintf('%s_%s_%s_BehavioralData.mat', iSubject, iStudy, 'LOC');
            strPathBehavioralDataFile = strcat(strResultsFolderName, strBehavioralDataFile);
            
            hFunction = str2func(sprintf('calculateSubjecPerformanceData%s_%s', iStudy, 'LOC'));
            singleSubjectPerformanceData = feval(hFunction, parametersParadigm, parametersAnalysisBehavioralData, strBehavioralDataFile, strPathBehavioralDataFile);

            % Write singleSubjectPerformanceData into a mat-file
            save(strPathPerformanceDataFile{cg, cs}, 'singleSubjectPerformanceData');
            strMessage = sprintf('\nSaving file %s\n', strPerformanceDataFile);
            disp(strMessage);    
        end
        
        %%{
        % singleSubjectPerformanceData is transferred into new variable
        % subjectPerformanceData which is used for calculation of mean
        % values and standard errors. 
        aStrVars = fieldnames(singleSubjectPerformanceData);
        for cfn = 1:length(aStrVars)
            nConditions = length(singleSubjectPerformanceData.(aStrVars{cfn}));
            for cco = 1:nConditions
                subjectPerformanceData.(aStrVars{cfn})(cg, cs, cco) = singleSubjectPerformanceData.(aStrVars{cfn})(cco);
           end
        end
        %}
    end
end


% The behavioral data of each subject are stored in txt and xlsx files in a
% format compatible with SPSS
hFunction = str2func(sprintf('writeComputedBehavioralDataToFile%s_%s', iStudy, 'LOC'));
[strSpssBehavioralDataFile, strExcelBehavioralDataFile, successTextFileCreation, successExcelFileCreation] = feval(hFunction, parametersStudy, parametersParadigm, parametersAnalysisBehavioralData, folderDefinition, aSubject, nGroups, nSubjects, subjectPerformanceData);


% Display message, if file creation failed
if successTextFileCreation ~= 0
    strMessage = sprintf('\nError! File %s could not be written in folder %s\n', strSpssBehavioralDataFile, folderDefinition.behavioralData);
    disp(strMessage);
end
if successExcelFileCreation ~= 0
    strMessage = sprintf('\nError! File %s could not be written in folder %s\n', strExcelBehavioralDataFile, folderDefinition.behavioralData);
    disp(strMessage);
end

%{
% The mean value and standard error for each performance parameter in
% each condition are calculated
strMeanValue = parametersAnalysisBehavioralData.strMeanValue;
strStandardError = parametersAnalysisBehavioralData.strStandardError;
aFieldNames = fieldnames(subjectPerformanceData)
nFields = length(aFieldNames);
for cfn = 1:nFields
    strFieldName = aFieldNames{cfn};
    strModifiedFieldName = regexprep(strFieldName, strFieldName(1), upper(strFieldName(1)), 'once');
    strFieldNameMeanValue = strcat(strMeanValue, strModifiedFieldName);
    strFieldNameStandardError = strcat(strStandardError, strModifiedFieldName);
    for cg = 1:nGroups
        
        %meantest = mean(subjectPerformanceData.(strFieldName)(cg, :, :))
        %test = subjectPerformanceData.(strFieldName)(cg)
        
        
        computedBehavioralData.(strFieldNameMeanValue)(cg, :)       = mean(subjectPerformanceData.(strFieldName)(cg, :, :));
        computedBehavioralData.(strFieldNameStandardError)(cg, :)   = std(subjectPerformanceData.(strFieldName)(cg, :, :)) / sqrt(nSubjects(cg));
    end
end
%}

%{
hFunction = str2func(sprintf('createBarGraph%s_%s_%s%i', iStudy, parametersStudy.iPsychophysics, parametersStudy.iExperiment, parametersStudy.experimentNumber));
feval(hFunction, parametersStudy, parametersParadigm, folderDefinition, computedBehavioralData, nSubjects);
%}

%}
end

function [bReprocessAllData, bAbortFunction] = selectReprocessingOptionATWM1_LOC(iStudy, parametersStudy);
strPrompt = sprintf('Reprocess data of all subjects\nfor %s_%s?', iStudy, parametersStudy.strExperiment);
aStrOptionsReprocessAllData = {
    'Yes'
    'No'
    };
defaulValueOptionsReprocessAllData = 2;
[optionReprocessAllData]  = listdlg('ListString', aStrOptionsReprocessAllData, 'PromptString', {strPrompt, ''}, 'InitialValue', defaulValueOptionsReprocessAllData, 'SelectionMode', 'single', 'ListSize', [200 50]);
if optionReprocessAllData == 1
    bReprocessAllData = true;
    bAbortFunction = false;
elseif optionReprocessAllData == 2
    bReprocessAllData = false;
    bAbortFunction = false;
else
    bReprocessAllData = false;
    bAbortFunction = true;
end

end

function [aSubject, nGroups, nSubjects] = prepareGroupInformationATWM1_LOC(parametersStudy, aSubject);
% Group information is processed
% If only a single group exists and aSubjects is not a structure, aSubjects
% is transformed into a structure with one field carrying the name of the
% default group name.
aSubject = aSubject.(genvarname(parametersStudy.strExperiment));
if isstruct(aSubject) ~= 1
    aSubjectTemp = aSubject;
    clear aSubject;
    aSubject.(parametersStudy.defaultGroupName) = aSubjectTemp;
end
aStrGroupVariableName = fieldnames(aSubject);
nGroups = length(aStrGroupVariableName);
aSubject.aStrGroupVariableName = sort(aStrGroupVariableName);
for cg = 1:nGroups
    strGroupNameCapitalLetters = upper(aSubject.aStrGroupVariableName{cg});
    aSubject.strShortGroupLabel{cg} = strGroupNameCapitalLetters(1:3);
    aSubject.strGroupLabel{cg} = regexprep(aSubject.aStrGroupVariableName{cg}, aSubject.aStrGroupVariableName{cg}(1), upper(aSubject.aStrGroupVariableName{cg}(1)), 'once');
    nSubjects(cg) = length(aSubject.(genvarname(aStrGroupVariableName{cg})));
end


end

function trialData = readLogfileATWM1_LOC(parametersParadigm, strLogFilePath);

global iStudy
global iSubject

fid = fopen(strLogFilePath, 'rt');

strMessage = sprintf('\nStart analysis of %s\n', strLogFilePath);
disp(strMessage);

% read strLines until the index of the first trial has been found
bFoundFirstTrial = false;
bIgnoreTrialIndex = false;
bIgnoreRetrievalIndex = true;
bIgnoreResponseIndex = false;
bValidResponseRecorded = false;
bFalseAlarmRecorded = false;

%cLines = 0; % avoid infinite loop
cTrials = 0;
while ~bFoundFirstTrial% && cLines < 40
    strLine = fgetl(fid);
    %cLines = cLines + 1;
    % search for the index of the first trial
    if ~isempty(strfind(strLine, parametersParadigm.iFirstTrial)) && bIgnoreTrialIndex == false
        bFoundFirstTrial = true;
    end
end

while ~feof(fid)      
    
    % Stimulus presentation
    if ~isempty(strfind(strLine, parametersParadigm.iTrial)) && bIgnoreTrialIndex == false
        cTrials = cTrials + 1;
        text = textscan(strLine, '%s %f %s %s %f %*[^\n]');
        %text = textscan(strLine, '%s')
        %test = text{1}
        trialData.strTrialInfo{cTrials} = text{4}{1};
        %tset = trialData.strTrialInfoEncoding{cTrials}
        trialData.stimulusOnset(cTrials) = text{5};
        
        trialData.response(cTrials) = 0;
        trialData.responseOnset(cTrials) = 0;
        
        % Test whether trial is a target or control trial
        if ~isempty(strfind(trialData.strTrialInfo{cTrials}, parametersParadigm.iTargetTrial))
            bTargetTrial = true;
            %trialData.bTargetTrial{cTrials} = bTargetTrial;
        elseif ~isempty(strfind(trialData.strTrialInfo{cTrials}, parametersParadigm.iStandardTrial))
            bTargetTrial = false;
            %trialData.bTargetTrial{cTrials} = bTargetTrial;
        end        
    end
    
    % Response
    if ~isempty(strfind(strLine, parametersParadigm.iResponse)) %&& bIgnoreResponseIndex == false
        %bIgnoreResponseIndex = true;
        if bTargetTrial == true
            bValidResponseRecorded = true;
        else 
            bFalseAlarmRecorded = true;
        end
        text = textscan(strLine, '%s %f %s %f %f %*[^\n]');
        trialData.response(cTrials) = text{4};
        trialData.responseOnset(cTrials) = text{5};
        trialData.bFalseAlarmRecorded{cTrials} = bFalseAlarmRecorded;
    end
    
    % Intertrial interval
    if ~isempty(strfind(strLine, 'ITI'))
        %%{
        % Check, whether a response was made in time
        if bValidResponseRecorded == true

        elseif bTargetTrial == true
            strMessage = sprintf('No valid response recorded for trial # %i in file %s', cTrials, strLogFilePath);
            disp(strMessage);
        elseif bFalseAlarmRecorded == true
            strMessage = sprintf('False alarm recorded for trial # %i in file %s', cTrials, strLogFilePath);
            disp(strMessage);
        end
        bIgnoreTrialIndex = false;
        bIgnoreResponseIndex = true;
        bValidResponseRecorded = false;
        bFalseAlarmRecorded = false;
        %}
    end
        
    % read next line
    strLine = fgetl(fid);
    if isempty(strLine)
        continue
    end

end
%{
% read rest of file
while ~feof(fid)      
    
    % Encoding
    if ~isempty(strfind(strLine, parametersParadigm.iTrial)) && bIgnoreTrialIndex == false
        bIgnoreTrialIndex = true;
        cTrials = cTrials + 1;
        text = textscan(strLine, '%s %f %s %s %f %*[^\n]');
        trialData.strTrialInfoEncoding{cTrials} = text{4}{1};
        trialData.encodingOnset(cTrials) = text{5};
    end
    
    % Delay
    if ~isempty(strfind(strLine, parametersParadigm.iDelay))
        text = textscan(strLine, '%s %f %s %s %f %*[^\n]');
        trialData.delayOnset(cTrials) = text{5};
        bIgnoreRetrievalIndex = false;
    end
    
    % Retrieval
    if ~isempty(strfind(strLine, parametersParadigm.iRetrieval)) && bIgnoreRetrievalIndex == false
        bIgnoreRetrievalIndex = true;
        bIgnoreResponseIndex = false;
        text = textscan(strLine, '%s %f %s %s %f %*[^\n]');
        trialData.strTrialInfoRetrieval{cTrials} = text{4};
        trialData.retrievalOnset(cTrials) = text{5};
        % Add placeholder values for response in case no valid response 
        % was made
        trialData.response(cTrials) = parametersParadigm.missingResponse;
        trialData.responseOnset(cTrials) = trialData.retrievalOnset(cTrials);
    end
    
    % Response
    if ~isempty(strfind(strLine, parametersParadigm.iResponse)) && bIgnoreResponseIndex == false
        bIgnoreResponseIndex = true;
        bValidResponseRecorded = true;
        text = textscan(strLine, '%s %f %s %f %f %*[^\n]');
        trialData.response(cTrials) = text{4};
        trialData.responseOnset(cTrials) = text{5};
    end
    
    % Intertrial interval
    if ~isempty(strfind(strLine, 'ITI'))
        % Check, whether a response was made in time
        if bValidResponseRecorded == true
            
        else
            strMessage = sprintf('No valid response recorded for trial # %i in file %s', cTrials, strLogFilePath);
                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                    BehavioralParameter, '');
                break
            end
        end
        nConditions = length(parametersParadigm.(strArrayConditionNames));
        for cco = 1:nConditions
            strConditionAnalysisLabel{cv, cco} = strcat(strBehavioralParameter, '_', parametersParadigm.(strArrayConditionNames){cco});
            aStrLabelCondition = [aStrLabelCondition, strConditionAnalysisLabel{cv, cco}];
        end
    end
end

% The column labels printed in the top row are created
% 1: general information
columnLabelInitialRows = {'Group_Number', 'Group_Label', 'Subject'};
% 2: names of each condition and analysis parameter
columnLabel = [columnLabelInitialRows, aStrLabelCondition];

% Write the data of each subject into one row
for cg = 1:nGroups
    for cs = 1:nSubjects
        row = [];
        for cv = 1:length(aStrVars)
            addData = [];
            if length(size(subjectPerformanceData.(aStrVars{cv}))) == 2
                addData = [addData, subjectPerformanceData.(aStrVars{cv})(cg, cs)];
            elseif length(size(subjectPerformanceData.(aStrVars{cv}))) == 3
                for cco = 1:length(subjectPerformanceData.(aStrVars{cv})(cg, cs, :))
                    %{
                    struc = subjectPerformanceData
                    group = cg
                    subj = cs
                    ind = cco
                    var = aStrVars{cv}
                    sizeVar = length(subjectPerformanceData.(aStrVars{cv})(cg, cs))
                    wholeData = subjectPerformanceData.(aStrVars{cv})
                    data = subjectPerformanceData.(aStrVars{cv})(cg, cs, cco)
                    %}
                    addData = [addData, subjectPerformanceData.(aStrVars{cv})(cg, cs, cco)];
                end
            else
                iSubject = aSubject.(genvarname(aSubject.aStrGroupVariableName{cg})){cs};
                strMessage = sprintf('Error when trying to write data for subject %s!\nIncompatible data format in variable %s', iSubject, aStrVars{cv});
                disp(strMessage);
            end
            row = [row, addData];
        end
        dataRow(cg, cs, :) = row;
    end
end
   
% Create the txt-file
fid = fopen(strOutputPath, 'wt');

% Write the column labels into the txt-file
fprintf(fid,'%s \t', columnLabel{:});
fprintf(fid,'\n');
for cg = 1:nGroups
    for cs = 1:nSubjects
        strSubject = aSubject.(genvarname(aSubject.aStrGroupVariableName{cg})){cs};

        fprintf(fid,'%i\t', cg);
        fprintf(fid,'%s\t', aSubject.strShortGroupLabel{cg});
        fprintf(fid,'%s\t', strSubject);

        fprintf(fid,'%.2f\t', dataRow(cg, cs, :));
        fprintf(fid,'\n');
    end
end
%test = fid
successTextFileCreation = fclose(fid)

% An additional excel file is created, which can be switched of because of
% the long processing time
if parametersAnalysisBehavioralData.bCreateExcelFileForResults == false
    successExcelFileCreation = -1;
    strMessage = sprintf('Creation of excel file for results turned off.\n');
    disp(strMessage);
else
    % Prepare an excel compatible column indexing system by concatenating
    % letters
    strAlphabet = 'ABCDEFGHIJKLMNOPQRSTUVWXYZ';
    nLetters = length(strAlphabet);

    counter = 0;
    for cfl = 1:nLetters
        aStrLetter{cfl} = strAlphabet(cfl);
        for csl = 1:nLetters
            counter = counter + 1;
            aStrLetter{nLetters + counter} = strcat(strAlphabet(cfl), strAlphabet(csl));
        end
    end

    % Define name of excel sheet for behavioral data
    strBeharvioralDataSheet = strcat(iStudy, '_', parametersAnalysisBehavioralData.strShortBehavioralData);

    % Test, whether excel file exists and can be modified
    fid = fopen(strPathExcelBehavioralDataFile,'w');
    if fid == -1 && exist(strPathExcelBehavioralDataFile, 'file') == 2
        % If excel file is already used by another process function is aborted
        strMessage = sprintf('File\n%s\nappears to be used by another process and cannot be modified', strExcelBehavioralDataFile);
        disp(strMessage);
        successExcelFileCreation = 1;
        return
    elseif fid ~= -1
        % Delete any previous version of the excel file with the same name
        fclose(fid);
        delete(strPathExcelBehavioralDataFile)
    end

    % Create excel file and rename the first sheet using activex
    xlswrite(strPathExcelBehavioralDataFile, 1)
    excel = actxserver('Excel.Application');
    workbook = excel.Workbooks.Open(strPathExcelBehavioralDataFile);
    workbook.Worksheets.Item(1).Name = strBeharvioralDataSheet;
    workbook.Save
    workbook.Close(false)
    invoke(excel, 'Quit');
    delete(excel);

    % Write data into the excel file
    % 1: The labels in the top row
    xlswrite(strPathExcelBehavioralDataFile, columnLabel, strBeharvioralDataSheet)

    % 2: The data for each suject in a separate row
    counterSubjectAcrossGroup = 0;
    for cg = 1:nGroups
        for cs = 1:nSubjects
            counterSubjectAcrossGroup = counterSubjectAcrossGroup + 1;
            infoContentRow = {cg, aSubject.strShortGroupLabel{cg}, strSubject};
            dataContentRow = dataRow(cg, cs, :);
            dataContentRow = transpose(squeeze(dataContentRow));

            iFirstLetter = 1;
            iSecondLetter = length(infoContentRow);
            xlRange = sprintf('%s%i:%s%i', aStrLetter{iFirstLetter}, (counterSubjectAcrossGroup + 1), aStrLetter{iSecondLetter}, (counterSubjectAcrossGroup + 1));
            xlswrite(strPathExcelBehavioralDataFile, infoContentRow, xlRange);        
            iFirstLetter = length(infoContentRow) + 1;
            iSecondLetter = length(dataContentRow) + length(infoContentRow);
            xlRange = sprintf('%s%i:%s%i', aStrLetter{iFirstLetter}, (counterSubjectAcrossGroup + 1), aStrLetter{iSecondLetter}, (counterSubjectAcrossGroup + 1));
            xlswrite(strPathExcelBehavioralDataFile, dataContentRow, xlRange);        
        end
    end
    successExcelFileCreation = 0;

end

end

function subjectPerformanceData = rearrangeFieldsInSubjectPerformanceDataATMW1(parametersAnalysisBehavioralData, subjectPerformanceData);
% Reorder fields in subjectPerformanceData 

if parametersAnalysisBehavioralData.bPutGlobalParametersAtFront == true
    % Reorder fields in subjectPerformanceData to put overall accuracy and
    % reaction time at the front of all other fields.
    for cgbp = 1:parametersAnalysisBehavioralData.nGlobalBehavioralParameters
        aStrVars = fieldnames(subjectPerformanceData);
        nVars = length(aStrVars);
        strGlobalBehavioralParameter = parametersAnalysisBehavioralData.aStrOverallBehavioralParameter{cgbp};
        for cbbp = 1:parametersAnalysisBehavioralData.nBasicBehavioralParameters
            strBasicBehavioralParameter = parametersAnalysisBehavioralData.aStrBasicBehavioralParameter{cbbp};
            if ~isempty(strfind(strGlobalBehavioralParameter, strBasicBehavioralParameter))
                iGlobalBehavioralParameter(cgbp) = find(strcmp(aStrVars, strGlobalBehavioralParameter));
                break
            end
        end
    end
    iNewOrder = 1:nVars;
    iNewOrder(iGlobalBehavioralParameter) = [];
    iNewOrder = [iGlobalBehavioralParameter, iNewOrder];
    subjectPerformanceData = orderfields(subjectPerformanceData, iNewOrder);
else
    % Reorder fields in subjectPerformanceData to put overall accuracy and
    % reaction time at the front of the respective fields
    for cgbp = 1:parametersAnalysisBehavioralData.nGlobalBehavioralParameters
        aStrVars = fieldnames(subjectPerformanceData);
        nVars = length(aStrVars);
        strGlobalBehavioralParameter = parametersAnalysisBehavioralData.aStrOverallBehavioralParameter{cgbp};
        for cbbp = 1:parametersAnalysisBehavioralData.nBasicBehavioralParameters
            strBasicBehavioralParameter = parametersAnalysisBehavioralData.aStrBasicBehavioralParameter{cbbp};
            if ~isempty(strfind(strGlobalBehavioralParameter, strBasicBehavioralParameter))
                iGlobalBehavioralParameter = find(strcmp(aStrVars, strGlobalBehavioralParameter));
                break
            end
        end
        iStartBasicBehavioralParameter = [];
        iOriginalOrder = 1:nVars;
        for cvn = 1:nVars
            if ~isempty(strfind(aStrVars{cvn}, strBasicBehavioralParameter)) && cvn ~= iGlobalBehavioralParameter && isempty(iStartBasicBehavioralParameter)
                iStartBasicBehavioralParameter = cvn;
            end
        end
        if iStartBasicBehavioralParameter == 1
            iUnchangedStart = [];
        else
            iUnchangedStart = iOriginalOrder(1:(iStartBasicBehavioralParameter - 1));
        end
            iChanged = iOriginalOrder(iStartBasicBehavioralParameter:(iGlobalBehavioralParameter - 1));
        if iGlobalBehavioralParameter == nVars
            iChangedEnd = [];
        else
            iChangedEnd = iOriginalOrder((iGlobalBehavioralParameter + 1):nVars);
        end
        iNewOrder = [iUnchangedStart, iGlobalBehavioralParameter, iChanged, iChangedEnd];
        subjectPerformanceData = orderfields(subjectPerformanceData, iNewOrder);
    end
end


end

function conditionAccuracy = computeConditionAccuracyATWM1(aTrialData, parametersParadigm, strCondition, aStrConditionForComparison);
% Study: ATWM1 
% Computes the response accurcay for one condition
%test1 = strCondition
%test2 = aStrConditionForComparison{1}
cct = 0;
for ct = 1:parametersParadigm.nTrialsTotal
    if strcmp(strCondition, aStrConditionForComparison{ct}) == 1
        cct = cct + 1;
        response(cct) = aTrialData.iTrialAccuracy(ct);
        %testResp = response(cct)
        if response(cct) == parametersParadigm.iMissingResponse
            %testMiss = response(cct)
            response(cct) = parametersParadigm.iIncorrectResponse;
        end
    end
end

% The number of correct answers is calculated
nCorrectAnswers = sum(response);

% The accuracy is calculated
conditionAccuracy = (nCorrectAnswers/length(response));

% The accuracy is calculated as the percentage of correct answers
% conditionAccuracy = (nCorrectAnswers/length(response)) * 100; 

end

function conditionReactionTime = computeConditionReactionTimeATWM1(aTrialData, parametersParadigm, strCondition, aStrConditionForComparison);
% Study: ATWM1 
% Computes the reaction time for one condition

cct = 0;
for ct = 1:parametersParadigm.nTrialsTotal
    %gen = strCondition
    %tri = aStrConditionForComparison{ct}
    if strcmp(strCondition, aStrConditionForComparison{ct}) == 1
        cct = cct + 1;
        reactionTime(cct) = aTrialData.reactionTime(ct);
        if aTrialData.iTrialAccuracy(ct) == parametersParadigm.iMissingResponse
            reactionTime(cct) = [];
        end
    end
end
% Reaction times from trials with missing response are excluded
validReactionTimes = reactionTime(reactionTime > 0);

% The average reaction time is calculated
conditionReactionTime = mean(validReactionTimes);

end

function createBarGraphATWM1_PSY_EXP7(parametersStudy, parametersParadigm, folderDefinition, computedBehavioralData, nSubjects);
% create bar graph of Cowan's K

global iStudy
global iSubject

strColorFlicker = 'black';
strColorNonflicker = 'white';
aStrBarColor = {
    strColorFlicker
    strColorNonflicker
    };

figureTitle = sprintf('%s %s %s%i', iStudy, parametersStudy.iPsychophysics, parametersStudy.iExperiment, parametersStudy.experimentNumber);

figure;
for cco = 1:(parametersParadigm.nConditionsRetrieval / 2)
    % Sort the bar graphs depending on the condition (Salient or
    % Nonsalient)
    if isempty(cell2mat(strfind(parametersParadigm.aConditionsRetrieval(cco * 2), 'Nonsalient')))
        iFirstBar   = (cco * 2) - 1;
        iSecondBar  = (cco * 2);    
    else
        iFirstBar   = (cco * 2);    
        iSecondBar  = (cco * 2) - 1;
    end
    dataFirstBar    = computedBehavioralData.meanConditionRetrievalCowansK(iFirstBar);
    dataSecondBar   = computedBehavioralData.meanConditionRetrievalCowansK(iSecondBar);
    
    subplot(1, (parametersParadigm.nConditionsRetrieval / 2), cco)
    x = [dataFirstBar, dataSecondBar];

    for cb = 1:numel(x)
        behavioralDataPlot = bar(cb, x(cb));
        if cb == 1
            hold on
        else
            hold off
        end
        set(behavioralDataPlot, 'FaceColor', aStrBarColor{cb});
    end
    strTitle = strrep(parametersParadigm.aConditions{cco} , '_', ' ');
    title(strTitle);
    ylabel('Cowan''s K');
    handleAxes = get(gcf,'CurrentAxes');
    set(handleAxes, 'XTickLabel', {'', ''});
    set(handleAxes, 'YLim', [0 parametersParadigm.wmLoad(cco)])
end

%hold off

%subplot(1, (parametersParadigm.nConditionsRetrieval / 2) + 1, cco + 1)
%axis off
handleLegend = legend('Salient', 'Nonsalient');

set(handleLegend, 'Location', 'WestOutside');

handleFigure = gcf;
%test = get(handleFigure)
set(handleFigure, 'Name', figureTitle);
%{
for cco = 1:(parametersParadigm.nConditionsRetrieval / 2)
    iFirstBar = (cco * 2) - 1;
    iSecondBar = cco * 2;
    subplot(1, (parametersParadigm.nConditions / 2), cco)
    x = computedBehavioralData.meanConditionCowansK(iFirstBar:iSecondBar);
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
end
%}
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







%supertitle(plotTitle)
%PaperType
%{
% Create first subplot
subplot(1, 3, 1)
x = computedBehavioralData.meanCowansK(1:2);
behavioralDataPlot = bar(x);

% Create second subplot    
subplot(1, 3, 2)
x = computedBehavioralData.meanCowansK(3:4);
behavioralDataPlot = bar(x);

% Create third subplot    
subplot(1, 3, 3)
x = computedBehavioralData.meanCowansK(5:6);
behavioralDataPlot = bar(x);
%}

%tet = get(behavioralDataPlot)
%set(behavioralDataPlot, 'BarWidth', 1.400);
%BarWidth: 0.8000



%title(plotTitle);

% Save Behavioral Data Plot as BMP
%set(gcf,'PaperPosition',[-1.17 1.82 13.33 4.85],'PaperType','A4', 'PaperOrientation', 'portrait')
%set(gcf, 'InvertHardCopy', 'off');
formatGraphicsFile = 'bmp';
plotFileName = sprintf('%s_%s%i_Performance_%i_subj.%s', iStudy, parametersStudy.iExperiment, parametersStudy.experimentNumber, nSubjects, formatGraphicsFile);

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


