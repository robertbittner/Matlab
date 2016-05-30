function dicomFileName = determineDicomFileNameATWM1(iSubject, strProjectType, iDicomFileRun, iDicomFileScan);
%%% © 2015 Robert Bittner
%%% This function determines the exact name of a DICOM file after the use
%%% of the rename DICOM file function in BrainVoyager.

%strProjectType = 'FMR';
%strProjectType = 'VMR';

if strcmp(strProjectType, 'vmr')
    dicomFileName = sprintf('%s-%04i-0001-%05i.dcm', iSubject, iDicomFileRun, iDicomFileScan);
elseif strcmp(strProjectType, 'fmr')
    dicomFileName = sprintf('%s-%04i-%04i-%05i.dcm', iSubject, iDicomFileRun, iDicomFileScan, iDicomFileScan);
end

end

