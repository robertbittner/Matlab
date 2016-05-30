function computeBehavioralDataATWM1_LOC ();
% ATWM1
% Analyze localizer presentation logfiles

clear all
clc

global iStudy

iStudy = 'ATWM1';

folderDefinition = eval(['folderDefinition', iStudy]);

aStrTargetStimulus = {
    'YELLOW_ALL'
    'YELLOW'
    'GREY_ALL'
    };

strFolderLogFiles = 'D:\Daten\ATWM1\Presentation_Logfiles\Localizer\';

%strLogFile = 'ADAL89-ATWM1_PSYPHY_LOCALIZER_TARGET_GREY_ALL.log';
%strLogFile = 'ADAL89-ATWM1_PSYPHY_LOCALIZER_TARGET_YELLOW_ALL.log';
%strLogFile = 'ADAL89-ATWM1_PSYPHY_LOCALIZER_TARGET_YELLOW.log';

aSubjects = {
    %%{
    'RANY93'
    'LEIN75'
    'ANCH81'
    'EREL59'
    %}
    %'ADAL89'
    
    };

nSubjects = numel(aSubjects);

nGroups = 1;

for cg = 1:nGroups
    for cs = 1:nSubjects
        iSubject = aSubjects{cs};
        for cts = 1:numel(aStrTargetStimulus)
            strLogFile = sprintf('%s-%s_PSYPHY_LOCALIZER_TARGET_%s.log', iSubject, iStudy, aStrTargetStimulus{cts});
            %strLogFile = 'TEST_YELLOW_ALL.log'
            
            pathLogFile = strcat(strFolderLogFiles, strLogFile);
            
            logfileData{cg, cs, cts} = readLogfilesLocalizerATWM1(pathLogFile);
            %{
        logfileData.nTotalTargetTrials  = nTargetTrials;
        logfileData.nTotalHits          = nHits;
        logfileData.nTotalMisses        = nMisses;
        logfileData.nTotalFalseAlarms   = nFalseAlarms;
            %}
            
        end
    end
end



[strSpssBehavioralDataFile, strExcelBehavioralDataFile, successTextFileCreation, successExcelFileCreation] = writeComputedBehavioralDataLocalizerToFileATWM1(aSubjects, nGroups, nSubjects, logfileData, aStrTargetStimulus);


end


function logfileData = readLogfilesLocalizerATWM1(pathLogFile);

global iStudy


parametersLocalizer = eval(['parametersLocalizer', iStudy]);


fid = fopen(pathLogFile, 'rt');


%%% Set intial values
bTargetTrial            = false;
bTargetTrialOneBack     = false;
bTargetTrialTwoBack     = false;
bResponse               = false;
bValidResponseRecorded  = false;
bResponseExpected       = false;

nTargetTrials   = 0;
nHits           = 0;
nMisses         = 0;
nFalseAlarms    = 0;


for c = 1:5
    strLine = fgetl(fid);
end

while ~feof(fid)
    
    strLine = fgetl(fid);
    
    % ADAL89	258	Picture	128_4_Objects_Pos3_TargetTrial	3703679	0	1	1506	2	0	1330	other	0
    % ADAL89	256	Picture	127_4_Objects_Pos1_DefaultTrial	3685940	0	1	1506	2	0	1330	other	0
    % ADAL89	14	Response	10	355041	15796	1
    
    text = textscan(strLine, '%s %s %s %s %s %*[^\n]');
    
    strSubject          = char(text{1});
    iPresentationTrial  = str2double(text{2}{1});
    strEventType        = text{3}{1};
    strTrialInfo        = text{4}{1};
    recordedTime        = str2num(text{5}{1});
    
    
    %%% Determine event type
    if strfind(strEventType, parametersLocalizer.strPicturePresentation)
        bPicture    = true;
        bResponse   = false;
    elseif strcmp(strEventType, parametersLocalizer.strResponse)
        bPicture    = false;
        bResponse   = true;
    end
    
    %{
    if bTargetTrialOneBack == true && bResponseExpected == true && bResponse == false
        nMisses = nMisses + 1;
    end
    %}
    
    %{
    %%% Determine whether the trial two back was a target trial
    if  bTargetTrialOneBack == true
        bTargetTrialTwoBack = true;
    else
        bTargetTrialTwoBack = false;
    end
    %}
    

    
    
    %%% Determine whether the trial one back was a target trial
    if bTargetTrial == true && bPicture == true
        bTargetTrialOneBack = true;
        index = iPresentationTrial;
    elseif bTargetTrial == false && bPicture == true
        bTargetTrialOneBack = false;
        index = iPresentationTrial;
    end
    
    %%% Determine whether trial is a target trial and whether a
    %%% response is exptected
    if ~isempty(strfind(strTrialInfo, parametersLocalizer.strTargetTrial)) && bPicture == true
        bTargetTrial = true;
        nTargetTrials = nTargetTrials + 1;
        bResponseExpected = true;
    elseif isempty(strfind(strTrialInfo, parametersLocalizer.strTargetTrial)) && bPicture == true
        bTargetTrial = false;
        if bTargetTrialOneBack == true && bValidResponseRecorded == false
            bResponseExpected = true;
        elseif bTargetTrialOneBack == true && bValidResponseRecorded == true
            bResponseExpected = false;
        end
    end
    
    %%% Evaluate a response
    if bResponse == true && bTargetTrial == true && bResponseExpected == true
        nHits = nHits + 1;
        bValidResponseRecorded = true;
    elseif bResponse == true && bTargetTrialOneBack == true && bResponseExpected == true
        nHits = nHits + 1;
        bValidResponseRecorded = true;
    elseif bResponse == true && bTargetTrial == false && bResponseExpected == false
        nFalseAlarms = nFalseAlarms + 1;
        bValidResponseRecorded = false;
    end
    
    %resp = bValidResponseRecorded == false
    %indesx = iPresentationTrial
    
    %{
    %%% Reset response tracker
    if bTargetTrialOneBack == true && bValidResponseRecorded == true;
        bValidResponseRecorded = false;
        bResponseExpected = false;
    end
    %}
    
    %{
    %%% Counted missed  targets
    if bTargetTrialOneBack == true && bResponseExpected == true && bValidResponseRecorded == false
        nMisses = nMisses + 1;
        index = iPresentationTrial;
        %bValidResponseRecorded = false
    %elseif bTargetTrialTwoBack == true && bResponseExpected == true && bValidResponseRecorded == false
    %    nMisses = nMisses + 1;
        %bValidResponseRecorded = false
    end
    %}
    %{
    if bTargetTrialOneBack == true && bValidResponseRecorded == true;
        bValidResponseRecorded = false;
        bResponseExpected = false;
    end
    %}
    %{
    tril = iPresentationTrial
    resp = bValidResponseRecorded
    oneback = bTargetTrialOneBack
    %}
