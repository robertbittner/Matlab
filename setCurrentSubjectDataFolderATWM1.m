function [folderDefinition] = setCurrentSubjectDataFolderATWM1(folderDefinition, parametersProjectFiles)

global strGroup
global strSubject
global bTestConfiguration

if bTestConfiguration && parametersProjectFiles.bUseSingleSubjectTestFolder
    %%% Add alternative test folder for subject to avoid deletion of processed
    %%% data set
    folderDefinition.strCurrentSubjectDataFolder = strcat(folderDefinition.singleSubjectDataTestConfig, strGroup, '\', strSubject, '\');
else
    folderDefinition.strCurrentSubjectDataFolder = strcat(folderDefinition.singleSubjectData,           strGroup, '\', strSubject, '\');
end

end