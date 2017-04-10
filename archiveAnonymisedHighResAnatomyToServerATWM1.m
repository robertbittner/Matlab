function [strPathLocalZipFileAnonymisedHighResAnatomy, strPathServerZipFileAnonymisedHighResAnatomy, success] = archiveAnonymisedHighResAnatomyToServerATWM1(folderDefinition, parametersMriSession, parametersStructuralMriSequenceHighRes, aStrLocalPathOriginalDicomFiles, parametersFileTransfer)
%%% Anonymise and copy DICOM files of high-res anatomy in separate folder on the server

global iStudy
global strGroup
global strSubject

parametersDicomFileAnonymisation = eval(['parametersDicomFileAnonymisation', iStudy]);

folderDefinition = defineAnonymisedHighResAnatomyArchiveFolderATWM1(folderDefinition, parametersDicomFileAnonymisation);
[aStrPathOriginalDicomFilesVmrHighRes, aStrOriginalDicomFilesVmrHighRes] = defineHighResAnatomyDicomFilesATWM1(parametersMriSession, aStrLocalPathOriginalDicomFiles);

[folderDefinition, aStrPathDicomFilesForAnonymisation, nFilesVmrHighRes, success] = copyDicomFilesToLocalArchiveForAnonymisationATWM1(folderDefinition, parametersFileTransfer, aStrPathOriginalDicomFilesVmrHighRes, aStrOriginalDicomFilesVmrHighRes);

if success
    [aStrAnonymisedDicomFilesVmrHighRes, aStrPathAnonymisedDicomFilesVmrHighRes] = anonymiseDicomFilesVmrHighResATWM1(aStrPathDicomFilesForAnonymisation, nFilesVmrHighRes);
    [strZipFileAnonymisedHighResAnatomy, strPathLocalZipFileAnonymisedHighResAnatomy, success] = zipAnonymisedDicomFilesATWM1(folderDefinition, parametersStructuralMriSequenceHighRes);
    
    if success
        [strPathServerZipFileAnonymisedHighResAnatomy, success] = copyZipFileWithAnonymisedDicomFilesToServerATWM1(folderDefinition, strZipFileAnonymisedHighResAnatomy, strPathLocalZipFileAnonymisedHighResAnatomy);
    end
    
end

end


function [aStrPathOriginalDicomFilesVmrHighRes, aStrOriginalDicomFilesVmrHighRes] = defineHighResAnatomyDicomFilesATWM1(parametersMriSession, aStrLocalPathOriginalDicomFiles)
%%% Define name and path of high-res anatomy DICOM files
fileIndexVmrHighRes = parametersMriSession.fileIndexVmrHighRes;
nFilesVmrHighRes    = parametersMriSession.nMeasurementsInRun(fileIndexVmrHighRes);

indexStart  = parametersMriSession.vStartIndexDicomFileRun(fileIndexVmrHighRes);
indexEnd    = indexStart + nFilesVmrHighRes;

aStrPathOriginalDicomFilesVmrHighRes    = aStrLocalPathOriginalDicomFiles(indexStart : indexEnd - 1);

strSeparator = '\';
for cf = 1:numel(aStrPathOriginalDicomFilesVmrHighRes)
    index = strfind(aStrPathOriginalDicomFilesVmrHighRes, strSeparator);
    index = index(:, 1);
    aStrOriginalDicomFilesVmrHighRes{cf} = aStrPathOriginalDicomFilesVmrHighRes(index + 1 : end);
end

end


function [folderDefinition, aStrPathDicomFilesForAnonymisation, nFilesVmrHighRes, success] = copyDicomFilesToLocalArchiveForAnonymisationATWM1(folderDefinition, parametersFileTransfer, aStrPathOriginalDicomFilesVmrHighRes, aStrOriginalDicomFilesVmrHighRes)
%%% Copy DICOM files of high-res anatomy in separate archive folder for
%%% anonymisation

global strSubject

%%% Create subject folder and anonymised subfolder for DICOM files
if ~exist(folderDefinition.archiveAnonymisedHighResAnatomySubject, 'dir')
    mkdir(folderDefinition.archiveAnonymisedHighResAnatomySubject);
    if ~exist(folderDefinition.archiveAnonymisedHighResAnatomySubjectAnon, 'dir')
        mkdir(folderDefinition.archiveAnonymisedHighResAnatomySubjectAnon);
    end
end

nFilesVmrHighRes = numel(aStrOriginalDicomFilesVmrHighRes);

