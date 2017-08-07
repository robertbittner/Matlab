function [folderDefinition, strPathLocalZipFileAnonymisedHighResAnatomy, strPathServerZipFileAnonymisedHighResAnatomy, success] = archiveAnonymisedHighResAnatomyToServerATWM1(folderDefinition, parametersMriSession,  parametersFileTransfer, parametersStructuralMriSequenceHighRes, aStrLocalPathOriginalDicomFiles)
%%% Anonymise and copy DICOM files of high-res anatomy in separate folder on the server

global iStudy
global strGroup
global strSubject

parametersFileTransfer.bArchiveFilesOnServer = true;


parametersDicomFileAnonymisation = eval(['parametersDicomFileAnonymisation', iStudy]);

folderDefinition = defineAnonymisedHighResAnatomyArchiveFolderSubjectATWM1(folderDefinition, parametersDicomFileAnonymisation, parametersStructuralMriSequenceHighRes);
[aStrPathOriginalDicomFilesVmrHighRes, aStrOriginalDicomFilesVmrHighRes] = defineHighResAnatomyDicomFilesATWM1(parametersMriSession, aStrLocalPathOriginalDicomFiles);
[folderDefinition, aStrPathDicomFilesForAnonymisation, nFilesVmrHighRes, bAllFilesCopied] = copyDicomFilesToLocalArchiveForAnonymisationATWM1(folderDefinition, parametersFileTransfer, aStrPathOriginalDicomFilesVmrHighRes, aStrOriginalDicomFilesVmrHighRes);

if bAllFilesCopied
    [aStrAnonymisedDicomFilesVmrHighRes, aStrPathAnonymisedDicomFilesVmrHighRes] = anonymiseDicomFilesVmrHighResATWM1(folderDefinition, parametersDicomFileAnonymisation, aStrPathDicomFilesForAnonymisation, aStrOriginalDicomFilesVmrHighRes, nFilesVmrHighRes);
    [strZipFileAnonymisedHighResAnatomy, strPathLocalZipFileAnonymisedHighResAnatomy, success] = zipAnonymisedDicomFilesATWM1(folderDefinition, parametersStructuralMriSequenceHighRes);
    
    if success && parametersFileTransfer.bArchiveFilesOnServer
        [strPathServerZipFileAnonymisedHighResAnatomy, success] = copyZipFileWithAnonymisedDicomFilesToServerATWM1(folderDefinition, strZipFileAnonymisedHighResAnatomy, strPathLocalZipFileAnonymisedHighResAnatomy);
    else
        strPathServerZipFileAnonymisedHighResAnatomy = '';
    end
    
end


end


function [folderDefinition, aStrPathDicomFilesForAnonymisation, nFilesVmrHighRes, bAllFilesCopied] = copyDicomFilesToLocalArchiveForAnonymisationATWM1(folderDefinition, parametersFileTransfer, aStrPathOriginalDicomFilesVmrHighRes, aStrOriginalDicomFilesVmrHighRes)
%%% Copy DICOM files of high-res anatomy in separate archive folder for
%%% anonymisation

global strSubject

%%% Create subject folder and anonymised subfolder for DICOM files
if ~exist(folderDefinition.anonymisedDataArchiveHighResAnatomySubject, 'dir')
    mkdir(folderDefinition.anonymisedDataArchiveHighResAnatomySubject);
end
if ~exist(folderDefinition.anonymisedDataArchiveHighResAnatomySubjectAnon, 'dir')
    mkdir(folderDefinition.anonymisedDataArchiveHighResAnatomySubjectAnon);
end


nFilesVmrHighRes = numel(aStrOriginalDicomFilesVmrHighRes);

for cf = 1:nFilesVmrHighRes
    %%% Define file path and copy file
    aStrPathDicomFilesForAnonymisation{cf} = fullfile(folderDefinition.anonymisedDataArchiveHighResAnatomySubjectAnon, aStrOriginalDicomFilesVmrHighRes{cf});
    if parametersFileTransfer.bOverwriteExistingFiles == true || ~exist(aStrPathDicomFilesForAnonymisation{cf}, 'file')
        %success(cf) = copyfile(aStrPathOriginalDicomFilesVmrHighRes{cf}, aStrPathDicomFilesForAnonymisation{cf});
        [success(cf),MESSAGE,MESSAGEID]= copyfile(aStrPathOriginalDicomFilesVmrHighRes{cf}, aStrPathDicomFilesForAnonymisation{cf});
        disp(MESSAGE)
    else
        success(cf) = 1;
    end
end

if sum(success) == nFilesVmrHighRes
    fprintf('All %i DICOM files for high-res anatomy of subject %s successfully copied for anonymisation!\n\n', nFilesVmrHighRes, strSubject);
    bAllFilesCopied = true;
else
    nrOfFilesNotCopied = nFilesVmrHighRes - sum(success);
    bAllFilesCopied = false;
    fprintf('Error while copying DICOM files for high-res anatomy of subject %s for anonymisation!\n', strSubject);
    fprintf('%i DICOM files were not copied!\n\n', nrOfFilesNotCopied);
end


end


function [aStrAnonymisedDicomFilesVmrHighRes, aStrPathAnonymisedDicomFilesVmrHighRes] = anonymiseDicomFilesVmrHighResATWM1(folderDefinition, parametersDicomFileAnonymisation, aStrPathDicomFilesForAnonymisation, aStrOriginalDicomFilesVmrHighRes, nFilesVmrHighRes)
%%% Anonymise DICOM files of high-res anatomy

global strSubject

