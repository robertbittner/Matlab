function [strFolderOriginalDicomFilesSubject, bSubjectFolderFound, bAbort] = determineSubjectFolderWithOriginalDicomFilesATWM1(folderDefinition, parametersDialog)

global strSubject

[aStrFolderOriginalDicomFilesSubject, nrOfSubjFolders] = searchForFolderContainingSubjectDicomFilesATMW1(folderDefinition);

bAbort = false;
bSubjectFolderFound = true;
if nrOfSubjFolders == 0
    strFolderOriginalDicomFilesSubject = '';
    bSubjectFolderFound = false;
    fprintf('No folder containing DICOM files found for subject %s.\nSkipping subject.\n\n', strSubject);
    
    %{
    while ~bSubjectFolderFound
        startFolder = strcat(folderDefinition.dicomFileTransferFromScanner);
        strTitle = sprintf('Multiple folders exist for subject %s. Please select folder.', strSubject);
        strFolderOriginalDicomFilesSubject = uigetdir(startFolder, strTitle);
        if ~isempty(find(strfind(strFolderOriginalDicomFilesSubject, strSubject), 1))
            bInvalidFolderSelected = false;
        else
            strTitle = 'Select DICOM file folder';
            strMessage = sprintf('No valid DICOM file folder selected for subject %s!\nPlease retry.', strSubject);
            strButton1 = sprintf('%sRetry%s', parametersDialog.strEmpty, parametersDialog.strEmpty);
            strButton2 = sprintf('%sCancel%s', parametersDialog.strEmpty, parametersDialog.strEmpty);
            default = strButton1;
            choice = questdlg(strMessage, strTitle, strButton1, strButton2, default);
            switch choice
                case strButton1
                    
                otherwise
                    bAbort = true;
                    fprintf('Function aborted by user.'\n);
            end
            if bAbort == true
                bInvalidFolderSelected = false;
                strFolderOriginalDicomFilesSubject = '';
            end
        end
    end
    %}
    
elseif nrOfSubjFolders == 1
    strFolderOriginalDicomFilesSubject = aStrFolderOriginalDicomFilesSubject{1};
else
    % Special case of more than 1 folder for selected subject
    bInvalidFolderSelected = true;
    while bInvalidFolderSelected
        startFolder = strcat(folderDefinition.dicomFileTransferFromScanner);
        strTitle = sprintf('Multiple folders exist for subject %s. Please select folder.', strSubject);
        strFolderOriginalDicomFilesSubject = uigetdir(startFolder, strTitle);
        if ~isempty(find(strfind(strFolderOriginalDicomFilesSubject, strSubject), 1))
            bInvalidFolderSelected = false;
        else
            strTitle = 'Select DICOM file folder';
            strMessage = sprintf('No valid DICOM file folder selected for subject %s!\nPlease retry.', strSubject);
            strButton1 = sprintf('%sRetry%s', parametersDialog.strEmpty, parametersDialog.strEmpty);
            strButton2 = sprintf('%sCancel%s', parametersDialog.strEmpty, parametersDialog.strEmpty);
            default = strButton1;
            choice = questdlg(strMessage, strTitle, strButton1, strButton2, default);
            switch choice
                case strButton1
                    
                otherwise
                    bAbort = true;
                    fprintf('Function aborted by user.'\n);
            end
            if bAbort == true
                bInvalidFolderSelected = false;
                strFolderOriginalDicomFilesSubject = '';
            end
        end
    end
end
if bSubjectFolderFound
    fprintf('Folder containing DICOM files found for subject %s!\n\n', strSubject);
end

end



function [aStrFolderOriginalDicomFilesSubject, nrOfSubjFolders] = searchForFolderContainingSubjectDicomFilesATMW1(folderDefinition)
%%% Search for folder containing DICOM files of selected subject

global strSubject

dicomFileTransferFromScanner = folderDefinition.dicomFileTransferFromScanner;
strucFolderContentTransferFromScanner = dir(dicomFileTransferFromScanner);
strucFolderContentTransferFromScanner = strucFolderContentTransferFromScanner(3:end);
nrOfSubjFolders = 0;
aStrFolderOriginalDicomFilesSubject = {};
for ccont = 1:numel(strucFolderContentTransferFromScanner)
    strFolderContent = strucFolderContentTransferFromScanner(ccont).name;
    strPathSubfolder = strcat(dicomFileTransferFromScanner, strFolderContent);
    if exist(strPathSubfolder, 'dir')
        if ~isempty(find(strfind(strPathSubfolder, strSubject), 1))
            nrOfSubjFolders = nrOfSubjFolders + 1;
            aStrFolderOriginalDicomFilesSubject{nrOfSubjFolders} = strPathSubfolder;
        end
    end
end

end