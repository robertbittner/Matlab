function [aStrDicomFiles, nrOfDicomFiles] = detectAllDicomFilesInFolderATWM1(folderDefinition, parametersDicomFiles)

strTargetFolder = folderDefinition.strDicomFilesSubFolderCurrentSession;
aStrDicomFiles = dir(strcat(strTargetFolder, '*', parametersDicomFiles.extDicomFile ));
nrOfDicomFiles = numel(aStrDicomFiles);

end