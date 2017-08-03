function [folderDefinition] = defineArchiveFolderForAnonymisedDataATWM1(folderDefinition, parametersStructuralMriSequenceHighRes)

strGen = folderDefinition.strHighResAnatomy;
strSpec = sprintf('%s_%s', parametersStructuralMriSequenceHighRes.strResolution, parametersStructuralMriSequenceHighRes.strSequence);
strOld = folderDefinition.strAnonymisedDataArchiveHighResAnatomy;
strNew = strrep(strOld, strGen, strSpec);
strOldFolder = sprintf('\\%s', strOld);
strNewFolder = sprintf('\\%s', strNew);
aStrFieldnames = fieldnames(folderDefinition);
nrOfFieldNames = numel(aStrFieldnames);
for cf = 1:nrOfFieldNames
    folderDefinition.(aStrFieldnames{cf}) = strrep(folderDefinition.(aStrFieldnames{cf}), strOldFolder, strNewFolder);
end


end