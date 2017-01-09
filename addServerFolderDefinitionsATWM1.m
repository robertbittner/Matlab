function folderDefinition = addServerFolderDefinitionsATWM1(folderDefinition)

global iDataSource

if isempty(iDataSource)
    iDataSource = 1;
end

if iDataSource == 1
    aStrFieldnames = fieldnames(folderDefinition);
    for cfn = 1:numel(aStrFieldnames)
        if ischar(folderDefinition.(genvarname(aStrFieldnames{cfn})))
            if ~isempty(strfind(folderDefinition.(genvarname(aStrFieldnames{cfn})), folderDefinition.study)) && numel(folderDefinition.(genvarname(aStrFieldnames{cfn}))) > numel(folderDefinition.study)
                folderDefinition.(genvarname(strcat(aStrFieldnames{cfn}, folderDefinition.strServer))) = strrep(folderDefinition.(genvarname(aStrFieldnames{cfn})), folderDefinition.dataDirectoryLocal, folderDefinition.dataDirectoryServer);
            end
        end
    end
    %bAllFoldersCanBeAccessed = checkLocalComputerFolderAccessATWM1(folderDefinition);
end


end
