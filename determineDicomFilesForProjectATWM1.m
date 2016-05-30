function [aStrPathSourceFile, strPathFirstSourceFile, bAbortFunction] = determineDicomFilesForProjectATWM1(folderDefinition, parametersMriScan, strProjectType, iDicomFileRun, nDicomFilesForProject);
global iStudy
global iSubject

%%% Check, whether all DICOM files required for the current project exist
bAbortFunction = false;
hFunction = str2func(strcat('determineDicomFileName', iStudy));
for iDicomFileScan = 1:nDicomFilesForProject
    aStrSourceFile{iDicomFileScan} = feval(hFunction, iSubject, strProjectType, iDicomFileRun, iDicomFileScan);
    
    %{
    %%% REMOVE!!!
    aStrSourceFile{iDicomFileScan} = strrep(aStrSourceFile{iDicomFileScan}, iSubject, [iSubject, '_ATWM']); % PAT01_ATWM
    strMessage = sprintf('Remove tranformation of DICOM file name from function %s', mfilename)
    %}
    
    aStrPathSourceFile{iDicomFileScan} = strcat(folderDefinition.strProjectDataSubFolder, aStrSourceFile{iDicomFileScan});
    if ~exist(aStrPathSourceFile{iDicomFileScan}, 'file')
        strMessage = sprintf('%s could not be found!', aStrPathSourceFile{iDicomFileScan});
        disp(strMessage);
        bAbortFunction = true;
    end
end
if bAbortFunction == true
    strPathFirstSourceFile = [];
    strMessage = sprintf('\nOne or more DICOM files could not be found!\nAborting project creation by function %s.\n', mfilename);
    disp(strMessage);
    return
else
    %%% Determine the name of the first DICOM file of the project
    strPathFirstSourceFile = aStrPathSourceFile{1};
end


end