function checkLogfilesATWM1_PSY_EXP8()
%%% Check, whether all presentation logfiles for EXP8 of a subject exist.

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




%parametersStudy.indBehavioralStudy                  = contains(parametersStudy.aStrStudies, parametersStudy.strBehavioralStudy);
%parametersStudy.indImagingStudy                     = contains(parametersStudy.aStrStudies, parametersStudy.strImaging);
%parametersStudy.indDefaultStudy                     = parametersStudy.indImagingStudy;



parametersParadigm                  = feval(str2func(strcat('parametersParadigm', iStudy, '_', parametersStudy.strPsychophysics, '_', parametersStudy.strExperiment, num2str(parametersStudy.experimentNumber))));
%parametersAnalysisBehavioralData    = feval(str2func(strcat('parametersAnalysisBehavioralData', iStudy)));
parametersParadigm.strExperiment    = strcat(iStudy, '_', parametersStudy.strPsychophysics, '_', parametersStudy.strExperiment, num2str(parametersStudy.experimentNumber));

parametersStudy.strBehavioralStudy = sprintf('%s_%s', iStudy, parametersStudy.strPsychophysics);

strFolderLogfileCheck = 'D:\Daten\ATWM1\PSY_Behavioral_Data\Logfile_Check\';
strLogFilesFolderName	= 'D:\Daten\ATWM1\PSY_Presentation_Logfiles\';


%%% Load subject names
hFunction = str2func(strcat('aSubject', iStudy, '_', parametersStudy.strPsychophysics));
aSubject = feval(hFunction);

hFunction = str2func(sprintf('prepareGroupInformation%s_%s', iStudy, parametersStudy.strPsychophysics));
[aSubject] = feval(hFunction, aSubject, parametersStudy);


%%% Open options dialog
strQuestion = 'Process logfiles of all subjects or of selected subjects';
strTitle = 'Mode of logfile processing';
strOption1 = 'Selected subject';
strOption2 = 'All subjects';
defaultOption = strOption1;
strSelectedOption = questdlg(strQuestion, strTitle , strOption1, strOption2, defaultOption);
switch strSelectedOption
    case strOption1
        bProcessSingleSubject   = true;
        bProcessAllSubjects     = false;
        strMode = strrep(strOption1, ' ', '_');
    case strOption2
        bProcessSingleSubject   = false;
        bProcessAllSubjects     = true;
        strMode = strrep(strOption2, ' ', '_');
    otherwise
        error('No option selected!\n');
end

if bProcessSingleSubject
    %%% Select subject whose logfiles need to be checked
    %%% Select group
    [iSelectedGroup] = listdlg('ListString',aSubject.strGroupLabel);
    aStrSubjects = sort(aSubject.(matlab.lang.makeValidName(aSubject.aStrGroupVariableName{iSelectedGroup})));
    %%% Select subject
    [iSelectedSubject] = listdlg('ListString',aStrSubjects);
    aStrSubjects = {aStrSubjects{iSelectedSubject}};
elseif bProcessAllSubjects
    aStrSubjects = aSubject.ALL;
end

nrOfSubjects = numel(aStrSubjects);

%%% Define name of file for logfile check results
strLogfileCheck = 'Logfile_Check_Results';
if nrOfSubjects > 1
    strFileLogfileCheck = sprintf('%s_%s_%s.txt', parametersStudy.strBehavioralStudy, strLogfileCheck, strMode);
else
    strFileLogfileCheck = sprintf('%s_%s_%s_%s.txt', parametersStudy.strBehavioralStudy, strLogfileCheck, strMode, aStrSubjects{1});
end

strPathLogfileCheck = fullfile(strFolderLogfileCheck, strFileLogfileCheck);
fid = fopen(strPathLogfileCheck, 'wt');

for cs = 1:nrOfSubjects
    iSubject = aStrSubjects{cs};
    cMissingFiles = 0;
    for cco = 1:parametersParadigm.nConditions
        for cr = 1:parametersParadigm.nRunsPerCondition(cco)
            strLogFileName = strcat(iSubject, '-', iStudy, '_', parametersStudy.strExperiment, num2str(parametersStudy.experimentNumber), '_', parametersStudy.strPsychophysics, '_', parametersParadigm.aConditions{cco}, '_', parametersStudy.strRun, num2str(parametersParadigm.iFullRuns(cr)), '.log');                strLogFilePath = strcat(strLogFilesFolderName, strLogFileName);
            if ~exist(strLogFilePath, 'file')
                strFileCheckResult = sprintf('Could not open %s\n', strLogFilePath);
                fprintf(fid, '%s', strFileCheckResult);
                disp(strFileCheckResult);
                cMissingFiles = cMissingFiles + 1;
                continue
            end
        end
    end
    
    if cMissingFiles > 0
        strOverallCheckResult = sprintf('Error: Missing files for subject %s!\n\n', iSubject);
        fprintf(fid, '%s', strOverallCheckResult);
        disp(strOverallCheckResult);
    else
        strOverallCheckResult = sprintf('Data files complete for subject %s!\n\n', iSubject);
        fprintf(fid, '%s', strOverallCheckResult);
        disp(strOverallCheckResult);
    end
end
fclose(fid);

end


function [aSubject] = prepareGroupInformationATWM1_PSY(aSubject, parametersStudy)
% Group information is processed
% If only a single group exists and aSubjects is not a structure, aSubjects
% is transformed into a structure with one field carrying the name of the
% default group name.

%global iStudy

aSubject = aSubject.(matlab.lang.makeValidName(parametersStudy.strBehavioralStudy)).Groups;
if isstruct(aSubject) ~= 1
    aSubjectTemp = aSubject;
    clear aSubject;
    aSubject.(parametersStudy.defaultGroupName) = aSubjectTemp;
end
aSubject.aStrGroupVariableName = fieldnames(aSubject);
aSubject.nGroups = length(aSubject.aStrGroupVariableName);
for cg = 1:aSubject.nGroups
    strGroupNameCapitalLetters = upper(aSubject.aStrGroupVariableName{cg});
    aSubject.strShortGroupLabel{cg} = strGroupNameCapitalLetters(1:3);
    aSubject.strGroupLabel{cg} = regexprep(aSubject.aStrGroupVariableName{cg}, aSubject.aStrGroupVariableName{cg}(1), upper(aSubject.aStrGroupVariableName{cg}(1)), 'once');
    aSubject.nSubjects(cg) = length(aSubject.(matlab.lang.makeValidName(aSubject.aStrGroupVariableName{cg})));
end

%%% Create a single array containing subject codes for all groups
aStrAllSubjects = [];
for cg = 1:aSubject.nGroups
    aStrSubjectsGroup = aSubject.(matlab.lang.makeValidName(aSubject.strGroupLabel{cg}));
    aStrAllSubjects = [aStrAllSubjects, aStrSubjectsGroup'];
end
aSubject.ALL = aStrAllSubjects';

end