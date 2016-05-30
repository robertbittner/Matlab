function transferCurrentSubjectDataToServerATWM1();

clear all
clc

global iStudy

iStudy = 'ATWM1';

folderDefinition        = eval(['folderDefinition', iStudy]);
parametersStudy         = eval(['parametersStudy', iStudy]);
parametersGroups        = eval(['parametersGroups', iStudy]);

%%% Check, whether all relevant local and server folders can be accessed
hFunction = str2func(sprintf('checkFolderAccess%s', iStudy));
bAllFoldersCanBeAccessed = feval(hFunction, folderDefinition);
if bAllFoldersCanBeAccessed == false
    error('Folders for study %s cannot be accessed.', iStudy);
end

%%% Read subject information
aSubject = eval(['processSubjectArray', iStudy, '_', parametersStudy.strImaging]);
nrOfSubjects = aSubject.(matlab.lang.makeValidName(strcat(iStudy, '_', parametersStudy.strImaging))).nSubjects.ALL;
aStrAllSubjects = aSubject.(matlab.lang.makeValidName(strcat(iStudy, '_', parametersStudy.strImaging))).(matlab.lang.makeValidName(parametersGroups.strGroups)).ALL;

[aStrBarcodeFile, aStrSubjectBarcode, nrOfBarcodeFiles] = readBarcodeFileNamesATWM1;
[aStrSubjectCodeFile, aStrSubjectCode, nrOfSubjectCodeFiles] = readSubjectCodeFileNamesATWM1;

checkFileAndSubjectIdConsistencyATWM1(aStrAllSubjects, aStrSubjectBarcode, aStrSubjectCode, nrOfSubjects, nrOfBarcodeFiles, nrOfSubjectCodeFiles)
strSubjectArrayFile = prepareSubjectArrayFileForTransferATWM1(folderDefinition, parametersStudy);
strAdditionalSubjectInformationFile = prepareAdditionalSubjectInformationFileForTransferATWM1(folderDefinition, parametersStudy);

%%% Compare local and server files
[aPathOriginalBarcodeFile, aPathTransferBarcodeFile, aPathOriginalSubjectCodeFile, aPathTransferSubjectCodeFile, aPathOriginalSubjectArrayFile, aPathTransferSubjectArrayFile, aPathOriginalAdditionalSubjectInformationFile, aPathTransferAdditionalSubjectInformationFile, bAbortTransfer] = prepareFilesForTransferATWM1(folderDefinition, aStrBarcodeFile, aStrSubjectCodeFile, strSubjectArrayFile, strAdditionalSubjectInformationFile, nrOfSubjects);
if bAbortTransfer == true
    return
end

%%% Transfer files
transferLocalSubjectInformationFilesToServerATWM1(aPathOriginalBarcodeFile, aPathTransferBarcodeFile, aPathOriginalSubjectCodeFile, aPathTransferSubjectCodeFile, aPathOriginalSubjectArrayFile, aPathTransferSubjectArrayFile, aPathOriginalAdditionalSubjectInformationFile, aPathTransferAdditionalSubjectInformationFile, nrOfSubjects);

end


function strSubjectArrayFile = prepareSubjectArrayFileForTransferATWM1(folderDefinition, parametersStudy);
global iStudy
% Check, whether subject array exists
strSubjectArrayFile = sprintf('aSubject%s_%s.m', iStudy, parametersStudy.strImaging);
pathSubjectArrayFile = strcat(folderDefinition.studyParameters, strSubjectArrayFile);

if ~exist(pathSubjectArrayFile, 'file')
    strMessage = sprintf('Could not find m-file %s containing subject informtion!\nAborting function.', pathSubjectArrayFile);
    error(strMessage);
end


end


