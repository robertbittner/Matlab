function simulateDataTransferFromScannerATWM1();

folderDefinition = folderDefinitionATWM1;
strFolderScanner = folderDefinition.strFolderScanner;
strFolderTransferFromScanner = folderDefinition.strFolderTransferFromScanner ;

strExtDicom = '.dcm';



parametersDicomFileTransfer = parametersDicomFileTransferATWM1;

iFilesToCopy = parametersDicomFileTransfer.iFilesToCopy;


structFiles = dir(strFolderScanner);
structFiles = structFiles(3:end);
nFiles = numel(structFiles);

counterDicomFile = 0;
for cf = 1:nFiles
    strFile = structFiles(cf).name;
    if strfind(strFile, strExtDicom)
        counterDicomFile = counterDicomFile + 1;
        aStrDicomFiles{counterDicomFile} = strFile;
    end
end
nDicomFiles = numel(aStrDicomFiles);

nPartialFileTransfers = size(iFilesToCopy);
nPartialFileTransfers = nPartialFileTransfers(1);

for cpt = 1:nPartialFileTransfers
    nFilesToCopy = iFilesToCopy(cpt, 2) - iFilesToCopy(cpt, 1) + 1;
    iCurrentFileToCopy = iFilesToCopy(cpt, 1):iFilesToCopy(cpt, 2);
    nFilesToCopy = length(iCurrentFileToCopy);
    %%{
    for cf = 1:nFilesToCopy
        pathDicomOnScanner = strcat(strFolderScanner, aStrDicomFiles{iCurrentFileToCopy(cf)});
        pathDicomTransfer = strcat(strFolderTransferFromScanner, aStrDicomFiles{iCurrentFileToCopy(cf)});
        copyfile(pathDicomOnScanner, pathDicomTransfer);
        pause(parametersDicomFileTransfer.delaySingleFileTransfer)
    end
    %}
    pause(parametersDicomFileTransfer.delayNextPartialTransfer)
end

quit force

end