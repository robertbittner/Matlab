function synchLocalAndServerSubjectArrayATWM1

%%% Load parameters
clear all
clc

global iStudy
global strSubject
global strGroup
global iSession

global bTestConfiguration

iStudy = 'ATWM1';

bTestConfiguration = false;
%bTestConfiguration = true;

folderDefinition            = eval(['folderDefinition', iStudy]);
parametersStudy             = eval(['parametersStudy', iStudy]);
parametersDialog            = eval(['parametersDialog', iStudy]);
%parametersDicomFiles        = eval(['parametersDicomFiles', iStudy]);
parametersFileTransfer      = eval(['parametersFileTransfer', iStudy]);
parametersProjectFiles      = eval(['parametersProjectFiles', iStudy]);
parametersGroups            = eval(['parametersGroups', iStudy])

parametersParadigm_WM_MRI   = eval(['parametersParadigm_WM_MRI_', iStudy]);

parametersStructuralMriSequenceHighRes  = eval(['parametersStructuralMriSequenceHighRes', iStudy]);
%parametersStructuralMriSequenceLowRes   = eval(['parametersStructuralMriSequenceLowRes', iStudy]);
%parametersFunctionalMriSequence_WM      = eval(['parametersFunctionalMriSequence_WM_', iStudy]);
%parametersFunctionalMriSequence_LOC     = eval(['parametersFunctionalMriSequence_LOC_', iStudy]);
%parametersFunctionalMriSequence_COPE    = eval(['parametersFunctionalMriSequence_COPE_', iStudy]);



nrOfSubjectsGroupMerged = [86     9     0     1     0    95]
maxNrOfSubjects = [86     9     0     0     0    95]
if ~isequal(nrOfSubjectsGroupMerged, maxNrOfSubjects)
    for cg = 1:numel(nrOfSubjectsGroupMerged(1:end-1))
        if nrOfSubjectsGroupMerged(cg) ~= maxNrOfSubjects(cg)
            fprintf('Discrepant subject number in group: %s\n', parametersGroups.aStrLongGroups{cg}); 
            if nrOfSubjectsGroupMerged(cg) > maxNrOfSubjects(cg)
                fprintf('Error!\nNumber of subjects in merged group: %s\nhigher than expected!\n\n', parametersGroups.aStrLongGroups{cg});
            end
        end
    end
end
%vDiffNrOfSubjects = vDiffNrOfSubjects

%tessdksdk= parametersGroups.aStrLongGroups{vDiffNrOfSubjects}
%test = fprintf('%s\n', parametersGroups.aStrLongGroups{vDiffNrOfSubjects}); 

return

%%% MOVE TO CALLING FUNCTION
%%% Define study (behavioral or imaging)
parametersStudy.strCurrentStudy                     = parametersStudy.aStrStudies{parametersStudy.indImagingStudy};
%%% MOVE TO CALLING FUNCTION

%%% REMOVE
fprintf('WARNING TEST COPY OF SERVER VERSION ACTIVATED!\n');
strSubjectArray = strcat('aSubject', parametersStudy.strCurrentStudy);
strFileSubjectArray = strcat(strSubjectArray, '.m');
strPathSubjectArrayServer       = fullfile('D:\Daten\ATWM1\_TEST\Server\Study_Parameters\', strFileSubjectArray);
strDummyArray = 'aSubjectATWM1_IMAGING - Kopie.m';
strPathDummyArray = fullfile('D:\Daten\ATWM1\_TEST\Server\Study_Parameters\', strDummyArray);
copyfile(strPathDummyArray, strPathSubjectArrayServer)
%%% REMOVE


%%% Load additional folder definitions
hFunction = str2func(sprintf('addServerFolderDefinitions%s', iStudy));
folderDefinition = feval(hFunction, folderDefinition);

%%% Access server
[~] = checkLocalComputerFolderAccessATWM1(folderDefinition);

%%% Read subject code files from server
strucSubjCode = readSubjectsCodeFilesATWM1(folderDefinition, parametersGroups, folderDefinition.strServer);

%%% Load local and server subject array
aSubjectLocal   = processSubjectArrayATWM1(parametersStudy, folderDefinition.strLocal);
aSubjectServer  = processSubjectArrayATWM1(parametersStudy, folderDefinition.strServer);

%%% Compare local and server subject data
aStrGroupFieldnamesLocal = fieldnames(aSubjectLocal.(matlab.lang.makeValidName(parametersStudy.strCurrentStudy)).Groups);
aStrGroupFieldnamesServer = fieldnames(aSubjectServer.(matlab.lang.makeValidName(parametersStudy.strCurrentStudy)).Groups);
if ~isempty(find(~find(strcmp(aStrGroupFieldnamesLocal, aStrGroupFieldnamesServer)), 1))
    error('Group names do not match for local and server version!\n');
end

%%% Detect groups with differing subjects
for cfn = 1:numel(aStrGroupFieldnamesLocal)
    nrOfSubjectsGroupLocal(cfn)    = aSubjectLocal.(matlab.lang.makeValidName(parametersStudy.strCurrentStudy)).nSubjects.(matlab.lang.makeValidName(aStrGroupFieldnamesLocal{cfn}));
    nrOfSubjectsGroupServer(cfn)   = aSubjectServer.(matlab.lang.makeValidName(parametersStudy.strCurrentStudy)).nSubjects.(matlab.lang.makeValidName(aStrGroupFieldnamesServer{cfn}));
    %{
    if isequal(nSubjectsGroupLocal(cfn), nSubjectsGroupServer(cfn))
        vDiffNrOfSubjects(cfn) = 0;
    else
        vDiffNrOfSubjects(cfn) = 1;
    end
    %}
    %%% Determine higher number of subjects for group
    maxNrOfSubjects(cfn) = max([nrOfSubjectsGroupLocal(cfn), nrOfSubjectsGroupServer(cfn)])
end

for cfn = 1:numel(aStrGroupFieldnamesLocal)
    aSubjectsGroupLocal{cfn}        = aSubjectLocal.(matlab.lang.makeValidName(parametersStudy.strCurrentStudy)).Groups.(matlab.lang.makeValidName(aStrGroupFieldnamesLocal{cfn}));
    aSubjectsGroupServer{cfn}       = aSubjectServer.(matlab.lang.makeValidName(parametersStudy.strCurrentStudy)).Groups.(matlab.lang.makeValidName(aStrGroupFieldnamesServer{cfn}));
    aSubjectsGroupMerged{cfn}       = union(aSubjectsGroupLocal{cfn}, aSubjectsGroupServer{cfn});
    nrOfSubjectsGroupMerged(cfn)    = numel(aSubjectsGroupMerged{cfn})
end

test = isequal(maxNrOfSubjects, nrOfSubjectsGroupMerged)

%%% Combine information


%%% Create new array


%%% Create local and server copy of array






end