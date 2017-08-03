function folderDefinition = defineAnonymisedHighResAnatomyArchiveFolderSubjectATWM1(folderDefinition, parametersDicomFileAnonymisation, parametersStructuralMriSequenceHighRes)

global strGroup
global strSubject


folderDefinition.anonymisedDataArchiveHighResAnatomyGroup           = strcat(folderDefinition.anonymisedDataArchiveHighResAnatomy, strGroup, '\');
folderDefinition.anonymisedDataArchiveHighResAnatomySubject         = strcat(folderDefinition.anonymisedDataArchiveHighResAnatomyGroup, strSubject, parametersDicomFileAnonymisation.strFolderWarning, '\');
folderDefinition.anonymisedDataArchiveHighResAnatomySubjectAnon     = strcat(folderDefinition.anonymisedDataArchiveHighResAnatomySubject, parametersStructuralMriSequenceHighRes.strSequence, '\');

folderDefinition.anonymisedDataArchiveHighResAnatomyGroupServer     = strcat(folderDefinition.anonymisedDataArchiveHighResAnatomyServer, strGroup, '\');
folderDefinition.anonymisedDataArchiveHighResAnatomySubjectServer   = strcat(folderDefinition.anonymisedDataArchiveHighResAnatomyGroupServer, strSubject, parametersDicomFileAnonymisation.strFolderWarning, '\');


end