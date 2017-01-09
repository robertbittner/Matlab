function strProjectDataSubFolder = selectProjectDataSubFolderATWM1(strSubjectDataFolder, strProjectDataType, varagin)

global iStudy
global nrOfSessions

hFunction = str2func(sprintf('defineProjectDataSubFolders%s', iStudy));
structProjectDataSubFolder = feval(hFunction, strSubjectDataFolder);

%%% Detect the fieldnames containing information about the different data
%%% subfolder types
aStrFieldnames = fieldnames(structProjectDataSubFolder);
iDataSubFolderTypes = regexpi(aStrFieldnames, strProjectDataType);
emptyIndex = cellfun(@isempty, iDataSubFolderTypes);
iDataSubFolderTypes(emptyIndex) = {0};
iDataSubFolderTypes = logical(cell2mat(iDataSubFolderTypes));
iDataSubFolderTypes = (find(iDataSubFolderTypes))';

if ~isempty(varagin)
    iSubFolder = varagin;
    strProjectDataSubFolder = structProjectDataSubFolder.(matlab.lang.makeValidName(aStrFieldnames{iDataSubFolderTypes})){iSubFolder};
else
    strProjectDataSubFolder = structProjectDataSubFolder.(matlab.lang.makeValidName(aStrFieldnames{iDataSubFolderTypes}));
end


end