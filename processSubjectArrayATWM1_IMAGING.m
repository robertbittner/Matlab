function aSubject = processSubjectArrayATWM1_IMAGING()

global iStudy

parametersStudy         = eval(['parametersStudy', iStudy]);
parametersGroups        = eval(['parametersGroups', iStudy]);

hFunction = str2func(sprintf('aSubject%s_%s', iStudy, parametersStudy.strImaging));
aSubject = feval(hFunction);

%%% Check whether subject labels match the predefined labels
aStrShortGroups = parametersGroups.aStrShortGroups;
aStrGroupFieldnames = fieldnames(aSubject.(genvarname(strcat(iStudy, '_', parametersStudy.strImaging))).Groups);
if ~isempty(setxor(aStrGroupFieldnames, aStrShortGroups))   
    error('Groups labels in %s.m do not match the labels specified in %s.m!', mfilename, strParmetersGroupFile)
end

%%% Write all subject IDs of all groups in a single array
aStrAllSubjectNames = {};
for cfn = 1:numel(aStrGroupFieldnames)
    aStrSubjectNameGroup{cfn} = aSubject.(genvarname(strcat(iStudy, '_', parametersStudy.strImaging))).(genvarname(parametersGroups.strGroups)).(genvarname(aStrGroupFieldnames{cfn}));
    aStrAllSubjectNames = [aStrAllSubjectNames, aStrSubjectNameGroup{cfn}'];
end
aSubject.(genvarname(strcat(iStudy, '_', parametersStudy.strImaging))).(genvarname(parametersGroups.strGroups)).ALL = sort(aStrAllSubjectNames);

%%% Check, whether all subject IDs are unique
aStrUniqueSubjects = unique(aSubject.(genvarname(strcat(iStudy, '_', parametersStudy.strImaging))).(genvarname(parametersGroups.strGroups)).ALL);
if numel(aSubject.(genvarname(strcat(iStudy, '_', parametersStudy.strImaging))).(genvarname(parametersGroups.strGroups)).ALL) ~= numel(aStrUniqueSubjects)
    for cs = 1:numel(aStrUniqueSubjects)
        strSubject = aStrUniqueSubjects{cs};
        if sum(strcmp(strSubject, aSubject.(genvarname(strcat(iStudy, '_', parametersStudy.strImaging))).(genvarname(parametersGroups.strGroups)).ALL)) ~= 1
            strMessage = sprintf('Duplicate entry for subject ID %s detected.\n', strSubject);
            disp(strMessage);
        end
    end
    error('Duplicate entries detected!')
end

%%% Determine number of subjects in each group and for all groups combined
for cfn = 1:numel(aStrGroupFieldnames)
    aSubject.(genvarname(strcat(iStudy, '_', parametersStudy.strImaging))).nSubjects.(genvarname(aStrGroupFieldnames{cfn})) = numel(aStrSubjectNameGroup{cfn});
end
aSubject.(genvarname(strcat(iStudy, '_', parametersStudy.strImaging))).nSubjects.ALL = numel(aStrAllSubjectNames);

%{
%%% Write all subject IDs of all groups in a single array and add group ID
for cfn = 1:numel(aStrGroupFieldnames)
    nSubjects = aSubject.(genvarname(strcat(iStudy, '_', parametersStudy.strImaging))).nSubjects.(genvarname(aStrGroupFieldnames{cfn}));
    for cs = 1:nSubjects
        aStrAllSubjectGroupNames{cs} = aStrGroupFieldnames{cfn}
    end
end


%aSubject.(genvarname(strcat(iStudy, '_', parametersStudy.strImaging))).(genvarname(parametersGroups.strGroups)).ALL = sort(aStrAllSubjectNames);
%}

end





