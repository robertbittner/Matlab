function folderDefinition = loadFolderDefinitionATWM1(parametersNetwork)

global iStudy

if ~isempty(find(strfind(parametersNetwork.strCurrentComputer, parametersNetwork.strDepartmentOfPsychiatry), 1))
    folderDefinition = eval(['folderDefinition', iStudy]);
elseif ~isempty(find(strfind(parametersNetwork.strCurrentComputer, parametersNetwork.strBrainImagingCenter), 1)) && ~isempty(find(strfind(parametersNetwork.strCurrentComputer, parametersNetwork.strPresentationComputer), 1))
    folderDefinition = eval(['folderDefinitionPresentationMri', iStudy]);    
end


end