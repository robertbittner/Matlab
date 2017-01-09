function [aStrPathOriginalDicomFiles, bDicomFilesComplete] = determineDeviatingDicomFileNamesATWM1(parametersDicomFiles, parametersMriSession, strPathOriginalDicomFiles, bDicomFilesComplete)
%%% Alternative method to determine DICOM file names 

global strSubject

aStrFiles = dir(strPathOriginalDicomFiles);
aStrFiles = aStrFiles(3:end);
nrOfDetectedDicomFiles = 0;
for cf = 1:numel(aStrFiles)
    if ~isempty(strfind(aStrFiles(cf).name, parametersDicomFiles.extDicomFile))
        nrOfDetectedDicomFiles = nrOfDetectedDicomFiles + 1;
        aStrPathOriginalDicomFiles{nrOfDetectedDicomFiles} = fullfile(aStrFiles(cf).folder, aStrFiles(cf).name);
    end
end
%parametersMriSession = parametersMriSession
if nrOfDetectedDicomFiles == parametersMriSession.nDicomFiles
    bDicomFilesComplete = 1;
    fprintf('\nComplete dataset with deviating file names detected for subject %s\n', strSubject);
end


end