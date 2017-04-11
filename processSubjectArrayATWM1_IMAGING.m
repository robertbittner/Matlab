function aSubject = processSubjectArrayATWM1_IMAGING()

global iStudy

parametersStudy         = eval(['parametersStudy', iStudy]);
parametersGroups        = eval(['parametersGroups', iStudy]);

hFunction = str2func(sprintf('aSubject%s_%s', iStudy, parametersStudy.strImaging));
aSubject = feval(hFunction);

%%% Check whether subject labels match the predefined labels
aStrShortGroups = parametersGroups.aStrShortGroups;
aStrGroupFieldnames = fieldnames(aSubject.(matlab.lang.makeValidName(strcat(iStudy, '_', parametersStudy.strImaging))).Groups);
if ~isempty(setxor(aStrGroupFieldnames, aStrShortGroups))   
    error('Groups labels in %s.m do not match the labels specified in %s.m!', mfilename, strParmetersGroupFile)
end

%%% Write all subject IDs of all groups in a single array
aStrAllSubjectNames = {};
for cfn = 1:numel(aStrGroupFieldnames)
    aStrSubjectNameGroup{cfn} = aSubject.(matlab.lang.makeValidName(strcat(iStudy, '_', parametersStudy.strImaging))).(matlab.lang.makeValidName(parametersGroups.strGroups)).(matlab.lang.makeValidName(aStrGroupFieldnames{cfn}));
    aStrAllSubjectNames = [aStrAllSubjectNames, aStrSubjectNameGroup{cfn}'];
end
aSubject.(matlab.lang.makeValidName(strcat(iStudy, '_', parametersStudy.strImaging))).(matlab.lang.makeValidName(parametersGroups.strGroups)).ALL = sort(aStrAllSubjectNames);

%%% Check, whether all subject IDs are unique
aStrUniqueSubjects = unique(aSubject.(matlab.lang.makeValidName(strcat(iStudy, '_', parametersStudy.strImaging))).(matlab.lang.makeValidName(parametersGroups.strGroups)).ALL);
if numel(aSubject.(matlab.lang.makeValidName(strcat(iStudy, '_', parametersStudy.strImaging))).(matlab.lang.makeValidName(parametersGroups.strGroups)).ALL) ~= numel(aStrUniqueSubjects)
    for cs = 1:numel(aStrUniqueSubjects)
        strSubject = aStrUniqueSubjects{cs};
        if sum(strcmp(strSubject, aSubject.(matlab.lang.makeValidName(strcat(iStudy, '_', parametersStudy.strImaging))).(matlab.lang.makeValidName(parametersGroups.strGroups)).ALL)) ~= 1
            fprintf('Duplicate entry for subject ID %s detected.\n\n', strSubject);
        end
    end
    error('Duplicate entries detected!')
end

%%% Determine number of subjects in each group and for all groups combined
for cfn = 1:numel(aStrGroupFieldnames)
    aSubject.(matlab.lang.makeValidName(strcat(iStudy, '_', parametersStudy.strImaging))).nSubjects.(matlab.lang.makeValidName(aStrGroupFieldnames{cfn})) = numel(aStrSubjectNameGroup{cfn});
end
aSubject.(matlab.lang.makeValidName(strcat(iStudy, '_', parametersStudy.strImaging))).nSubjects.ALL = numel(aStrAllSubjectNames);

%{
%%% Write all subject IDs of all groups in a single array and add group ID
for cfn = 1:numel(aStrGroupFieldnames)
    nSubjects = aSubject.(matlab.lang.makeValidName(strcat(iStudy, '_', parametersStudy.strImaging))).nSubjects.(matlab.lang.makeValidName(aStrGroupFieldnames{cfn}));
    for cs = 1:nSubjects
        aStrAllSubjectGroupNames{cs} = aStrGroupFieldnames{cfn}
    end
end


%aSubject.(matlab.lang.makeValidName(strcat(iStudy, '_', parametersStudy.strImaging))).(matlab.lang.makeValidName(parametersGroups.strGroups)).ALL = sort(aStrAllSubjectNames);
%}

end





