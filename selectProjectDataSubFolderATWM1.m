function strProjectDataSubFolder = selectProjectDataSubFolderATWM1(strSubjectDataFolder, strProjectDataType, varagin);

global iStudy

hFunction = str2func(sprintf('defineProjectDataSubFolder%s', iStudy));
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
    strProjectDataSubFolder = structProjectDataSubFolder.(genvarname(aStrFieldnames{iDataSubFolderTypes})){iSubFolder};
else
    strProjectDataSubFolder = structProjectDataSubFolder.(genvarname(aStrFieldnames{iDataSubFolderTypes}));
end


end