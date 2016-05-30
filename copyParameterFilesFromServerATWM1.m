function copyParameterFilesFromServerATWM1(folderDefinition)
% Detect parameter files
strucFolderContent = folderContentATWM1(folderDefinition.studyParametersServerMriScanner);
aStrPathParameterFiles = strucFolderContent.aStrPathFiles;
% Remove files in subfolders from array
for cf = 1:numel(aStrPathParameterFiles)
    strPathFile = aStrPathParameterFiles{cf};
    indFolderEnd = strfind(strPathFile, '\');
    indFolderEnd = indFolderEnd(end);
    strFolder = strPathFile(1:indFolderEnd);
    if ~strcmp(folderDefinition.studyParametersServerMriScanner, strFolder)
        aStrPathParameterFiles{cf} = [];
    end
end
aStrPathParameterFilesServer = aStrPathParameterFiles(~cellfun(@isempty, aStrPathParameterFiles));
aStrPathParemeterFilesLocal  = strrep(aStrPathParameterFilesServer,  folderDefinition.studyParametersServerMriScanner, folderDefinition.studyParametersLocalMriScanner);
nParameterFiles = numel(aStrPathParameterFilesServer);
% Check local copy and change date and copy files, which were changed on
% the server
for cf = 1:nParameterFiles
    if exist(aStrPathParemeterFilesLocal{cf}, 'file')
        strucFileServer = dir(aStrPathParameterFilesServer{cf});
        fileDateServer = strucFileServer.datenum;
        strucFileLocal = dir(aStrPathParemeterFilesLocal{cf});
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
        copyfile(aStrPathParameterFilesServer{cf}, aStrPathParemeterFilesLocal{cf});
        strMessage = sprintf('Copying file %s to local computer\n', aStrPathParameterFilesServer{cf});
        disp(strMessage);
    end
end


end