try
    for cf = 1:nFilesVmrHighRes
        %%% Define name for anonymised DICOM file
        strDicomFileAnonymised = strcat(parametersDicomFileAnonymisation.strAnonymised, '_', aStrOriginalDicomFilesVmrHighRes{cf});
        aStrAnonymisedDicomFilesVmrHighRes{cf} = strrep(aStrOriginalDicomFilesVmrHighRes{cf}, aStrOriginalDicomFilesVmrHighRes{cf}, strDicomFileAnonymised);
        aStrPathAnonymisedDicomFilesVmrHighRes{cf} = fullfile(folderDefinition.anonymisedDataArchiveHighResAnatomySubjectAnon, aStrAnonymisedDicomFilesVmrHighRes{cf});
        
        %%% Create anonymised DICOM file and delete original
        dicomanon(aStrPathDicomFilesForAnonymisation{cf}, aStrPathAnonymisedDicomFilesVmrHighRes{cf});
        delete(aStrPathDicomFilesForAnonymisation{cf});
    end
    fprintf('All %i DICOM files for high-res anatomy of subject %s successfully anonymised.\n\n', nFilesVmrHighRes, strSubject);
catch
    fprintf('Error while anonymising DICOM files for high-res anatomy of subject %s!\n', strSubject);
end


end


function [strZipFileAnonymisedHighResAnatomy, strPathLocalZipFileAnonymisedHighResAnatomy, success] = zipAnonymisedDicomFilesATWM1(folderDefinition, parametersStructuralMriSequenceHighRes)

global strSubject

strZipFileAnonymisedHighResAnatomy = sprintf('%s.zip', parametersStructuralMriSequenceHighRes.strSequence);
strPathLocalZipFileAnonymisedHighResAnatomy = fullfile(folderDefinition.anonymisedDataArchiveHighResAnatomySubject, strZipFileAnonymisedHighResAnatomy);

try
    if exist(strPathLocalZipFileAnonymisedHighResAnatomy, 'file')
        delete(strPathLocalZipFileAnonymisedHighResAnatomy);
    end
    zip(strPathLocalZipFileAnonymisedHighResAnatomy, folderDefinition.anonymisedDataArchiveHighResAnatomySubjectAnon);
    success = 1;
    fprintf('Zip file %s containing anonymised DICOM files for high-res anatomy of subject %s successfully created.\n\n', strPathLocalZipFileAnonymisedHighResAnatomy, strSubject);
catch
    success = 0;
    fprintf('Error! Could not create zip file %s containing anonymised DICOM files for subject %s!\n\n', strPathLocalZipFileAnonymisedHighResAnatomy, strSubject);
end

if success
    %%% Delete anonymised DICOM files
    try
        rmdir(folderDefinition.anonymisedDataArchiveHighResAnatomySubjectAnon, 's');
        success = true;
    catch
        success = false;
        fprintf('Error! Could not delete local folder containing anonymised DICOM files for subject %s!\n\n', strSubject);
    end
end


end


function [strPathServerZipFileAnonymisedHighResAnatomy, success] = copyZipFileWithAnonymisedDicomFilesToServerATWM1(folderDefinition, strZipFileAnonymisedHighResAnatomy, strPathLocalZipFileAnonymisedHighResAnatomy)

global strSubject
%folderDefinition = folderDefinition
%try
    %%% Copy zip file to server folder
    %{
    if ~exist(folderDefinition.anonymisedDataArchiveHighResAnatomyGroupServer, 'dir')
        mkdir(folderDefinition.anonymisedDataArchiveHighResAnatomyGroupServer);
    end
    if ~exist(folderDefinition.anonymisedDataArchiveHighResAnatomySubjectServer, 'dir')
        mkdir(folderDefinition.anonymisedDataArchiveHighResAnatomySubjectServer);
    end
    %}
    strPathServerZipFileAnonymisedHighResAnatomy = fullfile(folderDefinition.anonymisedDataArchiveHighResAnatomySubjectServer, strZipFileAnonymisedHighResAnatomy);
    %anonymisedDataArchiveHighResAnatomySubject = anonymisedDataArchiveHighResAnatomySubject
    %anonymisedDataArchiveHighResAnatomySubjectServer = anonymisedDataArchiveHighResAnatomySubjectServer
    
    fprintf('Storing anonymised DICOM files for high-res anatomy of subject %s in zip archive on server!\n\n', strSubject);
    %[success, strCopyMessage] = copyfile(strPathLocalZipFileAnonymisedHighResAnatomy, strPathServerZipFileAnonymisedHighResAnatomy, 'f')
    %test = exist(folderDefinition.anonymisedDataArchiveHighResAnatomySubject, 'file')
    [success, strCopyMessage] = copyfile(folderDefinition.anonymisedDataArchiveHighResAnatomySubject, folderDefinition.anonymisedDataArchiveHighResAnatomySubjectServer, 'f')
    
    %{
    strPathLocalZipFileAnonymisedHighResAnatomy = strPathLocalZipFileAnonymisedHighResAnatomy
    strPathServerZipFileAnonymisedHighResAnatomy = strPathServerZipFileAnonymisedHighResAnatomy
    
    test = exist(strPathLocalZipFileAnonymisedHighResAnatomy, 'file')
    %[{/a|/b}] 
    strCommand = sprintf('copy [/y] %s %s', strPathLocalZipFileAnonymisedHighResAnatomy, strPathServerZipFileAnonymisedHighResAnatomy);
    [status, cmdout] = system(strCommand)
    %}
    if success
        fprintf('Anonymised DICOM files for high-res anatomy of subject %s successfully stored in zip archive on server!\n\n', strSubject);
    else
        disp(strCopyMessage);
        fprintf('\n\n');
    end
    %{
catch
    success = false;
    strPathServerZipFileAnonymisedHighResAnatomy = '';
end
%}
if ~success
    fprintf('Error while storing anonymised DICOM files for high-res anatomy of subject %s in zip archive on server!\nFile could not be created!\n\n', strSubject);
end

end