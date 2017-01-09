function [aStrPathSourceFiles, strPathFirstSourceFile, bDicomFilesComplete] = determineDicomFilesForProjectATWM1(folderDefinition, strProjectType, iDicomFileRun, nrOfDicomFilesForProject)

global iStudy
global strSubject

%%% Check, whether all DICOM files required for the current project exist
bDicomFilesComplete = true;
hFunction = str2func(strcat('determineDicomFileName', iStudy));
for iDicomFileScan = 1:nrOfDicomFilesForProject
    aStrSourceFiles{iDicomFileScan} = feval(hFunction, strSubject, strProjectType, iDicomFileRun, iDicomFileScan);
    aStrPathSourceFiles{iDicomFileScan} = fullfile(folderDefinition.strDicomFilesSubFolderCurrentSession, aStrSourceFiles{iDicomFileScan});
    if ~exist(aStrPathSourceFiles{iDicomFileScan}, 'file')
        %%% Display name of missing DICOM file
        fprintf('%s could not be found!\n', aStrPathSourceFiles{iDicomFileScan});
        bDicomFilesComplete = false;
    end
end
%%% Display warning in case of missing DICOM files
if bDicomFilesComplete == false
    strPathFirstSourceFile = [];
    fprintf('\nOne or more DICOM files could not be found!\nAborting project creation by function %s.\n\n', mfilename);
    return
else
    %%% Determine the name of the first DICOM file of the project
    strPathFirstSourceFile = aStrPathSourceFiles{1};
end


end