function [aStrFileDate, fileDateTimeDifference, bSubjectIdentityMatches] = confirmSubjectIdentityOfDicomFilesATWM1(folderToBeScanned);

global iStudy
global iSubject

folderDefinition            = eval(['folderDefinition', iStudy]);
parametersDicomFiles        = eval(['parametersDicomFiles', iStudy]);
parametersDicomFileTransfer = eval(['parametersDicomFileTransfer', iStudy]);


[aStrDicomFiles, nDicomFiles] = scanFolderForDicomFilesATWM1(folderToBeScanned, parametersDicomFiles);
if isempty(aStrDicomFiles)
    aStrFileDate = [];
    fileDateTimeDifference = [];
    bSubjectIdentityMatches = false;    
else
    %%% Create temporay folder for subject identity confirmation but
    %%% delete a preexisting folder
    if exist(folderDefinition.strTempFolder, 'dir')
        rmdir(folderDefinition.strTempFolder, 's');
    end
    mkdir(folderDefinition.strTempFolder);
    
    %%% Copy files to temporary folder
    for cf = 1:parametersDicomFileTransfer.nDicomFilesForSubjectIdentityConfirmation
        pathDicomFileTransferFolder = strcat(folderToBeScanned, aStrDicomFiles{cf});
        pathDicomFilesForTempFolder = strcat(folderDefinition.strTempFolder, aStrDicomFiles{cf});
        status = copyfile(pathDicomFileTransferFolder, pathDicomFilesForTempFolder);
    end
    
    %%% Rename DICOM files in temporary folder
    renameDicomFilesATWM1(folderDefinition.strTempFolder)
    
    %%% Compare subject identity of renamed files in temporary folder with
    %%% iSubject
    [aStrRenamedDicomFiles, nRenamedDicomFiles] = scanFolderForDicomFilesATWM1(folderDefinition.strTempFolder, parametersDicomFiles);
    for cf = 1:nRenamedDicomFiles
        if ~isempty(strfind(aStrRenamedDicomFiles{cf}, iSubject))
            bSubjectIdentityMatches(cf) = true;
        else
            bSubjectIdentityMatches(cf) = false;
        end
    end
    [aStrFileDate, fileDateTimeDifference] = calculateFileDateTimeDifferencesATWM1(parametersDicomFileTransfer, folderToBeScanned, bSubjectIdentityMatches);

    rmdir(folderDefinition.strTempFolder, 's');
end


end

function [aStrFileDate, fileDateTimeDifference] = calculateFileDateTimeDifferencesATWM1(parametersDicomFileTransfer, folderToBeScanned, bSubjectIdentityMatches);
%%% Get information about the file date of the DICOM files to compare it
%%% with the file data of DICOM files in other folders
if bSubjectIdentityMatches == true
    structFiles = dir(folderToBeScanned);
    structFiles = structFiles(3:end);
    for cf = 1:parametersDicomFileTransfer.nDicomFilesForSubjectIdentityConfirmation
        aStrFileDate{cf} = structFiles(cf).date;
    end
    aStrFileDate = strrep(aStrFileDate, 'Mrz', 'Mar'); %%% Replace german with english month name => bug?
    vFileDates = datenum(aStrFileDate);
    currentDate = datenum(datetime('now'));
    fileDateTimeDifference = currentDate - mean(vFileDates);
else
    aStrFileDate = [];
    fileDateTimeDifference = [];
end


end
