function [aStrDicomFiles, nDicomFiles] = scanFolderForDicomFilesATWM1(folderToBeScanned, parametersDicomFiles);
structFiles = dir(folderToBeScanned);
structFiles = structFiles(3:end);
nFiles = numel(structFiles);
nDicomFiles = 0;
for cf = 1:nFiles
    strFile = structFiles(cf).name;
    if strfind(strFile, parametersDicomFiles.extDicomFile)
        nDicomFiles = nDicomFiles + 1;
        aStrDicomFiles{nDicomFiles} = strFile;
    end
end
if nDicomFiles == 0
    aStrDicomFiles = [];
end


end