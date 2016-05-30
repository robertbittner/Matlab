function TEST()

clear all
clc

global iStudy

iStudy = 'ATWM1';



folderDefinition        = eval(['folderDefinition', iStudy])

%{
bAllFoldersCanBeAccessed = checkFolderAccessATWM1(folderDefinition);
if bAllFoldersCanBeAccessed == false
    return
end
%}



%strLocalFolder = 'D:\Daten\ATWM1\Presentation\PresentationFiles_Subjects\CONT\GK41XTU\';
%strServerFolder = 'D:\Daten\ATWM1\Presentation\PresentationFiles_Subjects\CONT\GK41XTU\';


strLocalFolder = 'D:\Daten\ATWM1\_TEST\Local\PresentationFiles_Subjects\';
strServerFolder =  'D:\Daten\ATWM1\_TEST\Server\PresentationFiles_Subjects\';

%%% Remove
folderDefinition.dataDirectoryServer = 'D:\Daten\ATWM1\_TEST\Server\';
folderDefinition.dataDirectoryLocal = 'D:\Daten\ATWM1\_TEST\Local\';


strucServer = folderContentATWM1(strServerFolder)
strucLocal = folderContentATWM1(strLocalFolder)

%{
%%% Remove
%%% Simulate server data structure
aStrPathFiles       = strrep(strucServer.aStrPathFiles, folderDefinition.dataDirectoryLocal, folderDefinition.dataDirectoryServer);
aStrPathSubfolders  = strrep(strucServer.aStrPathSubfolders, folderDefinition.dataDirectoryLocal, folderDefinition.dataDirectoryServer);
strucServer.aStrPathFiles = aStrPathFiles;
strucServer.aStrPathSubfolders = aStrPathSubfolders;

%%% Simulate difference between server and local files/folders
aStrPathFiles = strucLocal.aStrPathFiles(1:end-2);%{1:end - 1, :}
strucLocal.aStrPathFiles = aStrPathFiles;%{2:2:end}
aStrPathSubfolders = strucLocal.aStrPathSubfolders(1:end-3);%{1:end - 1, :}
strucLocal.aStrPathSubfolders = aStrPathSubfolders;%{2:2:end}
%%% Remove
%}

%[aStrPathFoldersForTransfer, aStrPathFilesForTransfer, aStrPathFoldersForComparison, aStrPathFilesForComparison] = prepareTransferOfServerDataFoldersATWM1(folderDefinition, strucServer, strucLocal);
prepareTransferOfServerDataFoldersATWM1(folderDefinition, strucServer, strucLocal)



%%% Transfer data not found on local computer



for cfol = 1:numel(strucServer.aStrPathSubfolders)
    
    
end

end


function prepareTransferOfServerDataFoldersATWM1(folderDefinition, strucServer, strucLocal)

%%% Remove server and local root information from paths for direct
%%% comparison
aStrServerSubfolders    = strrep(strucServer.aStrPathSubfolders, folderDefinition.dataDirectoryServer, '');
aStrLocalFolders     = strrep(strucLocal.aStrPathSubfolders, folderDefinition.dataDirectoryLocal, '');

%%% Compare server and local folders
aStrFoldersForTransfer  = setdiff(aStrServerSubfolders, aStrLocalFolders);

%%{
%%% Transfer folders
if numel(aStrFoldersForTransfer) == 0
    strMessage = sprintf('No folder transfer necessary!\n');
    disp(strMessage);
else
    for cf = 1:numel(aStrFoldersForTransfer)
        strPathOriginalFolder = sprintf('%s%s', folderDefinition.dataDirectoryServer, aStrFoldersForTransfer{cf});
        strPathTransferFolder = sprintf('%s%s', folderDefinition.dataDirectoryLocal, aStrFoldersForTransfer{cf});    
        if ~exist(strPathTransferFolder, 'dir')
            [status, message] = copyfile(strPathOriginalFolder, strPathTransferFolder);
            if status == 1
                strMessage = sprintf('Transfering %s to\n%s\n', strPathOriginalFolder, strPathTransferFolder);
                disp(strMessage);
            end
        end
    end
end
%}


