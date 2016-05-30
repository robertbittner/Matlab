function strucFolderContent = folderContentATWM1(folder)

%folder = 'D:\Daten\ATWM1\Presentation\PresentationFiles_Subjects\CONT\GK41XTU\';
%folder = 'D:\Daten\ATWM1\'; %Presentation\PresentationFiles_Subjects\CONT\GK41XTU\';

nrOfSubfolders = 0;
nrOfFiles = 0;
aStrPathSubfolders = {};
aStrPathFiles = {};

aStrPathNewSubfolders = {folder};

bContinueSearching = true;
while bContinueSearching == true
    oldNrOfSubfolders = nrOfSubfolders;
    for cf = 1:numel(aStrPathNewSubfolders)
        strPathCurrentFolder = aStrPathNewSubfolders{cf};
        [aStrPathSubfolders, aStrPathFiles, nrOfSubfolders, nrOfFiles] = searchDirectory(strPathCurrentFolder, aStrPathSubfolders, aStrPathFiles, nrOfSubfolders, nrOfFiles);
    end
    nrOfNewSubfolders = nrOfSubfolders - oldNrOfSubfolders;
    if nrOfNewSubfolders == 0
        bContinueSearching = false;
    else
        aStrPathNewSubfolders = {};
        for cnf = 1:nrOfNewSubfolders
            aStrPathNewSubfolders{cnf} = aStrPathSubfolders{oldNrOfSubfolders + cnf};
        end
    end
end
strucFolderContent.aStrPathSubfolders   = aStrPathSubfolders;
strucFolderContent.aStrPathFiles        = aStrPathFiles;


end


function [aStrPathSubfolders, aStrPathFiles, nrOfSubfolders, nrOfFiles] = searchDirectory(strPathCurrentFolder, aStrPathSubfolders, aStrPathFiles, nrOfSubfolders, nrOfFiles)
strucFolderContent = dir(strPathCurrentFolder);
strucFolderContent = strucFolderContent(3:end);
if numel(strucFolderContent) > 0;
    for ccont = 1:numel(strucFolderContent)
        if strucFolderContent(ccont).isdir
            nrOfSubfolders = nrOfSubfolders + 1;
            strPathSubDir = strcat(strPathCurrentFolder, strucFolderContent(ccont).name, '\');
            aStrPathSubfolders{nrOfSubfolders} = strPathSubDir;
        else
            nrOfFiles = nrOfFiles + 1;
            strPathFile = strcat(strPathCurrentFolder, strucFolderContent(ccont).name);            
            aStrPathFiles{nrOfFiles} = strPathFile;
        end
    end
end


end