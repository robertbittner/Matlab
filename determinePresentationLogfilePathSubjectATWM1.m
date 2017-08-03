function [aStrPresentationLogfiles, nLogfiles, strucPathPresentationLogfiles] = determinePresentationLogfilePathSubjectATWM1(folderDefinition, parametersStudy, parametersParadigm_WM_MRI, structSubjectArchiveFolders)

global strGroup
global strSubject

[aStrPresentationLogfiles, nLogfiles] = defineNamesOfPresentationLogfilesATWM1(parametersStudy, parametersParadigm_WM_MRI);

%%% Determine local path for logfiles
strucPathPresentationLogfiles.strFolderLogfilesLocalGroup    = strcat(folderDefinition.logfiles, strGroup, '\');
strucPathPresentationLogfiles.strFolderLogfilesLocalSubject  = strcat(strucPathPresentationLogfiles.strFolderLogfilesLocalGroup, strSubject, '\');
for cf = 1:nLogfiles
    strucPathPresentationLogfiles.aStrPathLocalPresentationLogfiles{cf}           = fullfile(strucPathPresentationLogfiles.strFolderLogfilesLocalSubject, aStrPresentationLogfiles{cf});
    strucPathPresentationLogfiles.aStrPathLocalArchivePresentationLogfiles{cf}    = fullfile(structSubjectArchiveFolders.strFolderLocalArchiveDicomFilesSubject, aStrPresentationLogfiles{cf});
end

%%% Determine server path for logfiles
strucPathPresentationLogfiles.strFolderLogfilesServerGroup    = strcat(folderDefinition.logfilesServer, strGroup, '\');
strucPathPresentationLogfiles.strFolderLogfilesServerSubject  = strcat(strucPathPresentationLogfiles.strFolderLogfilesServerGroup, strSubject, '\');
for cf = 1:nLogfiles
    strucPathPresentationLogfiles.aStrPathServerPresentationLogfiles{cf}          = fullfile(strucPathPresentationLogfiles.strFolderLogfilesServerSubject, aStrPresentationLogfiles{cf});
    strucPathPresentationLogfiles.aStrPathServerArchivePresentationLogfiles{cf}   = fullfile(structSubjectArchiveFolders.strFolderServerArchiveDicomFilesSubject, aStrPresentationLogfiles{cf});
end


end