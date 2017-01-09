function folderDefinition = defineAnonymisedHighResAnatomyArchiveFolderATWM1(folderDefinition)

global iStudy
global strGroup
global strSubject

parametersStructuralMriSequenceHighRes  = eval(['parametersStructuralMriSequenceHighRes', iStudy]);

strAnonymisedHighResAnatomyArchive = strcat('___', upper(folderDefinition.strAnonymizedDataArchive), '_', parametersStructuralMriSequenceHighRes.strResolution, '_', parametersStructuralMriSequenceHighRes.strSequence);

folderDefinition.archiveAnonymisedHighResAnatomy          = strcat(folderDefinition.archiveDICOMfiles, strAnonymisedHighResAnatomyArchive, '\');
folderDefinition.archiveAnonymisedHighResAnatomyServer    = strcat(folderDefinition.archiveDICOMfilesServer, strAnonymisedHighResAnatomyArchive, '\');

folderDefinition.archiveAnonymisedHighResAnatomyGroup               = strcat(folderDefinition.archiveAnonymisedHighResAnatomy, strGroup, '\');
folderDefinition.archiveAnonymisedHighResAnatomySubject             = strcat(folderDefinition.archiveAnonymisedHighResAnatomyGroup, strSubject, '_DO_NOT_COPY_THIS_FOLDER_COPY_ONLY_ANONYMISED_SUBFOLDER', '\');
folderDefinition.archiveAnonymisedHighResAnatomySubjectSubfolder    = strcat(folderDefinition.archiveAnonymisedHighResAnatomySubject, parametersStructuralMriSequenceHighRes.strSequence, '\');


end