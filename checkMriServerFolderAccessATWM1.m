function bMriServerFolderCanBeAccessed = checkMriServerFolderAccessATWM1(folderDefinition);

global iStudy

[~, parametersDialog] = eval(['defineDialogTextElements', iStudy]);

[aStrFolderDefinitions, aStrLogfileTranferFolderDefinitions] = readFolderDefinitionsATWM1(folderDefinition);
[bMriServerFolderCanBeAccessed, bMriServerFolderManuallySelected, bMriServerFolderDisplayed] = setIntialValuesForBooleansATWM1();

while bMriServerFolderCanBeAccessed == false
    hFunction = str2func(sprintf('checkAccessToFolders%s', iStudy));
    [aStrInaccessibleNetworkDrives, bSeverFoldersCannotBeAccessed, bMriServerFolderCanBeAccessed] = feval(hFunction, aStrLogfileTranferFolderDefinitions);
    if bSeverFoldersCannotBeAccessed == true
        if bMriServerFolderDisplayed == false
            hFunction = str2func(sprintf('displayUnaccessibleFolders%s', iStudy));
            [bAbort, bMriServerFolderDisplayed] = feval(hFunction, aStrInaccessibleNetworkDrives, parametersDialog, bMriServerFolderDisplayed);
            if bAbort == true
                return
            end
        end
        
        hFunction = str2func(sprintf('manualSelectionOfNetworkDrives%s', iStudy));
        [bMriServerFolderManuallySelected, bAbort] = feval(hFunction, aStrInaccessibleNetworkDrives, bMriServerFolderManuallySelected);
        if bAbort == true
            return
        end
        
        hFunction = str2func(sprintf('checkAccessToFolders%s', iStudy));
        [~, ~, bMriServerFolderCanBeAccessed] = feval(hFunction, aStrFolderDefinitions);
    elseif bMriServerFolderCanBeAccessed == false && bMriServerFolderManuallySelected == true
        strMessage = sprintf('One or more folder(s) cannot be accessed!\nAborting function.');
        disp(strMessage);
        strMessage = sprintf('Please check, whether all specfied folders exist.');
        disp(strMessage);
        strMessage = sprintf('Please also check, whether server is connected.');
        disp(strMessage);
        return
    end
end


end


function [aStrFolderDefinitions, aStrLogfileTranferFolderDefinitions] = readFolderDefinitionsATWM1(folderDefinition)
% Read all folder definitions
aStrFieldnamesFolderDefinition = fieldnames(folderDefinition);
nFolders = 0;
for cf = 1:numel(aStrFieldnamesFolderDefinition)
    strFolder = folderDefinition.(genvarname(aStrFieldnamesFolderDefinition{cf}));
    if ischar(strFolder)
        if ~isempty(strfind(strFolder, folderDefinition.iDirectory)) && ~strcmp(folderDefinition.iDirectory, strFolder)
            nFolders = nFolders + 1;
            aStrFolderDefinitions{nFolders} = strFolder;
        end
    end
end

% Read folder definition required for logfile transfer
aStrLogfileTranferFolderDefinitions = {
    folderDefinition.logfilesLocalMriScanner
    folderDefinition.logfilesServerMriScanner
    };

end


function [bMriServerFolderCanBeAccessed, bMriServerFolderManuallySelected, bMriServerFolderDisplayed] = setIntialValuesForBooleansATWM1();
bMriServerFolderCanBeAccessed       = false;
bMriServerFolderManuallySelected    = false;
bMriServerFolderDisplayed    = false;

end


function [bAbort, bMriServerFolderDisplayed] = displayUnaccessibleFoldersATWM1(aStrInaccessibleNetworkDrives, parametersDialog, bMriServerFolderDisplayed);

strTitle = 'Network drives cannot be accessed by Matlab!';
strMessageStart = sprintf('Please select the following network drives manually\nin the next dialog to enable access by Matlab:\n\n');
strMessage = sprintf('%s', strMessageStart);
for cnd = 1:numel(aStrInaccessibleNetworkDrives)
    strMessagePart = sprintf('%s\n', aStrInaccessibleNetworkDrives{cnd});
    strMessage = sprintf('%s%s', strMessage, strMessagePart);
end
strButton1 = sprintf('%sOkay%s', parametersDialog.strEmpty, parametersDialog.strEmpty);
strButton2 = sprintf('%sCancel%s', parametersDialog.strEmpty, parametersDialog.strEmpty);
default = strButton1;
choice = questdlg(strMessage, strTitle, strButton1, strButton2, default);
if ~isempty(choice)
    bMriServerFolderDisplayed = true;
    
    switch choice
        case strButton1
            bAbort = false;
        case strButton2
            bAbort = true;
            strMessage = sprintf('Function aborted by user.');
            disp(strMessage);
    end
else
    bAbort = true;
    strMessage = sprintf('Function aborted by user.');
    disp(strMessage);
end


end


function [bMriServerFolderManuallySelected, bAbort] = manualSelectionOfNetworkDrivesATWM1(aStrInaccessibleNetworkDrives, bMriServerFolderManuallySelected);

iInaccessibleNetworkDrive = 1;

strDialogTitle = sprintf('Select network drive %s', aStrInaccessibleNetworkDrives{iInaccessibleNetworkDrive});
selectedFolder = uigetdir(aStrInaccessibleNetworkDrives{iInaccessibleNetworkDrive}, strDialogTitle);

if selectedFolder == 0
    bAbort = true;
    strMessage = sprintf('No folder selected!\nAborting function.');
    disp(strMessage);
else
    bMriServerFolderManuallySelected = true;
    bAbort = false;
end


end


function [aStrInaccessibleNetworkDrives, bSeverFoldersCannotBeAccessed, bMriServerFolderCanBeAccessed] = checkAccessToFoldersATWM1(aStrLogfileTranferFolderDefinitions)

bSeverFoldersCannotBeAccessed = false;
bSingleFolderCannotBeAccessed = false;
bMriServerFolderCanBeAccessed = false;
aStrInaccessibleNetworkDrives = {};
for cf = 1:numel(aStrLogfileTranferFolderDefinitions)
    if ~exist(aStrLogfileTranferFolderDefinitions{cf}, 'dir')
        strMessage = sprintf('Folder %s cannot be accessed!', aStrLogfileTranferFolderDefinitions{cf});
        disp(strMessage);
        bSingleFolderCannotBeAccessed = true;
        bSeverFoldersCannotBeAccessed = true;
        aStrInaccessibleNetworkDrives = [aStrInaccessibleNetworkDrives, aStrLogfileTranferFolderDefinitions{cf}];
    end
end
if bSingleFolderCannotBeAccessed == false
    bMriServerFolderCanBeAccessed = true;
end


end