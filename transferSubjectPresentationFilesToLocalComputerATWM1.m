function transferSubjectPresentationFilesToLocalComputerATWM1()

clear all
clc

global iStudy

iStudy = 'ATWM1';

folderDefinition        = eval(['folderDefinition', iStudy]);
parametersStudy         = eval(['parametersStudy', iStudy]);
parametersGroups        = eval(['parametersGroups', iStudy]);

strPresentationFileFolder = 'PresentationFiles_Subjects';
pathLocalPresentationFileFolder = strcat(folderDefinition.presentationFiles, strPresentationFileFolder, '\');
pathServerPresentationFileFolder = strrep(pathLocalPresentationFileFolder, folderDefinition.dataDirectoryLocal, folderDefinition.dataDirectoryServer);

parametersFileTransfer.strExtZip = '.zip';

%%% Check, whether all relevant local and server folders can be accessed
hFunction = str2func(sprintf('checkFolderAccess%s', iStudy));
bAllFoldersCanBeAccessed = feval(hFunction, folderDefinition);
if bAllFoldersCanBeAccessed == false
    error('Folders for study %s cannot be accessed.', iStudy);
end

%%% Read subject information
aSubject = eval(['processSubjectArray', iStudy, '_', parametersStudy.strImaging]);
aStrAllSubjects = aSubject.(matlab.lang.makeValidName(strcat(iStudy, '_', parametersStudy.strImaging))).(matlab.lang.makeValidName(parametersGroups.strGroups)).ALL;

[aLocalPathGroupSubfolder, bAbort] = preparePresentationFileGroupSubfoldersATWM1(parametersGroups, pathLocalPresentationFileFolder);
if bAbort == true
    return
end

[aStrServerPathGroupSubfolder, aStrPathSubjectSubfolder, aStrPathSubjectZipFile, nrOfSubjectFolders, nrOfSubjectZipFiles] = determinePresentationFoldersAndFilesForTransferATWM1(parametersGroups, parametersFileTransfer, aStrAllSubjects, pathServerPresentationFileFolder);

[aStrPathOriginalFolder, aStrPathTransferFolder, aStrPathOriginalFile, aStrPathTransferFile, bAbortTransfer] = preparePresentationFilesForTransferATWM1(folderDefinition, parametersGroups, aStrPathSubjectSubfolder, aStrPathSubjectZipFile, nrOfSubjectFolders, nrOfSubjectZipFiles);
if bAbortTransfer == true
    return
end
transferServerPresentationFolderAndFilesToLocalComputerATWM1(parametersGroups, aStrPathOriginalFolder, aStrPathTransferFolder, aStrPathOriginalFile, aStrPathTransferFile, nrOfSubjectFolders, nrOfSubjectZipFiles);


end


function [aStrLocalPathGroupSubfolder, bAbort] = preparePresentationFileGroupSubfoldersATWM1(parametersGroups, pathPresentationFileFolder)
%%% Check, whether group subfolders exist
if ~exist(pathPresentationFileFolder, 'dir')
    strMessage = sprintf('\nFolder %s could not be found!\nData transfer not possible!\n', pathPresentationFileFolder);
    disp(strMessage);
    bAbort = true;
    aStrLocalPathGroupSubfolder = [];
    return
else
    bAbort = false;
end
for cg = 1:parametersGroups.nGroups
    aStrLocalPathGroupSubfolder{cg} = strcat(pathPresentationFileFolder, parametersGroups.aStrShortGroups{cg}, '\');
    if ~exist(aStrLocalPathGroupSubfolder{cg}, 'dir')
        mkdir(aStrLocalPathGroupSubfolder{cg});
    end
end


end


function [aStrServerPathGroupSubfolder, aStrPathSubjectSubfolder, aStrPathSubjectZipFile, nrOfSubjectFolders, nrOfSubjectZipFiles] = determinePresentationFoldersAndFilesForTransferATWM1(parametersGroups, parametersFileTransfer, aStrAllSubjects, pathServerPresentationFileFolder)
%%% Detect subject folders and zip files on server
for cg = 1:parametersGroups.nGroups
    aStrServerPathGroupSubfolder{cg} = strcat(pathServerPresentationFileFolder, parametersGroups.aStrShortGroups{cg}, '\');
    strucSubfolderContent = dir(aStrServerPathGroupSubfolder{cg});
    strucSubfolderContent = strucSubfolderContent(3:end);
    nrOfSubjectFolders(cg) = 0;
    nrOfSubjectZipFiles(cg) = 0;
    for ccont = 1:numel(strucSubfolderContent)
        strSubfolderContent = strucSubfolderContent(ccont).name;
        pathSubfolderContent = strcat(aStrServerPathGroupSubfolder{cg}, strSubfolderContent);
        if exist(pathSubfolderContent, 'dir') && ismember(strSubfolderContent, aStrAllSubjects)
            nrOfSubjectFolders(cg) = nrOfSubjectFolders(cg) + 1;
            aStrPathSubjectSubfolder{cg, nrOfSubjectFolders(cg)} = pathSubfolderContent;
        elseif exist(pathSubfolderContent, 'file') 
            indEnd = strfind(strSubfolderContent, '_');
            indEnd = indEnd(1) - 1;
            strSubject = strSubfolderContent(1:indEnd);
            if strfind(strSubfolderContent, parametersFileTransfer.strExtZip) && ismember(strSubject, aStrAllSubjects)
                nrOfSubjectZipFiles(cg) = nrOfSubjectZipFiles(cg) + 1;
                aStrPathSubjectZipFile{cg, nrOfSubjectZipFiles(cg)} = pathSubfolderContent;
            end
        end
    end
end


end


function [aStrPathOriginalFolder, aStrPathTransferFolder, aStrPathOriginalFile, aStrPathTransferFile, bAbortTransfer] = preparePresentationFilesForTransferATWM1(folderDefinition, parametersGroups, aStrPathSubjectSubfolder, aStrPathSubjectZipFile, nrOfSubjectFolders, nrOfSubjectZipFiles)
%%% Compare orginal files and backup files
bAbortTransfer = false;
for cg = 1:parametersGroups.nGroups
    %%% Prepare folders for transfer
    for cs = 1:nrOfSubjectFolders(cg)
        pathOriginalFolder = aStrPathSubjectSubfolder{cg, cs};
        pathTransferFolder = strrep(pathOriginalFolder, folderDefinition.dataDirectoryServer, folderDefinition.dataDirectoryLocal);
        %bAbortTransfer = detectMoreRecentChangeInLocalFolderATWM1(bAbortTransfer, pathOriginalFolder, pathTransferFolder);
        aStrPathOriginalFolder{cg, cs} = pathOriginalFolder;
        aStrPathTransferFolder{cg, cs} = pathTransferFolder;
    end
    %%% Prepare files for transfer
    for cs = 1:nrOfSubjectZipFiles(cg)
        pathOriginalFile = aStrPathSubjectZipFile{cg, cs};
        pathTransferFile = strrep(pathOriginalFile, folderDefinition.dataDirectoryServer, folderDefinition.dataDirectoryLocal);
        bAbortTransfer = detectMoreRecentChangeOfLocalFileATWM1(bAbortTransfer, pathOriginalFile, pathTransferFile);
        aStrPathOriginalFile{cg, cs} = pathOriginalFile;
        aStrPathTransferFile{cg, cs} = pathTransferFile;
    end
end

if bAbortTransfer == true
    strMessage = 'Aborting file transfer!';
    waitfor(msgbox(strMessage));
    disp(strMessage);
end


end


function bAbortTransfer = detectMoreRecentChangeOfLocalFileATWM1(bAbortTransfer, pathOriginalFile, pathTransferFile)

if exist(pathTransferFile, 'file')
    strucLocalFile = dir(pathOriginalFile);
    strucServerFile = dir(pathTransferFile);
    %%% Check, whether local file was changed more recently than server
    %%% file
    if strucLocalFile.datenum > strucServerFile.datenum
        strMessage = sprintf('Error! Local file %s was changed more recently than server file %s', pathTransferFile, pathOriginalFile);
        disp(strMessage);
        bAbortTransfer = true;
    end
end

end


function bAbortTransfer = detectMoreRecentChangeInLocalFolderATWM1(bAbortTransfer, pathOriginalFolder, pathTransferFolder)
% strucFolderContent = folderContentATWM1(folder)
if exist(pathTransferFolder, 'dir')
    strucServerFolder = dir(pathOriginalFolder);
    strucLocalFolder = dir(pathTransferFolder);
    %%% Check, whether local folder was changed more recently than server
    %%% folder
    if strucLocalFolder.datenum > strucServerFolder.datenum
        %if test > test2
        strMessage = sprintf('Error! Local folder %s was changed more recently than server file %s', pathTransferFolder, pathOriginalFolder);
        disp(strMessage);
        bAbortTransfer = true;
    end
end

end


function transferServerPresentationFolderAndFilesToLocalComputerATWM1(parametersGroups, aStrPathOriginalFolder, aStrPathTransferFolder, aStrPathOriginalFile, aStrPathTransferFile, nrOfSubjectFolders, nrOfSubjectZipFiles)
bServerPresentationFoldersAndFilesTransferredToLocalComputer = false;

for cg = 1:parametersGroups.nGroups
    %%% Transfer folders
    for cs = 1:nrOfSubjectFolders(cg)
        pathOriginalFolder = aStrPathOriginalFolder{cg, cs};
        pathTransferFolder = aStrPathTransferFolder{cg, cs};
        bAbortTransfer = false;
        if bAbortTransfer == false
            copyfile(pathOriginalFolder, pathTransferFolder);
            strMessage = sprintf('Transferring folder %s to local computer.', pathOriginalFolder);
            disp(strMessage);
            bServerPresentationFoldersAndFilesTransferredToLocalComputer = true;
        end
    end
    %%% Transfer files
    for cs = 1:nrOfSubjectZipFiles(cg)
        pathOriginalFile = aStrPathOriginalFile{cg, cs};
        pathTransferFile = aStrPathTransferFile{cg, cs};
        bAbortTransfer = compareChangeDateOfServerAndLocalFileATWM1(pathOriginalFile, pathTransferFile);
        if bAbortTransfer == false
            copyfile(pathOriginalFile, pathTransferFile);
            strMessage = sprintf('Transferring file %s to local computer %s.', pathOriginalFile, pathTransferFile);
            disp(strMessage);
            bServerPresentationFoldersAndFilesTransferredToLocalComputer = true;
        end
    end
end

if bServerPresentationFoldersAndFilesTransferredToLocalComputer == true
    strMessage = sprintf('Transfer of Presentation data successful!\n');
    disp(strMessage);
else
    strMessage = sprintf('No transfer of Presentation data required!\n');
    disp(strMessage);
end


end


function bAbortTransfer = compareChangeDateOfServerAndLocalFolderATWM1(pathOriginalFolder, pathTransferFolder)

bAbortTransfer = false;
if exist(pathTransferFolder, 'dir')
    strucLocalFolder = dir(pathTransferFolder);
    strucServerFolder = dir(pathOriginalFolder);
    %%% Check, whether change date of server and local folder matches
    if strucLocalFolder.datenum == strucServerFolder.datenum
        strMessage = sprintf('No transfer necessary for folder %s\nChange date of server and local folder identical.\n\n', pathOriginalFolder);
        disp(strMessage);
        bAbortTransfer = true;
    end
end

end


function bAbortTransfer = compareChangeDateOfServerAndLocalFileATWM1(pathOriginalFile, pathTransferFile)

bAbortTransfer = false;
if exist(pathTransferFile, 'file')
    strucLocalFile = dir(pathTransferFile);
    strucServerFile = dir(pathOriginalFile);
    %%% Check, whether change date of server and local file matches
    if strucLocalFile.datenum == strucServerFile.datenum
        strMessage = sprintf('No transfer necessary for file %s\nChange date of server and local file identical.\n\n', pathOriginalFile);
        disp(strMessage);
        bAbortTransfer = true;
    end
end

end