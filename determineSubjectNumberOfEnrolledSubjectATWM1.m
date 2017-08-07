function determineSubjectNumberOfEnrolledSubjectATWM1()

global iStudy

iStudy = 'ATWM1';

folderDefinition            = eval(['folderDefinition', iStudy]);
parametersStudy             = eval(['parametersStudy', iStudy]);
parametersGroups            = eval(['parametersGroups', iStudy]);

%%% Access server
bAllFoldersCanBeAccessed = checkLocalComputerFolderAccessATWM1(folderDefinition);
if bAllFoldersCanBeAccessed == false
    bAbort = true;
    return
end

strucSubjCode = readSubjectsCodeFilesATWM1(folderDefinition, parametersGroups);

aSubject = processSubjectArrayATWM1(parametersStudy, folderDefinition.strLocal);

[~, ~, aStrSubject, nSubjects, bAbort] = selectGroupAndSubjectIdATWM1(parametersStudy, parametersGroups, aSubject);
if bAbort == true
    return
end

for cs = 1:nSubjects
    strSubject = aStrSubject{cs};
    indSubject = contains(strucSubjCode.aStrSubject, strSubject);
    subjectNumber = strucSubjCode.vSubjectNumber(indSubject);
    strGroup = strucSubjCode.aStrShortGroups{cs};
    fprintf('\n\n%s\n%s\n%i\n\n', strSubject, strGroup, subjectNumber)
    
end



end