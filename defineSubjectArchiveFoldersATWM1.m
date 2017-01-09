function structSubjectArchiveFolders = defineSubjectArchiveFoldersATWM1(folderDefinition)

global strGroup
global strSubject

%%% Local
structSubjectArchiveFolders.strFileDestinationLocal                 = folderDefinition.strLocal;
structSubjectArchiveFolders.strFolderLocalArchiveDicomFiles         = folderDefinition.archiveDICOMfiles;
structSubjectArchiveFolders.strFolderLocalArchiveDicomFilesGroup    = strcat(structSubjectArchiveFolders.strFolderLocalArchiveDicomFiles, strGroup, '\');
structSubjectArchiveFolders.strFolderLocalArchiveDicomFilesSubject  = strcat(structSubjectArchiveFolders.strFolderLocalArchiveDicomFilesGroup, strSubject, '\');

%%% Server
structSubjectArchiveFolders.strFileDestinationServer                = folderDefinition.strServer;
structSubjectArchiveFolders.strFolderServerArchiveDicomFiles        = folderDefinition.archiveDICOMfilesServer;
structSubjectArchiveFolders.strFolderServerArchiveDicomFilesGroup   = strcat(structSubjectArchiveFolders.strFolderServerArchiveDicomFiles, strGroup, '\');
structSubjectArchiveFolders.strFolderServerArchiveDicomFilesSubject = strcat(structSubjectArchiveFolders.strFolderServerArchiveDicomFilesGroup, strSubject, '\');

end