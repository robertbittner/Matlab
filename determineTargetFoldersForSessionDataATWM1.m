function folderDefinition = determineTargetFoldersForSessionDataATWM1(folderDefinition, parametersDicomFiles, parametersDataSubFolders, structProjectDataSubFolders)

global iSession

%%% Define target folder for DICOM files
strDicomFilesSession = sprintf('%s_session_%i', parametersDicomFiles.strDicomFormat, iSession);
indDicomFilesSubfolder = strfind(structProjectDataSubFolders.aStrProjectDataSubFolder, strDicomFilesSession);
emptyIndex = cellfun(@isempty,indDicomFilesSubfolder);
indDicomFilesSubfolder(emptyIndex) = {0};
indDicomFilesSubfolder = logical(cell2mat(indDicomFilesSubfolder));

folderDefinition.strDicomFilesSubFolderCurrentSession = structProjectDataSubFolders.aStrProjectDataSubFolder{indDicomFilesSubfolder};

%%% Define target folder for logfiles
strLogfilesSession = sprintf('%s_session_%i', parametersDataSubFolders.strLogfilesFolder, iSession);
indDicomFilesSubfolder = strfind(structProjectDataSubFolders.aStrProjectDataSubFolder, strLogfilesSession);
emptyIndex = cellfun(@isempty,indDicomFilesSubfolder);
indDicomFilesSubfolder(emptyIndex) = {0};
indDicomFilesSubfolder = logical(cell2mat(indDicomFilesSubfolder));

folderDefinition.strLogfilesSubFolderCurrentSession = structProjectDataSubFolders.aStrProjectDataSubFolder{indDicomFilesSubfolder};


end