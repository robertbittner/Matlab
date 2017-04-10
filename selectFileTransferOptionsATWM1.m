function [folderDefinition, parametersFileTransfer, bAbort] = selectFileTransferOptionsATWM1(folderDefinition, parametersFileTransfer)
%%% Create dialogs for the selection of file transfer options
global iStudy

parametersDialog = eval(['parametersDialog', iStudy]);

[bUseStandardTransferParameters, bAbort] = selectStandardOrCustomizedTransferATWM1(parametersDialog, parametersFileTransfer);
if bAbort == true
    return
end

if ~bUseStandardTransferParameters
    [folderDefinition, parametersFileTransfer, bAbort] = selectDicomFileTransferFolderOptionsATWM1(folderDefinition, parametersDialog, parametersFileTransfer);
    if bAbort == true
        return
    end

    [folderDefinition, parametersFileTransfer, bAbort] = selectLogfilesTransferFolderOptionsATWM1(folderDefinition, parametersDialog, parametersFileTransfer);
    if bAbort == true
        return
    end
    [parametersFileTransfer, bAbort] = selectFileOverwriteOption(parametersDialog, parametersFileTransfer);
    if bAbort == true
        return
    end

    [parametersFileTransfer, bAbort] = selectFileTransferOptionATWM1(parametersDialog, parametersFileTransfer, folderDefinition);
    if bAbort == true
        return
    end

    [parametersFileTransfer, bAbort] = selectProjectFileCreationOptionATWM1(parametersDialog, parametersFileTransfer);
    if bAbort == true
        return
    end

    [parametersFileTransfer, bAbort] = selectHighResAnatomyArchiveOptionATWM1(parametersDialog, parametersFileTransfer);
    if bAbort == true
        return
    end    
end

end


function [bUseStandardTransferParameters, bAbort] = selectStandardOrCustomizedTransferATWM1(parametersDialog, parametersFileTransfer)
%%% Create dialog to decide whether to use standard or customized file
%%% transfer settings

% Prepare display of default settings in dialog
strSettings = sprintf('\nDefault settings:\n\n');
for s = 1:parametersFileTransfer.nrOfFileTransferSettings
    if parametersFileTransfer.aBoolFileTransferSettings{s}
        strBool = 'true';
    else
        strBool = 'false';
    end
    strPart = sprintf('%s%s=%s%s\n\n', parametersFileTransfer.aStrBoolFileTransferSettings{s}, parametersDialog.strEmpty, parametersDialog.strEmpty, strBool);%parametersFileTransfer.aBoolFileTransferSettings{s});
    strSettings = [strSettings, strPart];
end
strQuestion = sprintf('Determine settings for file transfer for\n\n%s', strSettings);
strTitle = 'File transfer settings';
strOption1 = sprintf('%sUse standard file transfer settings%s', parametersDialog.strEmpty, parametersDialog.strEmpty);
strOption2 = sprintf('%sCustomize file transfer settings%s', parametersDialog.strEmpty, parametersDialog.strEmpty);
strOption3 = sprintf('%sAbort%s', parametersDialog.strEmpty, parametersDialog.strEmpty);
choice = questdlg(strQuestion, strTitle, strOption1, strOption2, strOption3, strOption1);
switch choice
    case strOption1
        bUseStandardTransferParameters = true;
        bAbort = false;
    case strOption2
        bUseStandardTransferParameters = false;
        bAbort = false;
    otherwise
        bUseStandardTransferParameters = true;
        bAbort = true;
        fprintf('No file transfer mode selected.\nAborting function.\n');
end


end


function [folderDefinition, parametersFileTransfer, bAbort] = selectDicomFileTransferFolderOptionsATWM1(folderDefinition, parametersDialog, parametersFileTransfer)
%%% Create dialog to decide whether to use an alternative DICOM fle 
%%% transfer folder
strQuestion = sprintf('DICOM file transfer folder options');
strTitle = 'DICOM file transfer folder options';
strOption1 = sprintf('%sUse standard DICOM file transfer folder%s', parametersDialog.strEmpty, parametersDialog.strEmpty);
strOption2 = sprintf('%sSelect alternative DICOM file transfer folder%s', parametersDialog.strEmpty, parametersDialog.strEmpty);
strOption3 = sprintf('%sAbort%s', parametersDialog.strEmpty, parametersDialog.strEmpty);
choice = questdlg(strQuestion, strTitle, strOption1, strOption2, strOption3, strOption1);
switch choice
    case strOption1
        bAbort = false;
    case strOption2
        [folderDefinition, parametersFileTransfer, bAbort] = selectAlternativeDicomFileTransferFolderATWM1(folderDefinition, parametersFileTransfer);
    otherwise
        bAbort = true;
        fprintf('No DICOM file transfer folder option selected.\nAborting function.\n');
