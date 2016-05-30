function computeBehavioralDataATWM1_PSY ();
% ATWM1
% Analyze psycho-physics presentation logfiles for EXP7

clear all; 
clc;

global iStudy
global iSubject

iStudy = 'ATWM1';

% Specifies the psychophysical experiment
experimentNumber = 7;

folderDefinition        = feval(str2func(strcat('folderDefinition', iStudy)));
parametersStudy         = feval(str2func(strcat('parametersStudy', iStudy)));

% Specifies the psychophysical experiment
parametersStudy.experimentNumber = experimentNumber;


parametersParadigm                  = feval(str2func(strcat('parametersParadigm', iStudy, '_', parametersStudy.iPsychophysics, '_', parametersStudy.iExperiment, num2str(parametersStudy.experimentNumber))));
parametersAnalysisBehavioralData    = feval(str2func(strcat('parametersAnalysisBehavioralData', iStudy)));
parametersParadigm.strExperiment    = strcat(iStudy, '_', parametersStudy.iPsychophysics, '_', parametersStudy.iExperiment, num2str(parametersStudy.experimentNumber));

hFunction = str2func(sprintf('selectReprocessingOption%s', iStudy));
[bReprocessAllData, bAbortFunction] = feval(hFunction, iStudy, parametersStudy);
if bAbortFunction == true
    strMessage = sprintf('No valid option selected. Script cannot be executed properly!');
    disp(strMessage);
    return
end


aSubject = feval(str2func(strcat('aSubject', iStudy)));


hFunction = str2func(sprintf('prepareGroupInformation%s', iStudy));
[aSubject, nGroups, nSubjects] = feval(hFunction, parametersStudy, parametersParadigm, aSubject);

% This needs to be removed
%{
aSubject = {
    'ANGELIKA_TEST'
    };
%}