for cf = 1:nFilesVmrHighRes
    %%% Define file path and copy file
    aStrPathDicomFilesForAnonymisation{cf} = fullfile(folderDefinition.archiveAnonymisedHighResAnatomySubjectAnon, aStrOriginalDicomFilesVmrHighRes{cf});
    if parametersFileTransfer.bOverwriteExistingFiles == true || ~exist(aStrPathDicomFilesForAnonymisation{cf}, 'file')
        success(cf) = copyfile(aStrPathOriginalDicomFilesVmrHighRes{cf}, aStrPathDicomFilesForAnonymisation{cf});
    else
        success(cf) = 1;
    end
end

if sum(success) == nFilesVmrHighRes
    fprintf('All %i DICOM files for high-res anatomy of subject %s successfully copied for anonymisation!\n\n', nFilesVmrHighRes, strSubject);
    success = true;
else
    nrOfFilesNotCopied = nFilesVmrHighRes - sum(success);
    success = false;
    fprintf('Error while copying DICOM files for high-res anatomy of subject %s for anonymisation!\n', strSubject);
    fprintf('%i DICOM files were not copied!\n\n', nrOfFilesNotCopied);
end

end


function [aStrAnonymisedDicomFilesVmrHighRes, aStrPathAnonymisedDicomFilesVmrHighRes] = anonymiseDicomFilesVmrHighResATWM1(aStrPathDicomFilesForAnonymisation, nFilesVmrHighRes)
%%% Anonymise DICOM files of high-res anatomy
for cf = 1:nFilesVmrHighRes
    fprintf('WARNING! Anonymisation of DICOM files has not yet been implemented and tested!\n');
    aStrPathAnonymisedDicomFilesVmrHighRes{cf}  = aStrPathDicomFilesForAnonymisation{cf};
    %aStrPathAnonymisedDicomFilesVmrHighRes{cf}  = dicmonanon(aStrPathOriginalDicomFilesVmrHighRes{cf});
    %%% This might not be necessary / might have to be modified
    %%% This depends on the implementation of the anondicom function, i.e.,
    %%% whether it creates a new file our just keeps the anonDicom in
    %%% memory
    index = strfind(aStrPathAnonymisedDicomFilesVmrHighRes{cf}, '\');
    indexFolder = index(end);
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


function [strZipFileAnonymisedHighResAnatomy, strPathLocalZipFileAnonymisedHighResAnatomy, success] = zipAnonymisedDicomFilesATWM1(folderDefinition, parametersStructuralMriSequenceHighRes)

strZipFileAnonymisedHighResAnatomy = sprintf('%s.zip', parametersStructuralMriSequenceHighRes.strSequence);
strPathLocalZipFileAnonymisedHighResAnatomy = fullfile(folderDefinition.folderDefinition.archiveAnonymisedHighResAnatomySubject, strZipFileAnonymisedHighResAnatomy);
try
    zip(strPathLocalZipFileAnonymisedHighResAnatomy, folderDefinition.archiveAnonymisedHighResAnatomySubjectSubfolder);
    success = 1;
catch
    success = 0;
    fprintf('Error! Could not create zip file containing anonymised DICOM files for subject %s!\n\n', strSubject);
end

if success
    %%% Delete anonymised DICOM files
    try
        rmdir(folderDefinition.archiveAnonymisedHighResAnatomySubjectAnon, 's');
        success = true;
    catch
        success = false;
        fprintf('Error! Could not delete local folder containing anonymised DICOM files for subject %s!\n\n', strSubject);
    end
end

end


function [strPathServerZipFileAnonymisedHighResAnatomy, success] = copyZipFileWithAnonymisedDicomFilesToServerATWM1(folderDefinition, strZipFileAnonymisedHighResAnatomy, strPathLocalZipFileAnonymisedHighResAnatomy)

global strSubject

%%% Copy zip file to server folder
if ~exist(folderDefinition.archiveAnonymisedHighResAnatomyGroupServer, 'dir')
    mkdir(folderDefinition.archiveAnonymisedHighResAnatomyGroupServer);
end
if ~exist(folderDefinition.archiveAnonymisedHighResAnatomySubjectServer, 'dir')
    mkdir(folderDefinition.archiveAnonymisedHighResAnatomySubjectServer);
end
strPathServerZipFileAnonymisedHighResAnatomy = fullfile(folderDefinition.archiveAnonymisedHighResAnatomySubjectServer, strZipFileAnonymisedHighResAnatomy);
[success, strCopyMessage] = copyfile(strPathLocalZipFileAnonymisedHighResAnatomy, strPathServerZipFileAnonymisedHighResAnatomy);

if success
    fprintf('Anonymised DICOM files for high-res anatomy of subject %s successfully stored in zip archive on server!\n\n', strSubject);
else
	fprintf('Error while storing anonymised DICOM files for high-res anatomy of subject %s in zip archive on server!\n', strSubject);
    disp(strCopyMessage);
end

end