end


end


function [folderDefinition, parametersFileTransfer, bAbort] = selectLogfilesTransferFolderOptionsATWM1(folderDefinition, parametersDialog, parametersFileTransfer)
%%% Create dialog to decide whether to use an alternative Presentation 
%%% logfiles transfer folder
strQuestion = sprintf('Presentation logfile transfer folder option');
strTitle = 'Presentation logfile transfer folder options';
strOption1 = sprintf('%sUse standard Presentation logfile transfer folder%s', parametersDialog.strEmpty, parametersDialog.strEmpty);
strOption2 = sprintf('%sSelect alternative Presentation logfile transfer folder%s', parametersDialog.strEmpty, parametersDialog.strEmpty);
strOption3 = sprintf('%sAbort%s', parametersDialog.strEmpty, parametersDialog.strEmpty);
choice = questdlg(strQuestion, strTitle, strOption1, strOption2, strOption3, strOption1);
switch choice
    case strOption1
        bAbort = false;
    case strOption2
        [folderDefinition, parametersFileTransfer, bAbort] = selectAlternativePresentationLogfileTransferFolderATWM1(folderDefinition, parametersFileTransfer);
    otherwise
        bAbort = true;
        fprintf('No Presentation logfile transfer folder option selected.\nAborting function.\n');
end


end


function [folderDefinition, parametersFileTransfer, bAbort] = selectAlternativeDicomFileTransferFolderATWM1(folderDefinition, parametersFileTransfer)
%%% Select alternative DICOM file transfer folder

strDialogTitle = 'Please select alternative DICOM file transfer folder';
folderDefinition.dicomFileTransferFromScanner = uigetdir(folderDefinition.dicomFileTransferFromScanner, strDialogTitle);

if ischar(folderDefinition.dicomFileTransferFromScanner)
    indDirSep = strfind(folderDefinition.dicomFileTransferFromScanner , folderDefinition.iDirectorySeparator);
    indLastDirSep = indDirSep(end);
    if indLastDirSep ~= numel(folderDefinition.dicomFileTransferFromScanner)
        folderDefinition.dicomFileTransferFromScanner = sprintf('%s%s', folderDefinition.dicomFileTransferFromScanner, folderDefinition.iDirectorySeparator);
    end
    parametersFileTransfer.bUseStandardDicomFileTransferFolder = false;
    bAbort = false;
else
    bAbort = true;
    fprintf('No valid alternative DICOM file transfer folder selected.\nAborting function.\n');
end


end


function [folderDefinition, parametersFileTransfer, bAbort] = selectAlternativePresentationLogfileTransferFolderATWM1(folderDefinition, parametersFileTransfer)
%%% Select alternative Presentation logfilesile transfer folder

strDialogTitle = 'Please select alternative Presentation logfiles transfer folder';
folderDefinition.logfilesServer = uigetdir(folderDefinition.logfilesServer, strDialogTitle);

if ischar(folderDefinition.logfilesServer)
    indDirSep = strfind(folderDefinition.logfilesServer , folderDefinition.iDirectorySeparator);
    indLastDirSep = indDirSep(end);
    if indLastDirSep ~= numel(folderDefinition.logfilesServer)
        folderDefinition.logfilesServer = sprintf('%s%s', folderDefinition.logfilesServer, folderDefinition.iDirectorySeparator);
    end
    parametersFileTransfer.bUseStandardDicomFileTransferFolder = false;
    bAbort = false;
else
    bAbort = true;
    fprintf('No valid alternative Presentation logfiles transfer folder selected.\nAborting function.\n');
end


end


function [parametersFileTransfer, bAbort] = selectFileTransferOptionATWM1(parametersDialog, parametersFileTransfer, folderDefinition)
%%% Create dialog to decide where the raw data is tranferred to

