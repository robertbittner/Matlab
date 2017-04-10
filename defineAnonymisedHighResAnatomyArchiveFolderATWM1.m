function folderDefinition = defineAnonymisedHighResAnatomyArchiveFolderATWM1(folderDefinition, parametersDicomFileAnonymisation)

global iStudy
global strGroup
global strSubject

parametersStructuralMriSequenceHighRes  = eval(['parametersStructuralMriSequenceHighRes', iStudy]);

strAnonymisedHighResAnatomyArchive = strcat('___', upper(folderDefinition.strAnonymizedDataArchive), '_', parametersStructuralMriSequenceHighRes.strResolution, '_', parametersStructuralMriSequenceHighRes.strSequence);

folderDefinition.archiveAnonymisedHighResAnatomy        = strcat(folderDefinition.archiveDICOMfiles, strAnonymisedHighResAnatomyArchive, '\');
folderDefinition.archiveAnonymisedHighResAnatomyServer 	= strcat(folderDefinition.archiveDICOMfilesServer, strAnonymisedHighResAnatomyArchive, '\');

folderDefinition.archiveAnonymisedHighResAnatomyGroup       = strcat(folderDefinition.archiveAnonymisedHighResAnatomy, strGroup, '\');
folderDefinition.archiveAnonymisedHighResAnatomySubject     = strcat(folderDefinition.archiveAnonymisedHighResAnatomyGroup, strSubject, parametersDicomFileAnonymisation.strFolderWarning, '\');
folderDefinition.archiveAnonymisedHighResAnatomySubjectAnon = strcat(folderDefinition.archiveAnonymisedHighResAnatomySubject, parametersStructuralMriSequenceHighRes.strSequence, '\');

folderDefinition.archiveAnonymisedHighResAnatomyGroupServer     = strcat(folderDefinition.archiveAnonymisedHighResAnatomyServer, strGroup, '\');
folderDefinition.archiveAnonymisedHighResAnatomySubjectServer   = strcat(folderDefinition.archiveAnonymisedHighResAnatomyGroupServer, strSubject, parametersDicomFileAnonymisation.strFolderWarning, '\');

end