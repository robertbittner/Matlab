function archiveAnonymisedHighResAnatomyToServerATWM1(folderDefinition, parametersMriSession, parametersStructuralMriSequenceHighRes, aStrLocalPathOriginalDicomFiles, aStrOriginalDicomFiles, parametersFileTransfer)
%%% Anonymise and copy DICOM files of high-res anatomy in separate folder on the server

global iStudy
global strGroup
global strSubject

[aStrPathOriginalDicomFilesVmrHighRes] = defineHighResAnatomyDicomFilesATWM1(parametersMriSession);
%{
%%% Detect high-res anatomy
fileIndexVmrHighRes = parametersMriSession.fileIndexVmrHighRes;
nFilesVmrHighRes    = parametersMriSession.nMeasurementsInRun(fileIndexVmrHighRes);
indexStart  = parametersMriSession.vStartIndexDicomFileRun(fileIndexVmrHighRes);
indexEnd    = indexStart + nFilesVmrHighRes;
aStrPathOriginalDicomFilesVmrHighRes    = aStrLocalPathOriginalDicomFiles(indexStart : indexEnd - 1);
aStrOriginalDicomFilesVmrHighRes        = aStrOriginalDicomFiles(indexStart : indexEnd - 1);
%}

[aStrAnonymisedDicomFilesVmrHighRes, aStrPathAnonymisedDicomFilesVmrHighRes] = anonymiseDicomFilesVmrHighResATWM1(aStrPathOriginalDicomFilesVmrHighRes, nFilesVmrHighRes);
%{
%%% Anonymise DICOM files
for cf = 1:nFilesVmrHighRes
    fprintf('WARNING! Anonymisation of DICOM files has not yet been tested and implemented!\n');
    aStrPathAnonymisedDicomFilesVmrHighRes{cf}  = aStrPathOriginalDicomFilesVmrHighRes{cf};
    %aStrPathAnonymisedDicomFilesVmrHighRes{cf}  = dicmonanon(aStrPathOriginalDicomFilesVmrHighRes{cf});
    %%% This might not be necessary / might have to be modified
    indexFile = strfind(aStrPathAnonymisedDicomFilesVmrHighRes{cf}, '\');
    indexFile = indexFile(end) + 1;
    aStrAnonymisedDicomFilesVmrHighRes{cf} = aStrPathAnonymisedDicomFilesVmrHighRes{cf}(indexFile:end);
    %%% This might not be necessary    
end
%}
%%% Copy anonymised DICOM files of high-res anatomy in separate archive
%%% folder on local computer
folderDefinition = defineAnonymisedHighResAnatomyArchiveFolderATWM1(folderDefinition);
if ~exist(folderDefinition.archiveAnonymisedHighResAnatomySubject, 'dir')
    mkdir(folderDefinition.archiveAnonymisedHighResAnatomySubject);
end
if ~exist(folderDefinition.archiveAnonymisedHighResAnatomySubjectSubfolder, 'dir')
    mkdir(folderDefinition.archiveAnonymisedHighResAnatomySubjectSubfolder);
end

for cf = 1:nFilesVmrHighRes
    strPathHighResAnatomy = fullfile(folderDefinition.archiveAnonymisedHighResAnatomySubject, aStrAnonymisedDicomFilesVmrHighRes{cf});
    strPathAnonymisedDicomFilesVmrHighRes = aStrPathAnonymisedDicomFilesVmrHighRes{cf};
    if parametersFileTransfer.bOverwriteExistingFiles == true || ~exist(strPathHighResAnatomy, 'file')
        success(cf) = copyfile(strPathAnonymisedDicomFilesVmrHighRes, strPathHighResAnatomy);
    else
        success(cf) = 1;
    end
end

if sum(success) == nFilesVmrHighRes
    strMessage = sprintf('All %i DICOM files for high-res anatomy of subject %s successfully copied to local computer!\n', nFilesVmrHighRes, strSubject);
    disp(strMessage);
else
    nrOfFilesNotCopied = nFilesVmrHighRes - sum(success);
    strMessage = sprintf('Error while copying DICOM files for high-res anatomy of subject %s to local computer!', strSubject);
    disp(strMessage);
    strMessage = sprintf('%i DICOM files were not copied!\n', nrOfFilesNotCopied);
    disp(strMessage);
end

%%% Zip high-res anatomy
strZipFileHighResAnatomy = sprintf('%s_%s_%s.zip', strSubject, iStudy, parametersStructuralMriSequenceHighRes.strSequence);
strPathZipFileHighResAnatomy = fullfile(folderDefinition.archiveAnonymisedHighResAnatomyGroup, strZipFileHighResAnatomy);
zip(strPathZipFileHighResAnatomy, folderDefinition.archiveAnonymisedHighResAnatomySubject);

%%% Copy zip file to server folder
if parametersFileTransfer.bArchiveFilesOnServer
    folderDefinition.archiveAnonymisedHighResAnatomyGroupServer = strcat(folderDefinition.archiveAnonymisedHighResAnatomyServer, strGroup, '\');
    if ~exist(folderDefinition.archiveAnonymisedHighResAnatomyGroupServer, 'dir')
        mkdir(folderDefinition.archiveAnonymisedHighResAnatomyGroupServer);
    end
    strPathServerZipFileHighResAnatomy = fullfile(folderDefinition.archiveAnonymisedHighResAnatomyGroupServer, strZipFileHighResAnatomy);
    [success, strCopyMessage] = copyfile(strPathZipFileHighResAnatomy, strPathServerZipFileHighResAnatomy);
    
    if success
        strMessage = sprintf('All %i anonymised DICOM files for high-res anatomy of subject %s successfully stored in zip archive\n%s on server!\n', nFilesVmrHighRes, strSubject, strPathServerZipFileHighResAnatomy);
        disp(strMessage);
    else
        nrOfFilesNotCopied = nFilesVmrHighRes - sum(success);
        strMessage = sprintf('Error while storing anonymised DICOM files for high-res anatomy of subject %s in zip archive %s on server!', strSubject, strPathServerZipFileHighResAnatomy);
        disp(strMessage);
        strMessage = sprintf('%i DICOM files were not copied!\n', nrOfFilesNotCopied);
        disp(strMessage);
        disp(strCopyMessage);
    end
end


end


function [aStrPathOriginalDicomFilesVmrHighRes] = defineHighResAnatomyDicomFilesATWM1(parametersMriSession)
%%% Define path to high-res anatomy DICOM files
fileIndexVmrHighRes = parametersMriSession.fileIndexVmrHighRes;
nFilesVmrHighRes    = parametersMriSession.nMeasurementsInRun(fileIndexVmrHighRes);

indexStart  = parametersMriSession.vStartIndexDicomFileRun(fileIndexVmrHighRes);
indexEnd    = indexStart + nFilesVmrHighRes;

aStrPathOriginalDicomFilesVmrHighRes    = aStrLocalPathOriginalDicomFiles(indexStart : indexEnd - 1);
%aStrOriginalDicomFilesVmrHighRes        = aStrOriginalDicomFiles(indexStart : indexEnd - 1);


end


function [aStrAnonymisedDicomFilesVmrHighRes, aStrPathAnonymisedDicomFilesVmrHighRes] = anonymiseDicomFilesVmrHighResATWM1(aStrPathOriginalDicomFilesVmrHighRes, nFilesVmrHighRes)
%%% Anonymise DICOM files of high-res anatomy 
for cf = 1:nFilesVmrHighRes
    fprintf('WARNING! Anonymisation of DICOM files has not yet been implemented and tested!\n');
    aStrPathAnonymisedDicomFilesVmrHighRes{cf}  = aStrPathOriginalDicomFilesVmrHighRes{cf};
    %aStrPathAnonymisedDicomFilesVmrHighRes{cf}  = dicmonanon(aStrPathOriginalDicomFilesVmrHighRes{cf});
    %%% This might not be necessary / might have to be modified
    %%% This depends on the implementation of the anondicom function, i.e.,
    %%% whether it creates a new file our just keeps the anonDicom in
    %%% memory
    index = strfind(aStrPathAnonymisedDicomFilesVmrHighRes{cf}, '\');
    indexFolder = index(end) ;
    indexFile = index(end) + 1;
    aStrAnonymisedDicomFilesVmrHighRes{cf} = aStrPathAnonymisedDicomFilesVmrHighRes{cf}(indexFile:end);
    %%% This might not be necessary    
    
    %%% REMOVE
    %%% Creates a dummy anonDicom files
    aStrNewAnonymisedDicomFilesVmrHighRes = strcat('ANON', '_', aStrAnonymisedDicomFilesVmrHighRes);
    folder = aStrPathAnonymisedDicomFilesVmrHighRes{cf}(1:indexFolder);
    aStrNewPathAnonymisedDicomFilesVmrHighRes{cf} = fullfile(folder, aStrNewAnonymisedDicomFilesVmrHighRes);
    copyfile(aStrPathAnonymisedDicomFilesVmrHighRes{cf}, aStrNewPathAnonymisedDicomFilesVmrHighRes{cf});
    
    aStrPathAnonymisedDicomFilesVmrHighRes{cf} = aStrNewPathAnonymisedDicomFilesVmrHighRes{cf};
    aStrAnonymisedDicomFilesVmrHighRes{cf} = aStrNewAnonymisedDicomFilesVmrHighRes{cf};
    %%% REMOVE
end


end


function [folderDefinition] = copyAnonymisedDicomFilesToLocalArchiveATWM1(folderDefinition, aStrAnonymisedDicomFilesVmrHighRes, aStrPathAnonymisedDicomFilesVmrHighRes, nFilesVmrHighRes)
global strSubject

%%% Copy anonymised DICOM files of high-res anatomy in separate archive
%%% folder on local computer
folderDefinition = defineAnonymisedHighResAnatomyArchiveFolderATWM1(folderDefinition);
if ~exist(folderDefinition.archiveAnonymisedHighResAnatomySubject, 'dir')
    mkdir(folderDefinition.archiveAnonymisedHighResAnatomySubject);
end
if ~exist(folderDefinition.archiveAnonymisedHighResAnatomySubjectSubfolder, 'dir')
    mkdir(folderDefinition.archiveAnonymisedHighResAnatomySubjectSubfolder);
end

for cf = 1:nFilesVmrHighRes
    strPathAnoymisedHighResAnatomy = fullfile(folderDefinition.archiveAnonymisedHighResAnatomySubject, aStrAnonymisedDicomFilesVmrHighRes{cf});
    strPathAnonymisedDicomFilesVmrHighRes = aStrPathAnonymisedDicomFilesVmrHighRes{cf};
    if parametersFileTransfer.bOverwriteExistingFiles == true || ~exist(strPathAnoymisedHighResAnatomy, 'file')
        success(cf) = copyfile(strPathAnonymisedDicomFilesVmrHighRes, strPathAnoymisedHighResAnatomy);
    else
        success(cf) = 1;
    end
end

if sum(success) == nFilesVmrHighRes
    strMessage = sprintf('All %i DICOM files for high-res anatomy of subject %s successfully copied to local computer!\n', nFilesVmrHighRes, strSubject);
    disp(strMessage);
else
    nrOfFilesNotCopied = nFilesVmrHighRes - sum(success);
    strMessage = sprintf('Error while copying DICOM files for high-res anatomy of subject %s to local computer!', strSubject);
    disp(strMessage);
    strMessage = sprintf('%i DICOM files were not copied!\n', nrOfFilesNotCopied);
    disp(strMessage);
end


end