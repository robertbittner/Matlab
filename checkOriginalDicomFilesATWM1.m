function [parametersMriSession, aStrOriginalDicomFiles, aStrPathOriginalDicomFiles, aStrPathMissingDicomFiles, bDicomFilesComplete] = checkOriginalDicomFilesATWM1(parametersMriSession, strPathOriginalDicomFiles)

global iStudy
global strSubject

parametersDicomFiles = eval(['parametersDicomFiles' iStudy]);

%{
%%% Define unrenamed DICOM files
parametersMriSession.nDicomFiles = 0;
for cr = 1:parametersMriSession.nTotalRuns
    parametersMriSession.vStartIndexDicomFileRun(cr) = parametersMriSession.nDicomFiles + 1;
    for cf = 1:parametersMriSession.nMeasurementsInRun(cr)
        parametersMriSession.nDicomFiles = parametersMriSession.nDicomFiles + 1;
        %%% DICOM naming scheme:    0001_MR000001.dcm
        aStrOriginalDicomFiles{parametersMriSession.nDicomFiles} = sprintf('%04i_MR%06i%s', cr, parametersMriSession.nDicomFiles, parametersDicomFiles.extDicomFile);
        aStrPathOriginalDicomFiles{parametersMriSession.nDicomFiles} = fullfile(strPathOriginalDicomFiles, aStrOriginalDicomFiles{parametersMriSession.nDicomFiles});
    end
end
parametersMriSession.nrOfUnrenamedDicomFiles = parametersMriSession.nDicomFiles;
%}
[parametersMriSession, aStrOriginalDicomFiles, aStrPathOriginalDicomFiles] = defineUnrenamedDicomFileNamesATWM1(parametersMriSession, parametersDicomFiles, strPathOriginalDicomFiles);

%%% Test, whether unrenamed DICOM files are complete
nrOfMissingDicomFiles = 0;
bDicomFilesComplete = true;
for cf = 1:parametersMriSession.nrOfUnrenamedDicomFiles
    if ~exist(aStrPathOriginalDicomFiles{cf}, 'file')
        fprintf('File %s not found\n', aStrPathOriginalDicomFiles{cf});
        bDicomFilesComplete = false;
        nrOfMissingDicomFiles = nrOfMissingDicomFiles + 1;
        aStrPathMissingDicomFiles{nrOfMissingDicomFiles} = aStrPathOriginalDicomFiles{cf};
    end
end

if ~bDicomFilesComplete && parametersMriSession.bDeviatingDicomFileNamesPossible
    [aStrPathOriginalDicomFiles, bDicomFilesComplete] = determineDeviatingDicomFileNamesATWM1(parametersDicomFiles,parametersMriSession, strPathOriginalDicomFiles, bDicomFilesComplete);
end

if bDicomFilesComplete
    aStrPathMissingDicomFiles = {};
else
    fprintf('%i DICOM files missing for subject %s.\n', nrOfMissingDicomFiles, strSubject);
end

end

