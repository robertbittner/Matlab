function aSubject = processSubjectArrayATWM1(parametersStudy, varargin)
%%%

global iStudy

folderDefinition        = eval(['folderDefinition', iStudy]);
parametersGroups        = eval(['parametersGroups', iStudy]);

%%% Specify the source (Local or Server). The defauls source is Local. 
if isempty(varargin)
    strSource = folderDefinition.strLocal;
else
    strSource = varargin{1};
end

[folderDefinition, aSubject, strSource] = loadSubjectArrayATWM1(folderDefinition, parametersStudy, strSource);

%%% Check whether subject labels match the predefined labels
aStrShortGroups = parametersGroups.aStrShortGroups;
aStrGroupFieldnames = fieldnames(aSubject.(matlab.lang.makeValidName(parametersStudy.strCurrentStudy)).Groups);
if ~isempty(setxor(aStrGroupFieldnames, aStrShortGroups))
    error('Group labels do not match the prespecified labels!')
end

%%% Write all subject IDs of all groups in a single array
aStrAllSubjectNames = {};
for cfn = 1:numel(aStrGroupFieldnames)
    aStrSubjectNameGroup{cfn} = aSubject.(matlab.lang.makeValidName(parametersStudy.strCurrentStudy)).(matlab.lang.makeValidName(parametersGroups.strGroups)).(matlab.lang.makeValidName(aStrGroupFieldnames{cfn}));
    aStrAllSubjectNames = [aStrAllSubjectNames, aStrSubjectNameGroup{cfn}'];
end
aSubject.(matlab.lang.makeValidName(parametersStudy.strCurrentStudy)).(matlab.lang.makeValidName(parametersGroups.strGroups)).ALL = (sort(aStrAllSubjectNames))';

%%% Check, whether all subject IDs are unique
aStrUniqueSubjects = unique(aSubject.(matlab.lang.makeValidName(parametersStudy.strCurrentStudy)).(matlab.lang.makeValidName(parametersGroups.strGroups)).ALL);
if numel(aSubject.(matlab.lang.makeValidName(parametersStudy.strCurrentStudy)).(matlab.lang.makeValidName(parametersGroups.strGroups)).ALL) ~= numel(aStrUniqueSubjects)
    for cs = 1:numel(aStrUniqueSubjects)
        strSubject = aStrUniqueSubjects{cs};
        if sum(strcmp(strSubject, aSubject.(matlab.lang.makeValidName(parametersStudy.strCurrentStudy)).(matlab.lang.makeValidName(parametersGroups.strGroups)).ALL)) ~= 1
            fprintf('Duplicate entry for subject ID %s detected.\n\n', strSubject);
        end
    end
    error('Duplicate entries detected!')
end

%%% Determine number of subjects in each group and for all groups combined
for cfn = 1:numel(aStrGroupFieldnames)
    aSubject.(matlab.lang.makeValidName(parametersStudy.strCurrentStudy)).nSubjects.(matlab.lang.makeValidName(aStrGroupFieldnames{cfn})) = numel(aStrSubjectNameGroup{cfn});
end
aSubject.(matlab.lang.makeValidName(parametersStudy.strCurrentStudy)).nSubjects.ALL = numel(aStrAllSubjectNames);

%{
%%% Write all subject IDs of all groups in a single array and add group ID
for cfn = 1:numel(aStrGroupFieldnames)
    nSubjects = aSubject.(matlab.lang.makeValidName(parametersStudy.strCurrentStudy)).nSubjects.(matlab.lang.makeValidName(aStrGroupFieldnames{cfn}));
    for cs = 1:nSubjects
        aStrAllSubjectGroupNames{cs} = aStrGroupFieldnames{cfn}
    end
end


%aSubject.(matlab.lang.makeValidName(parametersStudy.strCurrentStudy)).(matlab.lang.makeValidName(parametersGroups.strGroups)).ALL = sort(aStrAllSubjectNames);
%}

end


function [folderDefinition, aSubject, strSource] = loadSubjectArrayATWM1(folderDefinition, parametersStudy, strSource)

global iStudy

%%% Load additional folder definitions
hFunction = str2func(sprintf('addServerFolderDefinitions%s', iStudy));
folderDefinition = feval(hFunction, folderDefinition);

%%% Check server access
if strcmp(strSource, folderDefinition.strServer)
    [~] = checkLocalComputerFolderAccessATWM1(folderDefinition);
end

%%% Load local or server copy of the subject array file of the current
%%% study
strSubjectArray = strcat('aSubject', parametersStudy.strCurrentStudy);
strFileSubjectArray = strcat(strSubjectArray, '.m');

if strcmp(strSource, folderDefinition.strLocal)
    hFunction = str2func(strcat(strSubjectArray));
    %{
    %%% REMOVE
    fprintf('WARNING TEST FOLDERS ACITVATED!\n');
    fprintf('WARNING TEST FOLDERS ACITVATED!\n');
    fprintf('WARNING TEST FOLDERS ACITVATED!\n');
    strPathSubjectArrayLocal        = fullfile(folderDefinition.studyParameters, strFileSubjectArray);
    strPathSubjectArrayLocal        = fullfile('D:\Daten\ATWM1\_TEST\Local\Study_Parameters\', strFileSubjectArray);
    strTempFileSubjectArrayLocal    = strcat('aSubject', folderDefinition.strLocal, parametersStudy.strCurrentStudy, '.m');
    strPathTempSubjectArrayLocal    = fullfile(folderDefinition.studyParameters, strTempFileSubjectArrayLocal);
    copyfile(strPathSubjectArrayLocal, strPathTempSubjectArrayLocal)
    hFunction = str2func(strrep(strTempFileSubjectArrayLocal, '.m', ''));
    %%% REMOVE
    %}
    aSubject = feval(hFunction);
    %{
    %%% REMOVE
    delete(strPathTempSubjectArrayLocal);
    %%% REMOVE
    %}
elseif strcmp(strSource, folderDefinition.strServer)
    strPathSubjectArrayServer       = fullfile(folderDefinition.studyParametersServer, strFileSubjectArray);
    
    %%{
    %%% REMOVE
    strPathSubjectArrayServer       = fullfile('D:\Daten\ATWM1\_TEST\Server\Study_Parameters\', strFileSubjectArray);
    %%% REMOVE
    %}
    
    strTempFileSubjectArrayServer   = strcat('aSubject', folderDefinition.strServer, parametersStudy.strCurrentStudy, '.m');
    strPathTempSubjectArrayServer   = fullfile(folderDefinition.studyParameters, strTempFileSubjectArrayServer);
    copyfile(strPathSubjectArrayServer, strPathTempSubjectArrayServer)
    hFunction = str2func(strrep(strTempFileSubjectArrayServer, '.m', ''));
    aSubject = feval(hFunction);
    delete(strPathTempSubjectArrayServer);
else
    error('No valid source for subject array file specified!');
end
%}

end


