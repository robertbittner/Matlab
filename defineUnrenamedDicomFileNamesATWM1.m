function [parametersMriSession, aStrOriginalDicomFiles, aStrPathOriginalDicomFiles] = defineUnrenamedDicomFileNamesATWM1(parametersMriSession, parametersDicomFiles, strFolderOriginalDicomFiles)
%%% Define names and path of unrenamed DICOM files

parametersMriSession.nDicomFiles = 0;
for cr = 1:parametersMriSession.nTotalRuns
    parametersMriSession.vStartIndexDicomFileRun(cr) = parametersMriSession.nDicomFiles + 1;
    for cf = 1:parametersMriSession.nMeasurementsInRun(cr)
        parametersMriSession.nDicomFiles = parametersMriSession.nDicomFiles + 1;
        %%% DICOM naming scheme:    0001_MR000001.dcm
        aStrOriginalDicomFiles{parametersMriSession.nDicomFiles} = sprintf('%04i_MR%06i%s', cr, parametersMriSession.nDicomFiles, parametersDicomFiles.extDicomFile);
        aStrPathOriginalDicomFiles{parametersMriSession.nDicomFiles} = fullfile(strFolderOriginalDicomFiles, aStrOriginalDicomFiles{parametersMriSession.nDicomFiles});
    end
end
parametersMriSession.nrOfUnrenamedDicomFiles = parametersMriSession.nDicomFiles;


end