strLogFilesFolderName	= strcat(folderDefinition.logFiles, parametersStudy.iPsychophysics, '\', parametersStudy.iExperiment, num2str(parametersStudy.experimentNumber), '\');
strResultsFolderName	= strcat(folderDefinition.behavioralData, parametersStudy.iPsychophysics, '\', parametersStudy.iExperiment, num2str(parametersStudy.experimentNumber), '\');

for cg = 1:nGroups
    % Process the log files and save the trial data
    for cs = 1:nSubjects(cg)
        iSubject = aSubject.(genvarname(aSubject.aStrGroupVariableName{cg})){cs};
        strBehavioralDataFile = sprintf('%s_%s_%s_%s%i_BehavioralData.mat', iSubject, iStudy, parametersStudy.iPsychophysics, parametersStudy.iExperiment, parametersStudy.experimentNumber);
        strPathBehavioralDataFile = strcat(strResultsFolderName, strBehavioralDataFile);
        if exist(strPathBehavioralDataFile, 'file') && bReprocessAllData == false
            continue 
        end
                    
        % Extract and modify trial data from presentation logfiles
        for cco = 1:parametersParadigm.nConditions
            
            %for cr = 1:parametersParadigm.nRunsPerCondition(cco)
            for cr = 1:2
                %strLogFileName = strcat(iSubject, '-', iStudy, '_', parametersStudy.iExperiment, num2str(parametersStudy.experimentNumber), '_', parametersStudy.iPsychophysics, '_', parametersParadigm.aConditions{cco}, '_', parametersStudy.iRun, num2str(cr), '.log');
                
                %changed by Lara 20/05
                %strLogFileName = strcat(iSubject, '-', iStudy, '_', parametersStudy.iExperiment, num2str(parametersStudy.experimentNumber), '_', parametersStudy.iPsychophysics, '_', parametersParadigm.aConditions{cco}, '_', parametersStudy.iRun, num2str(parametersParadigm.iFullRuns(cr)), '.log');
                strLogFileName = strcat(iSubject, '-', iStudy, '_', parametersStudy.iExperiment, num2str(parametersStudy.experimentNumber), '_', parametersStudy.iPsychophysics, '_', parametersParadigm.aConditions{cco}, '_', parametersStudy.iRun, num2str(parametersParadigm.iFullRuns(cr)), '.log');
                strLogFilePath = strcat(strLogFilesFolderName, strLogFileName);
                
                if ~exist(strLogFilePath, 'file')
                    strMessage = sprintf('\nCould not open %s\n', strLogFilePath);
                    disp(strMessage);
                    continue
                end


                % Read trial data from logfile
                hFunction = str2func(sprintf('readLogfile%s', iStudy));
                tempTrialData = feval(hFunction, parametersParadigm, strLogFilePath);
                
                if isempty(tempTrialData),
                    break
                end

                % Determine additional information based on the extracted
                % trial data
                hFunction = str2func(sprintf('addTrialInformation%s', iStudy));
                tempTrialData = feval(hFunction, parametersParadigm, tempTrialData, strBehavioralDataFile, cr);

                hFunction = str2func(sprintf('determineTrialAccuracy%s', iStudy));
                tempTrialData = feval(hFunction, parametersParadigm, tempTrialData);

                hFunction = str2func(sprintf('calculateTrialReactionTime%s', iStudy));
                tempTrialData = feval(hFunction, parametersParadigm, tempTrialData);

                % Write data of current run into permanent variable
                trialDataRun{cco}{cr} = tempTrialData;
            end
        end
        
        %%% Save subject's behavioral data in a mat-file
        hFunction = str2func(sprintf('saveBehavioralData%s', iStudy));
        feval(hFunction, parametersParadigm, trialDataRun, strBehavioralDataFile, strPathBehavioralDataFile);
    end
end

% Calculate and store performance data for each subject
for cg = 1:nGroups
    for cs = 1:nSubjects(cg)
        iSubject = aSubject.(genvarname(aSubject.aStrGroupVariableName{cg})){cs};
        strPerformanceDataFile = sprintf('%s_%s_%s_%s%i_PerformanceData.mat', iSubject, iStudy, parametersStudy.iPsychophysics, parametersStudy.iExperiment, parametersStudy.experimentNumber);
        strPathPerformanceDataFile{cg, cs} = strcat(strResultsFolderName, strPerformanceDataFile);
        if exist(strPathPerformanceDataFile{cg, cs}, 'file') && bReprocessAllData == false
            load('-mat', strPathPerformanceDataFile{cg, cs});
        else
            strBehavioralDataFile = sprintf('%s_%s_%s_%s%i_BehavioralData.mat', iSubject, iStudy, parametersStudy.iPsychophysics, parametersStudy.iExperiment, parametersStudy.experimentNumber);
            strPathBehavioralDataFile = strcat(strResultsFolderName, strBehavioralDataFile);
            
            hFunction = str2func(sprintf('calculateSubjecPerformanceData%s', iStudy));
            singleSubjectPerformanceData = feval(hFunction, parametersParadigm, parametersAnalysisBehavioralData, strBehavioralDataFile, strPathBehavioralDataFile);
            
            % Write singleSubjectPerformanceData into a mat-file
            save(strPathPerformanceDataFile{cg, cs}, 'singleSubjectPerformanceData');
            strMessage = sprintf('\nSaving file %s\n', strPerformanceDataFile);
            disp(strMessage);    
        end
        
        % singleSubjectPerformanceData is transferred into new variable
        % subjectPerformanceData which is used for calculation of mean
        % values, standard errors, Cowan's K etc. 
        aStrVars = fieldnames(singleSubjectPerformanceData);
        for cfn = 1:length(aStrVars)
            nConditions = length(singleSubjectPerformanceData.(aStrVars{cfn}));
            for cco = 1:nConditions
                subjectPerformanceData.(aStrVars{cfn})(cg, cs, cco) = singleSubjectPerformanceData.(aStrVars{cfn})(cco);
           end
        end
    end
end

% The behavioral data of each subject are stored in txt and xlsx files in a
% format compatible with SPSS
hFunction = str2func(sprintf('writeComputedBehavioralDataToFile%s', iStudy));
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

% The mean value and standard error for each performance parameter in
% each condition are calculated
strMeanValue = parametersAnalysisBehavioralData.strMeanValue;
strStandardError = parametersAnalysisBehavioralData.strStandardError;
aFieldNames = fieldnames(subjectPerformanceData);
nFields = length(aFieldNames);
for cfn = 1:nFields
    strFieldName = aFieldNames{cfn};
    strModifiedFieldName = regexprep(strFieldName, strFieldName(1), upper(strFieldName(1)), 'once');
    strFieldNameMeanValue = strcat(strMeanValue, strModifiedFieldName);
    strFieldNameStandardError = strcat(strStandardError, strModifiedFieldName);
    for cg = 1:nGroups
        computedBehavioralData.(strFieldNameMeanValue)(cg, :) = mean(subjectPerformanceData.(strFieldName)(cg, :, :));
        computedBehavioralData.(strFieldNameStandardError)(cg, :) = std(subjectPerformanceData.(strFieldName)(cg, :, :)) / sqrt(nSubjects(cg));
    end
end

hFunction = str2func(sprintf('createBarGraph%s_%s_%s%i', iStudy, parametersStudy.iPsychophysics, parametersStudy.iExperiment, parametersStudy.experimentNumber));
feval(hFunction, parametersStudy, parametersParadigm, folderDefinition, computedBehavioralData, nSubjects);

end

function [bReprocessAllData, bAbortFunction] = selectReprocessingOptionATWM1(iStudy, parametersStudy);
strPrompt = sprintf('Reprocess data of all subjects\nfor %s_%s_%s%i?', iStudy, parametersStudy.iPsychophysics, parametersStudy.iExperiment, parametersStudy.experimentNumber);
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

function [aSubject, nGroups, nSubjects] = prepareGroupInformationATWM1(parametersStudy, parametersParadigm, aSubject);
% Group information is processed
% If only a single group exists and aSubjects is not a structure, aSubjects
% is transformed into a structure with one field carrying the name of the
% default group name.
aSubject = aSubject.(genvarname(parametersParadigm.strExperiment));
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

function trialData = readLogfileATWM1(parametersParadigm, strLogFilePath);

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
            disp(strMessage);
        end
        bIgnoreTrialIndex = false;
        bIgnoreResponseIndex = true;
        bValidResponseRecorded = false;
    end
    
    % read next line
    strLine = fgetl(fid);
    if isempty(strLine)
        continue
    end
end

% Check, whether the correct number of trials have been extracted
if cTrials ~= parametersParadigm.nTrialsPerRun
    strMessage = sprintf('\nError during trial extraction in file %s!\nnumber of exptected trials: %i\nnumber of extracted trials: %i', strLogFilePath, parametersParadigm.nTrialsPerRun, cTrials);
    disp(strMessage);
end


end

function [strSpssBehavioralDataFile, strExcelBehavioralDataFile, successTextFileCreation, successExcelFileCreation] = writeComputedBehavioralDataToFileATWM1(parametersStudy, parametersParadigm, parametersAnalysisBehavioralData, folderDefinition, aSubject, nGroups, nSubjects, subjectPerformanceData);
% The behavioral data are stored in a txt-file and xlsx-file using a SPSS
% compatible format

global iStudy

aStrVars = fieldnames(subjectPerformanceData);
if nGroups > 1
    strGroup = 'groups';
else
    strGroup = 'group';
end

% Define file names and paths
strSpssBehavioralDataFile = sprintf('%s_%s_%s%i_%i_%s_%i_subj_BHD_SPSS.txt', iStudy, parametersStudy.iPsychophysics, parametersStudy.iExperiment, parametersStudy.experimentNumber, nGroups, strGroup, sum(nSubjects));
strOutputPath = strcat(folderDefinition.behavioralData, strSpssBehavioralDataFile);

strExcelBehavioralDataFile = sprintf('%s_%s_%s%i_%i_%s_%i_subj_BHD.xlsx', iStudy, parametersStudy.iPsychophysics, parametersStudy.iExperiment, parametersStudy.experimentNumber, nGroups, strGroup, sum(nSubjects));
strPathExcelBehavioralDataFile = strcat(folderDefinition.behavioralData, strExcelBehavioralDataFile);

% Define the labels for conditions and analysis types
aStrLabelCondition = {};
for cv = 1:length(aStrVars)
    if length(size(subjectPerformanceData.(aStrVars{cv}))) == 2
        cco = 1;
        strConditionAnalysisLabel{cv, cco} = aStrVars{cv};
        aStrLabelCondition = [aStrLabelCondition, strConditionAnalysisLabel{cv, cco}];
    else
        % Transform fieldname into name of condition array as used in the
        % parametersParadigm file in order to directly access information
        % stored in this file.
        strVarName = aStrVars{cv};
        strArrayConditionNames = strrep(strVarName, parametersAnalysisBehavioralData.strCondition, 'aConditions');
        for cbp = 1:parametersAnalysisBehavioralData.nBehavioralParameters
            strBehavioralParameter = parametersAnalysisBehavioralData.aStrBehavioralParameter{cbp};
            if ~isempty(strfind(strArrayConditionNames , strBehavioralParameter))
                strArrayConditionNames = strrep(strArrayConditionNames, strBehavioralParameter, '');
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
   
%strOutputPath = 'D:\test.txt'
tes = strOutputPath
% Create the txt-file
fid = fopen(strOutputPath, 'wt')

if fid == -1
   error('Could not create file %s', strOutputPath);
end

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
successTextFileCreation = fclose(fid);

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

function subjectPerformanceData = calculateSubjecPerformanceDataATWM1(parametersParadigm, parametersAnalysisBehavioralData, strBehavioralDataFile, strPathBehavioralDataFile);

global iStudy

if ~exist(strPathBehavioralDataFile, 'file') 
    strMessage = sprintf('File %s not found/nin folder %s\n\n', strBehavioralDataFile, strPathBehavioralDataFile);
    disp(strMessage);
    return 
else
    % Import the trial data file
    load('-mat', strPathBehavioralDataFile, 'aTrialData')
end

% The accuracy and reaction time for each condition
% is calculated.
aFieldNames = fieldnames(aTrialData);
for cbbp = 1:parametersAnalysisBehavioralData.nBasicBehavioralParameters
    strBehavioralParameter = parametersAnalysisBehavioralData.aStrBasicBehavioralParameter{cbbp};
    for cfn = 1:length(aFieldNames)
        % Search for fieldnames containing the word condition, which
        % indicates that a field is relevant for analysis
        if strfind(aFieldNames{cfn}, parametersAnalysisBehavioralData.strCondition) == 1
            strConditionType = aFieldNames{cfn}; 

            % Transform fieldname into name of condition array as used in the
            % parametersParadigm file in order to directly access and use 
            % information stored in this file.
            % e.g.: from 'conditionRetrievalChange' to 'aConditionsRetrievalChange'
            strConditionArrayName = strrep(strConditionType, parametersAnalysisBehavioralData.strCondition, 'aConditions');
            nConditions = length(parametersParadigm.(genvarname(strConditionArrayName)));

            % For each condition type create new fieldnames for each type of
            % analysis (e.g.: Accuracy and ReactionTime)
            %strNewFieldNamePart = strrep(strConditionType, '', '');
            strNewFieldNamePart = strConditionType;
            strFieldNameCondtionBehvavioralParameter = strcat(strNewFieldNamePart, strBehavioralParameter);

            for cco = 1:nConditions
                strCondition = parametersParadigm.(genvarname(strConditionArrayName)){cco};
                aStrConditionForComparison = aTrialData.(genvarname(strConditionType));
                

                hFunction = str2func(sprintf('computeCondition%s%s', strBehavioralParameter, iStudy)); %'computeCondition', strBehavioralParameter, iStudy
                subjectPerformanceData.(genvarname(strFieldNameCondtionBehvavioralParameter))(cco) = feval(hFunction, aTrialData, parametersParadigm, strCondition, aStrConditionForComparison);

                %%% Delete?
                %subjectPerformanceData.(genvarname(strFieldNameCondtionBehvavioralParameter))(cco)   = eval(strcat('computeCondition', strBehavioralParameter, iStudy, '(aTrialData, parametersParadigm, strCondition, aStrConditionForComparison)'));
            end
        end
    end
end

% The number of sucessfully encoded items (Cowan's K) is calculated
% for each condition
strNoChange = strcat('_', parametersParadigm.strNoChange);
strChange = strcat('_', parametersParadigm.strChange);
for cccs = 1:parametersParadigm.nConditionsChange
    cco = ceil(cccs / 2);
    wmLoad = parametersParadigm.wmLoad(cco);
    if ~isempty(strfind(parametersParadigm.aConditionsChange{cccs}, strNoChange))
        accuracyNoChange = subjectPerformanceData.conditionChangeAccuracy(cccs);
    end
    if ~isempty(strfind(parametersParadigm.aConditionsChange{cccs}, strChange))
        accuracyChange = subjectPerformanceData.conditionChangeAccuracy(cccs);
    end
    if cccs / 2 == cco
        subjectPerformanceData.conditionCowansK(cco) = computeCowansK(wmLoad, accuracyNoChange, accuracyChange);
    end
end


% The number of sucessfully encoded items (Cowan's K) is calculated
% for each conditionRetrieval
strNoChange = strcat('_', parametersParadigm.strNoChange);
strChange = strcat('_', parametersParadigm.strChange);
for ccrcs = 1:parametersParadigm.nConditionsRetrievalChange
    ccrs = ceil(ccrcs / 2);
    cco = ceil(ccrs / 2);
    wmLoad = parametersParadigm.wmLoad(cco);
    if ~isempty(strfind(parametersParadigm.aConditionsRetrievalChange{ccrcs}, strNoChange))
        accuracyNoChange = subjectPerformanceData.conditionRetrievalChangeAccuracy(ccrcs);
    end
    if ~isempty(strfind(parametersParadigm.aConditionsRetrievalChange{ccrcs}, strChange))
        accuracyChange = subjectPerformanceData.conditionRetrievalChangeAccuracy(ccrcs);
    end
    if ccrcs / 2 == ccrs
        subjectPerformanceData.conditionRetrievalCowansK(ccrs) = computeCowansK(wmLoad, accuracyNoChange, accuracyChange);
    end
end

% Compute overall accuracy and reaction time
for cgbp = 1:parametersAnalysisBehavioralData.nGlobalBehavioralParameters
    strGlobalBehavioralParameter = parametersAnalysisBehavioralData.aStrOverallBehavioralParameter{cgbp};
    for cbbp = 1:parametersAnalysisBehavioralData.nBasicBehavioralParameters
        strBasicBehavioralParameter = parametersAnalysisBehavioralData.aStrBasicBehavioralParameter{cbbp};
        if ~isempty(strfind(strGlobalBehavioralParameter, strBasicBehavioralParameter))
            break
        end
    end
    subjectPerformanceData.(strGlobalBehavioralParameter) = mean(subjectPerformanceData.(genvarname(strcat(parametersAnalysisBehavioralData.strCondition, strBasicBehavioralParameter))));
end

% Reorder fields in subjectPerformanceData 
subjectPerformanceData = rearrangeFieldsInSubjectPerformanceDataATMW1(parametersAnalysisBehavioralData, subjectPerformanceData);

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

function saveBehavioralDataATWM1(parametersParadigm, trialDataRun, strBehavioralDataFile, strPathBehavioralDataFile);

global iStudy
global iSubject

% Combine the trial data from all runs and conditions into a single
% array 'aTrialData' 
counterTrials = 0;
for cco = 1:parametersParadigm.nConditions
    for cr = 1:parametersParadigm.nRunsPerCondition(cco)
        aStrFieldNames = fieldnames(trialDataRun{cco}{cr});
        previousCounterTrials = counterTrials;
        counterTrials = counterTrials + parametersParadigm.nTrialsPerRun;
        for cfn = 1:length(aStrFieldNames)
            aTrialData.(genvarname(aStrFieldNames{cfn}))(previousCounterTrials + 1:counterTrials) = trialDataRun{cco}{cr}.(genvarname(aStrFieldNames{cfn}));
        end
    end
end

% Write the trial data into a m-file
save(strPathBehavioralDataFile, 'aTrialData')
strMessage = sprintf('\nSaving file %s\n', strBehavioralDataFile);
disp(strMessage);

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

function tempTrialData = determineTrialAccuracyATWM1(parametersParadigm, tempTrialData);

% Determine, whether an answer was correct
for ct = 1:parametersParadigm.nTrialsPerRun
    trialInfo = tempTrialData.strTrialInfoEncoding{ct};
    
    recordedResponse = tempTrialData.response(ct);
    for cci = 1:length(parametersParadigm.aStrChange)
        if strcmp(tempTrialData.change{ct}, parametersParadigm.aStrChange{cci}) == 1
            expectedResponse = parametersParadigm.vValidResponses(cci);
        end
    end
    
    if recordedResponse == expectedResponse
        tempTrialData.iTrialAccuracy(ct) = parametersParadigm.iCorrectResponse;
    elseif recordedResponse == parametersParadigm.missingResponse
        tempTrialData.iTrialAccuracy(ct) = parametersParadigm.iMissingResponse;
    else
        tempTrialData.iTrialAccuracy(ct) = parametersParadigm.iIncorrectResponse;
    end
end

end

function tempTrialData = calculateTrialReactionTimeATWM1(parametersParadigm, tempTrialData);
% Calculate the reaction time for each trial and transform it to
% millisecond time scale

for ct = 1:parametersParadigm.nTrialsPerRun
    reactionTime = tempTrialData.responseOnset(ct) - tempTrialData.retrievalOnset(ct);
    % Set to millisecond time scale
    reactionTime = reactionTime * 0.1;      
    tempTrialData.reactionTime(ct) = reactionTime;
end

end

function tempTrialData = addTrialInformationATWM1(parametersParadigm, tempTrialData, strBehavioralDataFile, cr);

for ct = 1:parametersParadigm.nTrialsPerRun
    trialInfo = tempTrialData.strTrialInfoEncoding{ct};
    
    % Extract and add the trial number
    vSeparator = strfind(trialInfo, '_');
    trialNumber = str2double(trialInfo(1:(vSeparator(1)-1)));
    if trialNumber == ct
        tempTrialData.iTrial(ct) = trialNumber;
    else
        strMessage = sprintf('\nError while processing file %s!\nexpected and extraced trial numbers not matching\n', strBehavioralDataFile);
    end
    
    % Add the run number
    tempTrialData.iRun(ct) = cr;
    
    % Add salience condition
    for csc = 1:length(parametersParadigm.aSalienceConditions)
        if ~isempty(strfind(trialInfo, parametersParadigm.aSalienceConditions{csc}))
            tempTrialData.salienceCondition{ct} = parametersParadigm.aSalienceConditions{csc};
        end
    end
    
    % Add cue condition
    for ccc = 1:length(parametersParadigm.aCueConditions)
        strCueConditionIndex = sprintf('_%s_', parametersParadigm.aCueConditions{ccc});
        if ~isempty(strfind(trialInfo, strCueConditionIndex))
            tempTrialData.cueCondition{ct} = parametersParadigm.aCueConditions{ccc};
        end
    end
    
    % Add retrieval 
    for crs = 1:length(parametersParadigm.aStrRetrieval)
        strRetrieval = sprintf('_%s_', parametersParadigm.aStrRetrieval{crs});
        if ~isempty(strfind(trialInfo, strRetrieval))
            tempTrialData.retrieval{ct} = parametersParadigm.aStrRetrieval{crs};
        end
    end
    
    % Add change 
    for ccs = 1:length(parametersParadigm.aStrChange)
        strChange = sprintf('_%s_', parametersParadigm.aStrChange{ccs});
        if ~isempty(strfind(trialInfo, strChange))
            tempTrialData.change{ct} = parametersParadigm.aStrChange{ccs};
        end
    end
   
    % Add condition name
    for cc = 1:parametersParadigm.nConditions
        if ~isempty(strfind(trialInfo, parametersParadigm.aConditions{cc}))
            tempTrialData.condition{ct} = parametersParadigm.aConditions{cc};
        end
    end
    
    % Add conditionChange 
    for cccs = 1:parametersParadigm.nConditionsChange
        if ~isempty(strfind(trialInfo, parametersParadigm.aConditionsChange{cccs}))
            tempTrialData.conditionChange{ct} = parametersParadigm.aConditionsChange{cccs};
        end
    end
    
    % Add conditionRetrieval 
    for cc = 1:parametersParadigm.nConditions
        for crs = 1:length(parametersParadigm.aStrRetrieval)
            strRetrieval = strcat('_', parametersParadigm.aStrRetrieval{crs});
            if ~isempty(strfind(trialInfo, parametersParadigm.aConditions{cc})) && ~isempty(strfind(trialInfo, strRetrieval))
                tempTrialData.conditionRetrieval{ct} = strcat(tempTrialData.condition{ct}, '_', tempTrialData.retrieval{ct});
            end
        end
    end
    
    % Add conditionRetrievalChange 
    for cccs = 1:parametersParadigm.nConditionsChange
        for crs = 1:length(parametersParadigm.aStrRetrieval)
            strRetrieval = strcat('_', parametersParadigm.aStrRetrieval{crs});
            if ~isempty(strfind(trialInfo, parametersParadigm.aConditionsChange{cccs})) && ~isempty(strfind(trialInfo, strRetrieval))
                tempTrialData.conditionRetrievalChange{ct} = strcat(tempTrialData.condition{ct}, '_', tempTrialData.retrieval{ct}, '_', tempTrialData.change{ct});
            end
        end
    end
end

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