strQuestion = sprintf('Select file transfer mode');
strTitle = 'File transfer mode';
strOption1 = sprintf('%sFile transfer %s only%s', parametersDialog.strEmpty, upper(folderDefinition.strLocal), parametersDialog.strEmpty);
strOption2 = sprintf('%sFile transfer %s & %s%s', parametersDialog.strEmpty, upper(folderDefinition.strLocal), upper(folderDefinition.strServer), parametersDialog.strEmpty);
choice = questdlg(strQuestion, strTitle, strOption1, strOption2, strOption1);
switch choice
    case strOption1
        parametersFileTransfer.bArchiveFilesOnServer = false;
        bAbort = false;
    case strOption2
        parametersFileTransfer.bArchiveFilesOnServer = true;
        bAbort = false;
    otherwise
        parametersFileTransfer.bArchiveFilesOnLocal = false;
        parametersFileTransfer.bArchiveFilesOnServer = false;
        bAbort = true;
        printf('No file transfer mode selected.\nAborting function.\n');
end


end


function [parametersFileTransfer, bAbort] = selectFileOverwriteOption(parametersDialog, parametersFileTransfer)
%%% Create dialog to decide whether existing files will be overwritten
%%% during file transfer
strQuestion = sprintf('Select file overwrite option');
strTitle = 'File overwrite options';
strOption1 = sprintf('%sPreserve existing files%s', parametersDialog.strEmpty, parametersDialog.strEmpty);
strOption2 = sprintf('%sOverwrite existing files%s', parametersDialog.strEmpty, parametersDialog.strEmpty);
strOption3 = sprintf('%sAbort%s', parametersDialog.strEmpty, parametersDialog.strEmpty);
choice = questdlg(strQuestion, strTitle, strOption1, strOption2, strOption3, strOption1);
switch choice
    case strOption1
        parametersFileTransfer.bOverwriteExistingFiles = false;
        bAbort = false;
    case strOption2
        parametersFileTransfer.bOverwriteExistingFiles = true;
        bAbort = false;
    otherwise
        parametersFileTransfer.bOverwriteExistingFiles = false;
        bAbort = true;
        fprintf('No file overwrite option selected.\nAborting function.\n');
end


end


function [parametersFileTransfer, bAbort] = selectProjectFileCreationOptionATWM1(parametersDialog, parametersFileTransfer)
%%% Create dialog to decide whether project files will be created 
strQuestion = sprintf('Select project file creation options');
strTitle = 'Project file creation options';
strOption1 = sprintf('%sFile transfer only%s', parametersDialog.strEmpty, parametersDialog.strEmpty);
strOption2 = sprintf('%sFile transfer & Project file creation %s', parametersDialog.strEmpty, parametersDialog.strEmpty);
strOption3 = sprintf('%sAbort%s', parametersDialog.strEmpty, parametersDialog.strEmpty);
choice = questdlg(strQuestion, strTitle, strOption1, strOption2, strOption3, strOption1);
switch choice
    case strOption1
        parametersFileTransfer.bProjectFileCreation = false;
        bAbort = false;
    case strOption2
        parametersFileTransfer.bProjectFileCreation = true;
        bAbort = false;
    otherwise
        parametersFileTransfer.bProjectFileCreation = false;
        bAbort = true;
        fprintf('No file transfer option selected.\nAborting function.\n');
end


end


function [parametersFileTransfer, bAbort] = selectHighResAnatomyArchiveOptionATWM1(parametersDialog, parametersFileTransfer)
%%% Create dialog to decide whether HighResAnatomy will be archived separately 
strQuestion = sprintf('Select HighResAnatomy archive options');
strTitle = 'HighResAnatomy archive options';
strOption1 = sprintf('%sNo separate archiving%s', parametersDialog.strEmpty, parametersDialog.strEmpty);
strOption2 = sprintf('%sArchive separately%s', parametersDialog.strEmpty, parametersDialog.strEmpty);
strOption3 = sprintf('%sAbort%s', parametersDialog.strEmpty, parametersDialog.strEmpty);
choice = questdlg(strQuestion, strTitle, strOption1, strOption2, strOption3, strOption1);
switch choice
    case strOption1
        parametersFileTransfer.bArchiveHighResAnatomySeparately = false;
        bAbort = false;
    case strOption2
        parametersFileTransfer.bArchiveHighResAnatomySeparately = true;
        bAbort = false;
    otherwise
        parametersFileTransfer.bArchiveHighResAnatomySeparately = false;
        bAbort = true;
        fprintf('No HighResAnatomy archive options selected.\nAborting function.\n');
end


end