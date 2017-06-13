function structProjectDataSubFolders = defineProjectDataSubFoldersATWM1(strSubjectDataFolder)

global iStudy
global nrOfSessions

if isempty(nrOfSessions)
    nrOfSessions = 1;
end

parametersDataSubFolders         = eval(['parametersDataSubFolders', iStudy]);

aStrFieldnames = fieldnames(parametersDataSubFolders);
%%% Detect the fieldnames containing information about the different data
%%% subfolder types
strFieldnameType = parametersDataSubFolders.strValidDataSubFolder;
iDataSubFolderTypes = searchFieldnameTypeATWM1(aStrFieldnames, strFieldnameType);

%%% Define all subfolders
structProjectDataSubFolders.aStrProjectDataSubFolder = {};
for csf = iDataSubFolderTypes
    structProjectDataSubFolders.(matlab.lang.makeValidName(aStrFieldnames{csf})) = strcat(strSubjectDataFolder, parametersDataSubFolders.(matlab.lang.makeValidName(aStrFieldnames{csf})), '\');
    structProjectDataSubFolders.aStrProjectDataSubFolder = [structProjectDataSubFolders.aStrProjectDataSubFolder, structProjectDataSubFolders.(matlab.lang.makeValidName(aStrFieldnames{csf}))];
end

nDataSubFolder = parametersDataSubFolders.nDataSubFolder;

%%% Detect the fieldnames containing information about the different data
%%% subfolder types
strFieldnameType = parametersDataSubFolders.strValidStructDataSubSubFolder;
iDataSubFolderTypes = searchFieldnameTypeATWM1(aStrFieldnames, strFieldnameType);

%%% Define all sub-subfolders
for cstr = iDataSubFolderTypes
    structDataSubSubFolder = parametersDataSubFolders.(matlab.lang.makeValidName(aStrFieldnames{cstr}));
    strParentFolder = structProjectDataSubFolders.(matlab.lang.makeValidName(structDataSubSubFolder.strParentFolder));
    aStrSubFolderFieldnames = fieldnames(structDataSubSubFolder);

    strFieldnameType = parametersDataSubFolders.strValidDataSubFolder;
    iDataSubFolderTypes = searchFieldnameTypeATWM1(aStrSubFolderFieldnames, strFieldnameType);
    for cssf = iDataSubFolderTypes
        strSubSubFolder = structDataSubSubFolder.(matlab.lang.makeValidName(aStrSubFolderFieldnames{cssf}));
        structProjectDataSubFolders.(matlab.lang.makeValidName(aStrSubFolderFieldnames{cssf})) = strcat(strParentFolder, strSubSubFolder, '\');
        structProjectDataSubFolders.aStrProjectDataSubFolder = [structProjectDataSubFolders.aStrProjectDataSubFolder, structProjectDataSubFolders.(matlab.lang.makeValidName(aStrSubFolderFieldnames{cssf}))];
        nDataSubFolder = nDataSubFolder + 1;
    end
end

structProjectDataSubFolders.nDataSubFolder = nDataSubFolder;

end


function iDataSubFolderTypes = searchFieldnameTypeATWM1(aStrFieldnames, strFieldnameType)

iDataSubFolderTypes = regexpi(aStrFieldnames, strFieldnameType);
emptyIndex = cellfun(@isempty, iDataSubFolderTypes);
iDataSubFolderTypes(emptyIndex) = {0};
iDataSubFolderTypes = logical(cell2mat(iDataSubFolderTypes));
iDataSubFolderTypes = (find(iDataSubFolderTypes))';


end