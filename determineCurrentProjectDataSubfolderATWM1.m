function [folderDefinition, parametersProjectFiles] = determineCurrentProjectDataSubfolderATWM1(folderDefinition, parametersProjectFiles, structProjectDataSubFolders)
%%% Determine current project data subfolder

indProjectDataSubfolder = strfind(structProjectDataSubFolders.aStrProjectDataSubFolder, parametersProjectFiles.strCurrentProject);
emptyIndex = cellfun(@isempty, indProjectDataSubfolder);
indProjectDataSubfolder(emptyIndex) = {0};
indProjectDataSubfolder = logical(cell2mat(indProjectDataSubfolder));
folderDefinition.strCurrentProjectDataSubFolder = structProjectDataSubFolders.aStrProjectDataSubFolder{indProjectDataSubfolder};


end