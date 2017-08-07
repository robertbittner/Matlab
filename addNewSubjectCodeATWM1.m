function [status, pathSubjectArrayFile] = addNewSubjectCodeATWM1(aSubject)
%%% Add new subject code to selected group in aSubject

global iStudy

folderDefinition        = eval(['folderDefinition', iStudy]);
parametersStudy         = eval(['parametersStudy', iStudy]);
parametersGroups        = eval(['parametersGroups', iStudy]);


strSubjectArray = sprintf('aSubject%s_%s', iStudy, parametersStudy.strImaging);
strSubjectArrayFile = sprintf('%s.m', strSubjectArray);
pathSubjectArrayFile = strcat(folderDefinition.studyParameters, strSubjectArrayFile);
fid = fopen(pathSubjectArrayFile, 'wt');

if fid == -1
    status = 1;
    return
else
    
fprintf(fid, 'function aSubject = %s()', strSubjectArray);
fprintf(fid, '\n');

for cg = 1:parametersGroups.nGroups
    strShortGroups = parametersGroups.aStrShortGroups{cg};
    aSubjectsGroup = sort(aSubject.(genvarname(strcat(iStudy, '_', parametersStudy.strImaging))).(genvarname(parametersGroups.strGroups)).(genvarname(strShortGroups)));
    nSubjectsInGroup = numel(aSubjectsGroup);
    
    fprintf(fid, '\n');
    fprintf(fid, 'aSubject.%s_%s.%s.%s', iStudy, parametersStudy.strImaging, parametersGroups.strGroups, strShortGroups);
    fprintf(fid, '\t= {');
    
    for cs = 1:nSubjectsInGroup
        fprintf(fid, '\n');
        fprintf(fid, '\t''%s''', aSubjectsGroup{cs});
    end
    fprintf(fid, '\n');
    fprintf(fid, '\t};');
    fprintf(fid, '\n');

    fprintf(fid, 'aSubject.%s_%s.%s.%s', iStudy, parametersStudy.strImaging, parametersGroups.strGroups, strShortGroups);
    fprintf(fid, ' = ');
    fprintf(fid, 'sort(aSubject.%s_%s.%s.%s);', iStudy, parametersStudy.strImaging, parametersGroups.strGroups, strShortGroups);
    fprintf(fid, '\n');
end

fprintf(fid, '\n');
fprintf(fid, 'end');

status = fclose(fid);

end