%%% Remove server and local root information from paths for direct
%%% comparison
aStrServerFiles = strrep(strucServer.aStrPathFiles, folderDefinition.dataDirectoryServer, '');
aStrLocalFiles  = strrep(strucLocal.aStrPathFiles, folderDefinition.dataDirectoryLocal, '');

%%% Compare server and local files
aStrFilesForTransfer  = setdiff(aStrServerFiles, aStrLocalFiles);

aStrFilesForComparison  = union(aStrServerFiles, aStrLocalFiles)

%%% Compare existing files
for cf = 1:numel(aStrFilesForComparison)
    strPathOriginalFile = sprintf('%s%s', folderDefinition.dataDirectoryServer, aStrFilesForComparison{cf}) 
    strPathTransferFile = sprintf('%s%s', folderDefinition.dataDirectoryLocal, aStrFilesForComparison{cf});
    
    %%{
    strucOriginalFile = dir(strPathOriginalFile)
    tes = strucOriginalFile.datenum
    %}
end

%%% Transfer missing files
if numel(aStrFilesForTransfer) == 0
    strMessage = sprintf('No file transfer necessary!\n');
    disp(strMessage);
else
    for cf = 1:numel(aStrFilesForTransfer)
        strPathOriginalFile = sprintf('%s%s', folderDefinition.dataDirectoryServer, aStrFilesForTransfer{cf});
        strPathTransferFile = sprintf('%s%s', folderDefinition.dataDirectoryLocal, aStrFilesForTransfer{cf});
        if ~exist(strPathTransferFile, 'file')
            [status, message] = copyfile(strPathOriginalFile, strPathTransferFile);
            if status == 1
                strMessage = sprintf('Transfering %s to\n%s\n', strPathOriginalFile, strPathTransferFile);
                disp(strMessage);
            end
        end
    end
end


end


%{
function [aStrPathFoldersForTransfer, aStrPathFilesForTransfer, aStrPathFoldersForComparison, aStrPathFilesForComparison] = prepareTransferOfServerDataATWM1(folderDefinition, strucServer, strucLocal)

%%% Compare server and local data
%%% Remove server and local root information from paths for direct
%%% comparison
%%% 1: Server data
aStrServerSubfolders = strrep(strucServer.aStrPathSubfolders, folderDefinition.dataDirectoryServer, '');
aStrServerFiles = strrep(strucServer.aStrPathFiles, folderDefinition.dataDirectoryServer, '');

%%% 2: Local data
aStrLocalSubfolders = strrep(strucLocal.aStrPathSubfolders, folderDefinition.dataDirectoryLocal, '');
aStrLocalFiles = strrep(strucLocal.aStrPathFiles, folderDefinition.dataDirectoryLocal, '');

aStrFoldersForTransfer  = setdiff(aStrServerSubfolders, aStrLocalSubfolders);
aStrFilesForTransfer    = setdiff(aStrServerFiles, aStrLocalFiles);

aStrPathFoldersForTransfer      = strucServer.aStrPathSubfolders(ismember(aStrServerSubfolders, aStrFoldersForTransfer));
aStrPathFilesForTransfer        = strucServer.aStrPathFiles(ismember(aStrServerFiles, aStrFilesForTransfer));

aStrPathFoldersForComparison    = strucServer.aStrPathSubfolders(~ismember(aStrServerSubfolders, aStrFoldersForTransfer));
aStrPathFilesForComparison      = strucServer.aStrPathFiles(~ismember(aStrServerFiles, aStrFilesForTransfer));

aStrPathFoldersForComparison = strrep(aStrPathFoldersForComparison, folderDefinition.dataDirectoryServer, '')

for cf = 1:numel(aStrPathFoldersForComparison)
    strPathServerFolder = aStrPathFoldersForComparison{cf}
    strPathLocalFolder = aStrLocalSubfolders{ismember(aStrLocalSubfolders, strPathServerFolder)}
    strPathServerFolder = sprintf('%s%s', folderDefinition.dataDirectoryServer, strPathServerFolder)
    strPathLocalFolder = sprintf('%s%s', folderDefinition.dataDirectoryLocal, strPathLocalFolder)
end


end
%}