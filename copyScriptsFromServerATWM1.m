function copyScriptsFromServerATWM1(folderDefinition)
% Detect script files
strucFolderContent = folderContentATWM1(folderDefinition.matlabServerMriScanner);
aStrPathScriptFiles = strucFolderContent.aStrPathFiles;
% Remove files in subfolders from array
for cf = 1:numel(aStrPathScriptFiles)
    strPathFile = aStrPathScriptFiles{cf};
    indFolderEnd = strfind(strPathFile, '\');
    indFolderEnd = indFolderEnd(end);
    strFolder = strPathFile(1:indFolderEnd);
    if ~strcmp(folderDefinition.matlabServerMriScanner, strFolder) || isempty(find(strfind(strPathFile, '.m'), 1))
        aStrPathScriptFiles{cf} = [];
    end
end
aStrPathScriptFilesServer = aStrPathScriptFiles(~cellfun(@isempty, aStrPathScriptFiles));
aStrPathScriptFilesLocal  = strrep(aStrPathScriptFilesServer,  folderDefinition.matlabServerMriScanner, folderDefinition.matlabLocalMriScanner);
nScriptFiles = numel(aStrPathScriptFilesServer);
% Check local copy and change date and copy files, which were changed on
% the server
for cf = 1:nScriptFiles
    if exist(aStrPathScriptFilesLocal{cf}, 'file')
        strucFileServer = dir(aStrPathScriptFilesServer{cf});
        fileDateServer = strucFileServer.datenum;
        strucFileLocal = dir(aStrPathScriptFilesLocal{cf});
        fileDateLocal = strucFileLocal.datenum;
        if fileDateServer > fileDateLocal
            bCopyFile = true;
        else
            bCopyFile = false;
        end
    else
        bCopyFile = true;
    end
    if bCopyFile == true
        copyfile(aStrPathScriptFilesServer{cf}, aStrPathScriptFilesLocal{cf});
        strMessage = sprintf('Copying file %s to local computer\n', aStrPathScriptFilesServer{cf});
        disp(strMessage);
    end
end


end
