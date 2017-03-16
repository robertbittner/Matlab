function [bTransferSuccessful] = copyAnonymizedHighResAnatomyToServerATWM1(folderDefinition, parametersMriSession, parametersStructuralMriSequenceHighRes, aStrPathOriginalDicomFiles, aStrOriginalDicomFiles)

global strGroup
global strSubject

[folderDefinition] = defineArchiveFolderForAnonymizedDataATWM1(folderDefinition, parametersStructuralMriSequenceHighRes);

%%% Detect high-res anatomy
fileIndexVmrHighRes = parametersMriSession.fileIndexVmrHighRes;
nFilesVmrHighRes    = parametersMriSession.nMeasurementsInRun(fileIndexVmrHighRes);
indexStart  = parametersMriSession.vStartIndexDicomFileRune(fileIndexVmrHighRes);
indexEnd    = indexStart + nFilesVmrHighRes;
aStrPathOriginalDicomFilesVmrHighRes    = aStrPathOriginalDicomFiles(indexStart : indexEnd - 1);
aStrOriginalDicomFilesVmrHighRes        = aStrOriginalDicomFiles(indexStart : indexEnd - 1);

%%% Copy DICOM files of high-res anatomy in separate folder
%folderHighResAnatomy = strcat('X:\ATWM1\Archive_DICOM_Files\', 'High_Res_', parametersStructuralMriSequenceHighRes.strSequence, '\');
folderHighResAnatomyGroupServer = strcat(folderDefinition.anonymizedDataArchiveHighResAnatomyServer, strGroup, '\');
folderHighResAnatomySubject = strcat(folderHighResAnatomyGroupServer, strSubject, '_', parametersStructuralMriSequenceHighRes.strSequence, '\');
if ~exist(folderHighResAnatomySubject, 'dir')
    mkdir(folderHighResAnatomySubject);
end

for cf = 1:nFilesVmrHighRes
    strServerPathHighResAnatomy = fullfile(folderHighResAnatomySubject, aStrOriginalDicomFilesVmrHighRes{cf});
    strPathOriginalDicomFilesVmrHighRes = aStrPathOriginalDicomFilesVmrHighRes{cf};
    success(cf) = copyfile(strPathOriginalDicomFilesVmrHighRes, strServerPathHighResAnatomy);
end

error('Add anonymization of DICOM files to function %s here!');

if sum(success) == nFilesVmrHighRes
	fprintf('All %i DICOM files for high-res anatomy of subject %s successfully anonymised and copied to server!\n', nFilesVmrHighRes, strSubject);
    bTransferSuccessful = true;
else
    nrOfFilesNotCopied = nFilesVmrHighRes - sum(success);
    fprintf('Error while anonymising and copying DICOM files for high-res anatomy of subject %s to server!\n', strSubject);
    fprintf('%i DICOM files were not copied!\n', nrOfFilesNotCopied);
    bTransferSuccessful = false;
end


end