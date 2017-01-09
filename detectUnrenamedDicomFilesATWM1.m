function [bDicomFilesFound, bUnrenamedDicomFilesFound] = detectUnrenamedDicomFilesATWM1(parametersDicomFiles, strTargetFolder)

global strSubject

bDicomFilesFound = true;
bUnrenamedDicomFilesFound = false;
aStrDicomFiles = dir(strcat(strTargetFolder, '*', parametersDicomFiles.extDicomFile ));
nrOfDicomFiles = numel(aStrDicomFiles);
if isempty(aStrDicomFiles)
    bDicomFilesFound = false;
    return
end
for cf = 1:nrOfDicomFiles
    if isempty(strfind(aStrDicomFiles(cf).name, strSubject))
        bUnrenamedDicomFilesFound = true;
        break
    end
end

end