function bAllFoldersCanBeAccessed = checkFolderAccessATWM1(folderDefinition, parametersNetwork)

bAllFoldersCanBeAccessed = false;

if ~isempty(find(strfind(parametersNetwork.strCurrentComputer, parametersNetwork.strDepartmentOfPsychiatry), 1))
    bAllFoldersCanBeAccessed = checkLocalComputerFolderAccessATWM1(folderDefinition);
elseif ~isempty(find(strfind(parametersNetwork.strCurrentComputer, parametersNetwork.strBrainImagingCenter), 1)) && ~isempty(find(strfind(parametersNetwork.strCurrentComputer, parametersNetwork.strPresentationComputer), 1))
    bAllFoldersCanBeAccessed = checkMriServerFolderAccessATWM1(folderDefinition);
end

if bAllFoldersCanBeAccessed == false
    strMessage = sprintf('Folder cannot be accessed!\nAborting function!');
    disp(strMessage);
end


end