function strAdditionalSubjectInformationFile = prepareAdditionalSubjectInformationFileForTransferATWM1(folderDefinition, parametersStudy);
global iStudy
% Check, whether subject array exists
strAdditionalSubjectInformationFile = sprintf('aAdditionalSubjectInformation%s_%s.m', iStudy, parametersStudy.strImaging);
pathAdditionalSubjectInformationFile = strcat(folderDefinition.studyParameters, strAdditionalSubjectInformationFile);

if ~exist(pathAdditionalSubjectInformationFile, 'file')
    strMessage = sprintf('Could not find m-file %s containing subject informtion!\nAborting function.', pathAdditionalSubjectInformationFile);
    error(strMessage);
end


end


function [aPathOriginalBarcodeFile, aPathTransferBarcodeFile, aPathOriginalSubjectCodeFile, aPathTransferSubjectCodeFile, aPathOriginalSubjectArrayFile, aPathTransferSubjectArrayFile, aPathOriginalAdditionalSubjectInformationFile, aPathTransferAdditionalSubjectInformationFile, bAbortTransfer] = prepareFilesForTransferATWM1(folderDefinition, aStrBarcodeFile, aStrSubjectCodeFile, strSubjectArrayFile, strAdditionalSubjectInformationFile, nrOfSubjects);
%%% Compare orginal files and backup files
bAbortTransfer = false;
for cs = 1:nrOfSubjects
    % Compare barcode files
    strOriginalFile = aStrBarcodeFile{cs};
    pathOriginalFile = fullfile(folderDefinition.barcodes, strOriginalFile);
    pathTransferFile = strrep(pathOriginalFile, folderDefinition.dataDirectoryLocal, folderDefinition.dataDirectoryServer);
    bAbortTransfer = detectMoreRecentChangeOfServerFileATWM1(bAbortTransfer, pathOriginalFile, pathTransferFile);
    aPathOriginalBarcodeFile{cs} = pathOriginalFile;
    aPathTransferBarcodeFile{cs} = pathTransferFile;
    
    % Compare subject code files
    strOriginalFile = aStrSubjectCodeFile{cs};
    pathOriginalFile = fullfile(folderDefinition.subjectCodes, strOriginalFile);
    pathTransferFile = strrep(pathOriginalFile, folderDefinition.dataDirectoryLocal, folderDefinition.dataDirectoryServer);
    bAbortTransfer = detectMoreRecentChangeOfServerFileATWM1(bAbortTransfer, pathOriginalFile, pathTransferFile);
    aPathOriginalSubjectCodeFile{cs} = pathOriginalFile;
    aPathTransferSubjectCodeFile{cs} = pathTransferFile;
end
% Compare subject array file
strOriginalFile = strSubjectArrayFile;
pathOriginalFile = fullfile(folderDefinition.studyParameters, strOriginalFile);
pathTransferFile = strrep(pathOriginalFile, folderDefinition.dataDirectoryLocal, folderDefinition.dataDirectoryServer);
bAbortTransfer = detectMoreRecentChangeOfServerFileATWM1(bAbortTransfer, pathOriginalFile, pathTransferFile);
aPathOriginalSubjectArrayFile = pathOriginalFile;
aPathTransferSubjectArrayFile = pathTransferFile;

% Compare additional subject information file
strOriginalFile = strAdditionalSubjectInformationFile;
pathOriginalFile = fullfile(folderDefinition.studyParameters, strOriginalFile);
pathTransferFile = strrep(pathOriginalFile, folderDefinition.dataDirectoryLocal, folderDefinition.dataDirectoryServer);
bAbortTransfer = detectMoreRecentChangeOfServerFileATWM1(bAbortTransfer, pathOriginalFile, pathTransferFile);
aPathOriginalAdditionalSubjectInformationFile = pathOriginalFile;
aPathTransferAdditionalSubjectInformationFile = pathTransferFile;

if bAbortTransfer == true
    strMessage = 'Aborting file transfer!';
    waitfor(msgbox(strMessage));
    disp(strMessage);
end

end


