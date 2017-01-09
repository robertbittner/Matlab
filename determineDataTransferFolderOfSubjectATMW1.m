function subjectDataTransferFolder = determineDataTransferFolderOfSubjectATMW1()

global iStudy
global iSubject

folderDefinition            = eval(['folderDefinition', iStudy]);
parametersDicomFileTransfer = eval(['parametersDicomFileTransfer', iStudy]);

%%% Load additional folder definitions for MRI file transfer
hFunction = str2func(sprintf('folderDefinitionMriFileTransfer%s', iStudy));
folderDefinition = feval(hFunction, folderDefinition);

%%% Search for folders in scanner transfer root folder
aStrRootFolderContent = dir(folderDefinition.strFolderTransferFromScannerRoot);
aStrRootFolderContent = aStrRootFolderContent(3:end);
nFolders = 0;
for c = 1:numel(aStrRootFolderContent)
    strFolderContent = aStrRootFolderContent(c).name;
    pathFolderContent = strcat(folderDefinition.strFolderTransferFromScannerRoot, strFolderContent);
    if isdir(pathFolderContent)
        nFolders = nFolders + 1;
        aStrFolders{nFolders} = pathFolderContent;
    end
end

nSubjectDataFolders = 0;
for cfol = 1:nFolders
    folderToBeScanned = strcat(aStrFolders{cfol}, '\');
    hFunction = str2func(sprintf('confirmSubjectIdentityOfDicomFiles%s', iStudy));
    [aStrFileDate, fileDateTimeDifference, bSubjectIdentityMatches] = feval(hFunction, folderToBeScanned);
    
    %%% Remove
    if ~isempty(strfind(folderToBeScanned, 'Subject_TEST1'))
        fileDateTimeDifference = fileDateTimeDifference + 1000;
    end
    %%% Remove
    
    if bSubjectIdentityMatches == true
        nSubjectDataFolders = nSubjectDataFolders + 1;
        aStrTransferFolderOfSubject{nSubjectDataFolders} = folderToBeScanned;
        aFileDateTimeDifference(nSubjectDataFolders) = fileDateTimeDifference;
        minimumTimeDifference = min(aFileDateTimeDifference);
        iMinimumTimeDifference = ismember(minimumTimeDifference, aFileDateTimeDifference);
    end
end

%%% If multiple subject data folders exist, select the folder with the most
%%% current file dates
if nSubjectDataFolders > 0 && minimumTimeDifference < parametersDicomFileTransfer.maximumTimeDifferenceOfFileDatesAllowed
    subjectDataTransferFolder = aStrTransferFolderOfSubject{iMinimumTimeDifference};
else
    subjectDataTransferFolder = [];
end


end

