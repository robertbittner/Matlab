function bAllFoldersCanBeAccessed = checkLocalComputerFolderAccessATWM1(folderDefinition)

global iStudy

[~, parametersDialog] = eval(['defineDialogTextElements', iStudy]);

aStrFolderDefinitions = readFolderDefinitionsATWM1(folderDefinition);
[bAllFoldersCanBeAccessed, bFolderManuallySelected, bNetworkDriveFolderDisplayed] = setIntialValuesForBooleansATWM1();
bSkip = false;
while bAllFoldersCanBeAccessed == false
    hFunction = str2func(sprintf('checkAccessToLocalFoldersAndNetworkDrives%s', iStudy));
    [aStrInaccessibleNetworkDrives, bSeverFoldersCannotBeAccessed, bAllFoldersCanBeAccessed] = feval(hFunction, folderDefinition, aStrFolderDefinitions);
    if bSeverFoldersCannotBeAccessed && ~bSkip
        if ~bNetworkDriveFolderDisplayed
            hFunction = str2func(sprintf('displayUnaccessibleNetworkDrives%s', iStudy));
            [bAbort, bSkip, bNetworkDriveFolderDisplayed] = feval(hFunction, aStrInaccessibleNetworkDrives, parametersDialog, bNetworkDriveFolderDisplayed);
            if bAbort == true
                return
            end
        end
        if ~bSkip
            hFunction = str2func(sprintf('manualSelectionOfNetworkDrives%s', iStudy));
            [bFolderManuallySelected, bAbort] = feval(hFunction, aStrInaccessibleNetworkDrives, bFolderManuallySelected);
            if bAbort == true
                return
            end
            
            hFunction = str2func(sprintf('checkAccessToLocalFoldersAndNetworkDrives%s', iStudy));
            [~, ~, bAllFoldersCanBeAccessed] = feval(hFunction, folderDefinition, aStrFolderDefinitions);
        else
            bFolderManuallySelected = true; 
            bAllFoldersCanBeAccessed = true;
        end
    elseif ~bAllFoldersCanBeAccessed && bFolderManuallySelected
        fprintf('One or more folder(s) cannot be accessed!\nAborting function.\n');
        fprintf('Please check, whether all specfied folders exist.\n');
        fprintf('Please also check, whether server is connected.\n\n');
        return
    elseif ~bAllFoldersCanBeAccessed && ~bSeverFoldersCannotBeAccessed
        fprintf('One or more folder(s) cannot be accessed!\nThis may cause errors.\n\n');
        return
    end
end


end


function aStrFolderDefinitions = readFolderDefinitionsATWM1(folderDefinition)
aStrFieldnamesFolderDefinition = fieldnames(folderDefinition);
nFolders = 0;
for cf = 1:numel(aStrFieldnamesFolderDefinition)
    strFolder = folderDefinition.(matlab.lang.makeValidName(aStrFieldnamesFolderDefinition{cf}));
    if ischar(strFolder)
        if ~isempty(strfind(strFolder, folderDefinition.iDirectory)) && ~strcmp(folderDefinition.iDirectory, strFolder)
            nFolders = nFolders + 1;
            aStrFolderDefinitions{nFolders} = strFolder;
        end
    end
end


end


function [bAllFoldersCanBeAccessed, bFolderManuallySelected, bNetworkDriveFolderDisplayed] = setIntialValuesForBooleansATWM1()
bAllFoldersCanBeAccessed        = false;
bFolderManuallySelected         = false;
bNetworkDriveFolderDisplayed    = false;

end


function [bAbort, bSkip, bNetworkDriveFolderDisplayed] = displayUnaccessibleNetworkDrivesATWM1(aStrInaccessibleNetworkDrives, parametersDialog, bNetworkDriveFolderDisplayed)

strTitle = 'Network drives cannot be accessed by Matlab!';
strMessageStart = sprintf('Please select the following network drives manually\nin the next dialog to enable access by Matlab:\n\n');
strMessage = sprintf('%s', strMessageStart);
for cnd = 1:numel(aStrInaccessibleNetworkDrives)
    strMessagePart = sprintf('%s\n', aStrInaccessibleNetworkDrives{cnd});
    strMessage = sprintf('%s%s', strMessage, strMessagePart);
end
strOption1 = sprintf('%sOkay%s', parametersDialog.strEmpty, parametersDialog.strEmpty);
strOption2 = sprintf('%sSkip%s', parametersDialog.strEmpty, parametersDialog.strEmpty);
strOption3 = sprintf('%sCancel%s', parametersDialog.strEmpty, parametersDialog.strEmpty);
default = strOption1;
choice = questdlg(strMessage, strTitle, strOption1, strOption2, strOption3, default);
switch choice
    case strOption1
        bAbort = false;
        bSkip = false;
    case strOption2
        bAbort = false;
        bSkip = true;
        strMessage = sprintf('Skipping access checks for folders and network drives.\nThis may lead to errors!');
        disp(strMessage);
    case strOption3
        bAbort = true;
        bSkip = false;
        strMessage = sprintf('Function aborted by user.');
        disp(strMessage);
    otherwise
        bAbort = true;
        bSkip = false;
        strMessage = sprintf('Function aborted by user.');
        disp(strMessage);
end
if ~isempty(choice)
    bNetworkDriveFolderDisplayed = true;
end

end


function [bFolderManuallySelected, bAbort] = manualSelectionOfNetworkDrivesATWM1(aStrInaccessibleNetworkDrives, bFolderManuallySelected)

iInaccessibleNetworkDrive = 1;

strDialogTitle = sprintf('Select network drive %s', aStrInaccessibleNetworkDrives{iInaccessibleNetworkDrive});
selectedFolder = uigetdir(aStrInaccessibleNetworkDrives{iInaccessibleNetworkDrive}, strDialogTitle);

if selectedFolder == 0
    bAbort = true;
    strMessage = sprintf('No folder selected!\nAborting function.');
    disp(strMessage);
else
    bFolderManuallySelected = true;
    bAbort = false;
end


end


function [aStrInaccessibleNetworkDrives, bSeverFoldersCannotBeAccessed, bAllFoldersCanBeAccessed] = checkAccessToLocalFoldersAndNetworkDrivesATWM1(folderDefinition, aStrFolderDefinitions)

bSeverFoldersCannotBeAccessed = false;
bSingleFolderCannotBeAccessed = false;
bAllFoldersCanBeAccessed = false;
aStrInaccessibleNetworkDrives = {};
for cf = 1:numel(aStrFolderDefinitions)
    if ~exist(aStrFolderDefinitions{cf}, 'dir')
        strMessage = sprintf('Folder %s cannot be accessed!', aStrFolderDefinitions{cf});
        disp(strMessage);
        bSingleFolderCannotBeAccessed = true;
        if ismember(aStrFolderDefinitions{cf} , folderDefinition.dataDirectorySeverArray)
            bSeverFoldersCannotBeAccessed = true;
            aStrInaccessibleNetworkDrives = [aStrInaccessibleNetworkDrives, aStrFolderDefinitions{cf}];
        end
    end
end
if bSingleFolderCannotBeAccessed == false
    bAllFoldersCanBeAccessed = true;
end


end