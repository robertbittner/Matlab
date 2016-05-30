function structProjectDataSubFolder = defineProjectDataSubFolderATWM1(strSubjectDataFolder)%(parametersParadigm, parametersDicomFiles, strProjectDataFolder);

global iStudy

parametersDataSubFolder         = eval(['parametersDataSubFolder', iStudy]);

%%% Detect the fieldnames containing information about the different data
%%% subfolder types
aStrFieldnames = fieldnames(parametersDataSubFolder);
iDataSubFolderTypes = regexpi(aStrFieldnames, parametersDataSubFolder.strValidDataSubFolder);
emptyIndex = cellfun(@isempty, iDataSubFolderTypes);
iDataSubFolderTypes(emptyIndex) = {0};
iDataSubFolderTypes = logical(cell2mat(iDataSubFolderTypes));
iDataSubFolderTypes = (find(iDataSubFolderTypes))';

structProjectDataSubFolder.aStrProjectDataSubFolder = {};
for csf = iDataSubFolderTypes
    structProjectDataSubFolder.(genvarname(aStrFieldnames{csf})) = strcat(strSubjectDataFolder, parametersDataSubFolder.(genvarname(aStrFieldnames{csf})), '\');
    structProjectDataSubFolder.aStrProjectDataSubFolder = [structProjectDataSubFolder.aStrProjectDataSubFolder, structProjectDataSubFolder.(genvarname(aStrFieldnames{csf}))];
end

structProjectDataSubFolder.nDataSubFolder = parametersDataSubFolder.nDataSubFolder;

end