function bAbortTransfer = detectMoreRecentChangeOfServerFileATWM1(bAbortTransfer, pathOriginalFile, pathTransferFile);

if exist(pathTransferFile, 'file')
    strucLocalFile = dir(pathOriginalFile);
    strucServerFile = dir(pathTransferFile);
    %%% Check, whether server file was changed more recently than local
    %%% file
    if strucLocalFile.datenum < strucServerFile.datenum
        strMessage = sprintf('Error! Server file %s was changed more recently than local file %s', pathTransferFile, pathOriginalFile);
        disp(strMessage);
        bAbortTransfer = true;
    end
end

end


function transferLocalSubjectInformationFilesToServerATWM1(aPathOriginalBarcodeFile, aPathTransferBarcodeFile, aPathOriginalSubjectCodeFile, aPathTransferSubjectCodeFile, aPathOriginalSubjectArrayFile, aPathTransferSubjectArrayFile, aPathOriginalAdditionalSubjectInformationFile, aPathTransferAdditionalSubjectInformationFile, nrOfSubjects);
bLocalFilesTransferredToServer = false;
%%% Backup barcode files
for cs = 1:nrOfSubjects
    if ~exist(aPathTransferBarcodeFile{cs}, 'file')
        copyfile(aPathOriginalBarcodeFile{cs}, aPathTransferBarcodeFile{cs});
        strMessage = sprintf('Creating server backup of file %s', aPathOriginalBarcodeFile{cs});
        disp(strMessage);
        bLocalFilesTransferredToServer = true;
    end
end
%%% Backup subject code files
for cs = 1:nrOfSubjects
    if ~exist(aPathTransferSubjectCodeFile{cs}, 'file')
        copyfile(aPathOriginalSubjectCodeFile{cs}, aPathTransferSubjectCodeFile{cs});
        strMessage = sprintf('Creating server backup of file %s', aPathOriginalSubjectCodeFile{cs});
        disp(strMessage);
        bLocalFilesTransferredToServer = true;
    end
end
%%% Backup subject array file
bAbortTransfer = compareChangeDateOfLocalAndServerFileATWM1(aPathOriginalSubjectArrayFile, aPathTransferSubjectArrayFile);
if bAbortTransfer == false
    copyfile(aPathOriginalSubjectArrayFile, aPathTransferSubjectArrayFile);
    strMessage = sprintf('Creating server backup of file %s', aPathOriginalSubjectArrayFile);
    disp(strMessage);
    bLocalFilesTransferredToServer = true;
end
%%% Backup additional subject information file
bAbortTransfer = compareChangeDateOfLocalAndServerFileATWM1(aPathOriginalAdditionalSubjectInformationFile, aPathTransferAdditionalSubjectInformationFile);
if bAbortTransfer == false
    copyfile(aPathOriginalAdditionalSubjectInformationFile, aPathTransferAdditionalSubjectInformationFile);
    strMessage = sprintf('Creating server backup of file %s', aPathOriginalAdditionalSubjectInformationFile);
    disp(strMessage);
    bLocalFilesTransferredToServer = true;
end
if bLocalFilesTransferredToServer == true
    strMessage = sprintf('Transfer of subject data successful!\n');
    disp(strMessage);
else
    strMessage = sprintf('No transfer of subject data required!\n');
    disp(strMessage);
end


end


function bAbortTransfer = compareChangeDateOfLocalAndServerFileATWM1(pathOriginalFile, pathTransferFile);

if exist(pathTransferFile, 'file')
    strucLocalFile = dir(pathOriginalFile);
    strucServerFile = dir(pathTransferFile);
    %%% Check, whether change date of local and server file matches
    if strucLocalFile.datenum == strucServerFile.datenum
        strMessage = sprintf('No transfer necessary for file %s\nChange date of local and server file identical.\n\n', pathOriginalFile);
        disp(strMessage);
        bAbortTransfer = true;
    else
        bAbortTransfer = false;
    end
end

end