function structProjectDataSubFolders = defineProjectDataSubFoldersATWM1(strSubjectDataFolder)

global iStudy
global nrOfSessions

if isempty(nrOfSessions)
    nrOfSessions = 1;
end

parametersDataSubFolder         = eval(['parametersDataSubFolders', iStudy]);

%%% Detect the fieldnames containing information about the different data
%%% subfolder types
aStrFieldnames = fieldnames(parametersDataSubFolder);
iDataSubFolderTypes = regexpi(aStrFieldnames, parametersDataSubFolder.strValidDataSubFolder);
emptyIndex = cellfun(@isempty, iDataSubFolderTypes);
iDataSubFolderTypes(emptyIndex) = {0};
iDataSubFolderTypes = logical(cell2mat(iDataSubFolderTypes));
iDataSubFolderTypes = (find(iDataSubFolderTypes))';

structProjectDataSubFolders.aStrProjectDataSubFolder = {};
for csf = iDataSubFolderTypes
    structProjectDataSubFolders.(genvarname(aStrFieldnames{csf})) = strcat(strSubjectDataFolder, parametersDataSubFolder.(genvarname(aStrFieldnames{csf})), '\');
    structProjectDataSubFolders.aStrProjectDataSubFolder = [structProjectDataSubFolders.aStrProjectDataSubFolder, structProjectDataSubFolders.(genvarname(aStrFieldnames{csf}))];
end

structProjectDataSubFolders.nDataSubFolder = parametersDataSubFolder.nDataSubFolder;

end