end


logfileData.nTotalTargetTrials  = nTargetTrials;
logfileData.nTotalHits          = nHits;
logfileData.nTotalMisses        = nTargetTrials - nHits;
logfileData.nTotalFalseAlarms   = nFalseAlarms;
logfileData.nHitPercentage      = nHits / nTargetTrials

end



function [strSpssBehavioralDataFile, strExcelBehavioralDataFile, successTextFileCreation, successExcelFileCreation] = writeComputedBehavioralDataLocalizerToFileATWM1(aSubjects, nGroups, nSubjects, logfileData, aStrTargetStimulus);;
% The behavioral data are stored in a txt-file and xlsx-file using a SPSS
% compatible format


global iStudy



successTextFileCreation = '';
successExcelFileCreation = '';

folderDefinition = eval(['folderDefinition', iStudy]);
parametersLocalizer = eval(['parametersLocalizer', iStudy]);


parametersStudy.iLocalizer = 'LOC';

%%{
%aStrVars = fieldnames(subjectPerformanceData);
if nGroups > 1
    strGroup = 'groups';
else
    strGroup = 'group';
end
%}

% Define file names and paths
%strSpssBehavioralDataFile = sprintf('%s_%s_%s%i_%i_%s_%i_subj_BHD_SPSS.txt', iStudy, parametersStudy.iPsychophysics, parametersStudy.iExperiment, parametersStudy.experimentNumber, nGroups, strGroup, sum(nSubjects));
strSpssBehavioralDataFile = sprintf('%s_%s_%i_%s_%i_subj_BHD_SPSS.txt', iStudy, parametersStudy.iLocalizer, nGroups, strGroup, sum(nSubjects));
pathSpssBehavioralDataFile = strcat(folderDefinition.behavioralData, strSpssBehavioralDataFile);

strExcelBehavioralDataFile = sprintf('%s_%s_%i_subj_BHD_SPSS.xlsx', iStudy, parametersStudy.iLocalizer, nGroups, strGroup, sum(nSubjects));
strPathExcelBehavioralDataFile = strcat(folderDefinition.behavioralData, strExcelBehavioralDataFile);

% Define the labels
aStrLabelCondition = {};
counterLabel = 0;
for cts = 1:length(aStrTargetStimulus)
    for cbp = 1:numel(parametersLocalizer.aStrBehavioralParameters)
        counterLabel = counterLabel + 1;
        aStrLabelCondition{counterLabel} = sprintf('%s_%s', aStrTargetStimulus{cts}, parametersLocalizer.aStrBehavioralParameters{cbp});
    end
end


% The column labels printed in the top row are created
% 1: general information
columnLabelInitialRows = {'Group_Number', 'Group_Label', 'Subject'};
columnLabelInitialRows = {'Subject'};
% 2: names of each condition and analysis parameter
columnLabel = [columnLabelInitialRows, aStrLabelCondition];



%%{
% Write the data of each subject into one row
for cg = 1:nGroups
    for cs = 1:nSubjects
        row = [];
        for cts = 1:numel(aStrTargetStimulus)
            row = [row, logfileData{cg, cs, cts}.nTotalHits];
            row = [row, logfileData{cg, cs, cts}.nHitPercentage];
            row = [row, logfileData{cg, cs, cts}.nTotalMisses];
            row = [row, logfileData{cg, cs, cts}.nTotalFalseAlarms];
            
        end
        dataRow(cg, cs, :) = row;
    end
end

% Create the txt-file
fid = fopen(pathSpssBehavioralDataFile, 'wt');

if fid == -1
    error('Could not create file %s', strOutputPath);
end

%%{
% Write the column labels into the txt-file
fprintf(fid,'%s \t', columnLabel{:});
fprintf(fid,'\n');
for cg = 1:nGroups
    for cs = 1:nSubjects
        strSubject = aSubjects{cs};
        %{
        strSubject = aSubject.(genvarname(aSubject.aStrGroupVariableName{cg})){cs};
        
        fprintf(fid,'%i\t', cg);
        fprintf(fid,'%s\t', aSubject.strShortGroupLabel{cg});
        fprintf(fid,'%s\t', strSubject);
        %}
        fprintf(fid,'%s\t', strSubject);
        fprintf(fid,'%.4f\t', dataRow(cg, cs, :));
        %fprintf(fid,'%i\t', dataRow(cg, cs, :));
        fprintf(fid,'\n');
    end
end
%}
successTextFileCreation = fclose(fid);

%}

end