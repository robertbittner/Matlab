function checkLogfilesATWM1_PSY_EXP8 ();
% ATWM1
% Check, whether all presentation logfiles for EXP8 of a subject exist.


clear all;
clc;

global iStudy
global iSubject

iStudy = 'ATWM1';

% Specifies the psychophysical experiment
experimentNumber = 8;

folderDefinition        = feval(str2func(strcat('folderDefinition', iStudy)));
parametersStudy         = feval(str2func(strcat('parametersStudy', iStudy)));

% Specifies the psychophysical experiment
parametersStudy.experimentNumber = experimentNumber;


parametersParadigm                  = feval(str2func(strcat('parametersParadigm', iStudy, '_', parametersStudy.iPsychophysics, '_', parametersStudy.iExperiment, num2str(parametersStudy.experimentNumber))));
parametersAnalysisBehavioralData    = feval(str2func(strcat('parametersAnalysisBehavioralData', iStudy)));
parametersParadigm.strExperiment    = strcat(iStudy, '_', parametersStudy.iPsychophysics, '_', parametersStudy.iExperiment, num2str(parametersStudy.experimentNumber));

%{
hFunction = str2func(sprintf('selectReprocessingOption%s', iStudy));
[bReprocessAllData, bAbortFunction] = feval(hFunction, iStudy, parametersStudy);
if bAbortFunction == true
    strMessage = sprintf('No valid option selected. Script cannot be executed properly!');
    disp(strMessage);
    return
end
%}

aSubject = feval(str2func(strcat('aSubject', iStudy)));


hFunction = str2func(sprintf('prepareGroupInformation%s', iStudy));
[aSubject, nGroups, nSubjects] = feval(hFunction, parametersStudy, parametersParadigm, aSubject);

%test = aSubject

%{
aStrSubjectLists = {
    'ATWM1_PSY_EXP8'
    };
%}
[iSelectedGroup,ok] = listdlg('ListString',aSubject.strGroupLabel);

aStrSubjects = sort(aSubject.(genvarname(aSubject.aStrGroupVariableName{iSelectedGroup})));

[iSelectedSubject,ok] = listdlg('ListString',aStrSubjects);
%}
% This needs to be removed
%{
aSubject = {
    'ANGELIKA_TEST'
    };
%}



strLogFilesFolderName	= strcat(folderDefinition.logFiles, parametersStudy.iPsychophysics, '\', parametersStudy.iExperiment, num2str(parametersStudy.experimentNumber), '\');
strResultsFolderName	= strcat(folderDefinition.behavioralData, parametersStudy.iPsychophysics, '\', parametersStudy.iExperiment, num2str(parametersStudy.experimentNumber), '\');


%%% Check completness of data
%for cg = 1:nGroups
% Process the log files and save the trial data
%for cs = 1:nSubjects(cg)

%iSubject = aSubject.(genvarname(aSubject.aStrGroupVariableName{cg})){cs};
iSubject = aStrSubjects{iSelectedSubject};%aSubject.(genvarname(aSubject.aStrGroupVariableName{cg})){cs};

%strBehavioralDataFile = sprintf('%s_%s_%s_%s%i_BehavioralData.mat', iSubject, iStudy, parametersStudy.iPsychophysics, parametersStudy.iExperiment, parametersStudy.experimentNumber);
%strPathBehavioralDataFile = strcat(strResultsFolderName, strBehavioralDataFile);
cMissingFiles = 0;
for cco = 1:parametersParadigm.nConditions
    for cr = 1:parametersParadigm.nRunsPerCondition(cco)
        strLogFileName = strcat(iSubject, '-', iStudy, '_', parametersStudy.iExperiment, num2str(parametersStudy.experimentNumber), '_', parametersStudy.iPsychophysics, '_', parametersParadigm.aConditions{cco}, '_', parametersStudy.iRun, num2str(parametersParadigm.iFullRuns(cr)), '.log');                strLogFilePath = strcat(strLogFilesFolderName, strLogFileName);
        if ~exist(strLogFilePath, 'file')
            strMessage = sprintf('\nCould not open %s\n', strLogFilePath);
            disp(strMessage);
            cMissingFiles = cMissingFiles + 1;
            continue
        end
    end
end

if cMissingFiles > 0
            strMessage = sprintf('\nError: Missing files for subject %s!\n', iSubject);
            disp(strMessage);
else
    
            strMessage = sprintf('\nData files complete for subject %s!\n', iSubject);
            disp(strMessage);
end
%   end
%end
%}


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